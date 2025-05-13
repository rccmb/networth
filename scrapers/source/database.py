import json
from supabase import create_client, Client


class Database:
    def __init__(self):
        try:
            with open("secrets_persistent.json", "r") as f:
                secrets = json.load(f)

            supabase_url = secrets["supabase_url"]
            supabase_key = secrets["supabase_key"]

            self.client: Client = create_client(supabase_url, supabase_key)

        except Exception as e:
            print("[ERROR::DB] Could not initialize Supabase client:", e)
            self.client = None
            
            
    def insert_balance(self, source: str, balance: float):
        if not self.client:
            print("[ERROR::DB] Supabase client not initialized.")
            return None
        
        try:
            data = {
                "source": source,
                "balance": balance,
            }
            response = self.client.table("daily_source_balance").insert(data).execute()
            return response
        
        except Exception as e:
            print("[ERROR::DB] Insert failed:", e)
            return None

    
    def insert_multiple(self, array):
        if not self.client:
            print("[ERROR::DB] Supabase client not initialized.")
            return None
        
        try:
            responses = []
            
            for value in array:
                responses.append({"source": value["source"], "response": self.insert_balance(value["source"], value["value"])})
            
            return responses
            
        except Exception as e:
            print("[ERROR::DB] Insert failed:", e)
            return None
            
