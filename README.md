# Detección de Anomalías en los Gastos No Alimentarios de los Hogares Bolivianos

Aplicación de técnicas de aprendizaje no supervisado para la identificación de patrones atípicos en los gastos no alimentarios de los hogares bolivianos, utilizando **Gaussian Mixture Models (GMM)** y **Local Outlier Factor (LOF)**.

## Información del proyecto

| Campo                   | Descripción                                        |
| ----------------------- | -------------------------------------------------- |
| **Tipo**                | Proyecto universitario individual                  |
| **Área**                | Data Mining                                        |
| **Enfoque**             | Detección de anomalías                             |
| **Lenguaje**            | R                                                  |
| **Dataset**             | Encuesta de Hogares 2025 (EH2025)                  |
| **Institución**         | Instituto Nacional de Estadística (INE) de Bolivia |
| **Métodos principales** | GMM y LOF                                          |
| **Fecha de entrega**    | 22 de noviembre de 2026                            |

## Objetivo

Aplicar y comparar modelos de mezcla gaussianos (GMM) y Local Outlier Factor (LOF) para identificar patrones atípicos en los gastos no alimentarios de los hogares bolivianos, utilizando información de la Encuesta de Hogares 2025.

## Dataset

Se utiliza exclusivamente el módulo **Gastos No Alimentarios de la Encuesta de Hogares 2025**, publicado por el Instituto Nacional de Estadística de Bolivia.

**Archivos:**

- `EH2025_Gastos_No_Alimentarios.sav`: archivo original en formato SPSS.
- `EH2025_Gastos_No_Alimentarios.csv`: versión convertida a CSV para facilitar la exploración y el procesamiento de los datos.

Fuente: [Instituto Nacional de Estadística de Bolivia - ANDA](https://anda.ine.gob.bo/index.php/catalog/256/data-dictionary).

## Métodos de detección de anomalías

### Gaussian Mixture Models (GMM)

Modelo probabilístico que representa los datos como una combinación de distribuciones gaussianas. Se utilizará para identificar observaciones con baja probabilidad o densidad respecto a los patrones estimados.

### Local Outlier Factor (LOF)

Algoritmo basado en densidad local que compara la densidad de una observación con la de sus vecinos para identificar comportamientos atípicos.

### Comparación

Se analizarán las diferencias entre ambos métodos, considerando las anomalías identificadas, sus puntuaciones, sensibilidad a parámetros e interpretación socioeconómica.

## Tecnologías y librerías

El desarrollo se realizará en R, utilizando principalmente:

| Librería    | Propósito                              |
| ----------- | -------------------------------------- |
| `haven`     | Lectura de archivos SPSS               |
| `tidyverse` | Manipulación y transformación de datos |
| `ggplot2`   | Visualización de datos                 |
| `skimr`     | Exploración estadística                |
| `naniar`    | Análisis de valores faltantes          |
| `mclust`    | Implementación de GMM                  |
| `dbscan`    | Implementación de LOF                  |
| `corrplot`  | Análisis de correlaciones              |

## Estructura del proyecto

```text
deteccion-anomalias-gmm-lof/
│
├── data/
│   ├── EH2025_Gastos_No_Alimentarios.csv
│   └── EH2025_Gastos_No_Alimentarios.sav
│
├── script/
│   └── 01_convertir_csv.R
│
└── README.md
```

## Requisitos

- R (versión 4.x recomendada).
- RStudio o cualquier editor compatible con R.
- Archivo original de la Encuesta de Hogares 2025.

### Instalación de dependencias

Para convertir el archivo SPSS a CSV:

```r
install.packages("haven")
```

Para las siguientes etapas del análisis:

```r
install.packages(c(
  "tidyverse",
  "ggplot2",
  "skimr",
  "naniar",
  "mclust",
  "dbscan",
  "corrplot"
))
```

## Ejecución

### 1. Conversión del dataset

El script `01_convertir_csv.R` permite leer el archivo SPSS y generar su versión CSV.

Desde la raíz del proyecto:

```bash
Rscript script/01_convertir_csv.R
```

El archivo CSV resultante se almacena en el directorio `data/`.

### 2. Análisis de datos

En las siguientes etapas se desarrollarán los procesos de:

1. Inspección y exploración del dataset.
2. Selección de variables relevantes.
3. Limpieza y preprocesamiento.
4. Implementación de GMM.
5. Implementación de LOF.
6. Evaluación y comparación de resultados.
7. Interpretación de las anomalías detectadas.

## Consideraciones metodológicas

- Los valores extremos no representan necesariamente errores o anomalías reales.
- Los valores cero pueden representar gastos efectivamente inexistentes.
- Los identificadores no deben utilizarse automáticamente como variables predictoras.
- Se deben identificar los códigos especiales y valores faltantes antes del modelado.
- Las variables monetarias deben analizarse considerando sus unidades y periodos de referencia.
- Las decisiones de preprocesamiento y los parámetros de los modelos deben documentarse para garantizar la reproducibilidad.

## Entregable

El resultado final será un documento académico en formato PDF que contendrá:

- Fundamentos teóricos y matemáticos.
- Descripción del conjunto de datos.
- Metodología de preprocesamiento.
- Implementación de GMM y LOF.
- Resultados y visualizaciones.
- Comparación y discusión.
- Conclusiones.
- Anexo con el código fuente completo en R.

## Autoría

Proyecto universitario individual desarrollado como parte de la formación académica en Data Mining.

**Bolivia · 2026**.
