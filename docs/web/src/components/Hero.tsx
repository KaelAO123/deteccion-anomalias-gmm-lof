import { motion } from 'framer-motion';

export default function Hero() {
  return (
    <header
      id="hero"
      className="relative bg-gradient-to-br from-primary-dark via-primary to-primary-dark text-white pt-32 pb-24 px-6 overflow-hidden"
    >
      {/* Patrón de fondo */}
      <div className="absolute inset-0 opacity-10 pointer-events-none">
        <div className="absolute -top-32 -right-32 w-96 h-96 rounded-full bg-white blur-3xl" />
        <div className="absolute -bottom-32 -left-32 w-96 h-96 rounded-full bg-white blur-3xl" />
      </div>

      <div className="container-page relative max-w-4xl text-center">
        <motion.p
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.1 }}
          className="text-sm uppercase tracking-widest opacity-80 mb-6"
        >
          Minería de Datos · Noviembre 2026
        </motion.p>
        <motion.h1
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.2 }}
          className="text-3xl md:text-5xl font-extrabold leading-tight mb-6"
        >
          Detección de anomalías en el gasto no alimentario mensual de los hogares bolivianos
        </motion.h1>
        <motion.p
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.3 }}
          className="text-lg md:text-xl opacity-95 mb-10"
        >
          Una aplicación de <strong>Gaussian Mixture Models</strong> y{' '}
          <strong>Local Outlier Factor</strong> a la Encuesta de Hogares 2025
        </motion.p>
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.4 }}
          className="flex gap-4 justify-center flex-wrap"
        >
          <a href="#resumen" className="bg-white text-primary font-semibold px-6 py-3 rounded-lg hover:bg-gray-100 transition">
            Ver resultados
          </a>
          <a href="#comparacion" className="border-2 border-white font-semibold px-6 py-3 rounded-lg hover:bg-white hover:text-primary transition">
            Ir a la comparación
          </a>
        </motion.div>
      </div>
    </header>
  );
}