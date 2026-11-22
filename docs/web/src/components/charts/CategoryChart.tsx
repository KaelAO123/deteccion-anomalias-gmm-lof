import { BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer, Cell } from 'recharts';
import { useCSV, CaractCategoria } from '../../data/loaders';

const COLOR: Record<string, string> = {
  Ambos: '#B22222',
  'Solo GMM': '#E07B39',
  'Solo LOF': '#2E5E8C',
  Ninguno: '#B0B0B0',
};

export default function CategoryChart() {
  const { data, loading } = useCSV<CaractCategoria>('fase8_caract_categoria.csv');
  if (loading) return <p className="text-gray-400">Cargando…</p>;

  const chartData = data.map((d) => ({
    categoria: d.categoria,
    mediana: Number(d.mediana_gasto),
    pct_urbano: Number(d.pct_urbano),
    n: Number(d.n),
  }));

  return (
    <div className="bg-white rounded-xl shadow-sm p-6">
      <h3 className="font-bold text-primary mb-4">Gasto mediano por categoría</h3>
      <ResponsiveContainer width="100%" height={320}>
        <BarChart data={chartData}>
          <XAxis dataKey="categoria" />
          <YAxis tickFormatter={(v) => `${(v / 1000).toFixed(1)}k`} />
          <Tooltip formatter={(v: number) => `${v.toLocaleString()} Bs`} />
          <Bar dataKey="mediana" radius={[8, 8, 0, 0]}>
            {chartData.map((d, i) => (
              <Cell key={i} fill={COLOR[d.categoria] ?? '#999'} />
            ))}
          </Bar>
        </BarChart>
      </ResponsiveContainer>
    </div>
  );
}