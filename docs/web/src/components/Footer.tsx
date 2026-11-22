export default function Footer() {
  return (
    <footer className="bg-gray-900 text-gray-300 py-12 px-6">
      <div className="container-page grid md:grid-cols-3 gap-8">
        <div>
          <h4 className="font-bold text-white mb-3">Proyecto</h4>
          <p className="text-sm">Detección de anomalías en gasto no alimentario — EH2025 Bolivia.</p>
          <p className="text-sm mt-2">Minería de Datos · Noviembre 2026</p>
        </div>
        <div>
          <h4 className="font-bold text-white mb-3">Enlaces</h4>
          <ul className="space-y-1 text-sm">
            <li><a href="./informe.pdf" className="hover:text-white underline">Informe completo (PDF)</a></li>
            <li><a href="https://github.com/[usuario]/[repo]" className="hover:text-white underline" target="_blank" rel="noopener noreferrer">Repositorio en GitHub</a></li>
            <li><a href="./data/" className="hover:text-white underline">Datos procesados (CSV)</a></li>
          </ul>
        </div>
        <div>
          <h4 className="font-bold text-white mb-3">Fuente de datos</h4>
          <p className="text-sm">Instituto Nacional de Estadística de Bolivia</p>
          <a href="https://anda.ine.gob.bo/index.php/catalog/256" target="_blank" rel="noopener noreferrer" className="text-blue-300 underline text-sm">
            Encuesta de Hogares 2025
          </a>
        </div>
      </div>
      <div className="container-page mt-8 pt-6 border-t border-gray-700 text-center text-xs text-gray-500">
        © 2026 · Todos los derechos reservados.
      </div>
    </footer>
  );
}