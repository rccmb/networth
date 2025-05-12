import time
import webbrowser
import pyperclip
import pyautogui
import pytesseract
import cv2
import numpy as np
from PIL import ImageGrab


pytesseract.pytesseract.tesseract_cmd = r"C:\\Program Files\\Tesseract-OCR\\tesseract.exe"

def execute_xtb_scraper(username: str, password: str) -> bool:
    try:
        webbrowser.open("https://xstation5.xtb.com/?branch=pt#/_/login")

        time.sleep(5)

        pyautogui.press("tab") # Select username.
        pyautogui.press("tab") # Select password.
        
        pyperclip.copy(password)
        pyautogui.hotkey('ctrl', 'v')
        
        time.sleep(0.1)
        pyautogui.press("enter") # Login.
        time.sleep(8) 

        left, top, width, height = 315 - 56, 1067 - 19, 56, 19 # Account value box.
        bbox = (left, top, left + width, top + height)

        screenshot = ImageGrab.grab(bbox=bbox)
        screenshot_cv = cv2.cvtColor(np.array(screenshot), cv2.COLOR_RGB2BGR)

        value_text = pytesseract.image_to_string(screenshot_cv, config="--psm 7 -c tessedit_char_whitelist=0123456789.,")
        value_text = value_text.strip()

        if value_text:
            print("Total XTB Balance:", value_text + " €")
        else:
            print("[ERROR XTB] Could not extract account value.")

        return True

    except Exception as e:
        print("[ERROR XTB] Automation failed:", e)
        return False
    
    finally:
        pyautogui.hotkey('ctrl', 'w')
        time.sleep(2) 
        pyautogui.press("enter")