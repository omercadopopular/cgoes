# -*- coding: utf-8 -*-
"""
Download WTO GATT / CRM PDFs listed in `gatt_tpr_document_source.json`,
extract full text, and save to UTF-8 `.txt` files.

----------------------------------------------------------------------  
INPUT  
----------------------------------------------------------------------  
JSON file (scraped earlier):
    ROOT/data/wto-links/gatt_tpr_document_source.json

Fields per entry:
    {
      "period": "1986-1990",
      "symbol": "C/RM/G/1",
      "title": "Council - Trade Policy Review Mechanism - Australia",
      "date": "16/11/1989",
      "url": "https://docs.wto.org/gattdocs/q/.\\GG\\CRM\\G1.PDF"
    }

----------------------------------------------------------------------  
OUTPUT  
----------------------------------------------------------------------  
Text files saved to:
    ROOT/data/output_pdfs_text/gatt_<...>.txt

Manifests saved to:
    ROOT/data/wto-links/gatt_tpr_manifest.json

----------------------------------------------------------------------  
RUN  
----------------------------------------------------------------------  
python gatt-extract-files.py
"""

import json
import re
from io import BytesIO
from pathlib import Path

import requests
from PyPDF2 import PdfReader
import pycountry


# ============================================================================
# 0. DIRECTORY SETUP
# ============================================================================
base_dir = Path(__file__).resolve().parent.parent.parent
data_dir = base_dir / "data"

input_json = data_dir / "wto-links" / "gatt_tpr_document_source.json"
output_dir = data_dir / "output_pdfs_text"
output_dir.mkdir(parents=True, exist_ok=True)

manifest_path = data_dir / "wto-links" / "gatt_tpr_manifest.json"


# ============================================================================
# 1. COMPREHENSIVE COUNTRY OVERRIDES FOR GATT (1989–1995 CRM PARTICIPANTS)
# ============================================================================
# These include all WTO Members + historical GATT/CRM titles appearing before 1995.
# All normalized to lowercase for matching.
GATT_TITLE_COUNTRY_OVERRIDES = {
    # OECD-ish economies in CRM rounds
    "australia": ("Australia", "AUS"),
    "austria": ("Austria", "AUT"),
    "belgium": ("Belgium", "BEL"),
    "canada": ("Canada", "CAN"),
    "denmark": ("Denmark", "DNK"),
    "finland": ("Finland", "FIN"),
    "france": ("France", "FRA"),
    "germany": ("Germany", "DEU"),
    "greece": ("Greece", "GRC"),
    "iceland": ("Iceland", "ISL"),
    "ireland": ("Ireland", "IRL"),
    "italy": ("Italy", "ITA"),
    "japan": ("Japan", "JPN"),
    "luxembourg": ("Luxembourg", "LUX"),
    "netherlands": ("Netherlands", "NLD"),
    "new zealand": ("New Zealand", "NZL"),
    "norway": ("Norway", "NOR"),
    "portugal": ("Portugal", "PRT"),
    "spain": ("Spain", "ESP"),
    "sweden": ("Sweden", "SWE"),
    "switzerland": ("Switzerland", "CHE"),
    "united kingdom": ("United Kingdom", "GBR"),
    "united states": ("United States", "USA"),
    "usa": ("United States", "USA"),
    "uk": ("United Kingdom", "GBR"),

    # Asian economies under GATT
    "korea": ("Korea, Republic of", "KOR"),
    "republic of korea": ("Korea, Republic of", "KOR"),
    "south korea": ("Korea, Republic of", "KOR"),
    "hong kong": ("Hong Kong, China", "HKG"),
    "hong kong, china": ("Hong Kong, China", "HKG"),
    "chinese taipei": ("Chinese Taipei", "TWN"),
    "taiwan": ("Chinese Taipei", "TWN"),
    "singapore": ("Singapore", "SGP"),
    "malaysia": ("Malaysia", "MYS"),
    "thailand": ("Thailand", "THA"),

    # Americas
    "argentina": ("Argentina", "ARG"),
    "brazil": ("Brazil", "BRA"),
    "chile": ("Chile", "CHL"),
    "colombia": ("Colombia", "COL"),
    "mexico": ("Mexico", "MEX"),
    "peru": ("Peru", "PER"),
    "uruguay": ("Uruguay", "URY"),
    "venezuela": ("Venezuela", "VEN"),

    # Africa (few GATT CRM appearances)
    "egypt": ("Egypt", "EGY"),
    "morocco": ("Morocco", "MAR"),
    "south africa": ("South Africa", "ZAF"),

    # Middle East
    "israel": ("Israel", "ISR"),
    "turkey": ("Turkey", "TUR"),

    # European Communities (pre-WTO)
    "european communities": ("European Communities", "EEC"),  # custom
    "ec": ("European Communities", "EEC"),
    "eec": ("European Communities", "EEC"),

    # Rare / historic CRM titles
    "czechoslovakia": ("Czechoslovakia", None),
    "czech and slovak federal republic": ("Czech and Slovak Federal Republic", None),
    "yugoslavia": ("Yugoslavia", None),
}


# ============================================================================
# 2. HELPER UTILITIES
# ============================================================================
def sanitize_tag(value: str) -> str:
    """Make a filesystem-safe tag."""
    if value is None:
        return "na"
    tag = re.sub(r"[^A-Za-z0-9]+", "_", value)
    return tag.strip("_") or "na"


def pdf_bytes_to_text(pdf_bytes: bytes) -> str:
    """Extract full text from PDF bytes."""
    reader = PdfReader(BytesIO(pdf_bytes))
    pages = [(page.extract_text() or "") for page in reader.pages]
    return "\n".join(pages)


def parse_year_from_date(date_str: str):
    m = re.search(r"\b(\d{4})\b", date_str or "")
    if m:
        try:
            return int(m.group(1))
        except ValueError:
            return None
    return None


# --------------------------------------------------------------------------
# Robust country parsing for GATT CRM
# --------------------------------------------------------------------------
def parse_country_from_title(title: str):
    """
    Infer country from CRM/GATT titles using 3 passes:
    1. Override dictionary (exact substring match)
    2. Multi-word match against known country patterns
    3. Fallback: last segment after dash ("-")
    """

    if not title:
        return None, None

    t = title.lower().replace("–", "-").replace("—", "-")

    # PASS 1 — direct override match (best)
    for key, (cname, iso3) in GATT_TITLE_COUNTRY_OVERRIDES.items():
        if key in t:
            return cname, iso3

    # PASS 2 — attempt fuzzy match for multi-word countries
    words = t.split()
    max_len = min(4, len(words))
    for n in range(max_len, 0, -1):
        for i in range(len(words) - n + 1):
            seq = " ".join(words[i:i+n])
            if seq in GATT_TITLE_COUNTRY_OVERRIDES:
                cname, iso3 = GATT_TITLE_COUNTRY_OVERRIDES[seq]
                return cname, iso3

    # PASS 3 — fallback: last segment after dash
    parts = [p.strip() for p in t.split("-") if p.strip()]
    if parts:
        candidate = re.sub(r"[()]", "", parts[-1]).strip()
        if candidate:
            # try pycountry fallback
            try:
                c = pycountry.countries.lookup(candidate)
                return c.name, c.alpha_3
            except Exception:
                return candidate, None

    return None, None


# ============================================================================
# 3. MAIN SCRIPT
# ============================================================================
def main():
    with input_json.open("r", encoding="utf-8") as f:
        documents = json.load(f)

    print(f"Loaded {len(documents)} GATT CRM records")

    session = requests.Session()
    session.headers.update({"User-Agent": "Mozilla/5.0 (compatible; CRM-GATT-Scraper/1.0)"})

    manifest_entries = []

    for i, item in enumerate(documents, start=1):
        period = item.get("period", "").strip()
        symbol = item.get("symbol", "").strip()
        title  = item.get("title", "").strip()
        date   = item.get("date", "").strip()
        url    = item.get("url", "").replace("\\", "/")

        # Output filename
        period_tag = sanitize_tag(period)
        date_tag   = sanitize_tag(date)
        symbol_tag = sanitize_tag(symbol)
        base_name  = f"gatt_{period_tag}_{date_tag}_{symbol_tag}"
        txt_path   = output_dir / f"{base_name}.txt"

        # Metadata
        year = parse_year_from_date(date)
        country, iso3 = parse_country_from_title(title)

        status = "exists" if txt_path.exists() else "pending"
        error_msg = ""

        if txt_path.exists():
            print(f"[{i}/{len(documents)}] Skipping (exists) {symbol} -> {txt_path.name}")
        else:
            print(f"[{i}/{len(documents)}] Downloading {symbol} from {url}")

            # Download
            try:
                resp = session.get(url, timeout=60)
                resp.raise_for_status()
            except Exception as e:
                status = "error_download"
                error_msg = str(e)
                print(f"    Error downloading: {e}")
                manifest_entries.append({
                    "source": "GATT_CRM",
                    "period": period,
                    "date": date,
                    "year": year,
                    "symbol": symbol,
                    "title": title,
                    "country": country,
                    "iso3": iso3,
                    "url": url,
                    "txt_path": str(txt_path),
                    "txt_filename": txt_path.name,
                    "status": status,
                    "error_msg": error_msg,
                })
                continue

            # Parse PDF
            try:
                text = pdf_bytes_to_text(resp.content)
            except Exception as e:
                status = "error_parse"
                error_msg = str(e)
                print(f"    Error parsing: {e}")
                manifest_entries.append({
                    "source": "GATT_CRM",
                    "period": period,
                    "date": date,
                    "year": year,
                    "symbol": symbol,
                    "title": title,
                    "country": country,
                    "iso3": iso3,
                    "url": url,
                    "txt_path": str(txt_path),
                    "txt_filename": txt_path.name,
                    "status": status,
                    "error_msg": error_msg,
                })
                continue

            # Save text
            try:
                with txt_path.open("w", encoding="utf-8") as f:
                    f.write(text)
                status = "downloaded"
                print(f"    Saved to {txt_path}")
            except Exception as e:
                status = "error_write"
                error_msg = str(e)
                print(f"    Error writing: {e}")

        # Save manifest record
        manifest_entries.append({
            "source": "GATT_CRM",
            "period": period,
            "date": date,
            "year": year,
            "symbol": symbol,
            "title": title,
            "country": country,
            "iso3": iso3,
            "url": url,
            "txt_path": str(txt_path),
            "txt_filename": txt_path.name,
            "status": status,
            "error_msg": error_msg,
        })

    # Write manifest
    manifest_path.parent.mkdir(parents=True, exist_ok=True)
    with manifest_path.open("w", encoding="utf-8") as mf:
        json.dump(manifest_entries, mf, ensure_ascii=False, indent=2)

    print(f"\n✔ GATT/CRM manifest written to {manifest_path} ({len(manifest_entries)} entries)")


if __name__ == "__main__":
    main()
