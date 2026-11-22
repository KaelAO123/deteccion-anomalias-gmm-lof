import { motion } from "framer-motion";
import { ReactNode } from "react";
import AnimatedNumber from "./AnimatedNumber";

interface Props {
  value: ReactNode;
  label: string;
  accent?: "primary" | "accent";
}

export default function StatCard({ value, label, accent = "primary" }: Props) {
  return (
    <motion.div
      whileHover={{ y: -4 }}
      className="bg-white rounded-xl shadow-sm border border-gray-100 p-6 text-center"
    >
      <div
        className={`text-3xl font-extrabold mb-1 ${accent === "accent" ? "text-accent" : "text-primary"}`}
      >
        {typeof value === "number" ? <AnimatedNumber value={value} /> : value}
      </div>
      <div className="text-xs uppercase tracking-wider text-gray-500">
        {label}
      </div>
    </motion.div>
  );
}
