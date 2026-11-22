# Detección de anomalías en los gastos no alimentarios de los hogares bolivianos

Aplicación de **Gaussian Mixture Models (GMM)** y **Local Outlier Factor (LOF)** para identificar patrones atípicos en el gasto no alimentario mensual de los hogares bolivianos, usando la **Encuesta de Hogares 2025 (EH2025)** del Instituto Nacional de Estadística (INE) de Bolivia.

**Sitio web del proyecto:** [docs/web/](docs/web/) · **Informe PDF:** [docs/informe_final.pdf](docs/informe_final.pdf)

---

## Tabla de contenidos

- [Detección de anomalías en los gastos no alimentarios de los hogares bolivianos](#detección-de-anomalías-en-los-gastos-no-alimentarios-de-los-hogares-bolivianos)
  - [Tabla de contenidos](#tabla-de-contenidos)
  - [Contexto](#contexto)
  - [Resultados principales](#resultados-principales)
  - [Dataset](#dataset)
  - [Metodología](#metodología)
  - [Estructura del repositorio](#estructura-del-repositorio)
  - [Requisitos e instalación](#requisitos-e-instalación)
    - [R](#r)
    - [Frontend (opcional, para el sitio web)](#frontend-opcional-para-el-sitio-web)
  - [Reproducción](#reproducción)
    - [1. Colocar los datos crudos](#1-colocar-los-datos-crudos)
    - [2. Ejecutar el pipeline](#2-ejecutar-el-pipeline)
    - [3. Verificar las salidas](#3-verificar-las-salidas)
    - [4. (Opcional) Levantar el sitio web](#4-opcional-levantar-el-sitio-web)
  - [Tecnologías](#tecnologías)
  - [Consideraciones metodológicas](#consideraciones-metodológicas)
  - [Entregable](#entregable)
  - [Autoría](#autoría)

---

## Contexto


| Campo                  | Valor                                          |
| ------------------------ | ------------------------------------------------ |
| **Tipo**               | Proyecto universitario individual              |
| **Materia**            | Minería de Datos                              |
| **Enfoque**            | Detección de anomalías no supervisada        |
| **Lenguaje principal** | R                                              |
| **Frontend**           | React + TypeScript + Vite                      |
| **Dataset**            | EH2025 — Gastos No Alimentarios (INE Bolivia) |
| **Métodos**           | GMM (`mclust`) y LOF (`dbscan`)                |
| **Fecha de entrega**   | 22 de noviembre de 2026                        |

**Objetivo general:** aplicar y comparar GMM y LOF para detectar patrones atípicos en el gasto no alimentario **mensual** de los hogares bolivianos, y caracterizar socioeconómicamente las anomalías detectadas.

---

## Resultados principales


| Métrica                                   | Valor                                          |
| -------------------------------------------- | ------------------------------------------------ |
| Hogares analizados                         | 12.631 (tras excluir 95 sin gasto mensual)     |
| Variables de gasto                         | 22 (tras excluir 6 con >95 % de ceros)         |
| Modelo GMM                                 | **VEV con 13 componentes** (BIC = −427.983,7) |
| LOF                                        | **k = 20** vecinos                             |
| Anomalías detectadas (GMM, percentil 5 %) | **632** (5,00 %)                               |
| Anomalías detectadas (LOF, percentil 95)  | **632** (5,00 %)                               |
| Coincidencia entre ambos                   | **22 hogares** (0,17 %)                        |
| Jaccard                                    | 0,0177                                         |
| Cohen's κ                                 | −0,016                                        |

**Hallazgo central:** GMM y LOF **no son redundantes, son complementarios**. GMM detecta la _élite de gasto_ (hogares urbanos con gasto alto; mediana 1.825 Bs; 93,9 % urbanos). LOF detecta la _pobreza contextual_ (hogares rurales con gasto bajo; mediana 157,5 Bs; 56,4 % rurales). La coincidencia casi nula (22 hogares) es evidencia de que miden dimensiones distintas de la atipicidad.

> **Las anomalías detectadas no son fraudes ni errores.** Son hogares cuyos patrones de gasto se desvían del patrón general o local, lo cual puede deberse a composición demográfica, niveles de ingreso extremos, preferencias de consumo o incluso errores de registro.

---

## Dataset

Se usa exclusivamente el módulo **Gastos No Alimentarios** de la EH2025.

- **Fuente oficial:** [INE Bolivia — Catálogo ANDA 256](https://anda.ine.gob.bo/index.php/catalog/256)
- **Diccionario de variables:** [F22 — EH2025_Gastos_No_Alimentarios](https://anda.ine.gob.bo/index.php/catalog/256/data-dictionary/F22)
- **Archivos:**
  - `data/raw/EH2025_Gastos_No_Alimentarios.sav` — original SPSS (no versionado)
  - `data/raw/EH2025_Gastos_No_Alimentarios.csv` — derivado para análisis (no versionado)
- **Muestra:** 12.726 hogares, 66 variables (60 de gasto + 6 de diseño/identificación).
- **Módulos de gasto:** mensual (28 ítems), trimestral (8), semestral (3), anual (21).
- **Alcance del proyecto:** solo el módulo **mensual** (28 variables → 22 tras preprocesamiento).

---

## Metodología

Pipeline completo (reproducible con `script/00_main.R`):

1. **Conversión** SAV → CSV (`01_convertir_csv.R`).
2. **Exploración** univariada y bivariada (`02_exploracion.R`).
3. **Preprocesamiento** (`03_preprocesamiento.R`):
   - Exclusión de 6 variables con >95 % de ceros.
   - Exclusión de 95 hogares con gasto mensual total = 0.
   - Transformación `log(1+x)` + estandarización z-score.
   - Matriz principal (`log1p + z`) y matriz de sensibilidad (solo `z`).
4. **GMM** (`04_gmm.R`): selección VEV con 13 componentes vía BIC; detección por baja log-densidad (percentil 5 %).
5. **LOF** (`05_lof.R`): k = 20 seleccionado por análisis de sensibilidad; detección por LOF alto (percentil 95).
6. **Evaluación y comparación** (`06_evaluacion.R`): matriz de confusión, Jaccard, κ, caracterización socioeconómica, sensibilidad a umbrales y efecto de `log1p`.

**Fundamento matemático** (GMM con EM, LOF con reachability distance y LRD) documentado en el informe y en el sitio web (sección _Métodos_).

---

## Estructura del repositorio

```text
deteccion-anomalias-gmm-lof/
│
├── data/
│   ├── raw/                              # Datos originales (no versionados)
│   │   ├── EH2025_Gastos_No_Alimentarios.sav
│   │   └── EH2025_Gastos_No_Alimentarios.csv
│   └── processed/                        # Datos transformados (reproducibles)
│       ├── caracterizacion.rds
│       ├── matriz_principal.rds
│       ├── matriz_sensibilidad.rds
│       └── fase4_diagnostico.csv
│
├── script/                               # Pipeline R numerado
│   ├── 00_main.R                         # Orquestador
│   ├── 01_convertir_csv.R
│   ├── 02_exploracion.R
│   ├── 03_preprocesamiento.R
│   ├── 04_gmm.R
│   ├── 05_lof.R
│   └── 06_evaluacion.R
│
├── output/
│   ├── figures/                          # Figuras .png (reproducibles)
│   ├── tables/                           # Tablas .csv (reproducibles)
│   └── models/                           # Modelos .rds (reproducibles)
│
├── docs/
│   ├── informe_final.Rmd                 # Documento académico (fuente)
│   ├── informe_final.pdf                 # Documento académico (renderizado)
│   └── web/                              # Frontend React (ver README propio)
│       └── README.md
│
├── .gitignore
└── README.md
```

---

## Requisitos e instalación

### R

- **R ≥ 4.3** (recomendado 4.4+).
- RStudio (opcional, pero recomendado).

Paquetes necesarios:

```r
install.packages(c(
  "haven", "tidyverse", "skimr", "naniar",
  "mclust", "dbscan", "corrplot", "factoextra",
  "patchwork", "scales", "e1071"
))
```

### Frontend (opcional, para el sitio web)

- **Node.js ≥ 20** y **npm ≥ 10**.

```bash
cd docs/web
npm install
```

---

## Reproducción

### 1. Colocar los datos crudos

Descarga el archivo `.sav` desde el [catálogo ANDA](https://anda.ine.gob.bo/index.php/catalog/256) y colócalo en:

```code
data/raw/EH2025_Gastos_No_Alimentarios.sav
```

### 2. Ejecutar el pipeline

```r
# Desde la raíz del proyecto
source("script/00_main.R")
```

O por fases (recomendado la primera vez, para ver la salida de cada una):

```r
source("script/01_convertir_csv.R")
source("script/02_exploracion.R")
source("script/03_preprocesamiento.R")
source("script/04_gmm.R")       # ~15 min
source("script/05_lof.R")       # ~5 min
source("script/06_evaluacion.R")# ~15 min
```

### 3. Verificar las salidas

- Figuras → `output/figures/`
- Tablas → `output/tables/`
- Modelos → `output/models/`

### 4. (Opcional) Levantar el sitio web

```bash
cd docs/web
npm install
npm run dev    # http://localhost:5173
```

---

## Tecnologías


| Componente             | Herramienta                   | Rol                          |
| ------------------------ | ------------------------------- | ------------------------------ |
| Análisis estadístico | **R 4.4**                     | Pipeline completo            |
| GMM                    | `mclust`                      | Modelos de mezcla gaussianos |
| LOF                    | `dbscan`                      | Local Outlier Factor         |
| Manipulación          | `tidyverse`                   | dplyr, tidyr, purrr, readr   |
| Visualización         | `ggplot2`                     | Figuras del informe          |
| Exploración           | `skimr`, `naniar`             | Estadísticas y faltantes    |
| Correlaciones          | `corrplot`                    | Matriz de Spearman           |
| Frontend               | **React + TypeScript + Vite** | Sitio web descriptivo        |
| Estilos                | Tailwind CSS                  | Diseño responsive           |
| Animaciones            | Framer Motion                 | Micro-interacciones          |
| Gráficas web          | Recharts                      | Visualizaciones interactivas |
| Matemáticas           | KaTeX                         | Fórmulas de GMM y LOF       |

---

## Consideraciones metodológicas

- **Unidad de análisis:** cada fila es un hogar (confirmado: `folio` único en 12.726 filas).
- **Ceros:** son ceros reales (instrucción INE: "00 si no gastó"), no faltantes ni anomalías.
- **Valores extremos:** no se eliminan. La detección de anomalías se hace con métodos multivariantes, no con reglas IQR univariadas.
- **Identificadores:** `folio`, `upm`, `factor` no se usan como predictores; solo para trazabilidad y caracterización post-detección.
- **Estrato:** es un código de **diseño muestral**, no un estrato socioeconómico. Se usa solo para describir.
- **Periodicidad:** solo se analiza el módulo mensual. Los módulos trimestral, semestral y anual quedan como trabajo futuro.
- **Reproducibilidad:** semillas fijas (`set.seed(2025)`), rutas relativas, pipeline numerado, `.gitignore` para datos pesados.

---

## Entregable

1. **Documento académico** (`docs/informe_final.pdf`): portada, resumen, introducción, planteamiento, justificación, objetivos, marco teórico (con derivaciones), metodología, resultados, discusión, conclusiones, limitaciones, referencias APA 7 y **anexo con el código R completo**.
2. **Sitio web** (`docs/web/`): presentación visual con gráficas interactivas, tablas dinámicas y explicaciones de los métodos.
3. **Repositorio reproducible**: pipeline R + datos procesados + modelos entrenados.

---

## Autoría

Proyecto universitario individual desarrollado para la materia **Minería de Datos**.

**Bolivia · Noviembre 2026**

Datos: [INE Bolivia — Encuesta de Hogares 2025](https://anda.ine.gob.bo/index.php/catalog/256)
