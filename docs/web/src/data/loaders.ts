import { useEffect, useState } from 'react';
import Papa from 'papaparse';

export interface CSVResult<T> {
  data: T[];
  loading: boolean;
  error: string | null;
}

/**
 * Hook genérico para cargar un CSV desde /public/data/ y tiparlo.
 * Si actualizas el CSV, la página refleja los cambios sin tocar código.
 */
export function useCSV<T>(filename: string): CSVResult<T> {
  const [data, setData] = useState<T[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    Papa.parse<T>(`./data/${filename}`, {
      download: true,
      header: true,
      dynamicTyping: true,
      skipEmptyLines: true,
      complete: (results) => {
        setData(results.data);
        setLoading(false);
      },
      error: (err) => {
        setError(err.message);
        setLoading(false);
      },
    });
  }, [filename]);

  return { data, loading, error };
}

// --- Tipos de los CSV ---

export interface Univariado {
  variable: string;
  n_cero: number;
  pct_cero: number;
  media: number;
  mediana: number;
  asimetria: number;
}

export interface GmmBic {
  modelo: string;
  G: number;
  BIC: number;
  loglik: number;
  df: number;
  seleccionado: boolean;
}

export interface LofSensibilidad {
  k: number;
  lof_mediana: number;
  lof_p95: number;
  lof_p99: number;
  lof_max: number;
  n_anomalias_p5: number;
  pct_anomalias_p5: number;
}

export interface CaractCategoria {
  categoria: string;
  n: number;
  pct: number;
  mediana_gasto: number;
  media_gasto: number;
  pct_urbano: number;
}

export interface MatrizConfusion {
  GMM: string;
  FALSE: number;
  TRUE: number;
}

export interface MetricaAcuerdo {
  metrica: string;
  valor: number;
}

export interface CaractDepto {
  depto: number;
  categoria: string;
  n: number;
  pct: number;
}

export interface SensUmbrales {
  percentil: number;
  umbral_gmm: number;
  umbral_lof: number;
  n_anomalias_gmm: number;
  n_anomalias_lof: number;
  n_ambos: number;
  n_union: number;
  jaccard: number;
  kappa: number;
}

export interface EfectoLog1p {
  metodo: string;
  n_principal: number;
  n_sens: number;
  n_ambos: number;
  n_union: number;
  jaccard: number;
}