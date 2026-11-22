# ============================================================
# 05_lof.R — Fase 7: Implementación de Local Outlier Factor
# Entrada:  data/processed/matriz_principal.rds
#           data/processed/caracterizacion.rds
# Salidas:  output/models/lof_final.rds
#           output/tables/lof_sensibilidad_k.csv
#           output/tables/lof_detecciones.csv
#           output/figures/lof_sensibilidad_k.png
#           output/figures/lof_distribucion.png
# ============================================================

# --- Librerías ---
if (!requireNamespace("dbscan", quietly = TRUE)) {
  install.packages("dbscan")
}
library(dbscan)
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

# --- 2. Análisis de sensibilidad a k ---
# Para cada k, calcular LOF y registrar:
#  - distribución de LOF (min, mediana, media, max, percentil 95, percentil 99)
#  - proporción de anomalías con percentil 5%
#  - número de anomalías

ks <- c(5, 10, 15, 20, 30, 50)

cat("\nCalculando LOF para k =", paste(ks, collapse = ", "), "...\n")

resultados_k <- map_dfr(ks, function(k) {
  cat("  k =", k, "...\n")
  lof_k <- lof(as.data.frame(X), k = k)

  umbral_k <- quantile(lof_k, probs = 0.95, na.rm = TRUE) # percentil 95 de LOF
  # Nota: para LOF, valores ALTOS son anómalos, así que el "percentil 95"
  # captura el 5% superior.

  tibble(
    k = k,
    lof_min = min(lof_k, na.rm = TRUE),
    lof_mediana = median(lof_k, na.rm = TRUE),
    lof_media = mean(lof_k, na.rm = TRUE),
    lof_p95 = quantile(lof_k, 0.95, na.rm = TRUE),
    lof_p99 = quantile(lof_k, 0.99, na.rm = TRUE),
    lof_max = max(lof_k, na.rm = TRUE),
    umbral_p5 = umbral_k,
    n_anomalias_p5 = sum(lof_k > umbral_k, na.rm = TRUE),
    pct_anomalias_p5 = round(100 * mean(lof_k > umbral_k, na.rm = TRUE), 2)
  )
})

write_csv(resultados_k, file.path(ruta_tablas, "lof_sensibilidad_k.csv"))
cat("\nGuardado: lof_sensibilidad_k.csv\n")
print(as_tibble(resultados_k), n = Inf)

# --- 3. Gráfico de sensibilidad a k ---
p_sens <- resultados_k %>%
  select(k, lof_mediana, lof_p95, lof_p99, lof_max) %>%
  pivot_longer(-k, names_to = "estadistico", values_to = "valor") %>%
  ggplot(aes(x = factor(k), y = valor, color = estadistico, group = estadistico)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  scale_y_log10() +
  labs(
    title = "Sensibilidad de LOF al número de vecinos (k)",
    subtitle = "Escala log10; valores altos de LOF indican mayor atipicidad",
    x = "k (número de vecinos)",
    y = "Valor de LOF (escala log10)",
    color = "Estadístico"
  ) +
  theme_minimal(base_size = 11)

ggsave(file.path(ruta_figuras, "lof_sensibilidad_k.png"), p_sens,
  width = 9, height = 5, dpi = 150
)

# --- 4. Selección del k óptimo ---
# Criterios:
#  (a) Estabilidad: LOF no debe cambiar drásticamente entre k adyacentes.
#  (b) Proporción de anomalías: el percentil 95 de LOF debe capturar ~5%.
#  (c) Consistencia: la mediana de LOF debe ser estable.
#
# Como LOF no tiene un "mejor k" universal, se elige el k que:
#  - Produce una distribución de LOF más estable (menor cambio en p95 y p99).
#  - Tiene una proporción de anomalías cercana al 5% (por construcción del percentil).

# Calcular la diferencia relativa de p95 entre k adyacentes
resultados_k <- resultados_k %>%
  mutate(
    delta_p95 = c(NA, abs(diff(lof_p95)) / head(lof_p95, -1) * 100),
    delta_p99 = c(NA, abs(diff(lof_p99)) / head(lof_p99, -1) * 100)
  )

cat("\n=== Estabilidad de p95 y p99 entre k adyacentes ===\n")
print(resultados_k %>% select(k, lof_p95, delta_p95, lof_p99, delta_p99), n = Inf)

# Criterio: elegir el k con menor delta_p95 (más estable) entre k >= 10
k_optimo <- resultados_k %>%
  filter(k >= 10) %>%
  arrange(delta_p95) %>%
  slice(1) %>%
  pull(k)

cat("\n=== k óptimo seleccionado ===\n")
cat("k =", k_optimo, "\n")
cat(
  "Justificación: menor cambio relativo en p95 entre k adyacentes (",
  round(resultados_k$delta_p95[resultados_k$k == k_optimo], 2), "%).\n"
)

# --- 5. LOF final con k óptimo ---
cat("\nCalculando LOF final con k =", k_optimo, "...\n")
lof_final <- lof(as.data.frame(X), k = k_optimo)

# Guardar modelo LOF (en realidad es un vector de puntuaciones)
saveRDS(
  list(k = k_optimo, lof = lof_final),
  file.path(ruta_modelos, "lof_final.rds")
)

# --- 6. Umbrales de anomalía para LOF ---
# Para LOF, valores ALTOS son anómalos. El "percentil 5%" de anomalías
# corresponde al percentil 95 de LOF.
umbral_lof_p5 <- quantile(lof_final, 0.95, na.rm = TRUE)
umbral_lof_mad <- median(lof_final, na.rm = TRUE) + 3 * mad(lof_final, na.rm = TRUE)
umbral_lof_tukey <- quantile(lof_final, 0.75, na.rm = TRUE) +
  1.5 * IQR(lof_final, na.rm = TRUE)

cat("\n=== Umbrales de anomalía LOF (k =", k_optimo, ") ===\n")
cat("Percentil 95 (5% superior):", round(umbral_lof_p5, 4), "\n")
cat("MAD (mediana + 3 MAD):", round(umbral_lof_mad, 4), "\n")
cat("Tukey (Q3 + 1.5 IQR):", round(umbral_lof_tukey, 4), "\n")

# --- 7. Detecciones con cada criterio ---
detecciones_lof <- tibble(
  folio          = caract$folio,
  lof            = lof_final,
  anomalo_p5     = lof_final > umbral_lof_p5,
  anomalo_mad    = lof_final > umbral_lof_mad,
  anomalo_tukey  = lof_final > umbral_lof_tukey
) %>%
  left_join(caract, by = "folio")

cat("\n=== Proporción de anomalías por criterio (LOF) ===\n")
cat(
  "Percentil 95 (5%):", round(100 * mean(detecciones_lof$anomalo_p5), 2),
  "% (", sum(detecciones_lof$anomalo_p5), "hogares)\n"
)
cat(
  "MAD (3 MAD):", round(100 * mean(detecciones_lof$anomalo_mad), 2),
  "% (", sum(detecciones_lof$anomalo_mad), "hogares)\n"
)
cat(
  "Tukey:", round(100 * mean(detecciones_lof$anomalo_tukey), 2),
  "% (", sum(detecciones_lof$anomalo_tukey), "hogares)\n"
)

# --- 8. Distribución de LOF con umbrales ---
p_lof <- ggplot(detecciones_lof, aes(x = lof)) +
  geom_histogram(bins = 80, fill = "steelblue", color = "white", alpha = 0.7) +
  geom_vline(
    xintercept = umbral_lof_p5, color = "firebrick",
    linetype = "dashed", linewidth = 1
  ) +
  geom_vline(
    xintercept = umbral_lof_mad, color = "darkorange",
    linetype = "dotted", linewidth = 1
  ) +
  geom_vline(
    xintercept = umbral_lof_tukey, color = "purple",
    linetype = "dotdash", linewidth = 1
  ) +
  scale_x_log10() +
  labs(
    title = paste0("Distribución de LOF (k = ", k_optimo, ")"),
    subtitle = "Rojo: percentil 95 | Naranja: mediana + 3 MAD | Púrpura: Q3 + 1.5 IQR",
    x = "LOF (escala log10)", y = "Frecuencia"
  ) +
  theme_minimal(base_size = 11)

ggsave(file.path(ruta_figuras, "lof_distribucion.png"), p_lof,
  width = 8, height = 5, dpi = 150
)

# --- 9. Guardar detecciones ---
write_csv(detecciones_lof, file.path(ruta_tablas, "lof_detecciones.csv"))

cat("\n=== Archivos guardados ===\n")
cat("  output/models/lof_final.rds\n")
cat("  output/tables/lof_sensibilidad_k.csv\n")
cat("  output/tables/lof_detecciones.csv\n")
cat("  output/figures/lof_sensibilidad_k.png\n")
cat("  output/figures/lof_distribucion.png\n")

cat("\n=== Fase 7 completada ===\n")
