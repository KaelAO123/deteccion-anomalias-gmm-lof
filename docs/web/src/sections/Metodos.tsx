import { motion } from 'framer-motion';
import { BlockMath, InlineMath } from 'react-katex';

export default function Metodos() {
  return (
    <div className="space-y-8">
      {/* ---------- GMM ---------- */}
      <motion.article
        initial={{ opacity: 0, y: 20 }}
        whileInView={{ opacity: 1, y: 0 }}
        viewport={{ once: true, margin: '-50px' }}
        transition={{ duration: 0.5 }}
        className="bg-white dark:bg-slate-800 rounded-xl shadow-sm p-8"
      >
        <h3 className="text-2xl font-extrabold text-primary dark:text-blue-300 mb-4">
          Gaussian Mixture Model (GMM)
        </h3>

        <p className="text-gray-700 dark:text-gray-300 mb-4">
          Un GMM asume que los datos provienen de una mezcla de{' '}
          <InlineMath math="K" /> componentes gaussianos. Cada componente{' '}
          <InlineMath math="k" /> tiene su propia media{' '}
          <InlineMath math="\boldsymbol{\mu}_k" />, covarianza{' '}
          <InlineMath math="\boldsymbol{\Sigma}_k" /> y peso{' '}
          <InlineMath math="\pi_k" />.
        </p>

        <p className="text-sm font-semibold text-gray-800 dark:text-gray-200 mb-2">
          Función de densidad de probabilidad:
        </p>
        <div className="bg-gray-50 dark:bg-slate-900 rounded-lg p-4 mb-4 overflow-x-auto">
          <BlockMath math="p(\mathbf{x} \mid \boldsymbol{\theta}) = \sum_{k=1}^{K} \pi_k \, \mathcal{N}\!\left(\mathbf{x} \mid \boldsymbol{\mu}_k, \boldsymbol{\Sigma}_k\right)" />
        </div>

        <p className="text-gray-700 dark:text-gray-300 mb-2">
          donde <InlineMath math="\mathcal{N}" /> es la gaussiana multivariante:
        </p>
        <div className="bg-gray-50 dark:bg-slate-900 rounded-lg p-4 mb-4 overflow-x-auto">
          <BlockMath math="\mathcal{N}(\mathbf{x} \mid \boldsymbol{\mu}, \boldsymbol{\Sigma}) = \frac{1}{(2\pi)^{d/2} |\boldsymbol{\Sigma}|^{1/2}} \exp\!\left(-\tfrac{1}{2} (\mathbf{x}-\boldsymbol{\mu})^\top \boldsymbol{\Sigma}^{-1} (\mathbf{x}-\boldsymbol{\mu})\right)" />
        </div>

        <p className="text-sm font-semibold text-gray-800 dark:text-gray-200 mb-2">
          Estimación por EM — paso E (responsabilidades):
        </p>
        <div className="bg-gray-50 dark:bg-slate-900 rounded-lg p-4 mb-4 overflow-x-auto">
          <BlockMath math="\gamma_{ik} = \frac{\pi_k \, \mathcal{N}(\mathbf{x}_i \mid \boldsymbol{\mu}_k, \boldsymbol{\Sigma}_k)}{\sum_{j=1}^{K} \pi_j \, \mathcal{N}(\mathbf{x}_i \mid \boldsymbol{\mu}_j, \boldsymbol{\Sigma}_j)}" />
        </div>

        <p className="text-sm font-semibold text-gray-800 dark:text-gray-200 mb-2">
          Paso M (actualización de parámetros):
        </p>
        <div className="bg-gray-50 dark:bg-slate-900 rounded-lg p-4 mb-4 overflow-x-auto">
          <BlockMath math="\boldsymbol{\mu}_k = \frac{\sum_i \gamma_{ik} \mathbf{x}_i}{\sum_i \gamma_{ik}}, \qquad \boldsymbol{\Sigma}_k = \frac{\sum_i \gamma_{ik} (\mathbf{x}_i - \boldsymbol{\mu}_k)(\mathbf{x}_i - \boldsymbol{\mu}_k)^\top}{\sum_i \gamma_{ik}}" />
        </div>

        <p className="text-gray-700 dark:text-gray-300">
          <strong>Detección de anomalías:</strong> se calcula la log-densidad{' '}
          <InlineMath math="\log \hat{p}(\mathbf{x}_i)" /> y se declara anomalía
          si está por debajo del percentil 5 %. <strong>Advertencia:</strong>{' '}
          pertenecer a un componente pequeño no implica ser anomalía; la
          anomalía se define por baja densidad global.
        </p>
      </motion.article>

      {/* ---------- LOF ---------- */}
      <motion.article
        initial={{ opacity: 0, y: 20 }}
        whileInView={{ opacity: 1, y: 0 }}
        viewport={{ once: true, margin: '-50px' }}
        transition={{ duration: 0.5, delay: 0.1 }}
        className="bg-white dark:bg-slate-800 rounded-xl shadow-sm p-8"
      >
        <h3 className="text-2xl font-extrabold text-primary dark:text-blue-300 mb-4">
          Local Outlier Factor (LOF)
        </h3>

        <p className="text-gray-700 dark:text-gray-300 mb-4">
          LOF compara la densidad local de cada observación con la de sus{' '}
          <InlineMath math="k" /> vecinos más cercanos. Una observación es
          anómala si su densidad local es mucho menor que la de sus vecinos.
        </p>

        <p className="text-sm font-semibold text-gray-800 dark:text-gray-200 mb-2">
          Reachability distance (distancia de alcanzabilidad):
        </p>
        <div className="bg-gray-50 dark:bg-slate-900 rounded-lg p-4 mb-4 overflow-x-auto">
          <BlockMath math="\text{reach-dist}_k(\mathbf{x}, \mathbf{o}) = \max\!\left\{k\text{-distance}(\mathbf{o}),\; d(\mathbf{x}, \mathbf{o})\right\}" />
        </div>

        <p className="text-sm font-semibold text-gray-800 dark:text-gray-200 mb-2">
          Local Reachability Density (LRD):
        </p>
        <div className="bg-gray-50 dark:bg-slate-900 rounded-lg p-4 mb-4 overflow-x-auto">
          <BlockMath math="\text{lrd}_k(\mathbf{x}) = \left(\frac{1}{|N_k(\mathbf{x})|} \sum_{\mathbf{o} \in N_k(\mathbf{x})} \text{reach-dist}_k(\mathbf{x}, \mathbf{o})\right)^{-1}" />
        </div>

        <p className="text-sm font-semibold text-gray-800 dark:text-gray-200 mb-2">
          Local Outlier Factor:
        </p>
        <div className="bg-gray-50 dark:bg-slate-900 rounded-lg p-4 mb-4 overflow-x-auto">
          <BlockMath math="\text{LOF}_k(\mathbf{x}) = \frac{1}{|N_k(\mathbf{x})|} \sum_{\mathbf{o} \in N_k(\mathbf{x})} \frac{\text{lrd}_k(\mathbf{o})}{\text{lrd}_k(\mathbf{x})}" />
        </div>

        <p className="text-gray-700 dark:text-gray-300">
          <strong>Interpretación:</strong> <InlineMath math="\text{LOF} \approx 1" />{' '}
          indica densidad similar a los vecinos (normal).{' '}
          <InlineMath math="\text{LOF} > 1" /> indica densidad local menor
          (posible anomalía). <InlineMath math="\text{LOF} \gg 1" /> indica
          anomalía fuerte. En este trabajo se usa el percentil 95 de LOF como
          umbral (equivalente al 5 % superior).
        </p>
      </motion.article>

      {/* ---------- Comparación ---------- */}
      <motion.article
        initial={{ opacity: 0, y: 20 }}
        whileInView={{ opacity: 1, y: 0 }}
        viewport={{ once: true, margin: '-50px' }}
        transition={{ duration: 0.5, delay: 0.2 }}
        className="bg-white dark:bg-slate-800 rounded-xl shadow-sm p-8"
      >
        <h3 className="text-2xl font-extrabold text-primary dark:text-blue-300 mb-4">
          ¿Por qué comparar GMM y LOF?
        </h3>
        <div className="grid md:grid-cols-2 gap-6">
          <div>
            <h4 className="font-bold text-gray-800 dark:text-gray-200 mb-2">GMM</h4>
            <ul className="text-sm text-gray-700 dark:text-gray-300 space-y-1 list-disc list-inside">
              <li>Modela la distribución <strong>global</strong>.</li>
              <li>Detecta observaciones en regiones de baja probabilidad.</li>
              <li>Asume normalidad multivariante por componente.</li>
              <li>Salida: densidad estimada (probabilidad).</li>
            </ul>
          </div>
          <div>
            <h4 className="font-bold text-gray-800 dark:text-gray-200 mb-2">LOF</h4>
            <ul className="text-sm text-gray-700 dark:text-gray-300 space-y-1 list-disc list-inside">
              <li>Modela la densidad <strong>local</strong>.</li>
              <li>Detecta observaciones raras en su vecindario.</li>
              <li>No asume distribución; usa distancias.</li>
              <li>Salida: puntuación de anomalía (no probabilidad).</li>
            </ul>
          </div>
        </div>
        <p className="text-gray-700 dark:text-gray-300 mt-4">
          <strong>Hipótesis:</strong> si ambos métodos detectan los mismos
          hogares, hay evidencia fuerte de anomalía. Si divergen, miden
          dimensiones distintas y son <strong>complementarios</strong>.
        </p>
      </motion.article>
    </div>
  );
}