'use client';

import { useEffect, useState } from 'react';
import { useAuth } from '@/hooks/useAuth';
import { useRouter } from 'next/navigation';
import Layout from '@/components/Layout';
import { api } from '@/lib/api';
import { User } from '@/types';
import { Shield, ShieldOff, Mail, Calendar } from 'lucide-react';

export default function AdminUsersPage() {
  const { user, loading, isAdmin } = useAuth();
  const router = useRouter();
  const [users, setUsers] = useState<User[]>([]);
  const [loadingUsers, setLoadingUsers] = useState(true);

  useEffect(() => {
    if (!loading && (!user || !isAdmin)) {
      router.push('/dashboard');
      return;
    }

    if (user && isAdmin) {
      loadUsers();
    }
  }, [user, loading, isAdmin, router]);

  const loadUsers = async () => {
    try {
      const response = await api.getUsers();
      setUsers(response.data || []);
    } catch (error) {
      console.error('Failed to load users:', error);
    } finally {
      setLoadingUsers(false);
    }
  };

  const toggleUserStatus = async (userId: string, isBlocked: boolean) => {
    try {
      await api.updateUserStatus(userId, !isBlocked);
      setUsers(users.map(u => 
        u.id === userId ? { ...u, isBlocked: !isBlocked } : u
      ));
    } catch (error) {
      console.error('Failed to update user status:', error);
    }
  };

  if (loading || !user || !isAdmin) {
    return <div className="min-h-screen flex items-center justify-center">Loading...</div>;
  }

  return (
    <Layout>
      <div className="space-y-6">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">User Management</h1>
          <p className="mt-1 text-sm text-gray-500">
            Manage platform users and their access permissions.
          </p>
        </div>

        <div className="bg-white shadow overflow-hidden sm:rounded-md">
          <ul className="divide-y divide-gray-200">
            {loadingUsers ? (
              <li className="px-6 py-4 text-center">Loading users...</li>
            ) : users.length === 0 ? (
              <li className="px-6 py-4 text-center text-gray-500">No users found</li>
            ) : (
              users.map((user) => (
                <li key={user.id} className="px-6 py-4">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center">
                      <div className="flex-shrink-0">
                        <div className="h-10 w-10 rounded-full bg-gray-300 flex items-center justify-center">
                          <span className="text-sm font-medium text-gray-700">
                            {user.name.charAt(0).toUpperCase()}
                          </span>
                        </div>
                      </div>
                      <div className="ml-4">
                        <div className="flex items-center">
                          <p className="text-sm font-medium text-gray-900">{user.name}</p>
                          <span className={`ml-2 inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                            user.role === 'ADMIN' ? 'bg-red-100 text-red-800' :
                            user.role === 'CREATOR' ? 'bg-blue-100 text-blue-800' :
                            'bg-gray-100 text-gray-800'
                          }`}>
                            {user.role}
                          </span>
                        </div>
                        <div className="flex items-center mt-1 text-sm text-gray-500">
                          <Mail className="h-4 w-4 mr-1" />
                          {user.email}
                          <Calendar className="h-4 w-4 ml-4 mr-1" />
                          {new Date(user.createdAt).toLocaleDateString()}
                        </div>
                      </div>
                    </div>
                    <div className="flex items-center space-x-2">
                      <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                        user.isBlocked ? 'bg-red-100 text-red-800' : 'bg-green-100 text-green-800'
                      }`}>
                        {user.isBlocked ? 'Blocked' : 'Active'}
                      </span>
                      <button
                        onClick={() => toggleUserStatus(user.id, user.isBlocked)}
                        className={`inline-flex items-center px-3 py-1 border border-transparent text-sm leading-4 font-medium rounded-md ${
                          user.isBlocked
                            ? 'text-green-700 bg-green-100 hover:bg-green-200'
                            : 'text-red-700 bg-red-100 hover:bg-red-200'
                        }`}
                      >
                        {user.isBlocked ? (
                          <>
                            <Shield className="h-4 w-4 mr-1" />
                            Unblock
                          </>
                        ) : (
                          <>
                            <ShieldOff className="h-4 w-4 mr-1" />
                            Block
                          </>
                        )}
                      </button>
                    </div>
                  </div>
                </li>
              ))
            )}
          </ul>
        </div>
      </div>
    </Layout>
  );
}