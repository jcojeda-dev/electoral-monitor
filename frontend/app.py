import streamlit as st
import pandas as pd
import plotly.express as px

st.set_page_config(layout="wide")

st.title("📊 Monitor Electoral Perú 🔴 EN VIVO")

# =========================
# DATA SEGURA (SIN ARCHIVOS)
# =========================
data = [
    {"region": "Lima Metropolitana", "validos": 50000, "invalidos": 5000},
    {"region": "La Libertad", "validos": 30000, "invalidos": 3000},
    {"region": "Piura", "validos": 25000, "invalidos": 2000},
    {"region": "Arequipa", "validos": 20000, "invalidos": 1500},
]

df = pd.DataFrame(data)

# =========================
# KPIs
# =========================
col1, col2, col3 = st.columns(3)

col1.metric("Total votos", int(df["validos"].sum()))
col2.metric("Regiones", len(df))
col3.metric("Promedio", f"{df['validos'].mean():,.0f}")

# =========================
# GRÁFICO
# =========================
fig = px.bar(df, x="region", y="validos", color="validos")
st.plotly_chart(fig, use_container_width=True)

# =========================
# DETALLE
# =========================
region = st.selectbox("Selecciona región", df["region"])
r = df[df["region"] == region]

st.metric("Válidos", int(r["validos"].values[0]))
st.metric("Inválidos", int(r["invalidos"].values[0]))