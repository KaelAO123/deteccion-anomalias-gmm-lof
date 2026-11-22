const limitaciones = [
  {
    titulo: 'Ausencia de etiquetas verdaderas',
    detalle: 'No hay una clasificación previa de qué hogares son "anómalos". La evaluación es no supervisada y se basa en coincidencia entre métodos, estabilidad y interpretabilidad.',
  },
  {
    titulo: 'Alta proporción de ceros',
    detalle: '22 de 28 variables superan el 50 % de ceros. La transformación log(1+x) mitiga pero no elimina la asimetría residual.',
  },
  {
    titulo: 'Maldición de la dimensionalidad',
    detalle: 'Con 22 dimensiones, LOF puede perder poder discriminante. Se mitigó con estandarización y k = 20, pero persiste.',
  },
  {
    titulo: 'Un solo horizonte temporal',
    detalle: 'Solo se analizó el módulo mensual. Los módulos trimestral, semestral y anual quedan como trabajo futuro.',
  },
  {
    titulo: 'Interpretación socioeconómica',
    detalle: 'Las anomalías no son errores ni fraudes. Un gasto alto o bajo puede deberse a razones legítimas (composición del hogar, ingreso, preferencias).',
  },
];

export default function Limitaciones() {
  return (
    <ul className="space-y-3">
      {limitaciones.map((l, i) => (
        <li key={i} className="bg-white dark:bg-slate-800 rounded-xl shadow-sm p-5 border-l-4 border-accent">
          <strong className="text-primary dark:text-blue-300">{l.titulo}</strong>
          <p className="text-sm text-gray-700 dark:text-gray-300 mt-1">{l.detalle}</p>
        </li>
      ))}
    </ul>
  );
}