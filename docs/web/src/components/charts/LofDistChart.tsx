import { useCSV } from '../../data/loaders';

// Usa el PNG de output/figures/lof_distribucion.png como fallback visual
export default function LofDistChart() {
  return (
    <div className="bg-white dark:bg-slate-800 rounded-xl shadow-sm p-4">
      <img
        src="./figures/lof_distribucion.png"
        alt="Distribución de LOF con umbrales al percentil 95, mediana+3MAD y Q3+1.5IQR"
        className="w-full rounded-lg"
      />
      <p className="text-xs text-gray-500 dark:text-gray-400 mt-2 italic">
        La cola derecha concentra los hogares con densidad local baja.
      </p>
    </div>
  );
}