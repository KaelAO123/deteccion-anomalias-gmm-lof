import { useEffect, useRef, useState } from 'react';
import { useInView } from 'framer-motion';

interface Props {
  value: number;
  duration?: number;
  format?: (n: number) => string;
}

export default function AnimatedNumber({ value, duration = 1200, format = (n) => n.toLocaleString() }: Props) {
  const ref = useRef<HTMLSpanElement>(null);
  const inView = useInView(ref, { once: true, margin: '-50px' });
  const [display, setDisplay] = useState(0);

  useEffect(() => {
    if (!inView) return;
    const start = performance.now();
    const step = (now: number) => {
      const elapsed = now - start;
      const progress = Math.min(elapsed / duration, 1);
      // easeOutCubic
      const eased = 1 - Math.pow(1 - progress, 3);
      setDisplay(Math.round(value * eased));
      if (progress < 1) requestAnimationFrame(step);
    };
    requestAnimationFrame(step);
  }, [inView, value, duration]);

  return <span ref={ref}>{format(display)}</span>;
}