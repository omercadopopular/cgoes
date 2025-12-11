# -*- coding: utf-8 -*-
"""
Scrape WTO Trade Policy Reviews (TPR) list by country:
- Country
- Dates
- TPR Documents link

Outputs:
    ROOT/data/wto-links/crm_documents.json
"""

import time
import json
from pathlib import Path
from urllib.parse import urljoin

from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from webdriver_manager.chrome import ChromeDriverManager

BASE_URL = "https://www.wto.org"
TPR_URL = "https://www.wto.org/english/tratop_e/tpr_e/tp_rep_e.htm"


# ======================================================
#   OUTPUT DIRECTORY (per your specification)
# ======================================================
base_dir = Path(__file__).resolve().parent.parent.parent
data_dir = base_dir / "data"
output_dir = data_dir / "wto-links"
output_dir.mkdir(parents=True, exist_ok=True)

output_file = output_dir / "wto_tpr_document_source.json"


# ======================================================
#   Selenium Driver
# ======================================================
def make_driver(headless: bool = True):
    chrome_options = Options()
    if headless:
        chrome_options.add_argument("--headless=new")

    chrome_options.add_argument("--no-sandbox")
    chrome_options.add_argument("--disable-dev-shm-usage")

    return webdriver.Chrome(
        service=Service(ChromeDriverManager().install()),
        options=chrome_options,
    )


# ======================================================
#   Pagination helpers
# ======================================================
def get_max_page_number(driver, wait):
    try:
        wait.until(EC.presence_of_element_located(
            (By.CSS_SELECTOR, "#dataTable_paginate")
        ))
    except Exception:
        return 1

    buttons = driver.find_elements(By.CSS_SELECTOR, "#dataTable_paginate .paginate_button")

    nums = set()
    for b in buttons:
        t = b.text.strip()
        if t.isdigit():
            nums.add(int(t))

    return max(nums) if nums else 1


# ======================================================
#   Extract rows from current table view
# ======================================================
def get_rows_on_current_page(driver):
    rows = []

    body_rows = driver.find_elements(By.CSS_SELECTOR, "#dataTable tbody tr")
    if not body_rows:
        all_rows = driver.find_elements(By.CSS_SELECTOR, "#dataTable tr")
        body_rows = all_rows[1:]

    for tr in body_rows:
        tds = tr.find_elements(By.TAG_NAME, "td")
        if len(tds) < 3:
            continue

        country = tds[0].text.strip()
        dates = tds[1].text.strip()

        try:
            a = tds[2].find_element(By.TAG_NAME, "a")
            href = urljoin(BASE_URL, a.get_attribute("href"))
        except Exception:
            href = ""

        rows.append({
            "country": country,
            "dates": dates,
            "tpr_documents_url": href,
        })

    return rows


# ======================================================
#   Main Scraper
# ======================================================
def scrape_tpr_table():
    driver = make_driver(headless=True)
    wait = WebDriverWait(driver, 20)

    try:
        driver.get(TPR_URL)

        wait.until(EC.presence_of_element_located((By.CSS_SELECTOR, "#dataTable")))

        max_page = get_max_page_number(driver, wait)
        print(f"Detected {max_page} pages.")

        all_rows = []

        for page in range(1, max_page + 1):
            if page > 1:
                # click page button
                for b in driver.find_elements(By.CSS_SELECTOR, "#dataTable_paginate .paginate_button"):
                    if b.text.strip() == str(page):
                        b.click()
                        time.sleep(1.5)
                        break

            rows = get_rows_on_current_page(driver)
            print(f"Page {page}: {len(rows)} rows")
            all_rows.extend(rows)

        return all_rows

    finally:
        driver.quit()


# ======================================================
#   Save to JSON
# ======================================================
def save_to_json(data, path):
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
    print(f"✔ Saved {len(data)} rows to {path}")


# ======================================================
#   Run
# ======================================================
if __name__ == "__main__":
    rows = scrape_tpr_table()
    save_to_json(rows, output_file)
