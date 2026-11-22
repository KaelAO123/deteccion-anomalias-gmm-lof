import { motion } from 'framer-motion';
import { ReactNode } from 'react';

interface Props {
  id: string;
  title: string;
  children: ReactNode;
  alt?: boolean;
}

export default function Section({ id, title, children, alt }: Props) {
  return (
    <section
      id={id}
      className={`py-20 px-6 ${alt ? 'bg-bg-alt dark:bg-slate-800/50' : ''}`}
    >
      <div className="container-page">
        <motion.h2
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: '-100px' }}
          transition={{ duration: 0.5 }}
          className="section-title"
        >
          {title}
        </motion.h2>
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: '-100px' }}
          transition={{ duration: 0.5, delay: 0.1 }}
        >
          {children}
        </motion.div>
      </div>
    </section>
  );
}