import { BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer, Legend } from 'recharts';
import { useCSV, EfectoLog1p } from '../../data/loaders';

export default function EfectoLog1pChart() {
  const { data, loading } = useCSV<EfectoLog1p>('fase8_efecto_log1p.csv');
  if (loading) return <p className="text-gray-400">Cargando…</p>;

  const chartData = data.map((d) => ({
    metodo: d.metodo,
    principal: Number(d.n_principal),
    sensibilidad: Number(d.n_sens),
    coinciden: Number(d.n_ambos),
    jaccard: Number(d.jaccard),
  }));

  return (
    <div className="bg-white dark:bg-slate-800 rounded-xl shadow-sm p-6">
      <h3 className="font-bold text-primary dark:text-blue-300 mb-4">
        Efecto de <code>log(1+x)</code> en las detecciones
      </h3>
      <ResponsiveContainer width="100%" height={320}>
        <BarChart data={chartData}>
          <XAxis dataKey="metodo" />
          <YAxis />
          <Tooltip />
          <Legend />
          <Bar dataKey="principal" name="Con log1p" fill="#2E5E8C" radius={[6, 6, 0, 0]} />
          <Bar dataKey="sensibilidad" name="Sin log1p" fill="#B22222" radius={[6, 6, 0, 0]} />
          <Bar dataKey="coinciden" name="Coinciden" fill="#E07B39" radius={[6, 6, 0, 0]} />
        </BarChart>
      </ResponsiveContainer>
      <p className="text-xs text-gray-500 dark:text-gray-400 mt-2">
        Jaccard: GMM = {chartData.find((d) => d.metodo === 'GMM')?.jaccard.toFixed(3)} · LOF = {chartData.find((d) => d.metodo === 'LOF')?.jaccard.toFixed(3)}
      </p>
    </div>
  );
}