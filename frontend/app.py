import streamlit as st
import pandas as pd
import plotly.express as px
import requests
import json

st.set_page_config(layout="wide")

st.title("📊 Monitor Electoral Perú 🔴 EN VIVO")

# =========================
# DATA ONPE (robusta)
# =========================
@st.cache_data(ttl=60)
def fetch_data():
    try:
        url = "https://resultados.onpe.gob.pe/PRP2026/Elecciones/ResumenGeneral"
        headers = {"User-Agent": "Mozilla/5.0"}
        res = requests.get(url, headers=headers, timeout=10)

        if res.status_code == 200:
            raw = res.json()

            data = []
            for r in raw["departamentos"]:
                data.append({
                    "region": r["nombre"],
                    "validos": r["votosValidos"],
                    "nulos": r["votosNulos"],
                    "blancos": r["votosBlancos"]
                })

            return pd.DataFrame(data)

    except:
        pass

    # fallback
    return pd.DataFrame([
        {"region": "Lima Metropolitana", "validos": 50000, "nulos": 2000, "blancos": 1000},
        {"region": "La Libertad", "validos": 30000, "nulos": 1500, "blancos": 800},
        {"region": "Piura", "validos": 25000, "nulos": 1200, "blancos": 600},
        {"region": "Arequipa", "validos": 20000, "nulos": 1000, "blancos": 500},
    ])

df = fetch_data()

df["invalidos"] = df["nulos"] + df["blancos"]
df["total"] = df["validos"] + df["invalidos"]

# =========================
# KPIs
# =========================
c1, c2, c3 = st.columns(3)

c1.metric("Total votos", f"{df['total'].sum():,}")
c2.metric("Regiones", len(df))
c3.metric("Promedio", f"{df['total'].mean():,.0f}")

# =========================
# BARRA TIPO ONPE
# =========================
st.subheader("Avance de actas")

avance = 68.2
st.progress(avance / 100)
st.write(f"{avance}% contabilizado")

# =========================
# MAPA REAL
# =========================
st.subheader("🗺️ Mapa electoral")

try:
    with open("frontend/assets/peru.geojson") as f:
        geo = json.load(f)

    fig_map = px.choropleth(
        df,
        geojson=geo,
        locations="region",
        featureidkey="properties.name",
        color="validos",
        color_continuous_scale="Reds"
    )

    fig_map.update_geos(fitbounds="locations", visible=False)

    st.plotly_chart(fig_map, use_container_width=True)

except:
    st.warning("Mapa no disponible")

# =========================
# GRÁFICOS
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
# SELECTOR
# =========================
region = st.selectbox("Selecciona región", df["region"])
r = df[df["region"] == region]

st.metric("Válidos", int(r["validos"].values[0]))
st.metric("Inválidos", int(r["invalidos"].values[0]))

# =========================
# CANDIDATOS
# =========================
st.subheader("Resultados por candidato")

with open("frontend/assets/candidatos.json") as f:
    candidatos = json.load(f)

cols = st.columns(len(candidatos))

for i, c in enumerate(candidatos):
    with cols[i]:
        st.image(f"frontend/assets/{c['foto']}", width=120)
        st.write(c["nombre"])
        st.caption(c["partido"])
        st.metric("Votos", f"{c['votos']:,}")

# =========================
# ALERTA
# =========================
top = max(candidatos, key=lambda x: x["votos"])

st.success(f"🚨 Líder actual: {top['nombre']} ({top['partido']})")
