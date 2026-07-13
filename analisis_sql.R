# Análisis interactivo contra PostgreSQL.
# ── Ejecuta esto DENTRO de RStudio Server (docker compose up), NO en la imagen ──
# La imagen por lotes (Dockerfile + analisis.R) no incluye estos paquetes ni la
# base de datos: el host "db" solo existe dentro de la red del compose.

# La imagen rocker/rstudio no trae estos paquetes: se instalan aquí, en el
# contenedor, y se pierden cuando lo borras (así funciona; es la lección del Módulo 8).
install.packages(c("DBI", "RPostgres"))

suppressPackageStartupMessages({
  library(DBI)
  library(readr)
})

con <- dbConnect(
  RPostgres::Postgres(),
  host = "localhost",
  port = 5432,
  dbname = "pacientes",
  user = "postgres",
  password = Sys.getenv("POSTGRES_PASSWORD")  # llega desde el compose.yaml
)

# El CSV del proyecto pasa a ser una tabla de la base
pacientes <- read_csv("/home/rstudio/proyecto/datos/pacientes.csv", show_col_types = FALSE)
dbWriteTable(con, "pacientes", pacientes, overwrite = TRUE)

dbGetQuery(con, "
  SELECT servicio,
         COUNT(*) AS egresos,
         ROUND(AVG(dias_estada), 1) AS estada_promedio
  FROM pacientes
  GROUP BY servicio
  ORDER BY estada_promedio DESC
")

dbDisconnect(con)
