@st.cache_data(ttl=30)
def load_data():
    try:
        import requests

        url = "https://renzonunezaf.github.io/Elecciones_2026/"

        res = requests.get(url, timeout=10)

        html = res.text

        # PARSEO SIMPLE (REAL)
        rows = []

        # buscamos patrones tipo tabla
        import re

        pattern = re.findall(
            r"<tr>(.*?)</tr>",
            html,
            re.DOTALL
        )

        for row in pattern:
            cols = re.findall(r"<td>(.*?)</td>", row)

            if len(cols) >= 3:
                rows.append({
                    "region": cols[0].strip(),
                    "candidato": cols[1].strip(),
                    "votos": int(cols[2].replace(",", "").strip())
                })

        df = pd.DataFrame(rows)

        return df

    except Exception as e:
        st.error(f"Error real cargando datos: {e}")
        return pd.DataFrame()