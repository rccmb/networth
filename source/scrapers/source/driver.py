import json
import os
from selenium import webdriver
from selenium.webdriver.firefox.options import Options
from selenium.webdriver.firefox.service import Service


def initialize_driver():
    with open("C:\\Users\\rodri\\Desktop\\Projetos\\networth\\scrapers\\values.json", "r") as f:
        values = json.load(f)

    profile_path = values["user_data_directory_firefox"]
    geckodriver_path = values["geckodriver"]

    if not os.path.exists(profile_path):
        print("[ERROR] Firefox profile path does not exist.")
        input("Press Enter to continue...")
        return False
    
    options = Options()
    options.add_argument("--headless")
    options.add_argument(f"-profile")
    options.add_argument(profile_path)

    service = Service(executable_path=geckodriver_path)

    driver = webdriver.Firefox(service=service, options=options)
    
    return driver