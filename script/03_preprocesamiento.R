# ============================================================
# 03_preprocesamiento.R — Fase 4
# Preprocesamiento y selección de variables para GMM y LOF
# Entrada:  data/raw/EH2025_Gastos_No_Alimentarios.csv
# Salidas:  data/processed/
#   - matriz_principal.rds      (log1p + z-score, 22 vars)
#   - matriz_sensibilidad.rds   (solo z-score, 22 vars)
#   - caracterizacion.rds       (folio, depto, area, estrato, factor, total)
#   - fase4_diagnostico.csv     (asimetría antes/después, medias, sd)
# ============================================================

library(tidyverse)

set.seed(2025)

# --- Rutas ---
ruta_csv <- "data/raw/EH2025_Gastos_No_Alimentarios.csv"
ruta_processed <- "data/processed"
if (!dir.exists(ruta_processed)) dir.create(ruta_processed, recursive = TRUE)

# --- 1. Lectura ---
datos <- read_csv(ruta_csv, show_col_types = FALSE)

# --- 2. Definir variables ---
vars_mensuales_todas <- sprintf("s08b_10_%02d", 1:28)

# Variables excluidas por pct_cero > 95% (decisión Fase 4)
vars_excluidas <- c(
    "s08b_10_22", # guarderías (99.32%)
    "s08b_10_05", # CD/DVD (98.47%)
    "s08b_10_09", # servicio doméstico (97.56%)
    "s08b_10_21", # transferencias (97.06%)
    "s08b_10_03", # periódicos/libros (96.49%)
    "s08b_10_28" # telefonía fija (96.02%)
)

vars_mensuales <- setdiff(vars_mensuales_todas, vars_excluidas)
stopifnot(length(vars_mensuales) == 22)

cat("Variables retenidas (", length(vars_mensuales), "):\n", sep = "")
print(vars_mensuales)

# --- 3. Subconjunto y exclusión de hogares con gasto total = 0 ---
datos_mensual <- datos %>%
    select(folio, depto, area, upm, estrato, factor, all_of(vars_mensuales)) %>%
    mutate(total_mensual = rowSums(across(all_of(vars_mensuales)), na.rm = TRUE))

n_inicial <- nrow(datos_mensual)
datos_filtrado <- datos_mensual %>% filter(total_mensual > 0)
n_final <- nrow(datos_filtrado)

cat("\nHogares iniciales:      ", n_inicial, "\n")
cat("Hogares excluidos (=0): ", n_inicial - n_final, "\n")
cat("Hogares retenidos:      ", n_final, "\n")

# --- 4. Dataset de caracterización (para Fase 8) ---
caracterizacion <- datos_filtrado %>%
    select(folio, depto, area, upm, estrato, factor, total_mensual)

saveRDS(caracterizacion, file.path(ruta_processed, "caracterizacion.rds"))
cat("\nGuardado: caracterizacion.rds (", nrow(caracterizacion), " filas )\n", sep = "")

# --- 5. Matriz principal: log1p + z-score ---
matriz_log <- datos_filtrado %>%
    select(all_of(vars_mensuales)) %>%
    mutate(across(everything(), ~ log1p(.x)))

matriz_principal <- scale(matriz_log) # z-score (media 0, sd 1)

# Convertir a data.frame para guardar
matriz_principal_df <- as.data.frame(matriz_principal)
saveRDS(matriz_principal_df, file.path(ruta_processed, "matriz_principal.rds"))
cat("Guardado: matriz_principal.rds (", nrow(matriz_principal_df),
    " x ", ncol(matriz_principal_df), " )\n",
    sep = ""
)

# --- 6. Matriz de sensibilidad: solo z-score (sin log1p) ---
matriz_cruda <- datos_filtrado %>%
    select(all_of(vars_mensuales))

matriz_sensibilidad <- scale(matriz_cruda)
matriz_sensibilidad_df <- as.data.frame(matriz_sensibilidad)
saveRDS(matriz_sensibilidad_df, file.path(ruta_processed, "matriz_sensibilidad.rds"))
cat("Guardado: matriz_sensibilidad.rds (", nrow(matriz_sensibilidad_df),
    " x ", ncol(matriz_sensibilidad_df), " )\n",
    sep = ""
)

# --- 7. Verificación de integridad ---
verificar <- function(m, nombre) {
    n_na <- sum(is.na(m))
    n_inf <- sum(is.infinite(m))
    n_nan <- sum(is.nan(m))
    cat("\n[", nombre, "]\n", sep = "")
    cat("  NA:  ", n_na, "\n")
    cat("  Inf: ", n_inf, "\n")
    cat("  NaN: ", n_nan, "\n")
    if (n_na + n_inf + n_nan > 0) {
        stop("¡Integridad comprometida en ", nombre, "!")
    }
    cat("  ✓ Integridad OK\n")
}

verificar(matriz_principal, "matriz_principal")
verificar(matriz_sensibilidad, "matriz_sensibilidad")

# --- 8. Diagnóstico de la transformación (asimetría antes/después) ---
matriz_cruda_df        <- as.data.frame(matriz_cruda)
matriz_log_df          <- as.data.frame(matriz_log)
matriz_sensibilidad_df <- as.data.frame(matriz_sensibilidad)
# matriz_principal_df ya existe (creado en el bloque 5)

diag_asimetria <- tibble(
  variable      = vars_mensuales,
  asim_cruda    = sapply(matriz_cruda_df,        e1071::skewness),
  asim_log1p    = sapply(matriz_log_df,          e1071::skewness),
  asim_z_crudo  = sapply(matriz_sensibilidad_df, e1071::skewness),
  asim_z_log1p  = sapply(matriz_principal_df,    e1071::skewness),
  media_cruda   = sapply(matriz_cruda_df,        mean),
  media_z_log1p = sapply(matriz_principal_df,    mean),
  sd_cruda      = sapply(matriz_cruda_df,        sd),
  sd_z_log1p    = sapply(matriz_principal_df,    sd)
) %>%
  mutate(
    reduccion_asim = round(100 * (asim_cruda - asim_log1p) / abs(asim_cruda), 1)
  )

write_csv(diag_asimetria, file.path(ruta_processed, "fase4_diagnostico.csv"))
cat("\nGuardado: fase4_diagnostico.csv\n")
cat("\nDiagnóstico de asimetría (primeras 10 variables):\n")
print(
  head(diag_asimetria %>%
         select(variable, asim_cruda, asim_log1p, reduccion_asim), 10)
)
# --- 9. Verificación final de escalamiento ---
cat("\n=== Verificación de escalamiento (matriz_principal) ===\n")
cat("Medias (deberían ser ~0):\n")
print(round(colMeans(matriz_principal), 6))
cat("\nDesviaciones (deberían ser ~1):\n")
print(round(apply(matriz_principal, 2, sd), 6))

cat("\n=== Fase 4 completada ===\n")
