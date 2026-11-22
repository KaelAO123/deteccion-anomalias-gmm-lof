# ============================================================
# 00_main.R — Pipeline maestro
# Ejecuta secuencialmente todas las fases del proyecto.
# ============================================================

# --- Configuración global ---
set.seed(2025)
options(stringsAsFactors = FALSE)

# --- Rutas ---
ruta_data_raw <- "data/raw"
ruta_data_processed <- "data/processed"
ruta_output_fig <- "output/figures"
ruta_output_tab <- "output/tables"
ruta_output_mod <- "output/models"

# Crear carpetas si no existen
for (d in c(ruta_data_processed, ruta_output_fig, ruta_output_tab, ruta_output_mod)) {
    if (!dir.exists(d)) dir.create(d, recursive = TRUE)
}

# --- Ejecutar fases en orden ---
# source("script/01_convertir_csv.R")   # solo si parte del .sav
# source("script/02_exploracion.R")     # Fase 3
# source("script/03_preprocesamiento.R")# Fase 4
# source("script/04_gmm.R")             # Fase 6
# source("script/05_lof.R")             # Fase 7
# source("script/06_evaluacion.R")      # Fase 8

cat("Pipeline configurado. Descomenta las fases a medida que se completen.\n")
