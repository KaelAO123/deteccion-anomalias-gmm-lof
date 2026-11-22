import { ReactNode } from 'react';

interface Props {
  children: ReactNode;
  variant?: 'info' | 'warning';
}

export default function Callout({ children, variant = 'info' }: Props) {
  const cls = variant === 'warning' ? 'callout callout--warning' : 'callout';
  return <div className={cls}>{children}</div>;
}