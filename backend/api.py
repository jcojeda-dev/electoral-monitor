import time

REFRESH_INTERVAL = 15  # segundos

if "last_update" not in st.session_state:
    st.session_state.last_update = time.time()

if time.time() - st.session_state.last_update > REFRESH_INTERVAL:
    st.session_state.last_update = time.time()
    st.rerun()

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

    with open("backend/data/onpe_cache.json") as f:
        raw = json.load(f)

    data = []

    for r in raw["data"]:
        ganador = max(r["candidatos"], key=lambda x: x["votos"])

        data.append({
            "region": r["region"],
            "ganador": ganador["nombre"],
            "color": ganador["color"],
            "votos": ganador["votos"]
        })

    return {"status": "ok", "data": data}

if "prev_df" not in st.session_state:
    st.session_state.prev_df = df.copy()

prev_df = st.session_state.prev_df

events = []

# cambio de líder nacional
if not prev_df.empty:
    prev_top = prev_df["ganador"].value_counts().idxmax()
    new_top = df["ganador"].value_counts().idxmax()

    if prev_top != new_top:
        events.append(f"🚨 Nuevo líder nacional: {new_top}")

# cambio en Lima
try:
    prev_lima = prev_df[prev_df["region"] == "Lima Metropolitana"]["ganador"].values[0]
    new_lima = df[df["region"] == "Lima Metropolitana"]["ganador"].values[0]

    if prev_lima != new_lima:
        events.append("📍 Cambio de líder en Lima Metropolitana")
except:
    pass

st.markdown("### 🔴 EN VIVO")

if events:
    ticker = " | ".join(events)
else:
    ticker = "Actualizando resultados en tiempo real..."

st.markdown(f"""
<div style="background:black;color:white;padding:10px;">
{ticker}
</div>
""", unsafe_allow_html=True)

st.session_state.prev_df = df.copy()

import random

votos += random.randint(0, 10000)