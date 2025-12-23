'use client';

import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, BarChart, Bar } from 'recharts';

interface ChartProps {
  data: any[];
  type?: 'line' | 'bar';
  dataKey: string;
  xAxisKey: string;
  title?: string;
  color?: string;
}

export function Chart({ data, type = 'line', dataKey, xAxisKey, title, color = '#3b82f6' }: ChartProps) {
  return (
    <div className="bg-white p-6 rounded-lg shadow">
      {title && <h3 className="text-lg font-medium text-gray-900 mb-4">{title}</h3>}
      <div className="h-80">
        <ResponsiveContainer width="100%" height="100%">
          {type === 'line' ? (
            <LineChart data={data}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey={xAxisKey} />
              <YAxis />
              <Tooltip />
              <Line type="monotone" dataKey={dataKey} stroke={color} strokeWidth={2} />
            </LineChart>
          ) : (
            <BarChart data={data}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey={xAxisKey} />
              <YAxis />
              <Tooltip />
              <Bar dataKey={dataKey} fill={color} />
            </BarChart>
          )}
        </ResponsiveContainer>
      </div>
    </div>
  );
}