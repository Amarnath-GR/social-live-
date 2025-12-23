'use client';

import { useEffect, useState } from 'react';
import { useAuth } from '@/hooks/useAuth';
import { useRouter } from 'next/navigation';
import Layout from '@/components/Layout';
import { Chart } from '@/components/Chart';
import { api } from '@/lib/api';
import { AlertTriangle, CheckCircle, XCircle, Activity } from 'lucide-react';

export default function AdminSystemPage() {
  const { user, loading, isAdmin } = useAuth();
  const router = useRouter();
  const [systemHealth, setSystemHealth] = useState<any>(null);
  const [errorStats, setErrorStats] = useState<any>(null);
  const [performanceStats, setPerformanceStats] = useState<any>(null);

  useEffect(() => {
    if (!loading && (!user || !isAdmin)) {
      router.push('/dashboard');
      return;
    }

    if (user && isAdmin) {
      loadSystemData();
    }
  }, [user, loading, isAdmin, router]);

  const loadSystemData = async () => {
    try {
      const [health, errors, performance] = await Promise.all([
        api.getSystemHealth(),
        api.getErrorStats('24h'),
        api.getPerformanceStats('24h'),
      ]);
      
      setSystemHealth(health);
      setErrorStats(errors.data);
      setPerformanceStats(performance.data);
    } catch (error) {
      console.error('Failed to load system data:', error);
    }
  };

  if (loading || !user || !isAdmin) {
    return <div className="min-h-screen flex items-center justify-center">Loading...</div>;
  }

  const getHealthStatus = () => {
    if (!systemHealth) return { status: 'unknown', color: 'gray', icon: Activity };
    
    const memoryUsage = systemHealth.system?.memory?.heapUsed / systemHealth.system?.memory?.heapTotal;
    const hasErrors = errorStats?.totalErrors > 0;
    
    if (hasErrors || memoryUsage > 0.9) {
      return { status: 'critical', color: 'red', icon: XCircle };
    } else if (memoryUsage > 0.7) {
      return { status: 'warning', color: 'yellow', icon: AlertTriangle };
    } else {
      return { status: 'healthy', color: 'green', icon: CheckCircle };
    }
  };

  const healthStatus = getHealthStatus();

  return (
    <Layout>
      <div className="space-y-6">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">System Monitoring</h1>
          <p className="mt-1 text-sm text-gray-500">
            Monitor system health, performance, and error rates.
          </p>
        </div>

        {/* System Status Overview */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
          <div className="bg-white p-6 rounded-lg shadow">
            <div className="flex items-center">
              <healthStatus.icon className={`h-8 w-8 text-${healthStatus.color}-500`} />
              <div className="ml-4">
                <p className="text-sm text-gray-500">System Status</p>
                <p className="text-lg font-semibold capitalize">{healthStatus.status}</p>
              </div>
            </div>
          </div>
          
          <div className="bg-white p-6 rounded-lg shadow">
            <div className="flex items-center">
              <Activity className="h-8 w-8 text-blue-500" />
              <div className="ml-4">
                <p className="text-sm text-gray-500">Uptime</p>
                <p className="text-lg font-semibold">
                  {systemHealth ? `${Math.floor(systemHealth.system?.uptime / 3600)}h` : 'N/A'}
                </p>
              </div>
            </div>
          </div>

          <div className="bg-white p-6 rounded-lg shadow">
            <div className="flex items-center">
              <AlertTriangle className="h-8 w-8 text-orange-500" />
              <div className="ml-4">
                <p className="text-sm text-gray-500">Errors (24h)</p>
                <p className="text-lg font-semibold">{errorStats?.totalErrors || 0}</p>
              </div>
            </div>
          </div>

          <div className="bg-white p-6 rounded-lg shadow">
            <div className="flex items-center">
              <Activity className="h-8 w-8 text-purple-500" />
              <div className="ml-4">
                <p className="text-sm text-gray-500">Memory Usage</p>
                <p className="text-lg font-semibold">
                  {systemHealth ? 
                    `${Math.round(systemHealth.system?.memory?.heapUsed / 1024 / 1024)}MB` : 
                    'N/A'
                  }
                </p>
              </div>
            </div>
          </div>
        </div>

        {/* Error Statistics */}
        {errorStats && (
          <div className="bg-white p-6 rounded-lg shadow">
            <h3 className="text-lg font-medium text-gray-900 mb-4">Error Breakdown</h3>
            <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
              {Object.entries(errorStats.errorsByType || {}).map(([type, count]) => (
                <div key={type} className="text-center">
                  <p className="text-2xl font-bold text-red-600">{count as number}</p>
                  <p className="text-sm text-gray-500 capitalize">{type.replace('_', ' ')}</p>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Performance Charts */}
        {performanceStats && (
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
            <div className="bg-white p-6 rounded-lg shadow">
              <h3 className="text-lg font-medium text-gray-900 mb-4">Response Times</h3>
              <div className="space-y-2">
                {Object.entries(performanceStats).map(([metric, stats]: [string, any]) => (
                  <div key={metric} className="flex justify-between">
                    <span className="text-sm text-gray-500 capitalize">
                      {metric.replace('_', ' ')}
                    </span>
                    <span className="text-sm font-medium">
                      {stats.avg ? `${stats.avg.toFixed(2)}ms` : 'N/A'}
                    </span>
                  </div>
                ))}
              </div>
            </div>

            <div className="bg-white p-6 rounded-lg shadow">
              <h3 className="text-lg font-medium text-gray-900 mb-4">System Resources</h3>
              {systemHealth?.system && (
                <div className="space-y-4">
                  <div>
                    <div className="flex justify-between text-sm">
                      <span>Memory Usage</span>
                      <span>
                        {Math.round((systemHealth.system.memory.heapUsed / systemHealth.system.memory.heapTotal) * 100)}%
                      </span>
                    </div>
                    <div className="w-full bg-gray-200 rounded-full h-2">
                      <div 
                        className="bg-blue-600 h-2 rounded-full" 
                        style={{ 
                          width: `${(systemHealth.system.memory.heapUsed / systemHealth.system.memory.heapTotal) * 100}%` 
                        }}
                      ></div>
                    </div>
                  </div>
                  
                  <div className="grid grid-cols-2 gap-4 text-sm">
                    <div>
                      <p className="text-gray-500">Heap Used</p>
                      <p className="font-medium">
                        {Math.round(systemHealth.system.memory.heapUsed / 1024 / 1024)}MB
                      </p>
                    </div>
                    <div>
                      <p className="text-gray-500">Heap Total</p>
                      <p className="font-medium">
                        {Math.round(systemHealth.system.memory.heapTotal / 1024 / 1024)}MB
                      </p>
                    </div>
                  </div>
                </div>
              )}
            </div>
          </div>
        )}
      </div>
    </Layout>
  );
}