'use client';

import { useEffect, useState } from 'react';
import { useAuth } from '@/hooks/useAuth';
import { useRouter } from 'next/navigation';
import Layout from '@/components/Layout';
import { StatsGrid } from '@/components/StatsGrid';
import { Chart } from '@/components/Chart';
import { api } from '@/lib/api';
import { Users, FileText, TrendingUp, Activity } from 'lucide-react';

export default function DashboardPage() {
  const { user, loading } = useAuth();
  const router = useRouter();
  const [analytics, setAnalytics] = useState<any>(null);
  const [systemHealth, setSystemHealth] = useState<any>(null);

  useEffect(() => {
    if (!loading && !user) {
      router.push('/login');
      return;
    }

    if (user) {
      loadDashboardData();
    }
  }, [user, loading, router]);

  const loadDashboardData = async () => {
    try {
      const [analyticsData, healthData] = await Promise.all([
        api.getAnalytics(),
        api.getSystemHealth(),
      ]);
      
      setAnalytics(analyticsData.data);
      setSystemHealth(healthData);
    } catch (error) {
      console.error('Failed to load dashboard data:', error);
    }
  };

  if (loading) {
    return <div className="min-h-screen flex items-center justify-center">Loading...</div>;
  }

  if (!user) {
    return null;
  }

  const stats = [
    {
      title: 'Total Users',
      value: analytics?.totalUsers || 0,
      change: analytics?.userGrowth || 0,
      icon: <Users className="h-6 w-6" />,
    },
    {
      title: 'Total Posts',
      value: analytics?.totalPosts || 0,
      change: analytics?.postGrowth || 0,
      icon: <FileText className="h-6 w-6" />,
    },
    {
      title: 'Engagements',
      value: analytics?.totalEngagements || 0,
      change: analytics?.engagementGrowth || 0,
      icon: <TrendingUp className="h-6 w-6" />,
    },
    {
      title: 'System Health',
      value: systemHealth?.status === 'ok' ? 'Healthy' : 'Issues',
      icon: <Activity className="h-6 w-6" />,
    },
  ];

  const chartData = analytics?.dailyStats || [];

  return (
    <Layout>
      <div className="space-y-6">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">
            Welcome back, {user.name}
          </h1>
          <p className="mt-1 text-sm text-gray-500">
            Here's what's happening with your platform today.
          </p>
        </div>

        <StatsGrid stats={stats} />

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <Chart
            data={chartData}
            type="line"
            dataKey="users"
            xAxisKey="date"
            title="Daily Active Users"
            color="#3b82f6"
          />
          <Chart
            data={chartData}
            type="bar"
            dataKey="posts"
            xAxisKey="date"
            title="Daily Posts"
            color="#10b981"
          />
        </div>

        {systemHealth && (
          <div className="bg-white p-6 rounded-lg shadow">
            <h3 className="text-lg font-medium text-gray-900 mb-4">System Status</h3>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <div>
                <p className="text-sm text-gray-500">Uptime</p>
                <p className="text-lg font-semibold">
                  {Math.floor(systemHealth.uptime / 3600)}h {Math.floor((systemHealth.uptime % 3600) / 60)}m
                </p>
              </div>
              <div>
                <p className="text-sm text-gray-500">Memory Usage</p>
                <p className="text-lg font-semibold">
                  {Math.round(systemHealth.memory?.heapUsed / 1024 / 1024)}MB
                </p>
              </div>
              <div>
                <p className="text-sm text-gray-500">Active Requests</p>
                <p className="text-lg font-semibold">{systemHealth.activeRequests || 0}</p>
              </div>
            </div>
          </div>
        )}
      </div>
    </Layout>
  );
}