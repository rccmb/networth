import json, os
from getpass import getpass
import encryption


def main():
    while True:
        master_key = getpass("MASTER: ")
        master_key_confirm = getpass("MASTER CONFIRM: ")
        
        if master_key != master_key_confirm:
            print("Master passwords don't match.")
        else: 
            break
    
    degiro_user = input("DEGIRO_USERNAME: ")
    degiro_pass = getpass("DEGIRO_PASSWORD: ")
   
    xtb_user = input("XTB_USERNAME: ")
    xtb_pass = getpass("XTB_PASSWORD: ")
    
    cgd_user = input("CGD_USERNAME: ")
    cgd_pass = getpass("CGD_PASSWORD: ")

    data = encryption.get_data(master_key, degiro_user, degiro_pass, xtb_user, xtb_pass, cgd_user, cgd_pass)
    
    if os.path.exists("secrets_temporary.json"):
        os.remove("secrets_temporary.json")
    
    with open("secrets_temporary.json", "w") as f:
        json.dump(data, f, indent=4)


if __name__ == "__main__":
    main()