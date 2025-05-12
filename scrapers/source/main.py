from getpass import getpass
from institutions.degiro_scraper import execute_degiro_scraper
from institutions.xtb_scraper import execute_xtb_scraper
from institutions.cgd_scraper import execute_cgd_scraper
from driver import initialize_driver
from encryption import get_secrets      
import time
      
      
def main():
    master_key = getpass("MASTER: ")
    secrets = get_secrets(master_key)
    
    if secrets == False:
        return

    start = time.time()
    
    # Run manual first.
    execute_xtb_scraper(secrets["username_xtb"], secrets["password_xtb"])
    
    # Run automated second.
    driver = initialize_driver()
    execute_degiro_scraper(driver, secrets["username_degiro"], secrets["password_degiro"])
    execute_cgd_scraper(driver, secrets["username_cgd"], secrets["password_cgd"])
    driver.quit()
    
    end = time.time()
    print("Time elapsed: ", end - start)

if __name__ == "__main__":
    main()