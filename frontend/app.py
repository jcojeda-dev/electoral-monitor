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
        url = "https://resultados.onpe.gob.pe/PRP2026/Elecciones/ResumenGeneral"

        headers = {
            "User-Agent": "Mozilla/5.0",
            "Accept": "application/json"
        }

        res = requests.get(url, headers=headers, timeout=10)

        if res.status_code == 200:
            return res.json()
        else:
            return None
    except Exception as e:
        st.error(f"Error ONPE: {e}")
        return None

# =========================
# PROCESAR DATA
# =========================
def process_data(raw):
    try:
        data = []

        for r in raw["departamentos"]:
            data.append({
                "region": r["nombre"],
                "validos": r["votosValidos"],
                "nulos": r["votosNulos"],
                "blancos": r["votosBlancos"]
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
import json

st.subheader("🗺️ Mapa electoral del Perú")

# cargar geojson
with open("frontend/assets/peru_regions.geojson") as f:
    geojson = json.load(f)

# mapa
import json

with open("frontend/assets/peru.geojson") as f:
    geojson = json.load(f)

fig_map = px.choropleth(
    df,
    geojson=geojson,
    locations="region",
    featureidkey="properties.name",
    color="validos",
    color_continuous_scale="Reds"
)

fig_map.update_geos(fitbounds="locations", visible=False)

st.plotly_chart(fig_map, use_container_width=True)

region = st.selectbox("Selecciona región", df["region"])

filtered = df[df["region"] == region]

st.dataframe(filtered)

import json

with open("frontend/assets/candidatos.json") as f:
    candidatos = json.load(f)

st.subheader("Resultados por candidato")

for c in candidatos:
    st.metric(c["nombre"], c["votos"])

    top = max(candidatos, key=lambda x: x["votos"])

st.success(f"🟢 Líder actual: {top['nombre']}")
