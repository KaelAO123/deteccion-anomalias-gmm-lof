import Nav from "./components/Nav";
import Hero from "./components/Hero";
import Section from "./components/Section";
import StatCard from "./components/StatCard";
import Callout from "./components/Callout";
import Footer from "./components/Footer";
import CerosChart from "./components/charts/CerosChart";
import BicChart from "./components/charts/BicChart";
import LofSensChart from "./components/charts/LofSensChart";
import ConfusionMatrix from "./components/charts/ConfusionMatrix";
import CategoryChart from "./components/charts/CategoryChart";
import ScatterPca from "./components/charts/ScatterPca";
import DeptoHeatmap from "./components/charts/DeptoHeatmap";
import EfectoLog1pChart from "./components/charts/EfectoLog1pChart";
import Metodologia from "./sections/Metodologia";
import Limitaciones from "./sections/Limitaciones";
import Metodos from "./sections/Metodos";

export default function App() {
  return (
    <>
      <Nav />
      <Hero />

      <Section id="resumen" title="Resumen ejecutivo">
        <Callout variant="warning">
          <p className="text-lg">
            <strong>Hallazgo principal:</strong> GMM y LOF detectan{" "}
            <strong>632 hogares anómalos cada uno (5,00 %)</strong>, pero solo{" "}
            <strong>22 hogares coinciden</strong>. Los métodos son{" "}
            <strong>complementarios, no redundantes</strong>.
          </p>
        </Callout>
      </Section>

      <Section id="dataset" title="Dataset: Encuesta de Hogares 2025" alt>
        <div className="grid md:grid-cols-3 gap-6 mb-8">
          <StatCard value={12726} label="Hogares en la muestra" />
          <StatCard value={60} label="Variables de gasto" />
          <StatCard value={4} label="Horizontes temporales" />
        </div>
        <CerosChart />
      </Section>

      <Section id="metodologia" title="Metodología">
        <Metodologia />
      </Section>

      <Section id="metodos" title="Métodos: GMM y LOF" alt>
        <Metodos />
      </Section>
      
      <Section id="gmm" title="Resultados GMM" alt>
        <div className="grid md:grid-cols-3 gap-6 mb-8">
          <StatCard value="VEV · 13" label="Estructura · Componentes" />
          <StatCard value="−427.984" label="BIC" accent="accent" />
          <StatCard value={632} label="Anomalías (p5)" />
        </div>
        <div className="grid md:grid-cols-2 gap-6">
          <BicChart />
          <figure className="bg-white dark:bg-slate-800 rounded-xl shadow-sm p-4">
            <img
              src="./figures/gmm_logdens.png"
              alt="Distribución de log-densidad bajo GMM"
              className="w-full rounded-lg"
            />
            <figcaption className="text-xs text-gray-500 dark:text-gray-400 mt-2 italic">
              Distribución de log-densidad bajo GMM.
            </figcaption>
          </figure>
        </div>
      </Section>

      <Section id="lof" title="Resultados LOF">
        <div className="grid md:grid-cols-3 gap-6 mb-8">
          <StatCard value="k = 20" label="Vecinos" />
          <StatCard value="1,539" label="Umbral (p95)" accent="accent" />
          <StatCard value={632} label="Anomalías" />
        </div>
        <div className="grid md:grid-cols-2 gap-6">
          <LofSensChart />
          <figure className="bg-white dark:bg-slate-800 rounded-xl shadow-sm p-4">
            <img
              src="./figures/lof_distribucion.png"
              alt="Distribución de LOF con umbrales"
              className="w-full rounded-lg"
            />
            <figcaption className="text-xs text-gray-500 dark:text-gray-400 mt-2 italic">
              Distribución de LOF (k = 20).
            </figcaption>
          </figure>
        </div>
      </Section>

      <Section id="comparacion" title="Comparación GMM vs LOF" alt>
        <Callout variant="warning">
          <p className="text-lg">
            Solo <strong>22 hogares</strong> (0,17 %) fueron detectados por
            ambos métodos. Jaccard = <strong>0,0177</strong>; κ ={" "}
            <strong>−0,016</strong>.
          </p>
        </Callout>
        <div className="grid md:grid-cols-2 gap-6 mt-8">
          <ConfusionMatrix />
          <CategoryChart />
        </div>
        <div className="grid md:grid-cols-2 gap-6 mt-6">
          <ScatterPca />
          <EfectoLog1pChart />
        </div>
        <div className="mt-6">
          <DeptoHeatmap />
        </div>
      </Section>

      <Section id="conclusiones" title="Conclusiones">
        <ol className="space-y-4">
          {[
            [
              "GMM y LOF son complementarios, no redundantes.",
              "La coincidencia casi nula (22 hogares) confirma que miden dimensiones distintas.",
            ],
            [
              "GMM detecta la élite de gasto.",
              "Hogares urbanos (93,9 %) con gasto alto (mediana 1.825 Bs).",
            ],
            [
              "LOF detecta la pobreza contextual.",
              "Hogares rurales (56,4 %) con gasto bajo (mediana 157,5 Bs).",
            ],
            [
              "La transformación importa.",
              "Sin log(1+x), las detecciones cambian en un 80–90 %.",
            ],
            [
              "Ningún método es suficiente por sí solo.",
              "La combinación ofrece una caracterización más rica.",
            ],
          ].map(([title, desc], i) => (
            <li
              key={i}
              className="bg-white dark:bg-slate-800 rounded-xl shadow-sm p-6 border-l-4 border-accent"
            >
              <div className="flex items-start gap-4">
                <span className="bg-accent text-white font-bold rounded-full w-8 h-8 flex items-center justify-center flex-shrink-0">
                  {i + 1}
                </span>
                <div>
                  <strong className="text-primary dark:text-blue-300">
                    {title}
                  </strong>
                  <p className="text-gray-600 dark:text-gray-300 mt-1">
                    {desc}
                  </p>
                </div>
              </div>
            </li>
          ))}
        </ol>
      </Section>

      <Section id="limitaciones" title="Limitaciones" alt>
        <Limitaciones />
      </Section>

      <Footer />
    </>
  );
}
