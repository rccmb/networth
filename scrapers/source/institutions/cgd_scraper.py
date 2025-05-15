from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC


def execute_cgd_scraper(driver, username: str, password: str) -> bool:
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

        balance_span = WebDriverWait(driver, 15).until(EC.presence_of_element_located((By.ID, "saldoContabilisticoAssets")))
        balance_text = balance_span.text.strip()
        
        if balance_text is None:
            print("[ERROR CGD] Could not extract account value.")
            
        return balance_text

    except Exception as e:
        print("[ERROR CGD] Scraping failed:", e)
        input("Press Enter to continue...")
        return None
