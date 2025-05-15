import json
from supabase import create_client, Client


class Database:
    def __init__(self):
        try:
            with open("C:\\Users\\rodri\\Desktop\\Projetos\\networth\\scrapers\\secrets_persistent.json", "r") as f:
                secrets = json.load(f)

            supabase_url = secrets["supabase_url"]
            supabase_key = secrets["supabase_key"]

            self.client: Client = create_client(supabase_url, supabase_key)

        except Exception as e:
            print("[ERROR::DB] Could not initialize Supabase client:", e)
            input("Press Enter to continue...")
            self.client = None
            
            
    def insert_balance(self, source: str, balance: float, run_id: int = 0):
        if not self.client:
            print("[ERROR::DB] Supabase client not initialized.")
            input("Press Enter to continue...")
            return None
        
        try:
            data = {
                "run_id": run_id,
                "source": source,
                "balance": balance,
            }
            response = self.client.table("daily_source_balance").insert(data).execute()
            return response
        
        except Exception as e:
            print("[ERROR::DB] Insert failed:", e)
            input("Press Enter to continue...")
            return None

    
    def insert_multiple(self, array):
        if not self.client:
            print("[ERROR::DB] Supabase client not initialized.")
            input("Press Enter to continue...")
            return None
        
        try:
            # Obtaining the last run id.
            run_id_result = (
                self.client
                .table("daily_source_balance")
                .select("run_id")
                .order("run_id", desc=True)
                .limit(1)
                .execute()
            )
            
            last_run_id = 0
            if run_id_result.data and len(run_id_result.data) > 0:
                last_run_id = run_id_result.data[0].get("run_id", 0)
            
            responses = []
            
            for value in array:
                responses.append({"source": value["source"], "response": self.insert_balance(value["source"], value["value"], last_run_id + 1)})
            
            return responses
            
        except Exception as e:
            print("[ERROR::DB] Insert failed:", e)
            input("Press Enter to continue...")
            return None
            
