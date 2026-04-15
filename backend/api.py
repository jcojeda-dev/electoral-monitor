from fastapi import FastAPI
import json
import os

app = FastAPI()

# =========================
# CONFIG
# =========================
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DATA_PATH = os.path.join(BASE_DIR, "data", "onpe_cache.json")

# =========================
# ROOT (HEALTH CHECK)
# =========================
@app.get("/")
def root():
    return {
        "status": "ok",
        "message": "API funcionando"
    }

# =========================
# LOAD DATA
# =========================
def load_data():
    try:
        with open(DATA_PATH, "r", encoding="utf-8") as f:
            return json.load(f)
    except Exception as e:
        print("Error loading data:", e)
        return None

# =========================
# PROCESS DATA
# =========================
def process_data(raw):

    response = []

    for r in raw.get("data", []):

        candidatos = r.get("candidatos", [])

        if not candidatos:
            continue

        # calcular ganador
        ganador = max(candidatos, key=lambda x: x.get("votos", 0))

        response.append({
            "region": r.get("region"),
            "ganador": ganador.get("nombre"),
            "color": ganador.get("color"),
            "votos": ganador.get("votos")
        })

    return response

# =========================
# ENDPOINT PRINCIPAL
# =========================
@app.get("/onpe")
def get_onpe():

    raw = load_data()

    # 🔴 fallback si falla archivo
    if not raw:
        return {
            "status": "fallback",
            "data": [
                {
                    "region": "Lima Metropolitana",
                    "ganador": "Keiko",
                    "color": "#f57c00",
                    "votos": 4000000
                },
                {
                    "region": "La Libertad",
                    "ganador": "Castillo",
                    "color": "#c62828",
                    "votos": 900000
                }
            ]
        }

    try:
        data = process_data(raw)

        return {
            "status": "ok",
            "data": data
        }

    except Exception as e:
        return {
            "status": "error",
            "message": str(e),
            "data": []
        }