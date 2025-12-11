"""
Step 2(b) of the LLM‑assisted pipeline: classify motives for each
previously extracted reform episode.

This script reads a JSON lines file containing candidate reform
episodes (as produced by ``episode_extraction.py``), then prompts an
LLM to assign motive categories according to the predefined taxonomy.
The classifier sees only the snippet and metadata for each episode to
avoid contamination from surrounding text.  It returns a rationale,
identifies whether the motive appears exogenous (e.g., ideological or
international commitment) or endogenous (e.g., driven by macro
stabilization needs), proposes a second‑best category if warranted,
and reports a confidence score.

Example usage::

    python episode_motive_classification.py \
        --input_episodes episodes.jsonl \
        --output_file episode_motives.jsonl \
        --model gpt-4 \
        --max_tokens 1024

An OpenAI API key must be available via ``OPENAI_API_KEY``.
"""

from __future__ import annotations

import argparse
import json
import os
import textwrap
from typing import Dict, List, Optional

import openai


TAXONOMY_LIST = [
    "Ideological/long-run efficiency",
    "International commitment",
    "Macroeconomic stabilization",
    "Geopolitical/diplomatic",
    "Administrative/harmonization",
    "Other/unclear",
]


def build_motive_prompt(episode: Dict[str, any]) -> str:
    """Construct the classification prompt for a single episode.

    The prompt reminds the model of the available motive categories and
    requests a primary classification, optional secondary classification,
    exogeneity assessment, rationale, and second‑best category.

    Parameters
    ----------
    episode : Dict[str, any]
        A dictionary representing a reform episode with at least the
        fields ``episode_id``, ``doc_id``, ``quote``, and
        ``proposed_label``.

    Returns
    -------
    str
        The user prompt.
    """
    taxonomy_text = "\n".join(f"- {cat}" for cat in TAXONOMY_LIST)
    instructions = textwrap.dedent(
        """
        You are classifying a trade policy reform episode according to a
        predefined taxonomy.  Based solely on the provided snippet and
        metadata, assign the motive(s) that best describe the underlying
        rationale for the reform.  The available motive categories are:
        {taxonomy}

        In addition, indicate whether the motive appears **exogenous**
        (motivated by ideology, long-run efficiency, or international
        commitments) or **endogenous** (motivated by macroeconomic
        stabilization, fiscal needs, or domestic political pressures).

        Output a JSON object with the following keys:
        ``episode_id`` (copied from the input),
        ``motive_primary``,
        ``motive_secondary`` (null if none),
        ``exogenous_or_endogenous`` ("exogenous" or "endogenous"),
        ``rationale`` (1-2 sentences explaining your choice),
        ``second_best_class`` (the alternative motive category you
         considered and why, or null if none), and
        ``confidence`` (a number from 0 to 1 reflecting your subjective
        confidence in the classification).

        Do not mention the instructions in your answer.  Do not output
        any extraneous keys.
        """
    ).format(taxonomy=taxonomy_text).strip()
    quote = episode.get("quote", "").strip()
    proposed_label = episode.get("proposed_label", "")
    doc_id = episode.get("doc_id", "")
    ep_id = episode.get("episode_id", "")
    prompt = (
        f"{instructions}\n\n"
        f"Episode ID: {ep_id}\n"
        f"Document ID: {doc_id}\n"
        f"Proposed label: {proposed_label}\n"
        f"Quote:\n{quote}\n\n"
        "Return the JSON object now:"
    )
    return prompt


def call_llm(messages: List[Dict[str, str]], model: str = "gpt-4", max_tokens: int = 512) -> str:
    """Invoke the OpenAI ChatCompletion API.

    Parameters
    ----------
    messages : List[Dict[str, str]]
        The conversation messages.
    model : str
        LLM model name.
    max_tokens : int
        Response token limit.

    Returns
    -------
    str
        The assistant's reply content.
    """
    api_key = os.environ.get("OPENAI_API_KEY")
    if not api_key:
        raise RuntimeError("OPENAI_API_KEY is not set.")
    openai.api_key = api_key
    response = openai.ChatCompletion.create(
        model=model,
        messages=messages,
        temperature=0.2,
        max_tokens=max_tokens,
    )
    return response.choices[0].message["content"]


def classify_episodes(episodes: List[Dict[str, any]], model: str, max_tokens: int) -> List[Dict[str, any]]:
    """Classify motives for a list of reform episodes.

    Parameters
    ----------
    episodes : List[Dict[str, any]]
        Episodes to classify.
    model : str
        LLM model name.
    max_tokens : int
        Response token limit per call.

    Returns
    -------
    List[Dict[str, any]]
        List of classification results.
    """
    results: List[Dict[str, any]] = []
    for index, ep in enumerate(episodes):
        user_prompt = build_motive_prompt(ep)
        messages = [
            {"role": "system", "content": "You are a careful classifier of policy motives."},
            {"role": "user", "content": user_prompt},
        ]
        try:
            response_text = call_llm(messages, model=model, max_tokens=max_tokens)
        except Exception as e:
            print(f"LLM error on episode {ep.get('episode_id')}: {e}")
            continue
        cleaned = response_text.strip()
        if cleaned.startswith("```"):
            cleaned = cleaned.strip("` ")
        try:
            obj = json.loads(cleaned)
        except json.JSONDecodeError:
            print(f"Failed to parse JSON for episode {ep.get('episode_id')}: {response_text}")
            continue
        # Ensure required keys are present
        for key in ["episode_id", "motive_primary", "exogenous_or_endogenous", "rationale", "confidence"]:
            if key not in obj:
                print(f"Missing key '{key}' in LLM output for episode {ep.get('episode_id')}")
        results.append(obj)
    return results


def load_episodes(path: str) -> List[Dict[str, any]]:
    """Read episodes from a JSON lines file."""
    episodes: List[Dict[str, any]] = []
    with open(path, "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            episodes.append(json.loads(line))
    return episodes


def main() -> None:
    parser = argparse.ArgumentParser(description="Classify motives for reform episodes.")
    parser.add_argument("--input_episodes", required=True, help="Path to the episodes JSON lines file.")
    parser.add_argument("--output_file", required=True, help="Path for the motive classifications JSON lines.")
    parser.add_argument("--model", default="gpt-4", help="OpenAI model to use (default: gpt-4).")
    parser.add_argument("--max_tokens", type=int, default=512, help="Max tokens per response (default: 512).")
    args = parser.parse_args()

    episodes = load_episodes(args.input_episodes)
    print(f"Loaded {len(episodes)} episodes for classification")
    classifications = classify_episodes(episodes, model=args.model, max_tokens=args.max_tokens)
    with open(args.output_file, "w", encoding="utf-8") as f:
        for obj in classifications:
            f.write(json.dumps(obj, ensure_ascii=False) + "\n")
    print(f"Wrote {len(classifications)} classification records to {args.output_file}")


if __name__ == "__main__":
    main()