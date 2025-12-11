"""
Step 2(a) of the LLM‑assisted pipeline: page‑level episode discovery.

This script scans a set of trade policy documents and uses an LLM to
extract candidate "reform episodes".  Each episode should consist of a
verbatim quote describing a specific policy measure along with
structured metadata: the date or reference (if available), a concise
description of the measure, the stated reason or justification, the
affected instruments and sectors, and a proposed provisional label.

The LLM is instructed to return results in a strict JSON schema with
keys ``episode_id``, ``doc_id``, ``quote``, ``reason_text``,
``proposed_label``, and ``confidence``.  Page or paragraph anchors
should be included in ``episode_id`` to facilitate auditability.

Example usage::

    python episode_extraction.py \
        --input_dir /path/to/tprm_texts \
        --output_file episodes.jsonl \
        --model gpt-4 \
        --max_tokens 2048

An OpenAI API key must be provided via the ``OPENAI_API_KEY``
environment variable.
"""

from __future__ import annotations

import argparse
import glob
import json
import os
import textwrap
from typing import Dict, Iterable, List, Optional, Any

import openai

from motive_taxonomy import chunk_text  # Reuse chunking logic from the taxonomy module


def load_documents(directory: str) -> Dict[str, str]:
    """Load text files from a directory into a dictionary.

    Parameters
    ----------
    directory : str
        Directory containing .txt files.

    Returns
    -------
    Dict[str, str]
        Mapping from file basename (without extension) to file contents.
    """
    docs: Dict[str, str] = {}
    pattern = os.path.join(directory, "*.txt")
    for path in sorted(glob.glob(pattern)):
        with open(path, "r", encoding="utf-8", errors="ignore") as f:
            docs[os.path.splitext(os.path.basename(path))[0]] = f.read().strip()
    return docs


def build_episode_prompt(chunk: str) -> str:
    """Construct a detailed prompt instructing the LLM to extract episodes.

    Parameters
    ----------
    chunk : str
        The text segment to analyse.

    Returns
    -------
    str
        The user prompt for the LLM.
    """
    instructions = textwrap.dedent(
        """
        You are analysing a government trade‑policy review document.  Your
        job is to discover discrete "reform episodes" within the
        following text.  Each episode should correspond to a specific
        policy action or announcement (such as a tariff cut, removal of a
        quota, elimination of an import licence, introduction of a new
        subsidy, opening of a services market, etc.).

        For each episode you find, produce a JSON object with the
        following keys:

        - ``episode_id``: a unique identifier combining the document ID and
          the approximate location of the episode, such as
          "DOCID_p3_par12" for page 3, paragraph 12.  If no page or
          paragraph number is available, invent a simple numeric
          identifier (e.g., "DOCID_001").
        - ``doc_id``: the identifier of the document from which the text
          is drawn.
        - ``quote``: a verbatim quote from the text capturing the
          essential details of the policy measure.  Preserve line breaks
          and punctuation from the source where possible.
        - ``reason_text``: the stated reason or justification for the
          measure.  Use the document's own language; if no explicit
          justification is provided, write ``null``.
        - ``proposed_label``: a provisional, high‑level tag for the
          measure (e.g., "tariff liberalization", "import licensing
          removal", "subsidy phase‑out", etc.).  This is just a guess
          before formal classification.
        - ``confidence``: a floating‑point value between 0 and 1
          reflecting your confidence that the extracted quote indeed
          describes a reform episode.

        Return *only* a JSON array of objects matching the above
        schema.  If no reform episodes appear in the text, return an
        empty JSON array ``[]``.
        """
    ).strip()
    return f"{instructions}\n\nText:\n\n{chunk}\n\nJSON array:"


def call_llm(messages: List[Dict[str, str]], model: str = "gpt-4", max_tokens: int = 1024) -> str:
    """Send a chat completion request to the OpenAI API.

    Parameters
    ----------
    messages : List[Dict[str, str]]
        Conversation history for the LLM.  The last message should
        contain the user prompt.
    model : str, optional
        The model to use, by default ``gpt-4``.
    max_tokens : int, optional
        Maximum response tokens, by default 1024.

    Returns
    -------
    str
        The assistant's response as a string.
    """
    api_key = os.environ.get("OPENAI_API_KEY")
    if not api_key:
        raise RuntimeError("OPENAI_API_KEY is not set.  Please provide your OpenAI API key.")
    openai.api_key = api_key
    response = openai.ChatCompletion.create(
        model=model,
        messages=messages,
        temperature=0.2,
        max_tokens=max_tokens,
    )
    return response.choices[0].message["content"]


def extract_episodes_for_doc(doc_id: str, text: str, model: str, max_tokens: int) -> List[Dict[str, Any]]:
    """Process a single document and extract reform episodes.

    Parameters
    ----------
    doc_id : str
        Identifier of the document.
    text : str
        Document text.
    model : str
        Model name.
    max_tokens : int
        Maximum tokens per API call.

    Returns
    -------
    List[Dict[str, Any]]
        List of episode objects conforming to the required schema.
    """
    episodes: List[Dict[str, Any]] = []
    chunks = chunk_text(text)
    for chunk_index, chunk in enumerate(chunks):
        user_prompt = build_episode_prompt(chunk)
        messages = [
            {"role": "system", "content": "You are an assistant that extracts structured policy reforms."},
            {"role": "user", "content": user_prompt},
        ]
        try:
            response_text = call_llm(messages, model=model, max_tokens=max_tokens)
        except Exception as e:
            print(f"LLM error for {doc_id} chunk {chunk_index}: {e}")
            continue
        cleaned = response_text.strip()
        if cleaned.startswith("```"):
            cleaned = cleaned.strip("` ")
        try:
            data = json.loads(cleaned)
        except json.JSONDecodeError:
            print(f"Failed to parse JSON for {doc_id} chunk {chunk_index}: {response_text}")
            continue
        if not isinstance(data, list):
            print(f"Unexpected format (not a list) for {doc_id} chunk {chunk_index}: {data}")
            continue
        for obj in data:
            # Attach document ID if missing
            obj.setdefault("doc_id", doc_id)
            episodes.append(obj)
    return episodes


def main() -> None:
    parser = argparse.ArgumentParser(description="Extract reform episodes from trade policy documents.")
    parser.add_argument("--input_dir", required=True, help="Directory with input .txt files.")
    parser.add_argument("--output_file", required=True, help="Path for the JSON lines output.")
    parser.add_argument("--model", default="gpt-4", help="OpenAI model to use (default: gpt-4).")
    parser.add_argument("--max_tokens", type=int, default=1024, help="Max tokens per response (default: 1024).")
    args = parser.parse_args()

    docs = load_documents(args.input_dir)
    all_episodes: List[Dict[str, Any]] = []
    for doc_id, text in docs.items():
        print(f"Extracting episodes for {doc_id}...")
        episodes = extract_episodes_for_doc(doc_id, text, model=args.model, max_tokens=args.max_tokens)
        all_episodes.extend(episodes)

    with open(args.output_file, "w", encoding="utf-8") as f:
        for episode in all_episodes:
            f.write(json.dumps(episode, ensure_ascii=False) + "\n")
    print(f"Wrote {len(all_episodes)} episodes to {args.output_file}")


if __name__ == "__main__":
    main()