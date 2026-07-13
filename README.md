# Análisis de egresos — proyecto de ejemplo del curso de Docker

Este es el proyecto que acompaña al curso **Docker para Ciencia de Datos** de
[Hazla con Datos](https://hazlacondatos.com). Es un análisis de egresos
hospitalarios, pequeño y completo, empaquetado con Docker: te sirve para
**clonar, correr y estudiar** cómo encaja todo lo que enseña el curso —
Dockerfile reproducible, Docker Compose, PostgreSQL, `.env`, seguridad — en un
proyecto real.

No necesitas seguir el curso para usarlo, pero rinde el doble si lo llevas en
paralelo: cada archivo de aquí es la "respuesta modelo" de un módulo.

> ⚠️ **Sobre los datos.** El archivo `datos/pacientes.csv` es **100% sintético**:
> pacientes, fechas y diagnósticos inventados. Por eso, y solo por eso, está
> versionado en este repositorio. **En un proyecto real con datos de personas,
> la carpeta `datos/` va en `.gitignore` y nunca se sube a GitHub** (es justo lo
> que enseñan los Módulos 10 y 13). Aquí lo incluimos porque es de mentira y es
> el corazón del ejercicio.

## Requisitos

- **Docker Desktop** instalado y corriendo (macOS, o Windows con WSL2).
- Nada más: ni R, ni Python, ni PostgreSQL en tu máquina. Esa es la gracia.

## Primero: consigue tu `.env`

Las claves no viajan en el repo. Copia la plantilla y ponles el valor que quieras
(son locales y de práctica):

```bash
cp .env.example .env
```

## Dos formas de usar este proyecto

### 1. El análisis reproducible, con un solo comando

Empaqueta el análisis (R + sus paquetes con versión congelada) en una imagen y
lo corre. Los datos entran montados en solo lectura; el resultado vuelve a tu
carpeta `resultados/`.

```bash
docker build -t mi-analisis:1.0 .

docker run --rm \
  -v "$(pwd)/datos":/proyecto/datos:ro \
  -v "$(pwd)/resultados":/proyecto/resultados \
  mi-analisis:1.0
```

Al terminar, mira `resultados/estada_por_servicio.csv`: una fila por servicio con
su estadía promedio. Este es el corazón de la reproducibilidad (Módulos 9 y 10):
cualquier persona con Docker obtiene **exactamente** el mismo resultado, hoy o en
dos años, sin instalar R.

La primera construcción tarda unos minutos (está instalando los paquetes de R);
las siguientes son casi instantáneas gracias a la caché.

### 2. El entorno interactivo con base de datos

Levanta, con un comando, tu entorno de R en el navegador **más** una base de
datos PostgreSQL, conversando entre sí (Módulos 11 y 12):

```bash
docker compose up -d
```

- Abre **http://localhost:8787** — es **RStudio Server**, la interfaz que la
  imagen de rocker sirve en el navegador (tu IDE recomendado sigue siendo
  Positron; esto es solo la ventana del contenedor).
- Usuario `rstudio`, y la clave `RSTUDIO_PASSWORD` que pusiste en tu `.env`.
- Dentro, abre `analisis_sql.R` y ejecútalo: carga el CSV a PostgreSQL y lo
  consulta con SQL. **El host de la base es `db`** (el nombre del servicio),
  nunca `localhost`.

Para apagar todo:

```bash
docker compose down
```

Los datos de la base sobreviven en el volumen `pgdata`. Si además quieres
borrarlos y empezar de cero: `docker compose down -v`.

## Qué hay en el repo

```text
.
├── analisis.R          # Análisis por lotes (lo que hornea la imagen)
├── analisis_sql.R      # Análisis con PostgreSQL (se corre dentro de RStudio Server)
├── Dockerfile          # Imagen reproducible: R + renv + usuario sin privilegios
├── compose.yaml        # Stack RStudio Server + PostgreSQL
├── renv.lock           # Los paquetes de R con su versión exacta
├── .dockerignore       # Lo que NUNCA entra a la imagen (datos, secretos, .git)
├── .env.example        # Plantilla de variables; tu .env real no se versiona
├── datos/
│   └── pacientes.csv   # Datos SINTÉTICOS (por eso sí van en el repo)
└── resultados/         # Salidas del análisis (se generan al correr)
```

## Retos para seguir practicando

El proyecto funciona tal cual; ahora hazlo tuyo. De menos a más:

1. **Otro indicador.** Modifica `analisis.R` para calcular también la edad
   promedio por servicio (o los egresos por sexo). Reconstruye la imagen y corre.
2. **Un gráfico.** Agrega una visualización de la estadía por servicio y guárdala
   en `resultados/` como PNG. Tendrás que sumar `ggplot2` a `renv.lock`.
3. **Otros datos.** Reemplaza `datos/pacientes.csv` por uno tuyo con las mismas
   columnas y comprueba que todo corre igual, **sin tocar la imagen**: el entorno
   queda fijo y los datos entran por fuera.

## El curso

Este proyecto es el capstone del curso **Docker para Ciencia de Datos**. Si
quieres entender *por qué* cada archivo es como es —paso a paso, desde cero—,
el curso lo construye módulo a módulo en
[hazlacondatos.com](https://hazlacondatos.com).
