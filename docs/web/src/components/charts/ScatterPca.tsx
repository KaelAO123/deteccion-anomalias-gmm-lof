import {
  ScatterChart, Scatter, XAxis, YAxis, Tooltip,
  ResponsiveContainer, Cell, Legend,
} from 'recharts';
import { useCSV } from '../../data/loaders';

interface PcaPoint {
  PC1: number;
  PC2: number;
  categoria: string;
}

const COLOR: Record<string, string> = {
  Ambos: '#B22222',
  'Solo GMM': '#E07B39',
  'Solo LOF': '#2E5E8C',
  Ninguno: '#CBD5E1',
};

const SIZE: Record<string, number> = {
  Ambos: 60,
  'Solo GMM': 35,
  'Solo LOF': 35,
  Ninguno: 12,
};

const OPACITY: Record<string, number> = {
  Ambos: 0.95,
  'Solo GMM': 0.75,
  'Solo LOF': 0.75,
  Ninguno: 0.35,
};

const ORDEN = ['Ninguno', 'Solo LOF', 'Solo GMM', 'Ambos'];

export default function ScatterPca() {
  const { data, loading } = useCSV<PcaPoint>('fase8_pca_scatter.csv');
  if (loading) return <p className="text-gray-400">Cargando…</p>;

  return (
    <div className="bg-white dark:bg-slate-800 rounded-xl shadow-sm p-6">
      <h3 className="font-bold text-primary dark:text-blue-300 mb-4">
        Hogares en el espacio PCA
      </h3>
      <ResponsiveContainer width="100%" height={380}>
        <ScatterChart margin={{ top: 10, right: 20, bottom: 10, left: 0 }}>
          <XAxis
            type="number"
            dataKey="PC1"
            name="PC1"
            tick={{ fontSize: 10 }}
            stroke="#9CA3AF"
          />
          <YAxis
            type="number"
            dataKey="PC2"
            name="PC2"
            tick={{ fontSize: 10 }}
            stroke="#9CA3AF"
          />
          <Tooltip
            cursor={{ strokeDasharray: '3 3' }}
            content={({ active, payload }) => {
              if (!active || !payload?.length) return null;
              const p = payload[0].payload as PcaPoint;
              return (
                <div className="bg-white dark:bg-slate-900 border border-gray-200 dark:border-slate-700 rounded-lg p-2 text-xs shadow">
                  <div className="font-semibold" style={{ color: COLOR[p.categoria] }}>
                    {p.categoria}
                  </div>
                  <div className="text-gray-600 dark:text-gray-400">
                    PC1: {p.PC1.toFixed(2)} · PC2: {p.PC2.toFixed(2)}
                  </div>
                </div>
              );
            }}
          />
          <Legend
            wrapperStyle={{ fontSize: 12, paddingTop: 8 }}
            iconType="circle"
          />
          {ORDEN.map((cat) => {
            const puntos = data.filter((d) => d.categoria === cat);
            if (puntos.length === 0) return null;
            return (
              <Scatter
                key={cat}
                name={`${cat} (${puntos.length})`}
                data={puntos}
                fill={COLOR[cat]}
                fillOpacity={OPACITY[cat]}
                shape="circle"
                isAnimationActive={false}
              >
                {puntos.map((_, i) => (
                  <Cell key={i} fill={COLOR[cat]} r={SIZE[cat]} />
                ))}
              </Scatter>
            );
          })}
        </ScatterChart>
      </ResponsiveContainer>
      <p className="text-xs text-gray-500 dark:text-gray-400 mt-2">
        Para legibilidad, se muestran todos los puntos de interés y una muestra
        aleatoria de 800 hogares «Ninguno». El PCA no se usó como predictor.
      </p>
    </div>
  );
}