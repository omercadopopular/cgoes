# -*- coding: utf-8 -*-
"""
Run GATT and WTO TPR extraction scripts, then merge their manifests
into a single global manifest.

This version prints all output from sub-scripts LIVE in the Spyder console.
"""

import json
import subprocess
from pathlib import Path


# === PATHS ===
base_dir = Path(__file__).resolve().parent.parent.parent
code_dir = base_dir / "scr/extracting"
data_dir = base_dir / "data"
links_dir = data_dir / "wto-links"

gatt_script = code_dir / "gatt-extract-files.py"
wto_script = code_dir / "wto-extract-files.py"

gatt_manifest = links_dir / "gatt_tpr_manifest.json"
wto_manifest = links_dir / "wto_tpr_manifest.json"
global_manifest = links_dir / "global_tpr_manifest.json"


def run_script(script_path: Path, label: str) -> bool:
    """
    Run a Python script as a subprocess, printing all output LIVE.
    This works in Spyder because we do NOT redirect stdout/stderr.
    """
    print(f"▶ Running {label}: {script_path}")

    result = subprocess.run(
        ["python", str(script_path)],
        text=True     # ensures consistent behavior
        # no capture_output, no stdout=..., no stderr=...
    )

    if result.returncode != 0:
        print(f"❌ {label} FAILED (exit code {result.returncode})\n")
        return False

    print(f"✔ Finished {label} successfully\n")
    return True


def load_json_list(path: Path):
    if not path.exists():
        print(f"⚠ Manifest not found (skipping): {path}")
        return []
    with path.open("r", encoding="utf-8") as f:
        return json.load(f)


def harmonize_entry(entry: dict) -> dict:
    e = dict(entry)
    e.setdefault("source", None)
    e.setdefault("iso3", None)
    e.setdefault("year", None)
    e.setdefault("pdf_index", 0)

    if "symbol" in e:
        e.setdefault("doc_id", e["symbol"])
    elif "tp_id" in e:
        e.setdefault("doc_id", e["tp_id"])
    else:
        e.setdefault("doc_id", "")

    return e


def sort_key(entry: dict):
    iso3 = entry.get("iso3") or ""
    year = entry.get("year")
    year_sort = year if isinstance(year, int) else 9999
    source = entry.get("source") or ""
    doc_id = entry.get("doc_id") or ""
    pdf_index = entry.get("pdf_index") or 0
    return (iso3, year_sort, source, doc_id, pdf_index)


def main():
    # Run the two extractors and stream output
    gatt_ok = run_script(gatt_script, "GATT extractor")
    wto_ok = run_script(wto_script, "WTO extractor")

    if not gatt_ok:
        print("⚠ GATT extractor failed. See output above.")
    if not wto_ok:
        print("⚠ WTO extractor failed. See output above.")

    # Load manifests
    gatt_entries = load_json_list(gatt_manifest)
    wto_entries = load_json_list(wto_manifest)

    print(f"GATT manifest entries: {len(gatt_entries)}")
    print(f"WTO manifest entries:  {len(wto_entries)}")

    # Merge
    combined = gatt_entries + wto_entries
    harmonized = [harmonize_entry(e) for e in combined]
    sorted_entries = sorted(harmonized, key=sort_key)

    # Save global manifest
    global_manifest.parent.mkdir(parents=True, exist_ok=True)
    with global_manifest.open("w", encoding="utf-8") as f:
        json.dump(sorted_entries, f, ensure_ascii=False, indent=2)

    print(f"\n🌍 Global manifest written to: {global_manifest}")
    print(f"Total entries: {len(sorted_entries)}")


if __name__ == "__main__":
    main()
