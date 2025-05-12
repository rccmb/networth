import json
import time
from selenium import webdriver
from selenium.webdriver.firefox.options import Options
from selenium.webdriver.firefox.service import Service
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

from encryption import derive_key, decrypt
from cryptography.fernet import Fernet
import base64
import os

def execute_degiro_scraper(master_key: str) -> bool:
    try:
        with open("secrets.json", "r") as f:
            data = json.load(f)
        
        salt = base64.b64decode(data["salt"])
        key = derive_key(master_key, salt)
        fernet = Fernet(key)

        username = decrypt(data["username_degiro"], fernet)
        password = decrypt(data["password_degiro"], fernet)
        
    except Exception as e:
        print("[ERROR] Decrypting secrets.", e)
        return False
    
    with open("values.json", "r") as f:
        values = json.load(f)

    profile_path = values["user_data_directory_firefox"]
    geckodriver_path = values["geckodriver"]

    if not os.path.exists(profile_path):
        print("[ERROR DEGIRO] Firefox profile path does not exist.")
        return False
    
    options = Options()
    options.add_argument("--headless")
    options.add_argument(f"-profile")
    options.add_argument(profile_path)

    service = Service(executable_path=geckodriver_path)

    driver = webdriver.Firefox(service=service, options=options)

    try:
        driver.get("https://trader.degiro.nl/login/")
        WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.NAME, "username")))

        user_input = driver.find_element(By.NAME, "username")
        pass_input = driver.find_element(By.NAME, "password")

        user_input.clear()
        user_input.send_keys(username)

        pass_input.clear()
        pass_input.send_keys(password)

        login_btn = driver.find_element(By.CSS_SELECTOR, "button[type='submit']")
        login_btn.click()

        driver.get("https://trader.degiro.nl/trader/#/profile/personal-settings")

        WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.CSS_SELECTOR, '[data-id="totalPortfolio"][title]')))
        element = driver.find_element(By.CSS_SELECTOR, '[data-id="totalPortfolio"][title]')
        print("Total Degiro Balance:", element.get_attribute("title"), "€")
        return True

    except Exception as e:
        print("[ERROR DEGIRO] Scraping failed:", e)
        return False

    finally:
        driver.quit()
