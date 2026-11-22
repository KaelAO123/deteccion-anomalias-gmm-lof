# ============================================================
# 06_evaluacion.R — Fase 8: Evaluación, comparación e interpretación
# Entrada:  output/tables/gmm_detecciones.csv
#           output/tables/lof_detecciones.csv
#           data/processed/matriz_principal.rds
#           data/processed/matriz_sensibilidad.rds
#           data/processed/caracterizacion.rds
# Salidas:  output/tables/fase8_*.csv
#           output/figures/fase8_*.png
# ============================================================

# --- Librerías ---
library(tidyverse)
library(mclust)
library(dbscan)
library(patchwork)
library(scales)

set.seed(2025)

# --- Rutas ---
ruta_tablas  <- "output/tables"
ruta_figuras <- "output/figures"
ruta_modelos <- "output/models"
ruta_proc    <- "data/processed"

# ============================================================
# SECCIÓN 1 — Comparación principal: GMM vs. LOF
# ============================================================

gmm_det <- read_csv(file.path(ruta_tablas, "gmm_detecciones.csv"),
                    show_col_types = FALSE)
lof_det <- read_csv(file.path(ruta_tablas, "lof_detecciones.csv"),
                    show_col_types = FALSE)

# Unir por folio (ambos tienen 12.631 filas, mismos folios)
comparacion <- gmm_det %>%
  select(folio, logdens, anomalo_gmm = anomalo_p5,
         depto, area, estrato, factor, total_mensual) %>%
  left_join(
    lof_det %>% select(folio, lof, anomalo_lof = anomalo_p5),
    by = "folio"
  )

stopifnot(nrow(comparacion) == 12631)

# Matriz de confusión 2×2
matriz_conf <- table(
  GMM  = comparacion$anomalo_gmm,
  LOF  = comparacion$anomalo_lof
)
cat("\n=== Matriz de confusión GMM vs. LOF ===\n")
print(matriz_conf)

# Categorías de detección
comparacion <- comparacion %>%
  mutate(
    categoria = case_when(
      anomalo_gmm & anomalo_lof  ~ "Ambos",
      anomalo_gmm & !anomalo_lof ~ "Solo GMM",
      !anomalo_gmm & anomalo_lof ~ "Solo LOF",
      TRUE                       ~ "Ninguno"
    ),
    categoria = factor(categoria,
                       levels = c("Ambos", "Solo GMM", "Solo LOF", "Ninguno"))
  )

cat("\n=== Distribución por categoría ===\n")
print(table(comparacion$categoria))

write_csv(as.data.frame.matrix(matriz_conf) %>%
            rownames_to_column("GMM"),
          file.path(ruta_tablas, "fase8_matriz_confusion.csv"))

# ============================================================
# SECCIÓN 2 — Métricas de acuerdo
# ============================================================

# Jaccard = |A ∩ B| / |A ∪ B|
n_ambos   <- sum(comparacion$anomalo_gmm & comparacion$anomalo_lof)
n_solo_gmm <- sum(comparacion$anomalo_gmm & !comparacion$anomalo_lof)
n_solo_lof <- sum(!comparacion$anomalo_gmm & comparacion$anomalo_lof)
n_union   <- sum(comparacion$anomalo_gmm | comparacion$anomalo_lof)

jaccard <- n_ambos / n_union

# Cohen's kappa (manual, sin dependencia de caret)
tab <- table(comparacion$anomalo_gmm, comparacion$anomalo_lof)
n <- sum(tab)
po <- (tab[1,1] + tab[2,2]) / n           # acuerdo observado
pe <- (sum(tab[1,]) * sum(tab[,1]) +
       sum(tab[2,]) * sum(tab[,2])) / n^2  # acuerdo esperado
kappa <- (po - pe) / (1 - pe)

# Coincidencia bruta (intersección / n)
coincidencia_bruta <- n_ambos / n

metricas <- tibble(
  metrica   = c("Jaccard", "Cohen_kappa", "Coincidencia_bruta",
                "n_ambos", "n_solo_gmm", "n_solo_lof", "n_union"),
  valor     = round(c(jaccard, kappa, coincidencia_bruta,
                      n_ambos, n_solo_gmm, n_solo_lof, n_union), 4)
)

cat("\n=== Métricas de acuerdo ===\n")
print(metricas)

write_csv(metricas, file.path(ruta_tablas, "fase8_metricas_acuerdo.csv"))

# ============================================================
# SECCIÓN 3 — Caracterización socioeconómica por categoría
# ============================================================

# Resumen por categoría
caract_categoria <- comparacion %>%
  group_by(categoria) %>%
  summarise(
    n              = n(),
    pct            = round(100 * n() / nrow(comparacion), 2),
    mediana_gasto  = round(median(total_mensual), 1),
    media_gasto    = round(mean(total_mensual), 1),
    p25_gasto      = round(quantile(total_mensual, 0.25), 1),
    p75_gasto      = round(quantile(total_mensual, 0.75), 1),
    pct_urbano     = round(100 * mean(area == 1), 2),
    mediana_factor = round(median(factor), 2),
    .groups = "drop"
  )

cat("\n=== Caracterización por categoría ===\n")
print(as_tibble(caract_categoria), n = Inf)

write_csv(caract_categoria, file.path(ruta_tablas, "fase8_caract_categoria.csv"))

# Distribución por departamento
caract_depto <- comparacion %>%
  group_by(depto, categoria) %>%
  summarise(n = n(), .groups = "drop") %>%
  group_by(depto) %>%
  mutate(pct = round(100 * n / sum(n), 2)) %>%
  ungroup() %>%
  arrange(depto, categoria)

write_csv(caract_depto, file.path(ruta_tablas, "fase8_caract_depto.csv"))

# Distribución por estrato
caract_estrato <- comparacion %>%
  group_by(estrato, categoria) %>%
  summarise(n = n(), .groups = "drop") %>%
  group_by(estrato) %>%
  mutate(pct = round(100 * n / sum(n), 2)) %>%
  ungroup()

write_csv(caract_estrato, file.path(ruta_tablas, "fase8_caract_estrato.csv"))

# ============================================================
# SECCIÓN 4 — Análisis de sensibilidad a umbrales
# ============================================================

# Para GMM: recalcular umbrales en percentiles 1, 5, 10
# Para LOF: recalcular umbrales en percentiles 99, 95, 90 (equivalentes)

logdens <- gmm_det$logdens
lof_vals <- lof_det$lof

percentiles <- c(0.01, 0.05, 0.10)

sensibilidad <- map_dfr(percentiles, function(p) {
  # GMM: anomalía si logdens < percentil p
  umbral_gmm <- quantile(logdens, probs = p, na.rm = TRUE)
  # LOF: anomalía si lof > percentil (1-p)
  umbral_lof <- quantile(lof_vals, probs = 1 - p, na.rm = TRUE)

  a_gmm <- logdens < umbral_gmm
  a_lof <- lof_vals > umbral_lof

  n_ambos_p   <- sum(a_gmm & a_lof)
  n_union_p   <- sum(a_gmm | a_lof)
  jaccard_p   <- ifelse(n_union_p > 0, n_ambos_p / n_union_p, 0)

  tab_p <- table(a_gmm, a_lof)
  n_p <- sum(tab_p)
  po_p <- (tab_p[1,1] + tab_p[2,2]) / n_p
  pe_p <- (sum(tab_p[1,]) * sum(tab_p[,1]) +
           sum(tab_p[2,]) * sum(tab_p[,2])) / n_p^2
  kappa_p <- (po_p - pe_p) / (1 - pe_p)

  tibble(
    percentil       = p,
    umbral_gmm      = round(umbral_gmm, 4),
    umbral_lof      = round(umbral_lof, 4),
    n_anomalias_gmm = sum(a_gmm),
    n_anomalias_lof = sum(a_lof),
    n_ambos         = n_ambos_p,
    n_union         = n_union_p,
    jaccard         = round(jaccard_p, 4),
    kappa           = round(kappa_p, 4)
  )
})

cat("\n=== Sensibilidad a umbrales ===\n")
print(as_tibble(sensibilidad), n = Inf)

write_csv(sensibilidad, file.path(ruta_tablas, "fase8_sensibilidad_umbrales.csv"))

# ============================================================
# SECCIÓN 5 — Comparación con matriz de sensibilidad (sin log1p)
# ============================================================

# Cargar matriz de sensibilidad (solo z-score, sin log1p)
X_sens <- readRDS(file.path(ruta_proc, "matriz_sensibilidad.rds"))

cat("\nAjustando GMM sobre matriz_sensibilidad (sin log1p)...\n")
set.seed(2025)                          # ← añadir
gmm_sens <- Mclust(
  X_sens,
  G = 1:15,
  modelNames = c("EII", "VII", "EEI", "VEI", "EVI", "VVI", "EEE",
                 "VEE", "EVE", "VVE", "EEV", "VEV", "EVV", "VVV"),
  verbose = FALSE
)


logdens_sens <- dens(
  modelName  = gmm_sens$modelName,
  data       = as.data.frame(X_sens),
  parameters = gmm_sens$parameters,
  logarithm  = TRUE
)

umbral_gmm_sens <- quantile(logdens_sens, probs = 0.05, na.rm = TRUE)
a_gmm_sens <- logdens_sens < umbral_gmm_sens

cat("Ajustando LOF sobre matriz_sensibilidad (sin log1p)...\n")
lof_sens <- lof(as.data.frame(X_sens), k = 20)
umbral_lof_sens <- quantile(lof_sens, probs = 0.95, na.rm = TRUE)
a_lof_sens <- lof_sens > umbral_lof_sens

# Comparar detecciones con y sin log1p
comparacion_sens <- tibble(
  folio            = comparacion$folio,
  gmm_principal    = comparacion$anomalo_gmm,
  gmm_sensibilidad = a_gmm_sens,
  lof_principal    = comparacion$anomalo_lof,
  lof_sensibilidad = a_lof_sens
)

sens_gmm <- tibble(
  metodo      = "GMM",
  n_principal = sum(comparacion_sens$gmm_principal),
  n_sens      = sum(comparacion_sens$gmm_sensibilidad),
  n_ambos     = sum(comparacion_sens$gmm_principal & comparacion_sens$gmm_sensibilidad),
  n_union     = sum(comparacion_sens$gmm_principal | comparacion_sens$gmm_sensibilidad),
  jaccard     = round(
    sum(comparacion_sens$gmm_principal & comparacion_sens$gmm_sensibilidad) /
    sum(comparacion_sens$gmm_principal | comparacion_sens$gmm_sensibilidad), 4)
)

sens_lof <- tibble(
  metodo      = "LOF",
  n_principal = sum(comparacion_sens$lof_principal),
  n_sens      = sum(comparacion_sens$lof_sensibilidad),
  n_ambos     = sum(comparacion_sens$lof_principal & comparacion_sens$lof_sensibilidad),
  n_union     = sum(comparacion_sens$lof_principal | comparacion_sens$lof_sensibilidad),
  jaccard     = round(
    sum(comparacion_sens$lof_principal & comparacion_sens$lof_sensibilidad) /
    sum(comparacion_sens$lof_principal | comparacion_sens$lof_sensibilidad), 4)
)

sens_transformacion <- bind_rows(sens_gmm, sens_lof)

cat("\n=== Efecto de log1p en las detecciones ===\n")
print(as_tibble(sens_transformacion), n = Inf)

write_csv(sens_transformacion,
          file.path(ruta_tablas, "fase8_efecto_log1p.csv"))

# ============================================================
# SECCIÓN 6 — Figuras para el documento
# ============================================================

# --- Figura 1: Scatter PC1-PC2 coloreado por categoría de detección ---
X <- readRDS(file.path(ruta_proc, "matriz_principal.rds"))
pca <- prcomp(X, center = FALSE, scale. = FALSE)
pca_df <- as.data.frame(pca$x[, 1:2]) %>%
  mutate(categoria = comparacion$categoria)

var_exp <- round(100 * pca$sdev^2 / sum(pca$sdev^2), 1)

p_scatter <- ggplot(pca_df, aes(x = PC1, y = PC2, color = categoria)) +
  geom_point(alpha = 0.4, size = 0.5) +
  scale_color_manual(
    values = c("Ambos" = "firebrick", "Solo GMM" = "darkorange",
               "Solo LOF" = "steelblue", "Ninguno" = "grey80")
  ) +
  labs(
    title = "Hogares en el espacio PCA coloreados por categoría de detección",
    subtitle = paste0("PC1 = ", var_exp[1], "% ; PC2 = ", var_exp[2], "%"),
    x = paste0("PC1 (", var_exp[1], "%)"),
    y = paste0("PC2 (", var_exp[2], "%)"),
    color = "Categoría"
  ) +
  theme_minimal(base_size = 11) +
  guides(color = guide_legend(override.aes = list(size = 3, alpha = 1)))

ggsave(file.path(ruta_figuras, "fase8_scatter_categorias.png"), p_scatter,
       width = 9, height = 6, dpi = 150)

# --- Figura 2: Boxplots de gasto total por categoría ---
p_box <- ggplot(comparacion, aes(x = categoria, y = total_mensual, fill = categoria)) +
  geom_boxplot(outlier.size = 0.3, outlier.alpha = 0.2) +
  scale_y_log10(labels = comma) +
  scale_fill_manual(
    values = c("Ambos" = "firebrick", "Solo GMM" = "darkorange",
               "Solo LOF" = "steelblue", "Ninguno" = "grey70")
  ) +
  labs(
    title = "Gasto no alimentario mensual total por categoría de detección",
    subtitle = "Escala log10; se excluyen hogares con gasto = 0 (ya filtrados)",
    x = NULL, y = "Gasto total mensual (Bs, log10)"
  ) +
  theme_minimal(base_size = 11) +
  theme(legend.position = "none")

ggsave(file.path(ruta_figuras, "fase8_boxplot_gasto.png"), p_box,
       width = 9, height = 5, dpi = 150)

# --- Verificación defensiva ---
if (!"categoria" %in% names(comparacion)) {
  comparacion <- comparacion %>%
    mutate(
      categoria = case_when(
        anomalo_gmm & anomalo_lof  ~ "Ambos",
        anomalo_gmm & !anomalo_lof ~ "Solo GMM",
        !anomalo_gmm & anomalo_lof ~ "Solo LOF",
        TRUE                       ~ "Ninguno"
      ),
      categoria = factor(categoria,
                         levels = c("Ambos", "Solo GMM", "Solo LOF", "Ninguno"))
    )
}
# --- Figura 3: Barras de proporción por área ---
p_area <- comparacion %>%
  mutate(
    area = factor(
      area,
      levels = c(1, 2),
      labels = c("Urbana", "Rural")
    )
  ) %>%
  dplyr::count(area, categoria, .drop = FALSE) %>%
  group_by(area) %>%
  mutate(pct = 100 * n / sum(n)) %>%
  ungroup() %>%
  ggplot(aes(x = area, y = pct, fill = categoria)) +
  geom_col(position = "dodge") +
  scale_fill_manual(
    values = c(
      "Ambos" = "firebrick",
      "Solo GMM" = "darkorange",
      "Solo LOF" = "steelblue",
      "Ninguno" = "grey70"
    ),
    name = "Categoría"
  ) +
  labs(
    title = "Distribución de categorías de detección por área",
    x = NULL,
    y = "% dentro del área"
  ) +
  theme_minimal(base_size = 11)

ggsave(file.path(ruta_figuras, "fase8_barras_area.png"), p_area,
       width = 8, height = 5, dpi = 150)

# --- Figura 4: Heatmap de proporción por departamento ---
p_depto <- caract_depto %>%
  filter(categoria != "Ninguno") %>%
  ggplot(aes(x = factor(depto), y = categoria, fill = pct)) +
  geom_tile(color = "white") +
  scale_fill_gradient(low = "white", high = "firebrick") +
  labs(
    title = "Proporción de hogares detectados por departamento y categoría",
    subtitle = "Solo categorías con detección (excluye 'Ninguno')",
    x = "Departamento (código INE)", y = NULL, fill = "%"
  ) +
  theme_minimal(base_size = 11)

ggsave(file.path(ruta_figuras, "fase8_heatmap_depto.png"), p_depto,
       width = 10, height = 4, dpi = 150)

# --- Figura 5: Sensibilidad a umbrales ---
p_sens <- sensibilidad %>%
  select(percentil, jaccard, kappa) %>%
  pivot_longer(-percentil, names_to = "metrica", values_to = "valor") %>%
  ggplot(aes(x = factor(percentil), y = valor, fill = metrica)) +
  geom_col(position = "dodge") +
  labs(
    title = "Acuerdo entre GMM y LOF según umbral de anomalía",
    x = "Percentil de anomalía", y = "Valor de la métrica", fill = "Métrica"
  ) +
  theme_minimal(base_size = 11)

ggsave(file.path(ruta_figuras, "fase8_sensibilidad_umbrales.png"), p_sens,
       width = 8, height = 5, dpi = 150)

# --- Figura 6: Comparación con/sin log1p ---
p_log1p <- sens_transformacion %>%
  select(metodo, n_principal, n_sens) %>%
  pivot_longer(-metodo, names_to = "version", values_to = "n") %>%
  ggplot(aes(x = metodo, y = n, fill = version)) +
  geom_col(position = "dodge") +
  labs(
    title = "Efecto de la transformación log1p en el número de anomalías",
    subtitle = "Principal = log1p + z-score | Sensibilidad = solo z-score",
    x = NULL, y = "N.º de anomalías detectadas", fill = "Versión"
  ) +
  theme_minimal(base_size = 11)

ggsave(file.path(ruta_figuras, "fase8_efecto_log1p.png"), p_log1p,
       width = 8, height = 5, dpi = 150)

set.seed(2025)

pca_df_export_full <- pca_df %>%
  mutate(categoria = as.character(categoria))

# Muestra de "Ninguno" (800 puntos)
n_ninguno_muestra <- 800
ninguno_muestra <- pca_df_export_full %>%
  filter(categoria == "Ninguno") %>%
  slice_sample(n = n_ninguno_muestra)

# Todos los puntos de interés
interes <- pca_df_export_full %>%
  filter(categoria != "Ninguno")

pca_df_export <- bind_rows(interes, ninguno_muestra) %>%
  select(PC1, PC2, categoria)

cat("Exportando", nrow(pca_df_export), "puntos PCA (",
    sum(pca_df_export$categoria == "Ninguno"), "Ninguno +",
    sum(pca_df_export$categoria != "Ninguno"), "de interés)\n")

write_csv(pca_df_export, file.path(ruta_tablas, "fase8_pca_scatter.csv"))
cat("Guardado: fase8_pca_scatter.csv\n")
# ============================================================
# Resumen final
# ============================================================

cat("\n=== RESUMEN FASE 8 ===\n")
cat("GMM anomalías (percentil 5%):  ", sum(comparacion$anomalo_gmm), "\n")
cat("LOF anomalías (percentil 95):  ", sum(comparacion$anomalo_lof), "\n")
cat("Detectados por ambos:          ", n_ambos, "\n")
cat("Solo GMM:                      ", n_solo_gmm, "\n")
cat("Solo LOF:                      ", n_solo_lof, "\n")
cat("Jaccard:                       ", round(jaccard, 4), "\n")
cat("Cohen's kappa:                 ", round(kappa, 4), "\n")
cat("Coincidencia bruta:            ", round(coincidencia_bruta * 100, 2), "%\n")

cat("\n=== Archivos generados ===\n")
cat("  output/tables/fase8_matriz_confusion.csv\n")
cat("  output/tables/fase8_metricas_acuerdo.csv\n")
cat("  output/tables/fase8_caract_categoria.csv\n")
cat("  output/tables/fase8_caract_depto.csv\n")
cat("  output/tables/fase8_caract_estrato.csv\n")
cat("  output/tables/fase8_sensibilidad_umbrales.csv\n")
cat("  output/tables/fase8_efecto_log1p.csv\n")
cat("  output/figures/fase8_scatter_categorias.png\n")
cat("  output/figures/fase8_boxplot_gasto.png\n")
cat("  output/figures/fase8_barras_area.png\n")
cat("  output/figures/fase8_heatmap_depto.png\n")
cat("  output/figures/fase8_sensibilidad_umbrales.png\n")
cat("  output/figures/fase8_efecto_log1p.png\n")

cat("\n=== Fase 8 completada ===\n")