import json
from getpass import getpass
from institutions.degiro_scraper import execute_degiro_scraper
      
      
def main():
    master_key = getpass("MASTER: ")
    # execute_degiro_scraper(master_key)
    # execute_xtb_scraper(master_key)
    # execute_cgd_scraper(master_key)
    

if __name__ == "__main__":
    main()