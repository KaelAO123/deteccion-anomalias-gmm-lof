# Frontend — Detección de anomalías EH2025

Sitio web descriptivo del proyecto de detección de anomalías en el gasto no alimentario mensual de los hogares bolivianos (EH2025), usando GMM y LOF.

**Stack:** React 18 + TypeScript + Vite + Tailwind CSS + Framer Motion + Recharts + KaTeX.

---

## Tabla de contenidos

- [Frontend — Detección de anomalías EH2025](#frontend--detección-de-anomalías-eh2025)
  - [Tabla de contenidos](#tabla-de-contenidos)
  - [Características](#características)
  - [Requisitos](#requisitos)
  - [Instalación](#instalación)
  - [Desarrollo](#desarrollo)
    - [Si aparece `ENOSPC: System limit for number of file watchers reached`](#si-aparece-enospc-system-limit-for-number-of-file-watchers-reached)
  - [Build y despliegue](#build-y-despliegue)
    - [Build de producción](#build-de-producción)
    - [Previsualizar el build](#previsualizar-el-build)
    - [Desplegar](#desplegar)
  - [Estructura](#estructura)
  - [Datos dinámicos](#datos-dinámicos)
  - [Actualizar con un nuevo dataset](#actualizar-con-un-nuevo-dataset)
    - [Regenerar `fase8_pca_scatter.csv` con muestreo](#regenerar-fase8_pca_scattercsv-con-muestreo)
  - [Secciones de la página](#secciones-de-la-página)
  - [Accesibilidad](#accesibilidad)
  - [Licencia](#licencia)

---

## Características

- **9 secciones** navegables: Hero, Resumen, Dataset, Metodología, Métodos (GMM/LOF con fórmulas), GMM, LOF, Comparación, Conclusiones y Limitaciones.
- **Gráficas interactivas** con Recharts: proporción de ceros, BIC comparativo, sensibilidad de LOF a `k`, matriz de confusión, gasto por categoría, scatter PCA, efecto de `log1p` y heatmap por departamento.
- **Fórmulas matemáticas** renderizadas con KaTeX (gaussianas, EM, reachability distance, LRD, LOF).
- **Modo claro/oscuro** persistente en `localStorage`.
- **Animaciones** con Framer Motion: scroll-triggered, hover, contadores animados y subrayado deslizante en el nav.
- **Datos dinámicos**: las gráficas y tablas leen CSV de `public/data/`. Si actualizas un CSV, la página se regenera sin tocar código.
- **Responsive**: móvil, tablet y escritorio.
- **Accesible**: `prefers-reduced-motion`, `aria-label`, foco visible, contraste suficiente.

---

## Requisitos

- **Node.js ≥ 20** ([descargar](https://nodejs.org/))
- **npm ≥ 10** (viene con Node)

Verifica:

```bash
node --version   # >= 20
npm --version    # >= 10
```

---

## Instalación

Desde `docs/web/`:

```bash
npm install
```

Esto instala todas las dependencias (React, Vite, Tailwind, Recharts, Framer Motion, KaTeX, PapaParse).

---

## Desarrollo

```bash
npm run dev
```

Abre [http://localhost:5173](http://localhost:5173). El servidor recarga automáticamente al guardar cambios (HMR).

### Si aparece `ENOSPC: System limit for number of file watchers reached`

Es un límite de Linux. Solución:

```bash
# Temporal
sudo sysctl fs.inotify.max_user_watches=524288

# Permanente
echo "fs.inotify.max_user_watches=524288" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

Y añade a `vite.config.ts`:

```ts
server: {
  watch: {
    ignored: ['**/node_modules/**', '**/dist/**', '**/.git/**'],
  },
},
```

---

## Build y despliegue

### Build de producción

```bash
npm run build
```

Genera `dist/` con HTML, CSS y JS minificados. Es un sitio **estático**: no necesita backend.

### Previsualizar el build

```bash
npm run preview
```

### Desplegar

**GitHub Pages:**

1. Sube el repo a GitHub.
2. Settings → Pages → Source: `Deploy from a branch` → Branch: `main` → Folder: `/docs/web/dist` (o usa `gh-pages`).
3. La URL será `https://kaelao123.github.io/deteccion-anomalias-gmm-lof/`.

**Netlify / Vercel:**

1. Arrastra `docs/web/dist/` a [Netlify Drop](https://app.netlify.com/drop).
2. O conecta el repo y configura:
   - **Build command:** `cd docs/web && npm install && npm run build`
   - **Publish directory:** `docs/web/dist`

**Servir localmente (para probar el build):**

```bash
cd docs/web/dist
python3 -m http.server 8000
# http://localhost:8000
```

---

## Estructura

```text
docs/web/
├── index.html
├── package.json
├── vite.config.ts
├── tailwind.config.js
├── postcss.config.js
├── tsconfig.json
├── public/
│   ├── data/                       # CSV (copiados desde output/tables/)
│   │   ├── fase3_resumen_univariado.csv
│   │   ├── fase8_caract_categoria.csv
│   │   ├── fase8_caract_depto.csv
│   │   ├── fase8_efecto_log1p.csv
│   │   ├── fase8_matriz_confusion.csv
│   │   ├── fase8_metricas_acuerdo.csv
│   │   ├── fase8_pca_scatter.csv
│   │   ├── fase8_sensibilidad_umbrales.csv
│   │   ├── gmm_bic.csv
│   │   ├── gmm_detecciones.csv
│   │   ├── lof_detecciones.csv
│   │   └── lof_sensibilidad_k.csv
│   └── figures/                    # PNG (copiados desde output/figures/)
│       ├── fase3_pct_ceros.png
│       ├── gmm_bic.png
│       ├── gmm_logdens.png
│       ├── lof_distribucion.png
│       ├── lof_sensibilidad_k.png
│       └── fase8_boxplot_gasto.png
└── src/
    ├── main.tsx
    ├── App.tsx
    ├── index.css
    ├── data/
    │   └── loaders.ts              # Hook useCSV + tipos
    ├── components/
    │   ├── Nav.tsx
    │   ├── Hero.tsx
    │   ├── Section.tsx
    │   ├── StatCard.tsx
    │   ├── Callout.tsx
    │   ├── Footer.tsx
    │   ├── ThemeToggle.tsx
    │   ├── AnimatedNumber.tsx
    │   └── charts/
    │       ├── CerosChart.tsx
    │       ├── BicChart.tsx
    │       ├── LofSensChart.tsx
    │       ├── ConfusionMatrix.tsx
    │       ├── CategoryChart.tsx
    │       ├── ScatterPca.tsx
    │       ├── DeptoHeatmap.tsx
    │       └── EfectoLog1pChart.tsx
    └── sections/
        ├── Metodologia.tsx
        ├── Metodos.tsx
        └── Limitaciones.tsx
```

---

## Datos dinámicos

La página **no hardcodea** los números. Los lee de `public/data/` con el hook `useCSV<T>(filename)` (en `src/data/loaders.ts`), que usa `papaparse` para parsear el CSV y lo tipa con TypeScript.

Si actualizas un CSV (mismos nombres de columna), la página refleja los cambios al recargar. **No necesitas tocar código React.**

---

## Actualizar con un nuevo dataset

Si tienes una nueva versión de la EH (por ejemplo, EH2026) y quieres actualizar la página:

1. **Reejecuta el pipeline R** con el nuevo dataset:
   ```bash
   # Desde la raíz del proyecto
   source("script/00_main.R")
   ```
2. **Copia los nuevos CSV y PNG** a `public/`:
   ```bash
   cp output/tables/*.csv docs/web/public/data/
   cp output/figures/*.png docs/web/public/figures/
   ```
3. **Recarga la página** (`npm run dev` con HMR, o `npm run build` si es producción).

Las gráficas y tablas se regeneran automáticamente. Si la nueva versión tiene **columnas distintas**, actualiza los tipos en `src/data/loaders.ts` y los componentes que las consumen.

### Regenerar `fase8_pca_scatter.csv` con muestreo

Para que el scatter PCA no sea lento, el CSV exportado incluye **todos** los puntos de interés y una **muestra aleatoria de 800 "Ninguno"**. El código está al final de `06_evaluacion.R`:

```r
set.seed(2025)
pca_df_export_full <- pca_df %>% mutate(categoria = as.character(categoria))

ninguno_muestra <- pca_df_export_full %>%
  filter(categoria == "Ninguno") %>%
  slice_sample(n = 800)

interes <- pca_df_export_full %>% filter(categoria != "Ninguno")

pca_df_export <- bind_rows(interes, ninguno_muestra) %>%
  select(PC1, PC2, categoria)

write_csv(pca_df_export, "output/tables/fase8_pca_scatter.csv")
```

---

## Secciones de la página

| Sección          | Contenido                                                                              |
| ---------------- | -------------------------------------------------------------------------------------- |
| **Hero**         | Título, subtítulo, botones de navegación                                               |
| **Resumen**      | Hallazgo principal: complementariedad GMM vs. LOF                                      |
| **Dataset**      | 12.726 hogares, 60 variables, 4 horizontes + gráfico de ceros                          |
| **Metodología**  | Pipeline de 4 pasos con iconos SVG                                                     |
| **Métodos**      | GMM (gaussiana, EM) y LOF (reachability, LRD, LOF) con fórmulas KaTeX                  |
| **GMM**          | Modelo VEV 13 componentes, BIC, distribución de log-densidad                           |
| **LOF**          | k = 20, sensibilidad, distribución de LOF                                              |
| **Comparación**  | Matriz de confusión, Jaccard, κ, scatter PCA, efecto `log1p`, heatmap por departamento |
| **Conclusiones** | 5 hallazgos numerados                                                                  |
| **Limitaciones** | 5 limitaciones metodológicas                                                           |

---

## Accesibilidad

- **`prefers-reduced-motion`**: las animaciones se desactivan si el usuario lo prefiere.
- **`aria-label`**: botones (tema, menú) tienen etiquetas descriptivas.
- **Foco visible**: `outline` en todos los elementos interactivos.
- **Contraste**: colores cumplen WCAG AA en texto principal.
- **`alt` text**: todas las imágenes tienen descripción.

---

## Licencia

Uso académico. Los datos son propiedad del INE Bolivia y se usan bajo los términos del catálogo ANDA.

---

**Proyecto:** Detección de anomalías en gasto no alimentario — EH2025 Bolivia
**Materia:** Minería de Datos
**Fecha:** Noviembre 2026
