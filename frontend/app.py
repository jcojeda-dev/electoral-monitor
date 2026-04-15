import streamlit as st
import pandas as pd
import plotly.express as px
import requests
import time

st.set_page_config(layout="wide")

# =========================
# CONFIG
# =========================
DATA_URL = "https://renzonunezaf.github.io/Elecciones_2026/"
REFRESH = 30  # segundos

# =========================
# AUTO REFRESH
# =========================
if "last_update" not in st.session_state:
    st.session_state.last_update = time.time()

if time.time() - st.session_state.last_update > REFRESH:
    st.session_state.last_update = time.time()
    st.rerun()

# =========================
# LOAD REAL DATA (HTML TABLE)
# =========================
@st.cache_data(ttl=30)
def load_data():
    try:
        tables = pd.read_html(DATA_URL)
        df = tables[0]  # primera tabla

        df.columns = [c.lower() for c in df.columns]

        # normalizar nombres esperados
        df = df.rename(columns={
            "región": "region",
            "candidato": "candidato",
            "votos": "votos"
        })

        df["votos"] = pd.to_numeric(df["votos"], errors="coerce").fillna(0)

        return df

    except Exception as e:
        st.error(f"Error cargando datos reales: {e}")
        return pd.DataFrame()

df = load_data()

if df.empty:
    st.error("No se pudo cargar la data")
    st.stop()

# =========================
# HEADER
# =========================
st.title("📊 Monitor Electoral Perú 🔴 EN VIVO")

# =========================
# FILTROS
# =========================
st.sidebar.header("Filtros")

regiones = st.sidebar.multiselect(
    "Selecciona región",
    options=df["region"].unique(),
    default=df["region"].unique()
)

candidatos = st.sidebar.multiselect(
    "Selecciona candidato",
    options=df["candidato"].unique(),
    default=df["candidato"].unique()
)

df = df[
    (df["region"].isin(regiones)) &
    (df["candidato"].isin(candidatos))
]

# =========================
# KPIs
# =========================
total_votos = df["votos"].sum()

c1, c2 = st.columns(2)
c1.metric("Total votos", f"{total_votos:,.0f}")
c2.metric("Regiones", df["region"].nunique())

# =========================
# RESULTADO NACIONAL
# =========================
st.subheader("Resultados nacionales")

resumen = df.groupby("candidato")["votos"].sum().reset_index()
resumen["%"] = resumen["votos"] / resumen["votos"].sum() * 100
resumen = resumen.sort_values("votos", ascending=False)

fig = px.bar(
    resumen,
    x="candidato",
    y="%",
    text=resumen["%"].map(lambda x: f"{x:.2f}%")
)

fig.update_traces(textposition="outside")

st.plotly_chart(fig, use_container_width=True)

# =========================
# GANADOR POR REGIÓN
# =========================
st.subheader("Ganador por región")

df_top = df.sort_values("votos", ascending=False).groupby("region").first().reset_index()

st.dataframe(df_top)

# =========================
# DETALLE
# =========================
st.subheader("Detalle completo")

st.dataframe(df.sort_values(["region", "votos"], ascending=[True, False]))