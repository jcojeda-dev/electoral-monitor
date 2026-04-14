from fastapi import FastAPI
import requests
import pandas as pd

app = FastAPI()

# =========================
# SCRAPER ONPE ROBUSTO
# =========================
def fetch_onpe():
    try:
        url = "https://resultados.onpe.gob.pe/PRP2026/Elecciones/ResumenGeneral"

        headers = {
            "User-Agent": "Mozilla/5.0",
            "Accept": "application/json"
        }

        res = requests.get(url, headers=headers, timeout=10)

        if res.status_code == 200:
            return res.json()

    except:
        return None

# =========================
# ENDPOINT
# =========================
@app.get("/onpe")
def get_onpe():

    raw = fetch_onpe()

    if not raw:
        return {"status": "fallback", "data": []}

    try:
        data = []

        for r in raw["departamentos"]:
            data.append({
                "region": r["nombre"],
                "validos": r["votosValidos"],
                "nulos": r["votosNulos"],
                "blancos": r["votosBlancos"]
            })

        return {
            "status": "ok",
            "data": data
        }

    except:
        return {"status": "error", "data": []}