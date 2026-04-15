from fastapi import FastAPI
import requests

app = FastAPI()

# =========================
# ROOT
# =========================
@app.get("/")
def root():
    return {"status": "ok", "message": "API funcionando"}

# =========================
# SCRAPER ONPE
# =========================
def fetch_onpe():
    try:
        session = requests.Session()

        headers = {
            "User-Agent": "Mozilla/5.0",
            "Accept": "application/json, text/plain, */*",
            "Referer": "https://resultados.onpe.gob.pe/",
            "Origin": "https://resultados.onpe.gob.pe"
        }

        # Paso 1: abrir página (para cookies)
        session.get("https://resultados.onpe.gob.pe/", headers=headers)

        # Paso 2: endpoint real (puede variar)
        url = "https://resultados.onpe.gob.pe/api/Resultados/Resumen"

        res = session.get(url, headers=headers, timeout=10)

        if res.status_code == 200:
            return res.json()

    except Exception as e:
        print("Error ONPE:", e)

    return None

# =========================
# ENDPOINT REAL
# =========================

import json

@app.get("/onpe")
def get_onpe():

    try:
        with open("backend/data/onpe_cache.json") as f:
            data = json.load(f)

        return {
            "status": "ok",
            "data": data["data"]
        }

    except:
        return {"status": "error", "data": []}