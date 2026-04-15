import streamlit as st
import pandas as pd
import plotly.express as px
import requests
import json
import time

st.set_page_config(layout="wide")

# =========================
# LIVE MODE
# =========================
if "last_update" not in st.session_state:
    st.session_state.last_update = time.time()

if time.time() - st.session_state.last_update > 10:
    st.session_state.last_update = time.time()
    st.rerun()

# =========================
# FETCH DATA (API)
# =========================
@st.cache_data(ttl=10)
def fetch_data():
    try:
        res = requests.get("https://electoral-monitor.onrender.com/onpe", timeout=5)
        data = res.json()

        if data["status"] == "ok":
            return pd.DataFrame(data["data"])

    except Exception as e:
        st.warning(f"Error API: {e}")

    return pd.DataFrame()

df = fetch_data()

if df.empty:
    st.error("No hay datos disponibles")
    st.stop()

# =========================
# HEADER
# =========================
st.title("📊 Monitor Electoral Perú 🔴 EN VIVO")

# =========================
# KPI
# =========================
top = df["ganador"].value_counts().idxmax()
st.success(f"🏆 Líder nacional: {top}")

# =========================
# MAPA
# =========================
st.subheader("🗺️ Mapa electoral por candidato")

try:
    with open("frontend/assets/peru.geojson") as f:
        geo = json.load(f)

    fig_map = px.choropleth(
        df,
        geojson=geo,
        locations="region",
        featureidkey="properties.name",
        color="ganador",
        color_discrete_map={
            "Keiko": "#f57c00",
            "Castillo": "#c62828"
        }
    )

    fig_map.update_geos(fitbounds="locations", visible=False)

    st.plotly_chart(fig_map, use_container_width=True)

except:
    st.warning("Mapa no disponible")

# =========================
# LIVE EVENTS
# =========================
if "prev_df" not in st.session_state:
    st.session_state.prev_df = df.copy()

prev_df = st.session_state.prev_df
events = []

if not prev_df.empty:
    prev_top = prev_df["ganador"].value_counts().idxmax()
    new_top = df["ganador"].value_counts().idxmax()

    if prev_top != new_top:
        events.append(f"🚨 Nuevo líder nacional: {new_top}")

# =========================
# TICKER
# =========================
st.markdown("### 🔴 EN VIVO")

ticker = " | ".join(events) if events else "Actualizando resultados..."

st.markdown(f"""
<div style="background:black;color:white;padding:10px;">
{ticker}
</div>
""", unsafe_allow_html=True)

# =========================
# TABLA DETALLE
# =========================
st.subheader("Resultados por región")

st.dataframe(df)

# =========================
# GUARDAR ESTADO
# =========================
st.session_state.prev_df = df.copy()

c1.metric("Total votos", f"{df['votos'].sum():,}")

c1, c2 = st.columns(2)

c1.metric("Total votos (ganadores)", f"{df['votos'].sum():,}")
c2.metric("Regiones reportadas", len(df))

df["votos"]