# ============================================================
# 04_gmm.R — Fase 6: Implementación de GMM
# Entrada:  data/processed/matriz_principal.rds
#           data/processed/caracterizacion.rds
# Salidas:  output/models/gmm_final.rds
#           output/tables/gmm_bic.csv
#           output/tables/gmm_detecciones.csv
#           output/figures/gmm_bic.png
#           output/figures/gmm_logdens.png
# ============================================================

if (!requireNamespace("mclust", quietly = TRUE)) {
    install.packages("mclust")
}
library(mclust)
library(tidyverse)

set.seed(2025)

# --- Rutas ---
ruta_matriz <- "data/processed/matriz_principal.rds"
ruta_caract <- "data/processed/caracterizacion.rds"
ruta_modelos <- "output/models"
ruta_tablas <- "output/tables"
ruta_figuras <- "output/figures"

for (d in c(ruta_modelos, ruta_tablas, ruta_figuras)) {
    if (!dir.exists(d)) dir.create(d, recursive = TRUE)
}

# --- 1. Cargar datos ---
X <- readRDS(ruta_matriz)
caract <- readRDS(ruta_caract)
stopifnot(nrow(X) == nrow(caract))

cat("Matriz de entrada:", nrow(X), "x", ncol(X), "\n")

# --- 2. Ajustar GMM con todas las estructuras por defecto ---
# mclust explora automáticamente el número de componentes y las estructuras
# de covarianza disponibles para datos multivariados.

cat("\nAjustando GMM (esto puede tardar unos minutos)...\n")
gmm <- Mclust(
    X,
    G = 1:15,
    modelNames = c(
        "EII", "VII", "EEI", "VEI", "EVI", "VVI", "EEE",
        "VEE", "EVE", "VVE", "EEV", "VEV", "EVV", "VVV"
    ),
    verbose = FALSE
)

cat("\n=== Resumen del modelo seleccionado ===\n")
print(summary(gmm))

cat("\nMejor modelo según BIC:\n")
cat("  Número de componentes:", gmm$G, "\n")
cat("  Estructura de covarianza:", gmm$modelName, "\n")
cat("  BIC:", round(gmm$bic, 2), "\n")
cat("  Log-verosimilitud:", round(gmm$loglik, 2), "\n")

# ============================================================
# BLOQUE 3 (CORREGIDO v2) — Tabla BIC de modelos comparables
# ============================================================
# VVV con G=13 no converge con 22 dimensiones (3.587 parámetros).
# Se reemplaza por EEE, que es estable y representativa de la familia
# de covarianzas restringidas.

cat("\n=== Reajustando modelos comparables con G = 13 ===\n")

set.seed(2025)
cat("  Ajustando VEV (G=13)...\n")
gmm_vev <- Mclust(X, G = 13, modelNames = "VEV", verbose = FALSE)

set.seed(2025)
cat("  Ajustando EII (G=13)...\n")
gmm_eii <- Mclust(X, G = 13, modelNames = "EII", verbose = FALSE)

set.seed(2025)
cat("  Ajustando EEE (G=13)...\n")
gmm_eee <- Mclust(X, G = 13, modelNames = "EEE", verbose = FALSE)

# Extracción defensiva del BIC (maneja NULL, vector, escalar)
extraer_bic <- function(modelo, nombre) {
    b <- modelo$bic
    if (is.null(b) || length(b) == 0) {
        cat("  ADVERTENCIA:", nombre, "no convergió (bic = NULL).\n")
        return(NA_real_)
    }
    if (length(b) > 1) {
        cat(
            "  Aviso:", nombre, "tiene bic de longitud", length(b),
            "; se usa el primer elemento.\n"
        )
        b <- b[1]
    }
    as.numeric(b)
}

bic_vev <- extraer_bic(gmm_vev, "VEV")
bic_eii <- extraer_bic(gmm_eii, "EII")
bic_eee <- extraer_bic(gmm_eee, "EEE")

cat("\nBIC extraídos:\n")
cat("  VEV:", bic_vev, "\n")
cat("  EII:", bic_eii, "\n")
cat("  EEE:", bic_eee, "\n")

# Verificar que al menos dos modelos convergieron
n_convergen <- sum(!is.na(c(bic_vev, bic_eii, bic_eee)))
if (n_convergen < 2) {
    stop("Menos de 2 modelos convergieron. Revisar configuración de mclust.")
}

# Tabla comparativa (con posible NA para modelos no convergentes)
bic_tabla <- tibble(
    modelo       = c("VEV", "EII", "EEE"),
    G            = 13,
    BIC          = c(bic_vev, bic_eii, bic_eee),
    loglik       = c(gmm_vev$loglik, gmm_eii$loglik, gmm_eee$loglik),
    df           = c(gmm_vev$df, gmm_eii$df, gmm_eee$df),
    seleccionado = c(TRUE, FALSE, FALSE)
) %>%
    arrange(desc(is.na(BIC)), BIC) # NA al final, luego ordenar por BIC

cat("\n=== Tabla BIC comparativa (G = 13) ===\n")
print(as_tibble(bic_tabla), n = Inf)

write_csv(bic_tabla, file.path(ruta_tablas, "gmm_bic.csv"))
cat("\nGuardado: gmm_bic.csv\n")

# --- 4. Gráfico BIC vs. número de componentes ---
p_bic <- ggplot(bic_tabla, aes(x = G, y = BIC)) +
    geom_line(color = "steelblue", linewidth = 1) +
    geom_point(color = "steelblue", size = 2) +
    geom_point(
        data = bic_tabla %>% filter(G == gmm$G, modelo == gmm$modelName),
        color = "firebrick", size = 4, shape = 18
    ) +
    labs(
        title = "Selección del número de componentes GMM",
        subtitle = paste0(
            "Modelo seleccionado: G = ", gmm$G,
            " (", gmm$modelName, ")"
        ),
        x = "Número de componentes (G)",
        y = "BIC (menor es mejor)"
    ) +
    theme_minimal(base_size = 11)

ggsave(file.path(ruta_figuras, "gmm_bic.png"), p_bic,
    width = 8, height = 5, dpi = 150
)


# --- 5. Densidad logarítmica por observación ---
# logdens: log de la densidad estimada bajo el GMM ajustado
logdens <- dens(
    modelName  = gmm$modelName,
    data       = as.data.frame(X),
    parameters = gmm$parameters,
    logarithm  = TRUE
)

# Verificación inmediata
stopifnot(
    is.numeric(logdens),
    length(logdens) == nrow(X),
    sum(is.na(logdens)) == 0
)

cat("\nResumen de log-densidad:\n")
print(summary(logdens))
# --- 6. Umbrales de anomalía ---
# Criterio principal: percentil 5%
umbral_p5 <- quantile(logdens, probs = 0.05, na.rm = TRUE)

# Criterios alternativos para sensibilidad (se usan en Fase 8)
# MAD sobre logdens
mediana_logdens <- median(logdens, na.rm = TRUE)
mad_logdens <- mad(logdens, na.rm = TRUE)
umbral_mad <- mediana_logdens - 3 * mad_logdens # 3 MAD (aprox. 99.7% si normal)

# Tukey (IQR)
q1 <- quantile(logdens, 0.25, na.rm = TRUE)
q3 <- quantile(logdens, 0.75, na.rm = TRUE)
iqr_logdens <- q3 - q1
umbral_tukey <- q1 - 1.5 * iqr_logdens

cat("\n=== Umbrales de anomalía ===\n")
cat("Percentil 5%:", round(umbral_p5, 4), "\n")
cat("MAD (3 MAD):", round(umbral_mad, 4), "\n")
cat("Tukey (Q1 - 1.5 IQR):", round(umbral_tukey, 4), "\n")

# --- 7. Detecciones con cada criterio ---
# --- Diagnóstico defensivo ---
cat("class(logdens):", class(logdens), "\n")
cat("length(logdens):", length(logdens), "\n")
cat("nrow(X):", nrow(X), "\n")
cat("sum(is.na(logdens)):", sum(is.na(logdens)), "\n")
cat("summary(logdens):\n")
print(summary(logdens))
detecciones <- tibble(
    folio         = caract$folio,
    logdens       = logdens,
    anomalo_p5    = logdens < umbral_p5,
    anomalo_mad   = logdens < umbral_mad,
    anomalo_tukey = logdens < umbral_tukey
) %>%
    left_join(caract, by = "folio")

cat("\n=== Proporción de anomalías por criterio ===\n")
cat(
    "Percentil 5%:", round(100 * mean(detecciones$anomalo_p5), 2), "% (",
    sum(detecciones$anomalo_p5), "hogares)\n"
)
cat(
    "MAD (3 MAD):", round(100 * mean(detecciones$anomalo_mad), 2), "% (",
    sum(detecciones$anomalo_mad), "hogares)\n"
)
cat(
    "Tukey:", round(100 * mean(detecciones$anomalo_tukey), 2), "% (",
    sum(detecciones$anomalo_tukey), "hogares)\n"
)

# --- 8. Distribución de log-densidad con umbrales ---
p_logdens <- ggplot(detecciones, aes(x = logdens)) +
    geom_histogram(bins = 80, fill = "steelblue", color = "white", alpha = 0.7) +
    geom_vline(
        xintercept = umbral_p5, color = "firebrick",
        linetype = "dashed", linewidth = 1
    ) +
    geom_vline(
        xintercept = umbral_mad, color = "darkorange",
        linetype = "dotted", linewidth = 1
    ) +
    geom_vline(
        xintercept = umbral_tukey, color = "purple",
        linetype = "dotdash", linewidth = 1
    ) +
    labs(
        title = "Distribución de log-densidad bajo GMM",
        subtitle = "Rojo: percentil 5% | Naranja: 3 MAD | Púrpura: Tukey",
        x = "Log-densidad", y = "Frecuencia"
    ) +
    theme_minimal(base_size = 11)

ggsave(file.path(ruta_figuras, "gmm_logdens.png"), p_logdens,
    width = 8, height = 5, dpi = 150
)

# --- 9. Guardar modelo y detecciones ---
saveRDS(gmm, file.path(ruta_modelos, "gmm_final.rds"))
write_csv(detecciones, file.path(ruta_tablas, "gmm_detecciones.csv"))

cat("\n=== Archivos guardados ===\n")
cat("  output/models/gmm_final.rds\n")
cat("  output/tables/gmm_bic.csv\n")
cat("  output/tables/gmm_detecciones.csv\n")
cat("  output/figures/gmm_bic.png\n")
cat("  output/figures/gmm_logdens.png\n")

cat("\n=== Fase 6 completada ===\n")


cat("class(gmm$BIC):", class(gmm$BIC), "\n")
cat("dim(gmm$BIC):", dim(gmm$BIC), "\n")
cat("names(gmm$BIC):", names(gmm$BIC), "\n")
cat("str(gmm$BIC):\n")
str(gmm$BIC)
