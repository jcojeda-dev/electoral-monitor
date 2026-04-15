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