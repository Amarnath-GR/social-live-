import React, { useState, useEffect } from 'react';
import { Line, Bar, Pie } from 'react-chartjs-2';

interface AnalyticsDashboard {
  totalEvents: number;
  uniqueUsers: number;
  topContent: any[];
  engagementMetrics: any;
  revenueMetrics: any;
}

export const AnalyticsDashboard: React.FC = () => {
  const [data, setData] = useState<AnalyticsDashboard | null>(null);
  const [timeframe, setTimeframe] = useState('7d');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchAnalytics();
  }, [timeframe]);

  const fetchAnalytics = async () => {
    setLoading(true);
    try {
      const response = await fetch(`/api/analytics/dashboard?timeframe=${timeframe}`);
      const result = await response.json();
      if (result.success) {
        setData(result.data);
      }
    } catch (error) {
      console.error('Failed to fetch analytics:', error);
    } finally {
      setLoading(false);
    }
  };

  const trackEvent = async (eventType: string, data: any) => {
    try {
      await fetch('/api/analytics/events/track', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ eventType, data }),
      });
    } catch (error) {
      console.error('Failed to track event:', error);
    }
  };

  if (loading) return <div>Loading analytics...</div>;
  if (!data) return <div>No data available</div>;

  return (
    <div className="analytics-dashboard">
      <div className="dashboard-header">
        <h1>Analytics Dashboard</h1>
        <select 
          value={timeframe} 
          onChange={(e) => setTimeframe(e.target.value)}
          onClick={() => trackEvent('engagement', { action: 'timeframe_change', targetType: 'dashboard', targetId: 'analytics' })}
        >
          <option value="24h">Last 24 Hours</option>
          <option value="7d">Last 7 Days</option>
          <option value="30d">Last 30 Days</option>
          <option value="90d">Last 90 Days</option>
        </select>
      </div>

      <div className="metrics-grid">
        <div className="metric-card">
          <h3>Total Events</h3>
          <p className="metric-value">{data.totalEvents.toLocaleString()}</p>
        </div>
        
        <div className="metric-card">
          <h3>Unique Users</h3>
          <p className="metric-value">{data.uniqueUsers.toLocaleString()}</p>
        </div>
        
        <div className="metric-card">
          <h3>Total Revenue</h3>
          <p className="metric-value">${data.revenueMetrics.totalRevenue.toFixed(2)}</p>
        </div>
        
        <div className="metric-card">
          <h3>Average Order Value</h3>
          <p className="metric-value">${data.revenueMetrics.averageOrderValue.toFixed(2)}</p>
        </div>
      </div>

      <div className="charts-grid">
        <div className="chart-container">
          <h3>Top Content</h3>
          <Bar
            data={{
              labels: data.topContent.slice(0, 10).map((item, index) => `Content ${index + 1}`),
              datasets: [{
                label: 'Views',
                data: data.topContent.slice(0, 10).map(item => item._count.eventId),
                backgroundColor: 'rgba(54, 162, 235, 0.6)',
              }],
            }}
            options={{
              responsive: true,
              plugins: {
                legend: { position: 'top' },
                title: { display: true, text: 'Most Viewed Content' },
              },
            }}
          />
        </div>

        <div className="chart-container">
          <h3>Engagement Distribution</h3>
          <Pie
            data={{
              labels: Object.keys(data.engagementMetrics),
              datasets: [{
                data: Object.values(data.engagementMetrics).map((item: any) => item._count?.eventId || 0),
                backgroundColor: [
                  'rgba(255, 99, 132, 0.6)',
                  'rgba(54, 162, 235, 0.6)',
                  'rgba(255, 205, 86, 0.6)',
                  'rgba(75, 192, 192, 0.6)',
                ],
              }],
            }}
            options={{
              responsive: true,
              plugins: {
                legend: { position: 'right' },
                title: { display: true, text: 'Engagement Types' },
              },
            }}
          />
        </div>
      </div>

      <div className="events-table">
        <h3>Recent Events</h3>
        <EventsTable timeframe={timeframe} />
      </div>
    </div>
  );
};

const EventsTable: React.FC<{ timeframe: string }> = ({ timeframe }) => {
  const [events, setEvents] = useState([]);

  useEffect(() => {
    fetchEvents();
  }, [timeframe]);

  const fetchEvents = async () => {
    try {
      const response = await fetch(`/api/analytics/events?timeframe=${timeframe}&limit=50`);
      const result = await response.json();
      if (result.success) {
        setEvents(result.data.events);
      }
    } catch (error) {
      console.error('Failed to fetch events:', error);
    }
  };

  return (
    <table className="events-table">
      <thead>
        <tr>
          <th>Event Type</th>
          <th>User ID</th>
          <th>Timestamp</th>
          <th>Platform</th>
          <th>Data</th>
        </tr>
      </thead>
      <tbody>
        {events.map((event: any) => (
          <tr key={event.eventId}>
            <td>{event.eventType}</td>
            <td>{event.userId}</td>
            <td>{new Date(event.timestamp).toLocaleString()}</td>
            <td>{event.platform}</td>
            <td>{JSON.stringify(event.eventData).substring(0, 100)}...</td>
          </tr>
        ))}
      </tbody>
    </table>
  );
};