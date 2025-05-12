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

def execute_cgd_scraper(master_key: str) -> bool:
    try:
        with open("secrets.json", "r") as f:
            data = json.load(f)
        
        salt = base64.b64decode(data["salt"])
        key = derive_key(master_key, salt)
        fernet = Fernet(key)

        username = decrypt(data["username_cgd"], fernet)
        password = decrypt(data["password_cgd"], fernet)
        
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
        driver.get("https://www.cgd.pt/Particulares/Pages/Particulares_v2.aspx")
        
        WebDriverWait(driver, 10).until(EC.element_to_be_clickable((By.CSS_SELECTOR, "a.direct-link.desktop"))).click()
        WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.ID, "input_cx1"))).send_keys(username)

        driver.find_element(By.NAME, "login_btn_1").click()

        try: # Warning if appears.
            WebDriverWait(driver, 5).until(EC.element_to_be_clickable((By.CSS_SELECTOR, "a[href='#fecharAviso']"))).click()
        except:
            pass
        
        WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.NAME, "passwordInput"))).send_keys(password)

        driver.find_element(By.ID, "loginForm:submit").click()

        WebDriverWait(driver, 10).until(EC.url_contains("caixadirectaonline.cgd.pt"))
        driver.get("https://caixadirectaonline.cgd.pt/cdo/private/comuns/consultaPosicaoGlobal.seam")

        saldo_span = WebDriverWait(driver, 15).until(EC.presence_of_element_located((By.ID, "saldoContabilisticoAssets")))

        saldo = saldo_span.text.strip()
        print("Total CGD Balance:", saldo + " €")

        return True

    except Exception as e:
        print("[ERROR CGD] Scraping failed:", e)
        return False

    finally:
        driver.quit()
