@st.cache_data(ttl=30)
def load_data():
    try:
        url = "https://raw.githubusercontent.com/itamarRtec/analisis1/main/data/archivo.json"

        res = requests.get(url, timeout=10)
        data = res.json()

        df = pd.DataFrame(data)

        return df

    except Exception as e:
        st.error(f"Error cargando data real: {e}")
        return pd.DataFrame()