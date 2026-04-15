import streamlit as st
import time

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
    return {"status": "ok", "message": "API funcionando"}

# =========================
# ENDPOINT PRINCIPAL
# =========================
@app.get("/onpe")
def get_onpe():

    try:
        with open(DATA_PATH, "r", encoding="utf-8") as f:
            raw = json.load(f)

        response = []

        for r in raw.get("data", []):

            # validar candidatos
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

        return {
            "status": "ok",
            "data": response
        }

    except Exception as e:
        return {
            "status": "error",
            "message": str(e),
            "data": []
        }