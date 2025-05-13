from getpass import getpass
from institutions.degiro_scraper import execute_degiro_scraper
from institutions.xtb_scraper import execute_xtb_scraper
from institutions.cgd_scraper import execute_cgd_scraper
from driver import initialize_driver
from encryption import get_secrets      
import time
from database import Database
import re
      
    
def parse_euro_value(text: str) -> float:
    if not text:
        return 0.0
    clean = re.sub(r"[^\d,\.]", "", text.strip())
    if "," in clean and "." in clean:
        clean = clean.replace(".", "").replace(",", ".")
    elif "," in clean:
        clean = clean.replace(",", ".")
    return float(clean)
    
      
def main():
    master_key = getpass("MASTER: ")
    secrets = get_secrets(master_key)
    
    if secrets == False:
        return
    
    start = time.time()
    
    database = Database()
    
    # Run manual first.
    xtb_text = execute_xtb_scraper(secrets["username_xtb"], secrets["password_xtb"])
    xtb_balance = parse_euro_value(xtb_text)
    
    # Run automated second.
    driver = initialize_driver()
    
    degiro_text = execute_degiro_scraper(driver, secrets["username_degiro"], secrets["password_degiro"])
    degiro_balance = parse_euro_value(degiro_text)
    
    cgd_text = execute_cgd_scraper(driver, secrets["username_cgd"], secrets["password_cgd"])
    cgd_balance = parse_euro_value(cgd_text)
    
    driver.quit()
    
    print("XTB:", xtb_balance, "€")
    print("Degiro:", degiro_balance, "€")
    print("CGD:", cgd_balance, "€")
    
    if xtb_text is None or degiro_text is None or cgd_text is None:
        print("[ERROR] Errors have occurred, nothing will be saved.")
        return
    
    array = [
        {"source": "XTB", "value": xtb_balance},
        {"source": "DEGIRO", "value": degiro_balance},
        {"source": "CGD", "value": cgd_balance},
    ]
    responses = database.insert_multiple(array)
    
    for response in responses:
        if response["response"] is None:
            print("[ERROR::DB::INSERT_MULTIPLE] Something went wrong with one of the inserts:", response["source"])
    
    total_balance = xtb_balance + degiro_balance + cgd_balance
    
    print("Total Balance:", total_balance, "€")
    
    end = time.time()
    print("Time elapsed:", end - start, "seconds.")

if __name__ == "__main__":
    main()