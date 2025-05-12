import base64, os
import json
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
from cryptography.hazmat.primitives import hashes
from cryptography.fernet import Fernet


def derive_key(master_pass: str, salt: bytes) -> bytes:
    kdf = PBKDF2HMAC(
        algorithm=hashes.SHA256(),
        length=32,
        salt=salt,
        iterations=310_000,
    )
    return base64.urlsafe_b64encode(kdf.derive(master_pass.encode()))


def encrypt(plain: str, f: Fernet) -> str:
    encrypted = f.encrypt(plain.encode()).decode()
    return encrypted


def decrypt(cipher_text: str, f: Fernet) -> str:
    decrypted = f.decrypt(cipher_text.encode()).decode()
    return decrypted


def get_data(master_key: str, degiro_user: str, degiro_pass: str, xtb_user: str, xtb_pass: str, cgd_user: str, cgd_pass: str):
    salt = os.urandom(16)
    key = derive_key(master_key, salt)
    f = Fernet(key)
    
    return {
        "salt": base64.b64encode(salt).decode(),
        "username_degiro": encrypt(degiro_user, f),
        "password_degiro": encrypt(degiro_pass, f),
        "username_xtb": encrypt(xtb_user, f),
        "password_xtb": encrypt(xtb_pass, f),
        "username_cgd": encrypt(cgd_user, f),
        "password_cgd": encrypt(cgd_pass, f),
    }
    
    
def get_secrets(master_key: str):
    try:
        with open("secrets.json", "r") as f:
            data = json.load(f)
        
        salt = base64.b64decode(data["salt"])
        key = derive_key(master_key, salt)
        fernet = Fernet(key)

        degiro_user = decrypt(data["username_degiro"], fernet)
        degiro_pass = decrypt(data["password_degiro"], fernet)
        
        xtb_user = decrypt(data["username_xtb"], fernet)
        xtb_pass = decrypt(data["password_xtb"], fernet)
        
        cgd_user = decrypt(data["username_cgd"], fernet)
        cgd_pass = decrypt(data["password_cgd"], fernet)
        
        return {
            "username_degiro": degiro_user,
            "password_degiro": degiro_pass,
            "username_xtb": xtb_user,
            "password_xtb": xtb_pass,
            "username_cgd": cgd_user,
            "password_cgd": cgd_pass
        }
        
    except Exception as e:
        print("[ERROR] Decrypting secrets.", e)
        return False