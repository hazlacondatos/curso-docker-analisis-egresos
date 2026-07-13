# Análisis por lotes: estadía promedio por servicio.
# Es el script que la imagen de Docker "hornea" y ejecuta (ver Dockerfile).
# Lee datos/, escribe resultados/. No usa base de datos (eso es analisis_sql.R).

# suppress... y show_col_types silencian mensajes informativos:
# en un análisis por lotes, el log queda limpio.
suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
})

pacientes <- read_csv("datos/pacientes.csv", show_col_types = FALSE)

estada_por_servicio <- pacientes |>
  group_by(servicio) |>
  summarise(
    egresos = n(),
    promedio_dias_estada = round(mean(dias_estada), 1)
  ) |>
  arrange(desc(promedio_dias_estada))

write_csv(estada_por_servicio, "resultados/estada_por_servicio.csv")

cat("Listo: resultados/estada_por_servicio.csv\n")
