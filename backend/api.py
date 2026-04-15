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
# ENDPOINT REAL
# =========================
@app.get("/onpe")
def get_onpe():

    raw = fetch_onpe()

    # fallback si ONPE falla
    if not raw:
        return {
            "status": "fallback",
            "data": [
                {"region": "Lima Metropolitana", "validos": 50000, "nulos": 2000, "blancos": 1000},
                {"region": "La Libertad", "validos": 30000, "nulos": 1500, "blancos": 800}
            ]
        }

    try:
        data = []

        for r in raw.get("departamentos", []):
            data.append({
                "region": r.get("nombre"),
                "validos": r.get("votosValidos", 0),
                "nulos": r.get("votosNulos", 0),
                "blancos": r.get("votosBlancos", 0)
            })

        return {
            "status": "ok",
            "data": data
        }

    except:
        return {"status": "error", "data": []}