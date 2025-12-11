# -*- coding: utf-8 -*-
"""
Download ALL PDFs linked from each WTO TPR 'TPR Documents' page,
extract text, and save it as .txt files.

Also builds a per-PDF manifest with metadata and local file paths.

----------------------------------------------------------------------
INPUT
----------------------------------------------------------------------
JSON file:
    ROOT/data/wto-links/wto_tpr_document_source.json

Structure (example element):
    {
      "country": "Albania",
      "dates": "22 and 24 November 2023",
      "tpr_documents_url": "https://www.wto.org/english/tratop_e/tpr_e/tp549_e.htm"
    }

----------------------------------------------------------------------
OUTPUT TEXT FILES
----------------------------------------------------------------------
Directory:
    ROOT/data/output_pdfs_text/

For each PDF linked from a TPR page, the script creates a filename:

    wto_<tp_id>_<pdf_stem>_<country>_<index>.txt

where:
    - tp_id     : stem of the TPR page URL, e.g. "tp549_e"
    - pdf_stem  : stem of the PDF link, e.g. "WT_TPR_S_549"
    - country   : filesystem-safe country name, e.g. "Albania"
    - index     : 1, 2, 3, ... for multiple PDFs on same TPR page

Example:
    wto_tp549_e_WT_TPR_S_549_Albania_1.txt

----------------------------------------------------------------------
OUTPUT MANIFEST
----------------------------------------------------------------------
Manifest file (JSON array):
    ROOT/data/wto-links/wto_tpr_manifest.json

Each entry (one per PDF) contains at least:
    {
      "source": "WTO_TPR",
      "country": "Albania",
      "iso3": "ALB",
      "dates": "22 and 24 November 2023",
      "year": 2023,
      "tpr_documents_url": "...",
      "tp_id": "tp549_e",
      "pdf_url": "...",
      "pdf_stem": "WT_TPR_S_549",
      "pdf_index": 1,
      "txt_path": "data/output_pdfs_text/...",
      "txt_filename": "...",
      "status": "downloaded" | "exists" | "error_download" | "error_parse" | "error_write",
      "filename_fallback": true/false
      "error_msg": ""
    }
"""

import json
import re
import hashlib
from io import BytesIO
from pathlib import Path
from urllib.parse import urljoin

import requests
from bs4 import BeautifulSoup
from PyPDF2 import PdfReader
from docx import Document   # pip install python-docx
import pycountry            # pip install pycountry


BASE_URL = "https://www.wto.org"

# === PATHS ===
base_dir = Path(__file__).resolve().parent.parent.parent
data_dir = base_dir / "data"

input_json = data_dir / "wto-links" / "wto_tpr_document_source.json"
output_dir = data_dir / "output_pdfs_text"
output_dir.mkdir(parents=True, exist_ok=True)

manifest_path = data_dir / "wto-links" / "wto_tpr_manifest.json"


# === SPECIAL CASE ISO OVERRIDES ===
SPECIAL_COUNTRY_MAP = {
    "Hong Kong, China": "HKG",
    "Macao, China": "MAC",
    "Chinese Taipei": "TWN",
    "European Union": "EUN",
    "European Communities": "EEC",
}


# ============================================================================
# PARSERS FOR DIFFERENT FORMATS
# ============================================================================
def pdf_to_text(content: bytes) -> str:
    reader = PdfReader(BytesIO(content))
    texts = [(p.extract_text() or "") for p in reader.pages]
    return "\n".join(texts)


def docx_to_text(content: bytes) -> str:
    doc = Document(BytesIO(content))
    return "\n".join(p.text for p in doc.paragraphs)


def doc_to_text(content: bytes) -> str:
    """Best-effort extract for legacy .doc files."""
    try:
        return content.decode("latin-1", errors="replace")
    except Exception:
        return "[UNSUPPORTED .DOC FORMAT]"


def txt_to_text(content: bytes) -> str:
    try:
        return content.decode("utf-8", errors="replace")
    except Exception:
        return content.decode("latin-1", errors="replace")


# ============================================================================
# HELPERS
# ============================================================================
def load_tpr_index(path: Path):
    with path.open("r", encoding="utf-8") as f:
        return json.load(f)


def sanitize_country(country: str) -> str:
    return re.sub(r"[^A-Za-z0-9]+", "_", country).strip("_") or "UNKNOWN"


def get_tp_id_from_url(url: str) -> str:
    try:
        return Path(url).stem
    except Exception:
        return "tpr_unknown"


def extract_report_links(html: str):
    """Extract PDF/DOC/DOCX/TXT links from a TPR page."""
    soup = BeautifulSoup(html, "html.parser")
    links = soup.find_all("a", href=True)

    extensions = [".pdf", ".doc", ".docx", ".txt"]

    hrefs = []
    for a in links:
        href = a["href"]
        lower = href.lower()
        if any(lower.endswith(ext) for ext in extensions):
            hrefs.append(href)

    # de-duplicate while preserving order
    seen = set()
    uniq = []
    for h in hrefs:
        if h not in seen:
            uniq.append(h)
            seen.add(h)

    return uniq


def country_to_iso3(country_name: str | None) -> str | None:
    if not country_name:
        return None
    name = country_name.strip()
    if name in SPECIAL_COUNTRY_MAP:
        return SPECIAL_COUNTRY_MAP[name]
    try:
        c = pycountry.countries.lookup(name)
        return c.alpha_3
    except Exception:
        return None


def build_fallback_filename(tp_id, pdf_stem, iso3, j, country):
    """Short filename + hash, always with .txt extension."""
    h = hashlib.sha256(f"{country}|{pdf_stem}|{tp_id}|{j}".encode()).hexdigest()[:8]
    base = f"wto_{tp_id}_{pdf_stem}_{iso3 or 'UNK'}_{j}_{h}"
    safe_base = re.sub(r"[^A-Za-z0-9_]+", "_", base)
    return f"{safe_base}.txt"


# ============================================================================
# MAIN
# ============================================================================
def main():
    entries = load_tpr_index(input_json)
    print(f"Loaded {len(entries)} WTO TPR index entries.")

    session = requests.Session()
    session.headers.update({
        "User-Agent": "Mozilla/5.0 (compatible; WTO-TPR-Scraper/1.0)"
    })

    manifest_entries = []

    for idx, entry in enumerate(entries, start=1):
        country = (entry.get("country") or "").strip()
        dates = (entry.get("dates") or "").strip()
        tpr_url = (entry.get("tpr_documents_url") or "").strip()

        iso3 = country_to_iso3(country)
        print(f"[{idx}/{len(entries)}] {country} ({iso3}) -> {tpr_url}")

        # Fetch page
        try:
            resp = session.get(tpr_url, timeout=60)
            resp.raise_for_status()
        except Exception as e:
            print(f"  Error fetching TPR page: {e}")
            continue

        report_hrefs = extract_report_links(resp.text)
        if not report_hrefs:
            print("  No TPR report files found (.pdf/.doc/.docx/.txt).")
            continue

        tp_id = get_tp_id_from_url(tpr_url)
        country_tag = sanitize_country(country)

        # Extract year from dates
        m = re.search(r"\b(\d{4})\b", dates or "")
        year = int(m.group(1)) if m else None

        # Process each linked file
        for j, href in enumerate(report_hrefs, start=1):
            url = urljoin(BASE_URL, href)
            pdf_stem = Path(href).stem
            ext = href.lower()

            # First attempt: long descriptive filename (keeps compatibility)
            base_name = f"wto_{tp_id}_{pdf_stem}_{country_tag}_{j}"
            safe_base_name = re.sub(r"[^A-Za-z0-9_]+", "_", base_name)
            long_symbol = f"{safe_base_name}.txt"
            txt_path = output_dir / long_symbol
            filename_fallback = False

            # If already exists, do not re-download or re-parse
            if txt_path.exists():
                status = "exists"
                error_msg = ""
            else:
                # Download file
                print(f"    Downloading file {j}/{len(report_hrefs)}: {url}")
                try:
                    r = session.get(url, timeout=90)
                    r.raise_for_status()
                except Exception as e:
                    status = "error_download"
                    error_msg = str(e)
                    print(f"    Error downloading: {e}")
                    manifest_entries.append({
                        "source": "WTO_TPR",
                        "country": country,
                        "iso3": iso3,
                        "dates": dates,
                        "year": year,
                        "tpr_documents_url": tpr_url,
                        "tp_id": tp_id,
                        "pdf_url": url,
                        "pdf_stem": pdf_stem,
                        "pdf_index": j,
                        "txt_path": str(txt_path),
                        "txt_filename": long_symbol,
                        "filename_fallback": filename_fallback,
                        "status": status,
                        "error_msg": error_msg
                    })
                    continue

                # Parse according to file type
                try:
                    if ext.endswith(".pdf"):
                        text = pdf_to_text(r.content)
                    elif ext.endswith(".docx"):
                        text = docx_to_text(r.content)
                    elif ext.endswith(".doc"):
                        text = doc_to_text(r.content)
                    elif ext.endswith(".txt"):
                        text = txt_to_text(r.content)
                    else:
                        raise ValueError(f"Unsupported file extension: {ext}")
                except Exception as e:
                    status = "error_parse"
                    error_msg = str(e)
                    print(f"    Error parsing {ext}: {e}")
                    manifest_entries.append({
                        "source": "WTO_TPR",
                        "country": country,
                        "iso3": iso3,
                        "dates": dates,
                        "year": year,
                        "tpr_documents_url": tpr_url,
                        "tp_id": tp_id,
                        "pdf_url": url,
                        "pdf_stem": pdf_stem,
                        "pdf_index": j,
                        "txt_path": str(txt_path),
                        "txt_filename": long_symbol,
                        "filename_fallback": filename_fallback,
                        "status": status,
                        "error_msg": error_msg
                    })
                    continue

                # Try saving with long filename
                try:
                    with txt_path.open("w", encoding="utf-8") as f:
                        f.write(text)
                    status = "downloaded"
                    error_msg = ""
                    print(f"    Saved to {txt_path}")
                except Exception as e:
                    # Likely Windows path length issue → fallback filename
                    print(f"    Error saving long filename: {e}")
                    filename_fallback = True
                    short_name = build_fallback_filename(tp_id, pdf_stem, iso3, j, country)
                    txt_path = output_dir / short_name

                    try:
                        with txt_path.open("w", encoding="utf-8") as f:
                            f.write(text)
                        status = "downloaded"
                        error_msg = ""
                        print(f"    Fallback saved to {txt_path}")
                    except Exception as e2:
                        status = "error_write"
                        error_msg = str(e2)
                        print(f"    Error saving fallback filename: {e2}")

            # Manifest entry
            manifest_entries.append({
                "source": "WTO_TPR",
                "country": country,
                "iso3": iso3,
                "dates": dates,
                "year": year,
                "tpr_documents_url": tpr_url,
                "tp_id": tp_id,
                "pdf_url": url,
                "pdf_stem": pdf_stem,
                "pdf_index": j,
                "txt_path": str(txt_path),
                "txt_filename": txt_path.name,
                "filename_fallback": filename_fallback,
                "status": status,
                "error_msg": error_msg,
            })

    # Write manifest
    with manifest_path.open("w", encoding="utf-8") as mf:
        json.dump(manifest_entries, mf, ensure_ascii=False, indent=2)

    print(f"\n✔ WTO manifest written to {manifest_path} ({len(manifest_entries)} entries)")


if __name__ == "__main__":
    main()
