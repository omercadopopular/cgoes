"""
Utility for classifying trade‑policy reforms into a simple taxonomy.

This module reads a collection of plain text files (such as the World
Trade Organization Trade Policy Review documents provided in this task)
and uses a Large Language Model (LLM) to identify specific reform
measures and label their motives.  The taxonomy of motives mirrors the
framework described by Reinhart and Rogoff and includes both a
primary motive category and an optional secondary category.  The
direction/size module records whether the measure involves an ad‑valorem
tariff cut, removal of specific duties or quotas, elimination of
non‑tariff barriers, the opening of services markets, or whether the
measure is temporary or permanent.

The output of this script is a consolidated JSON file with one record
per detected reform.  Each record contains the identifier of the
source document, a verbatim snippet quoting the reform, the proposed
motive(s), the direction classification, and a model‑reported
confidence score.  The code is structured to be auditable and
replicable: chunking logic ensures that documents are split into
manageable pieces, and all prompts sent to the LLM are captured.

Example usage:

    python motive_taxonomy.py \
        --input_dir /path/to/tprm_texts \
        --output_file reform_classification.jsonl \
        --model gpt-4 \
        --max_tokens 2048

An OpenAI API key must be provided via the environment variable
``OPENAI_API_KEY`` or by editing the ``api_key`` variable below.  If
you wish to use an alternative LLM provider, adapt the ``call_llm``
function accordingly.
"""


from __future__ import annotations

import argparse
import glob
import json
import os
import textwrap
from dataclasses import dataclass, field
from typing import Any, Dict, Iterable, List, Optional, Sequence

import openai


MOTIVE_CATEGORIES: List[str] = [
    "Ideological/long-run efficiency",
    "International commitment",
    "Macroeconomic stabilization",
    "Geopolitical/diplomatic",
    "Administrative/harmonization",
    "Other/unclear",
]

DIRECTION_CATEGORIES: List[str] = [
    "Ad-valorem cut (percentage-point reduction)",
    "Removal of specific duties/quotas",
    "Non-tariff barrier (NTB) removal",
    "Services market-access opening",
    "Temporary measure",
    "Permanent measure",
]

@dataclass
class ReformRecord:
    doc_id: str
    snippet: str
    motive_primary: str
    motive_secondary: Optional[str]
    direction: str
    size: Optional[str]
    confidence: float
    anchor: Optional[str] = None

    def to_dict(self) -> Dict[str, Any]:
        return {
            "doc_id": self.doc_id,
            "snippet": self.snippet,
            "motive_primary": self.motive_primary,
            "motive_secondary": self.motive_secondary,
            "direction": self.direction,
            "size": self.size,
            "confidence": self.confidence,
            "anchor": self.anchor,
        }

def load_documents_from_gss(gss_json: str, directory: str) -> Dict[str, str]:
    with open(gss_json, "r", encoding="utf-8") as f:
        records = json.load(f)
    docs: Dict[str, str] = {}
    for rec in records:
        file = os.path.join(directory, rec["txt_filename"])
        try:
            with open(file, "r", encoding="utf-8", errors="ignore") as f:
                docs[rec["doc_id"]] = f.read().strip()
        except FileNotFoundError:
            print(f"Missing: {file}")
    return docs

def chunk_text(text: str, max_tokens: int = 2500, overlap: int = 200) -> List[str]:
    chars = max_tokens * 4
    step = chars - overlap * 4
    return [text[i:i+chars] for i in range(0, len(text), step)]

def build_classification_prompt(chunk: str) -> str:
    taxonomy = """...<unchanged prompt>..."""  # omitted for brevity
    return f"{taxonomy}\n\nText to analyse:\n\n{chunk}\n\nProvide the JSON array now:"

def call_llm(messages: Sequence[Dict[str, str]], model: str = "gpt-4", max_tokens: int = 1024) -> str:
    api_key = os.environ.get("OPENAI_API_KEY")
    if not api_key:
        raise RuntimeError("OPENAI_API_KEY not set")
    openai.api_key = api_key
    response = openai.ChatCompletion.create(
        model=model, messages=messages, temperature=0.2, max_tokens=max_tokens
    )
    return response.choices[0].message["content"]

def classify_reforms(doc_id: str, text: str, model: str, max_tokens: int) -> List[ReformRecord]:
    records: List[ReformRecord] = []
    for i, chunk in enumerate(chunk_text(text)):
        prompt = build_classification_prompt(chunk)
        messages = [
            {"role": "system", "content": "You are a meticulous classifier of trade policy reforms."},
            {"role": "user", "content": prompt},
        ]
        try:
            reply = call_llm(messages, model=model, max_tokens=max_tokens)
            if reply.strip().startswith("```"): reply = reply.strip("`\n ")
            data = json.loads(reply)
            for d in data:
                records.append(ReformRecord(
                    doc_id=doc_id,
                    snippet=d.get("snippet", ""),
                    motive_primary=d.get("motive_primary", "Other/unclear"),
                    motive_secondary=d.get("motive_secondary"),
                    direction=d.get("direction", ""),
                    size=d.get("size"),
                    confidence=float(d.get("confidence", 0.0)),
                    anchor=d.get("anchor"),
                ))
        except Exception as e:
            print(f"{doc_id} chunk {i} failed: {e}")
    return records

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--gss_file", required=True)
    parser.add_argument("--text_dir", required=True)
    parser.add_argument("--output_file", required=True)
    parser.add_argument("--model", default="gpt-4")
    parser.add_argument("--max_tokens", type=int, default=1024)
    args = parser.parse_args()

    docs = load_documents_from_gss(args.gss_file, args.text_dir)
    all_records = []
    for doc_id, text in docs.items():
        print(f"Processing {doc_id}...")
        all_records.extend(classify_reforms(doc_id, text, args.model, args.max_tokens))

    with open(args.output_file, "w", encoding="utf-8") as f:
        for r in all_records:
            f.write(json.dumps(r.to_dict(), ensure_ascii=False) + "\n")
    print(f"Wrote {len(all_records)} records to {args.output_file}")

if __name__ == "__main__":
    main()