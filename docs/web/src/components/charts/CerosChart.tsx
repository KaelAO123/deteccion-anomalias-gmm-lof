import { BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer, ReferenceLine } from 'recharts';
import { useCSV, Univariado } from '../../data/loaders';

export default function CerosChart() {
  const { data, loading } = useCSV<Univariado>('fase3_resumen_univariado.csv');

  if (loading) return <p className="text-gray-400">Cargando…</p>;

  const chartData = data
    .slice()
    .sort((a, b) => b.pct_cero - a.pct_cero)
    .map((d) => ({
      variable: d.variable.replace('s08b_10_', '_'),
      pct_cero: Number(d.pct_cero),
    }));

  return (
    <div className="bg-white rounded-xl shadow-sm p-6">
      <h3 className="font-bold text-primary mb-4">Proporción de ceros por variable</h3>
      <ResponsiveContainer width="100%" height={400}>
        <BarChart data={chartData} layout="vertical" margin={{ left: 30, right: 20 }}>
          <XAxis type="number" domain={[0, 100]} tickFormatter={(v) => `${v}%`} />
          <YAxis type="category" dataKey="variable" width={80} tick={{ fontSize: 11 }} />
          <Tooltip formatter={(v: number) => `${v.toFixed(1)}%`} />
          <ReferenceLine x={90} stroke="#B22222" strokeDasharray="4 4" />
          <Bar dataKey="pct_cero" fill="#2E5E8C" radius={[0, 4, 4, 0]} />
        </BarChart>
      </ResponsiveContainer>
      <p className="text-xs text-gray-500 mt-2">Línea roja: umbral del 90 %.</p>
    </div>
  );
}