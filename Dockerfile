# Imagen reproducible del análisis por lotes (Módulos 9, 10, 13 y 17 del curso).
FROM rocker/r-ver:4.6.1

# Bibliotecas de sistema que necesitan los paquetes de R al compilarse.
RUN apt-get update && apt-get install -y --no-install-recommends \
    libcurl4-openssl-dev libssl-dev libxml2-dev \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /proyecto

# renv restaura los paquetes EXACTOS de renv.lock (versiones congeladas).
RUN R -q -e "install.packages('renv', repos = 'https://cloud.r-project.org')"

# El lock se copia ANTES que el código para aprovechar la caché de capas:
# editar el análisis no reinstala los paquetes.
COPY renv.lock renv.lock
RUN R -q -e "renv::restore()"

COPY . .

# Buenas prácticas de seguridad (Módulo 13): correr como usuario sin privilegios.
RUN useradd --create-home analista && chown -R analista:analista /proyecto
USER analista

CMD ["Rscript", "analisis.R"]
