import { BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer, Cell } from 'recharts';
import { useCSV, GmmBic } from '../../data/loaders';

export default function BicChart() {
  const { data, loading } = useCSV<GmmBic>('gmm_bic.csv');
  if (loading) return <p className="text-gray-400">Cargando…</p>;

  const chartData = data.map((d) => ({
    modelo: d.modelo,
    BIC: Number(d.BIC),
    seleccionado: d.seleccionado,
  }));

  return (
    <div className="bg-white rounded-xl shadow-sm p-6">
      <h3 className="font-bold text-primary mb-4">Comparación BIC (G = 13)</h3>
      <ResponsiveContainer width="100%" height={320}>
        <BarChart data={chartData}>
          <XAxis dataKey="modelo" />
          <YAxis tickFormatter={(v) => `${(v / 1000).toFixed(0)}k`} />
          <Tooltip formatter={(v: number) => v.toLocaleString()} />
          <Bar dataKey="BIC" radius={[8, 8, 0, 0]}>
            {chartData.map((d, i) => (
              <Cell key={i} fill={d.seleccionado ? '#B22222' : '#2E5E8C'} />
            ))}
          </Bar>
        </BarChart>
      </ResponsiveContainer>
      <p className="text-xs text-gray-500 mt-2">Rojo: modelo seleccionado (VEV).</p>
    </div>
  );
}