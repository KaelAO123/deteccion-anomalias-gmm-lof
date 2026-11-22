import { useCSV, CaractDepto } from '../../data/loaders';

const DEPTO_NOMBRE: Record<number, string> = {
  1: 'Chuquisaca', 2: 'La Paz', 3: 'Cochabamba', 4: 'Oruro', 5: 'Potosí',
  6: 'Tarija', 7: 'Santa Cruz', 8: 'Beni', 9: 'Pando',
};

const CATS = ['Ambos', 'Solo GMM', 'Solo LOF'] as const;

export default function DeptoHeatmap() {
  const { data, loading } = useCSV<CaractDepto>('fase8_caract_depto.csv');
  if (loading) return <p className="text-gray-400">Cargando…</p>;

  const byDepto = data.reduce<Record<number, Record<string, number>>>((acc, row) => {
    if (!acc[row.depto]) acc[row.depto] = {};
    acc[row.depto][row.categoria] = Number(row.pct);
    return acc;
  }, {});

  const maxPct = Math.max(
    ...data.filter((d) => CATS.includes(d.categoria as any)).map((d) => Number(d.pct))
  );

  const colorFor = (pct: number) => {
    if (!pct) return 'bg-gray-50 dark:bg-slate-700';
    const intensity = Math.min(pct / maxPct, 1);
    return `rgba(178, 34, 34, ${0.15 + intensity * 0.75})`;
  };

  return (
    <div className="bg-white dark:bg-slate-800 rounded-xl shadow-sm p-6 overflow-x-auto">
      <h3 className="font-bold text-primary dark:text-blue-300 mb-4">
        % de hogares detectados por departamento
      </h3>
      <table className="w-full text-sm">
        <thead>
          <tr className="border-b border-gray-200 dark:border-slate-600">
            <th className="text-left py-2 font-semibold text-gray-600 dark:text-gray-300">Departamento</th>
            {CATS.map((c) => (
              <th key={c} className="text-center py-2 font-semibold text-gray-600 dark:text-gray-300">{c}</th>
            ))}
          </tr>
        </thead>
        <tbody>
          {Object.keys(byDepto).map((d) => {
            const num = Number(d);
            return (
              <tr key={d} className="border-b border-gray-100 dark:border-slate-700">
                <td className="py-2 text-gray-800 dark:text-gray-200">{DEPTO_NOMBRE[num] ?? `Depto ${num}`}</td>
                {CATS.map((c) => {
                  const pct = byDepto[num][c] ?? 0;
                  return (
                    <td
                      key={c}
                      className="text-center py-2 font-mono text-xs"
                      style={{ backgroundColor: colorFor(pct), color: pct > maxPct * 0.6 ? 'white' : '#1A1A1A' }}
                    >
                      {pct.toFixed(2)}%
                    </td>
                  );
                })}
              </tr>
            );
          })}
        </tbody>
      </table>
    </div>
  );
}