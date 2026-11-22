import { LineChart, Line, XAxis, YAxis, Tooltip, ResponsiveContainer, Legend } from 'recharts';
import { useCSV, LofSensibilidad } from '../../data/loaders';

export default function LofSensChart() {
  const { data, loading } = useCSV<LofSensibilidad>('lof_sensibilidad_k.csv');
  if (loading) return <p className="text-gray-400">Cargando…</p>;

  const chartData = data.map((d) => ({
    k: d.k,
    p95: Number(d.lof_p95),
    p99: Number(d.lof_p99),
    mediana: Number(d.lof_mediana),
  }));

  return (
    <div className="bg-white rounded-xl shadow-sm p-6">
      <h3 className="font-bold text-primary mb-4">Sensibilidad de LOF a k</h3>
      <ResponsiveContainer width="100%" height={320}>
        <LineChart data={chartData}>
          <XAxis dataKey="k" />
          <YAxis scale="log" domain={['auto', 'auto']} />
          <Tooltip />
          <Legend />
          <Line type="monotone" dataKey="mediana" stroke="#666" name="Mediana" />
          <Line type="monotone" dataKey="p95" stroke="#B22222" name="P95" strokeWidth={2} />
          <Line type="monotone" dataKey="p99" stroke="#2E5E8C" name="P99" />
        </LineChart>
      </ResponsiveContainer>
    </div>
  );
}