
# ============================================================
# CONVERSIÓN DE SPSS (.sav) A CSV
# Dataset: EH2025_Gastos_No_Alimentarios
# ============================================================
install.packages("haven")
library(haven)

# Rutas de los archivos
archivo_entrada <- "data/raw/EH2025_Gastos_No_Alimentarios.sav"
archivo_salida <- "data/raw/EH2025_Gastos_No_Alimentarios.csv"

# 1. Leer archivo SPSS
datos <- read_sav(archivo_entrada)

# 2. Convertir variables etiquetadas a sus valores originales
#    Conserva los códigos numéricos y evita convertirlos
#    automáticamente en etiquetas de texto.
datos_csv <- as.data.frame(datos)

# 3. Exportar a CSV
write.csv(
  datos_csv,
  file = archivo_salida,
  row.names = FALSE,
  na = "",
  fileEncoding = "UTF-8"
)

# 4. Mostrar información del resultado
cat("Conversión completada.\n")
cat("Filas:", nrow(datos_csv), "\n")
cat("Columnas:", ncol(datos_csv), "\n")
cat("Archivo:", archivo_salida, "\n")

# 5. Visualizar una muestra
print(head(datos_csv, 10))
