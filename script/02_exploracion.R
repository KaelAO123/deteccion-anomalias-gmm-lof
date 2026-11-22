# ============================================================
# 02_exploracion.R — Fase 3: Exploración estadística y visualización
# Entrada:  data/raw/EH2025_Gastos_No_Alimentarios.csv
# Salidas:  output/figures/*.png, output/tables/*.csv
# ============================================================

library(tidyverse)
library(skimr)
library(corrplot)
library(patchwork)
library(scales)

# --- Rutas ---
ruta_csv    <- "data/raw/EH2025_Gastos_No_Alimentarios.csv"
ruta_fig    <- "output/figures"
ruta_tab    <- "output/tables"

# --- Lectura ---
datos <- read_csv(ruta_csv, show_col_types = FALSE)

# --- Subconjunto mensual ---
vars_mensuales <- sprintf("s08b_10_%02d", 1:28)

datos_mensual <- datos %>%
  select(folio, depto, area, upm, estrato, factor, all_of(vars_mensuales))

# --- 3.2. Resumen univariado ---
resumen_univariado <- datos_mensual %>%
  summarise(across(all_of(vars_mensuales), list(
    n_cero    = ~ sum(.x == 0, na.rm = TRUE),
    pct_cero  = ~ round(100 * mean(.x == 0, na.rm = TRUE), 2),
    media     = ~ round(mean(.x, na.rm = TRUE), 2),
    mediana   = ~ median(.x, na.rm = TRUE),
    desv      = ~ round(sd(.x, na.rm = TRUE), 2),
    min       = ~ min(.x, na.rm = TRUE),
    p25       = ~ quantile(.x, 0.25, na.rm = TRUE),
    p75       = ~ quantile(.x, 0.75, na.rm = TRUE),
    p95       = ~ quantile(.x, 0.95, na.rm = TRUE),
    max       = ~ max(.x, na.rm = TRUE),
    asimetria = ~ round(e1071::skewness(.x, na.rm = TRUE), 2)
  ))) %>%
  pivot_longer(everything(),
               names_to = c("variable", ".value"),
               names_pattern = "(.+)_(n_cero|pct_cero|media|mediana|desv|min|p25|p75|p95|max|asimetria)$") %>%
  arrange(desc(pct_cero))

write_csv(resumen_univariado, file.path(ruta_tab, "fase3_resumen_univariado.csv"))

# --- 3.3. Gráficos ---
# --- 3.3.1. Proporción de ceros por variable (gráfico de barras) ---
p_ceros <- resumen_univariado %>%
  mutate(variable = fct_reorder(variable, pct_cero)) %>%
  ggplot(aes(x = pct_cero, y = variable, fill = pct_cero > 90)) +
  geom_col() +
  geom_vline(xintercept = 90, linetype = "dashed", color = "red") +
  scale_fill_manual(values = c("steelblue", "firebrick"),
                    labels = c("≤ 90 %", "> 90 %"),
                    name = "Ceros") +
  labs(title = "Proporción de ceros por variable de gasto mensual",
       subtitle = "Línea roja: umbral del 90 %",
       x = "% de hogares con gasto = 0", y = NULL) +
  theme_minimal(base_size = 11) +
  theme(legend.position = "bottom")

ggsave("output/figures/fase3_pct_ceros.png", p_ceros, width = 8, height = 8, dpi = 150)
print(p_ceros)

# --- 3.3.2. Histogramas en escala original y log1p (4 variables de ejemplo) ---
# Elegir 4 variables con distintos niveles de ceros para ilustrar
vars_ejemplo <- c("s08b_10_02", "s08b_10_06", "s08b_10_16", "s08b_10_23")
# (transporte, higiene personal, almuerzos fuera, combustibles)

p_hist_orig <- datos_mensual %>%
  select(all_of(vars_ejemplo)) %>%
  pivot_longer(everything(), names_to = "variable", values_to = "valor") %>%
  ggplot(aes(x = valor)) +
  geom_histogram(bins = 50, fill = "steelblue", color = "white") +
  facet_wrap(~ variable, scales = "free", ncol = 2) +
  labs(title = "Distribución original (escala Bs)",
       x = "Gasto mensual (Bs)", y = "Frecuencia") +
  theme_minimal(base_size = 10)

p_hist_log <- datos_mensual %>%
  select(all_of(vars_ejemplo)) %>%
  mutate(across(everything(), ~ log1p(.x))) %>%
  pivot_longer(everything(), names_to = "variable", values_to = "valor") %>%
  ggplot(aes(x = valor)) +
  geom_histogram(bins = 50, fill = "darkorange", color = "white") +
  facet_wrap(~ variable, scales = "free", ncol = 2) +
  labs(title = "Distribución transformada log1p",
       x = "log(1 + gasto)", y = "Frecuencia") +
  theme_minimal(base_size = 10)

p_hist_orig + p_hist_log +
  plot_annotation(title = "Comparación original vs. log1p en 4 variables representativas")

ggsave("output/figures/fase3_hist_orig_vs_log.png", width = 12, height = 6, dpi = 150)

# --- 3.3.3. Boxplots de las 28 variables (escala log1p para visualizar) ---
p_box <- datos_mensual %>%
  select(all_of(vars_mensuales)) %>%
  mutate(across(everything(), ~ log1p(.x))) %>%
  pivot_longer(everything(), names_to = "variable", values_to = "valor") %>%
  ggplot(aes(x = variable, y = valor)) +
  geom_boxplot(fill = "steelblue", outlier.size = 0.5, outlier.alpha = 0.3) +
  coord_flip() +
  labs(title = "Boxplots de gasto mensual (escala log1p)",
       x = NULL, y = "log(1 + gasto)") +
  theme_minimal(base_size = 9)

ggsave("output/figures/fase3_boxplots.png", p_box, width = 9, height = 9, dpi = 150)
# --- 3.4.1. Matriz de correlación de Spearman (robusta a asimetría) ---
cor_spearman <- datos_mensual %>%
  select(all_of(vars_mensuales)) %>%
  cor(method = "spearman", use = "pairwise.complete.obs")

# Visualización
png("output/figures/fase3_corr_spearman.png", width = 1200, height = 1200, res = 120)
corrplot(cor_spearman,
         method = "color",
         type = "upper",
         order = "hclust",
         addCoef.col = NULL,
         tl.col = "black",
         tl.cex = 0.6,
         tl.srt = 45,
         col = colorRampPalette(c("navy", "white", "firebrick3"))(200),
         title = "Correlación de Spearman — 28 variables de gasto mensual",
         mar = c(0, 0, 2, 0))
dev.off()
# --- 3.4.2. Identificar pares con correlación alta (|r| > 0.7) ---
pares_altos <- which(abs(cor_spearman) > 0.7 & upper.tri(cor_spearman), arr.ind = TRUE) %>%
  as.data.frame() %>%
  mutate(
    var1 = rownames(cor_spearman)[row],
    var2 = colnames(cor_spearman)[col],
    r = cor_spearman[cbind(row, col)]
  ) %>%
  arrange(desc(abs(r))) %>%
  select(var1, var2, r)

cat("Pares con |r| > 0.7:\n")
print(pares_altos)
# --- 3.5.1. PCA sobre log1p + escalado (diagnóstico, no modelado) ---
# Solo ejecutar si el criterio anterior se cumple.

datos_log <- datos_mensual %>%
  select(all_of(vars_mensuales)) %>%
  mutate(across(everything(), ~ log1p(.x))) %>%
  scale()  # estandarización (media 0, sd 1)

pca <- prcomp(datos_log, center = FALSE, scale. = FALSE)

# Varianza explicada
var_exp <- data.frame(
  componente = 1:length(pca$sdev),
  var_explicada = pca$sdev^2 / sum(pca$sdev^2),
  var_acumulada = cumsum(pca$sdev^2 / sum(pca$sdev^2))
)

print(head(var_exp, 10))

# --- 3.5.2. Gráfico de sedimentación (scree plot) ---
p_scree <- ggplot(var_exp, aes(x = componente, y = var_explicada)) +
  geom_line(color = "steelblue") +
  geom_point(color = "steelblue", size = 2) +
  geom_hline(yintercept = 1/length(vars_mensuales), linetype = "dashed", color = "red") +
  labs(title = "Scree plot — PCA sobre log1p(28 variables mensuales)",
       subtitle = "Línea roja: umbral de Kaiser (1/28)",
       x = "Componente principal", y = "Proporción de varianza explicada") +
  theme_minimal(base_size = 11)

ggsave("output/figures/fase3_scree.png", p_scree, width = 8, height = 5, dpi = 150)
print(p_scree)

# --- 3.5.3. Biplot de los dos primeros componentes (con depto como color) ---
# NOTA: depto se usa SOLO para colorear, NO como predictor.
pca_df <- as.data.frame(pca$x[, 1:2]) %>%
  mutate(depto = factor(datos_mensual$depto),
         area  = factor(datos_mensual$area))

p_biplot <- ggplot(pca_df, aes(x = PC1, y = PC2, color = area)) +
  geom_point(alpha = 0.3, size = 0.5) +
  labs(title = "Biplot PC1–PC2 (color = área urbana/rural)",
       subtitle = "Solo diagnóstico exploratorio; no se usa como predictor",
       x = paste0("PC1 (", round(100*var_exp$var_explicada[1], 1), " %)"),
       y = paste0("PC2 (", round(100*var_exp$var_explicada[2], 1), " %)")) +
  theme_minimal(base_size = 11)

ggsave("output/figures/fase3_biplot.png", p_biplot, width = 9, height = 6, dpi = 150)
# --- 3.6.1. Conteo de outliers univariados por regla IQR (solo diagnóstico) ---
outliers_iqr <- datos_mensual %>%
  summarise(across(all_of(vars_mensuales), ~ {
    q <- quantile(.x, c(0.25, 0.75), na.rm = TRUE)
    iqr <- q[2] - q[1]
    sum(.x > q[2] + 1.5 * iqr | .x < q[1] - 1.5 * iqr, na.rm = TRUE)
  })) %>%
  pivot_longer(everything(), names_to = "variable", values_to = "n_outliers") %>%
  mutate(pct_outliers = round(100 * n_outliers / nrow(datos_mensual), 2)) %>%
  arrange(desc(pct_outliers))

print(outliers_iqr, n = 28)
# --- 3.6.2. ¿Cuántos hogares tienen gasto total mensual = 0? ---
datos_mensual <- datos_mensual %>%
  mutate(total_mensual = rowSums(across(all_of(vars_mensuales)), na.rm = TRUE))

cat("Hogares con gasto mensual total = 0:", sum(datos_mensual$total_mensual == 0), "\n")
cat("Hogares con gasto mensual total > 0:", sum(datos_mensual$total_mensual > 0), "\n")
cat("Resumen del gasto total mensual (Bs):\n")
print(summary(datos_mensual$total_mensual))
# --- 3.7.1. Gasto total mensual por área (urbano/rural) ---
p_area <- datos_mensual %>%
  mutate(area = factor(area, labels = c("Urbana", "Rural"))) %>%
  ggplot(aes(x = area, y = total_mensual, fill = area)) +
  geom_boxplot(outlier.size = 0.3, outlier.alpha = 0.2) +
  scale_y_log10(labels = comma) +
  labs(title = "Gasto no alimentario mensual total por área",
       x = NULL, y = "Gasto total mensual (Bs, escala log10)") +
theme_minimal(base_size = 11) +
  theme(legend.position = "none")

# --- 3.7.2. Gasto total mensual por departamento ---
p_depto <- datos_mensual %>%
  mutate(depto = factor(depto)) %>%
  ggplot(aes(x = depto, y = total_mensual, fill = depto)) +
  geom_boxplot(outlier.size = 0.3, outlier.alpha = 0.2) +
  scale_y_log10(labels = comma) +
  labs(title = "Gasto no alimentario mensual total por departamento",
       x = "Departamento (código INE)", y = "Gasto total mensual (Bs, log10)") +
  theme_minimal(base_size = 11) +
  theme(legend.position = "none")

p_area + p_depto

ggsave("output/figures/fase3_gasto_por_area_depto.png", width = 12, height = 5, dpi = 150)
