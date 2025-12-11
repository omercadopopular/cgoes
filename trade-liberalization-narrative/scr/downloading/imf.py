import time
import json
import os
from pathlib import Path
from dataclasses import dataclass, asdict

from selenium import webdriver
from selenium.webdriver.edge.service import Service
from selenium.webdriver.edge.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

from bs4 import BeautifulSoup


# ============================
# PATHS
# ============================

base_dir = Path(__file__).resolve().parent.parent.parent # Assuming `/code` is one level below the root directory
driverpath = os.path.join(base_dir, "selenium-drive\chromedriver.exe")
print(driverpath)
OUTPUT_FILE = r"\imf-links\imf_country_reports.json"

# ============================
# TARGET URL
# ============================

URL = ("https://www.imf.org/en/publications/search"
       "#sortCriteria=%40imfdate%20ascending&cf-type=COUNTRYREPS&numberOfResults=50")


# ============================
# CSS SELECTORS
# ============================

RESULT_SELECTOR = "div.CoveoResult"
TITLE_SELECTOR = "a.CoveoResultLink"
DATE_SELECTOR = ".coveo-imf-date"
ABSTRACT_SELECTOR = ".coveo-result-description, .coveo-result-summary"

# Pagination radio buttons (you inspected these):
PAGER_SELECTOR = "input[type='radio'][name^='atomic-pager']"


# ============================
# DATA STRUCTURE
# ============================

@dataclass
class Publication:
    title: str
    date: str
    abstract: str
    link: str


# ============================
# DRIVER SETUP
# ============================

def setup_driver():
    opts = Options()
    opts.use_chromium = True
    opts.add_argument("--headless=new")   # remove if you want visual mode
    opts.add_argument("--disable-gpu")
    opts.add_argument("--no-sandbox")

    service = Service(driverpath)
    driver = webdriver.Edge(service=service, options=opts)
    driver.set_page_load_timeout(40)
    return driver


# ============================
# HELPERS
# ============================

def wait_for_results(driver):
    WebDriverWait(driver, 25).until(
        EC.presence_of_all_elements_located((By.CSS_SELECTOR, RESULT_SELECTOR))
    )


def parse_page_html(driver):
    """Parse page contents using BeautifulSoup for reliability."""
    soup = BeautifulSoup(driver.page_source, "html.parser")
    publications = []

    for res in soup.select(RESULT_SELECTOR):
        # title + link
        title_el = res.select_one(TITLE_SELECTOR)
        if not title_el:
            continue

        title = title_el.get_text(strip=True)
        link = title_el.get("href", "")

        # date
        date_el = res.select_one(DATE_SELECTOR)
        date = date_el.get_text(strip=True) if date_el else ""

        # abstract
        abstract_el = res.select_one(ABSTRACT_SELECTOR)
        abstract = abstract_el.get_text(strip=True) if abstract_el else ""

        publications.append(Publication(title, date, abstract, link))

    return publications


# ============================
# MAIN SCRAPER
# ============================

def main():
    driver = setup_driver()
    driver.get(URL)
    time.sleep(3)

    all_pubs = []

    # Wait for page 1 results
    wait_for_results(driver)

    # Get the pagination buttons
    pagers = driver.find_elements(By.CSS_SELECTOR, PAGER_SELECTOR)
    num_pages = len(pagers)

    print(f"Detected {num_pages} pages.")

    for i in range(num_pages):
        # Page buttons may update on each click → re-select them
        pagers = driver.find_elements(By.CSS_SELECTOR, PAGER_SELECTOR)
        btn = pagers[i]

        page_number = btn.get_attribute("value")
        print(f"\nNavigating to page {page_number}...")

        # click using JS (normal clicks often fail for shadow DOM / overlapping elements)
        driver.execute_script("arguments[0].click();", btn)
        time.sleep(2)

        wait_for_results(driver)

        pubs = parse_page_html(driver)
        print(f" → Collected {len(pubs)} results on page {page_number}")

        all_pubs.extend(pubs)

    # Save to JSON
    with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
        json.dump([asdict(p) for p in all_pubs], f, ensure_ascii=False, indent=2)

    print(f"\nDONE. Total publications collected: {len(all_pubs)}")
    print(f"Saved to: {OUTPUT_FILE}")

    driver.quit()


if __name__ == "__main__":
    main()
