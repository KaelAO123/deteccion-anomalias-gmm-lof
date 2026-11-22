import { motion, useScroll, useSpring, AnimatePresence } from "framer-motion";
import { useEffect, useState } from "react";
import ThemeToggle from "./ThemeToggle";

const links = [
  { href: "#resumen", label: "Resumen" },
  { href: "#dataset", label: "Dataset" },
  { href: "#metodologia", label: "Metodología" },
  { href: "#metodos", label: "Métodos" },
  { href: "#gmm", label: "GMM" },
  { href: "#lof", label: "LOF" },
  { href: "#comparacion", label: "Comparación" },
  { href: "#conclusiones", label: "Conclusiones" },
  { href: "#limitaciones", label: "Limitaciones" },
];

export default function Nav() {
  const [active, setActive] = useState("");
  const [scrolled, setScrolled] = useState(false);
  const [menuOpen, setMenuOpen] = useState(false);

  const { scrollYProgress } = useScroll();
  const scaleX = useSpring(scrollYProgress, {
    stiffness: 100,
    damping: 30,
    restDelta: 0.001,
  });

  useEffect(() => {
    const onScroll = () => {
      setScrolled(window.scrollY > 50);
      const sections = links
        .map((l) => document.querySelector(l.href))
        .filter(Boolean) as Element[];
      const current = sections.find((s) => {
        const rect = s.getBoundingClientRect();
        return rect.top <= 120 && rect.bottom >= 120;
      });
      setActive(current ? `#${current.id}` : "");
    };
    window.addEventListener("scroll", onScroll, { passive: true });
    onScroll();
    return () => window.removeEventListener("scroll", onScroll);
  }, []);

  useEffect(() => {
    document.body.style.overflow = menuOpen ? "hidden" : "";
    return () => {
      document.body.style.overflow = "";
    };
  }, [menuOpen]);

  const handleLinkClick = () => setMenuOpen(false);

  // Colores dinámicos según estado
  const textBase = scrolled
    ? "text-gray-700 dark:text-gray-200"
    : "text-white/90";
  const textHover = scrolled
    ? "hover:text-primary dark:hover:text-blue-300"
    : "hover:text-white";
  const textActive = scrolled
    ? "text-primary dark:text-blue-300"
    : "text-white";
  const brandColor = scrolled
    ? "text-primary dark:text-blue-300"
    : "text-white";

  return (
    <>
      <motion.div
        className="fixed top-0 left-0 right-0 h-1 bg-accent origin-left z-[60]"
        style={{ scaleX }}
        aria-hidden="true"
      />

      <motion.nav
        className={`fixed top-0 inset-x-0 z-50 transition-all duration-300 ${
          scrolled
            ? "bg-white/90 dark:bg-slate-900/90 backdrop-blur shadow-sm"
            : "bg-transparent"
        }`}
        initial={{ y: -20, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ duration: 0.4 }}
      >
        <div className="container-page flex items-center justify-between py-4">
          <a
            href="#hero"
            className={`font-extrabold text-lg transition-colors ${brandColor}`}
          >
            EH2025 · Anomalías
          </a>

          <ul className="hidden md:flex items-center gap-6">
            {links.map((l) => (
              <li key={l.href}>
                <a
                  href={l.href}
                  className={`text-sm transition-colors relative ${
                    active === l.href
                      ? `${textActive} font-semibold`
                      : `${textBase} ${textHover}`
                  }`}
                >
                  {l.label}
                  {active === l.href && (
                    <motion.span
                      layoutId="nav-underline"
                      className="absolute -bottom-1 left-0 right-0 h-0.5 bg-accent rounded-full"
                      transition={{
                        type: "spring",
                        stiffness: 380,
                        damping: 30,
                      }}
                    />
                  )}
                </a>
              </li>
            ))}
          </ul>

          <div className="flex items-center gap-2">
            {/* ThemeToggle con contraste adaptado */}
            <div className={scrolled ? "" : "text-white"}>
              <ThemeToggle />
            </div>

            <button
              onClick={() => setMenuOpen(!menuOpen)}
              className={`md:hidden p-2 rounded-lg transition ${
                scrolled
                  ? "hover:bg-gray-100 dark:hover:bg-slate-700"
                  : "hover:bg-white/10"
              }`}
              aria-label={menuOpen ? "Cerrar menú" : "Abrir menú"}
              aria-expanded={menuOpen}
              aria-controls="mobile-menu"
            >
              <svg
                className={`w-6 h-6 ${
                  scrolled ? "text-gray-700 dark:text-gray-200" : "text-white"
                }`}
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                {menuOpen ? (
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M6 18L18 6M6 6l12 12"
                  />
                ) : (
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M4 6h16M4 12h16M4 18h16"
                  />
                )}
              </svg>
            </button>
          </div>
        </div>

        <AnimatePresence>
          {menuOpen && (
            <motion.div
              id="mobile-menu"
              initial={{ height: 0, opacity: 0 }}
              animate={{ height: "auto", opacity: 1 }}
              exit={{ height: 0, opacity: 0 }}
              transition={{ duration: 0.25 }}
              className="md:hidden overflow-hidden bg-white dark:bg-slate-900 border-t border-gray-200 dark:border-slate-700"
            >
              <ul className="container-page py-4 space-y-1">
                {links.map((l) => (
                  <li key={l.href}>
                    <a
                      href={l.href}
                      onClick={handleLinkClick}
                      className={`block py-2.5 px-3 rounded-lg text-sm transition-colors ${
                        active === l.href
                          ? "bg-blue-50 dark:bg-slate-800 text-primary dark:text-blue-300 font-semibold"
                          : "text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-slate-800"
                      }`}
                    >
                      {l.label}
                    </a>
                  </li>
                ))}
              </ul>
            </motion.div>
          )}
        </AnimatePresence>
      </motion.nav>
    </>
  );
}
