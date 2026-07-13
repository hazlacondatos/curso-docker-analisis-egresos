# 🐛 Versión EJERCICIO — este proyecto está roto a propósito

> Estás en la rama **`ejercicio`** del proyecto de ejemplo del curso
> **Docker para Ciencia de Datos** de [Hazla con Datos](https://hazlacondatos.com).
> Aquí **nada funciona a la primera**: es a propósito. Tu misión es arreglarlo
> usando el método de diagnóstico del **Módulo 15**.
>
> ¿Quieres la versión que sí funciona (la solución)? Está en la rama **`main`**.

## La misión, en dos partes

**Parte 1 — Haz que el análisis con base de datos funcione.**
Hay **varios errores** que impiden correr `analisis_sql.R` dentro de RStudio
Server. No están señalados: los vas a descubrir corriendo el código y **leyendo
lo que Docker y R te dicen**. Cuando termines, la consulta SQL debe devolver una
fila por servicio con su estadía promedio.

**Parte 2 (reto) — Audita la seguridad.**
Hay **un problema que no rompe nada**, pero que jamás debería estar en un
proyecto con datos. Encuéntralo pasando el **checklist de seguridad del
Módulo 13** sobre la imagen. Pista de partida: `docker history` y el tamaño de
la imagen tienen algo que contarte.

## El método (Módulo 15): cinco preguntas, en orden

1. **¿El contenedor está corriendo?** → `docker compose ps` / `docker ps -a`
2. **¿Qué dijo antes de fallar?** → `docker compose logs` / el error en la consola de R
3. **¿Cómo se ve por dentro?** → `docker compose exec rstudio bash`, y mira las rutas
4. **¿Está configurado como crees?** → `docker inspect`, la sección de los montajes
5. **¿El problema es de Docker o del programa?** → reproduce el fallo a mano

Casi todos los errores de este ejercicio se resuelven en las preguntas 2, 3 y 4.

## Cómo ponerlo en marcha

Requisitos: **Docker Desktop** corriendo (macOS o Windows con WSL2). Nada más.

```bash
cp .env.example .env
docker compose up -d
```

Abre **http://localhost:8787** (usuario `rstudio`, la clave de tu `.env`), abre
`analisis_sql.R` y ejecútalo línea por línea. Ahí empieza la cacería.

> 💡 ¿Te atascas? Hay pistas **progresivas** (de suaves a explícitas) en
> [`PISTAS.md`](PISTAS.md). Úsalas solo cuando de verdad lo necesites: pelear el
> error un rato es donde está el aprendizaje.

## La solución

Cuando quieras comparar, la versión correcta es la rama **`main`** de este mismo
repo:

```bash
git checkout main
```

o revisa el `diff` para ver exactamente qué cambiaba:

```bash
git diff ejercicio main
```

> ⚠️ **Sobre los datos.** `datos/pacientes.csv` es **100% sintético** (inventado).
> Por eso está en el repo. En un proyecto real con datos de personas, `datos/`
> va en `.gitignore` y nunca se sube — justo lo que audita la Parte 2.
