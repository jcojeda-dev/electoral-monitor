import streamlit as st
import pandas as pd
import plotly.express as px
import requests

st.set_page_config(layout="wide")

st.title("📊 Monitor Electoral Perú 🔴 EN VIVO")

# =========================
# API ONPE (INTENTO REAL)
# =========================
def fetch_onpe():
    try:
        url = "https://resultados.onpe.gob.pe/api/elecciones/eleccion/1/resumen"
        res = requests.get(url, timeout=5)

        if res.status_code == 200:
            return res.json()
        else:
            return None
    except:
        return None

# =========================
# PROCESAR DATA
# =========================
def process_data(raw):
    try:
        regiones = raw["data"]

        data = []
        for r in regiones:
            data.append({
                "region": r["departamento"],
                "validos": r["votos_validos"],
                "nulos": r["votos_nulos"],
                "blancos": r["votos_blancos"]
            })

        return data
    except:
        return None

# =========================
# FALLBACK (SI FALLA ONPE)
# =========================
def fallback():
    return [
        {"region": "Lima Metropolitana", "validos": 50000, "nulos": 2000, "blancos": 1000},
        {"region": "La Libertad", "validos": 30000, "nulos": 1500, "blancos": 800},
        {"region": "Piura", "validos": 25000, "nulos": 1200, "blancos": 600},
        {"region": "Arequipa", "validos": 20000, "nulos": 1000, "blancos": 500},
    ]

# =========================
# EJECUCIÓN
# =========================
raw = fetch_onpe()

if raw:
    data = process_data(raw)
else:
    st.warning("Usando datos simulados (ONPE no disponible)")
    data = fallback()

df = pd.DataFrame(data)

df["invalidos"] = df["nulos"] + df["blancos"]
df["total"] = df["validos"] + df["invalidos"]

# =========================
# KPIs
# =========================
col1, col2, col3 = st.columns(3)

col1.metric("Total votos", int(df["total"].sum()))
col2.metric("Regiones", len(df))
col3.metric("Promedio", f"{df['total'].mean():,.0f}")

# =========================
# GRÁFICO
# =========================
st.subheader("Resultados por región")

fig = px.bar(df, x="region", y="validos", color="validos")
st.plotly_chart(fig, use_container_width=True)

# =========================
# COMPARATIVA
# =========================
st.subheader("Válidos vs Inválidos")

fig2 = px.bar(df, x="region", y=["validos", "invalidos"], barmode="group")
st.plotly_chart(fig2, use_container_width=True)

# =========================
# DETALLE
# =========================
region = st.selectbox("Selecciona región", df["region"])
r = df[df["region"] == region]

st.metric("Válidos", int(r["validos"].values[0]))
st.metric("Inválidos", int(r["invalidos"].values[0]))
