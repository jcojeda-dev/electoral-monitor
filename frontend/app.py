import streamlit as st
import pandas as pd
import plotly.express as px
import requests

st.set_page_config(layout="wide")

st.title("📊 Monitor Electoral Perú 🔴 EN VIVO")

# =========================
# SIMULACIÓN ESTRUCTURA ONPE
# =========================
def get_data():
    # luego conectamos API real
    return [
        {"region": "Lima Metropolitana", "validos": 50000, "nulos": 2000, "blancos": 1000},
        {"region": "La Libertad", "validos": 30000, "nulos": 1500, "blancos": 800},
        {"region": "Piura", "validos": 25000, "nulos": 1200, "blancos": 600},
        {"region": "Arequipa", "validos": 20000, "nulos": 1000, "blancos": 500},
    ]

data = get_data()

df = pd.DataFrame(data)

df["invalidos"] = df["nulos"] + df["blancos"]
df["total"] = df["validos"] + df["invalidos"]

# =========================
# KPIs
# =========================
col1, col2, col3 = st.columns(3)

col1.metric("Total votos", int(df["total"].sum()))
col2.metric("Actas procesadas", "68.2%")
col3.metric("Participación estimada", "72%")

# =========================
# GRÁFICO ONPE STYLE
# =========================
st.subheader("Resultados por región")

fig = px.bar(
    df,
    x="region",
    y="validos",
    color="validos",
    text="validos"
)

st.plotly_chart(fig, use_container_width=True)

# =========================
# COMPARATIVA PRO
# =========================
st.subheader("Votos válidos vs inválidos")

fig2 = px.bar(
    df,
    x="region",
    y=["validos", "invalidos"],
    barmode="group"
)

st.plotly_chart(fig2, use_container_width=True)

# =========================
# DETALLE
# =========================
region = st.selectbox("Selecciona región", df["region"])
r = df[df["region"] == region]

st.metric("Válidos", int(r["validos"].values[0]))
st.metric("Inválidos", int(r["invalidos"].values[0]))
