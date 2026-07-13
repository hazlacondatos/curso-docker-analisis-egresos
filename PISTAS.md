# Pistas progresivas

Cada bug tiene tres pistas, de la más suave a la más explícita. **Abre una a la
vez** (haz clic en el triángulo) y vuelve a intentarlo antes de abrir la
siguiente. La solución completa está en la rama `main`.

El orden de abajo es, más o menos, el orden en que te vas a topar con los
errores al correr `analisis_sql.R`.

---

## Parte 1 — Hacer que funcione

### Bug 1 · La conexión a la base de datos falla

<details>
<summary>Pista 1 — ¿dónde mirar?</summary>

El primer error aparece en `dbConnect(...)`, antes de tocar los datos. Lee el
mensaje completo: menciona un **host** y un puerto. ¿Qué host dice? (Módulo 12.)
</details>

<details>
<summary>Pista 2 — ¿qué está mal?</summary>

Dentro de un contenedor, `localhost` es **ese mismo contenedor**, no la base de
datos. Entre servicios del mismo Compose, el host es el **nombre del servicio**.
¿Cómo se llama el servicio de la base en `compose.yaml`?
</details>

<details>
<summary>Pista 3 — el arreglo</summary>

En `analisis_sql.R`, cambia `host = "localhost"` por `host = "db"`.
</details>

### Bug 2 · El script no encuentra el CSV

<details>
<summary>Pista 1 — ¿dónde mirar?</summary>

Ya conectado a la base, el siguiente error es un **"cannot open file"** en
`read_csv(...)`. La ruta que usa el script, ¿existe de verdad dentro del
contenedor? Entra a mirar: `docker compose exec rstudio bash` y `ls /home/rstudio`.
(Preguntas 3 y 4 del método.)
</details>

<details>
<summary>Pista 2 — ¿qué está mal?</summary>

El script lee de `/home/rstudio/proyecto/...`, pero el proyecto no está montado
ahí. Revisa la clave `volumes:` de `compose.yaml` y compárala con la ruta del
script. `docker inspect` (sección de montajes) también lo delata. (Módulo 8:
montar en la ruta interna equivocada.)
</details>

<details>
<summary>Pista 3 — el arreglo</summary>

En `compose.yaml`, el montaje dice `.:/home/rstudio/trabajo`. Cámbialo a
`.:/home/rstudio/proyecto` para que coincida con la ruta del script, y vuelve a
levantar (`docker compose up -d`).
</details>

### Bug 3 · La consulta SQL falla

<details>
<summary>Pista 1 — ¿dónde mirar?</summary>

Con la conexión y los datos ya OK, `dbGetQuery(...)` revienta con un error de
PostgreSQL. Léelo: habla de una **función que no existe** con ciertos tipos.
¿Es un problema de Docker, o del programa? (Pregunta 5 del método.)
</details>

<details>
<summary>Pista 2 — ¿qué está mal?</summary>

`dias_estada` llega desde R como `double precision`, y el `ROUND(x, 1)` de dos
argumentos **solo existe para `numeric`** en PostgreSQL. Es un clásico. (Módulo 12.)
</details>

<details>
<summary>Pista 3 — el arreglo</summary>

Convierte a `numeric` antes de redondear:
`ROUND(AVG(dias_estada)::numeric, 1)`.
</details>

---

## Parte 2 (reto) — La auditoría de seguridad

<details>
<summary>Pista 1 — ¿dónde mirar?</summary>

Construye la imagen del análisis por lotes (`docker build -t mi-analisis:1.0 .`)
y mírala con `docker history mi-analisis:1.0`, o su tamaño con `docker images`.
Compáralo con lo que esperarías de una imagen que solo lleva código. (Módulos 10 y 13.)
</details>

<details>
<summary>Pista 2 — ¿qué está mal?</summary>

El `Dockerfile` hace `COPY . .` y el `.dockerignore` **no** excluye `datos/`.
Resultado: el CSV de pacientes queda **horneado dentro de la imagen** — y las
capas no olvidan, aunque después lo borres. Con datos reales, eso es una fuga.
</details>

<details>
<summary>Pista 3 — el arreglo</summary>

Dos cambios: en el `Dockerfile`, vuelve a copiar solo lo necesario
(`COPY analisis.R analisis.R` en vez de `COPY . .`); y en `.dockerignore`, agrega
`datos/` (y `resultados/`). Reconstruye y verifica con `docker history` que ya no
aparece. Los datos entran por bind mount **al correr**, nunca por `COPY`.
</details>
