from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time

    
def execute_degiro_scraper(driver, username: str, password: str) -> bool:
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
        time.sleep(3) # Degiro needs to get fresh value.
        element = driver.find_element(By.CSS_SELECTOR, '[data-id="totalPortfolio"][title]')
        balance_text = element.get_attribute("title")

        return balance_text

    except Exception as e:
        print("[ERROR DEGIRO] Scraping failed:", e)
        return None
