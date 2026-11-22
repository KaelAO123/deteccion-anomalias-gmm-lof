import { motion } from 'framer-motion';
import { ReactNode } from 'react';

interface Paso {
  titulo: string;
  descripcion: string;
  detalle: string;
  icono: ReactNode;
}

const IconPreproc = () => (
  <svg className="w-8 h-8" fill="none" stroke="currentColor" strokeWidth={1.8} viewBox="0 0 24 24">
    <path strokeLinecap="round" strokeLinejoin="round" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
    <path strokeLinecap="round" strokeLinejoin="round" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
  </svg>
);

const IconGmm = () => (
  <svg className="w-8 h-8" fill="none" stroke="currentColor" strokeWidth={1.8} viewBox="0 0 24 24">
    <path strokeLinecap="round" strokeLinejoin="round" d="M3 17l6-6 4 4 8-8" />
    <circle cx="9" cy="11" r="1.5" fill="currentColor" />
    <circle cx="13" cy="15" r="1.5" fill="currentColor" />
    <circle cx="21" cy="7" r="1.5" fill="currentColor" />
  </svg>
);

const IconLof = () => (
  <svg className="w-8 h-8" fill="none" stroke="currentColor" strokeWidth={1.8} viewBox="0 0 24 24">
    <circle cx="12" cy="12" r="3" />
    <circle cx="12" cy="12" r="7" strokeDasharray="3 3" />
    <circle cx="12" cy="12" r="10" strokeDasharray="2 4" />
    <circle cx="18" cy="6" r="1.5" fill="currentColor" />
    <circle cx="6" cy="18" r="1.5" fill="currentColor" />
  </svg>
);

const IconCompare = () => (
  <svg className="w-8 h-8" fill="none" stroke="currentColor" strokeWidth={1.8} viewBox="0 0 24 24">
    <path strokeLinecap="round" strokeLinejoin="round" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2" />
    <rect x="9" y="3" width="6" height="4" rx="1" />
    <path strokeLinecap="round" strokeLinejoin="round" d="M9 12h6M9 16h6" />
  </svg>
);

const pasos: Paso[] = [
  {
    titulo: 'Preprocesamiento',
    descripcion: 'Exclusión de 6 variables con >95 % de ceros y 95 hogares sin gasto mensual. Transformación log(1+x) + z-score.',
    detalle: '12.726 → 12.631 hogares · 28 → 22 variables',
    icono: <IconPreproc />,
  },
  {
    titulo: 'GMM',
    descripcion: 'Selección de modelo VEV con 13 componentes vía BIC. Detección por baja log-densidad (percentil 5 %).',
    detalle: '632 anomalías · BIC = −427.984',
    icono: <IconGmm />,
  },
  {
    titulo: 'LOF',
    descripcion: 'Selección de k = 20 vía análisis de sensibilidad. Detección por LOF alto (percentil 95).',
    detalle: '632 anomalías · k = 20',
    icono: <IconLof />,
  },
  {
    titulo: 'Comparación',
    descripcion: 'Matriz de confusión, Jaccard, kappa. Caracterización socioeconómica por departamento, área y estrato.',
    detalle: '22 coincidencias · Jaccard = 0,0177',
    icono: <IconCompare />,
  },
];

export default function Metodologia() {
  return (
    <div className="space-y-4">
      {pasos.map((paso, i) => (
        <motion.div
          key={i}
          initial={{ opacity: 0, x: -20 }}
          whileInView={{ opacity: 1, x: 0 }}
          viewport={{ once: true, margin: '-50px' }}
          transition={{ duration: 0.5, delay: i * 0.1 }}
          className="bg-white dark:bg-slate-800 rounded-xl shadow-sm p-6 flex gap-4 items-start"
        >
          <div className="text-primary dark:text-blue-300 flex-shrink-0 mt-1">
            {paso.icono}
          </div>
          <div className="flex-1">
            <div className="flex items-center gap-3 mb-1">
              <span className="bg-primary text-white text-xs font-bold rounded-full w-6 h-6 flex items-center justify-center">
                {i + 1}
              </span>
              <h3 className="font-bold text-primary dark:text-blue-300">{paso.titulo}</h3>
            </div>
            <p className="text-gray-700 dark:text-gray-300 text-sm">{paso.descripcion}</p>
            <p className="text-xs text-accent font-mono mt-2">{paso.detalle}</p>
          </div>
        </motion.div>
      ))}
    </div>
  );
}