import { useAuth } from '../hooks/useAuth';

export const ProfilePage = () => {
  const { user } = useAuth();

  return (
    <div>
      <h1 className="text-3xl font-bold mb-6">Profile</h1>
      <div className="bg-white p-6 rounded-lg shadow-md">
        <div className="mb-4">
          <label className="block text-sm font-medium text-gray-700 mb-1">Display Name</label>
          <p className="text-lg">{user?.displayName || 'Not set'}</p>
        </div>
        <div className="mb-4">
          <label className="block text-sm font-medium text-gray-700 mb-1">Email</label>
          <p className="text-lg">{user?.email}</p>
        </div>
      </div>
    </div>
  );
};
