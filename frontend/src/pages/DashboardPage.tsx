import { useAuth } from '../hooks/useAuth';

export const DashboardPage = () => {
  const { user } = useAuth();

  return (
    <div>
      <h1 className="text-3xl font-bold mb-6">Dashboard</h1>
      
      <div className="bg-white p-6 rounded-lg shadow-md mb-6">
        <h2 className="text-xl font-semibold mb-4">
          Welcome back, {user?.displayName || 'Rider'}!
        </h2>
        <p className="text-gray-600">
          This is your dashboard. Here you'll see your ride statistics, recent activities, and more.
        </p>
      </div>

      <div className="grid md:grid-cols-3 gap-6">
        <div className="bg-white p-6 rounded-lg shadow-md">
          <h3 className="text-lg font-semibold mb-2">Total Rides</h3>
          <p className="text-3xl font-bold text-primary-600">0</p>
        </div>
        <div className="bg-white p-6 rounded-lg shadow-md">
          <h3 className="text-lg font-semibold mb-2">Total Distance</h3>
          <p className="text-3xl font-bold text-primary-600">0 km</p>
        </div>
        <div className="bg-white p-6 rounded-lg shadow-md">
          <h3 className="text-lg font-semibold mb-2">Total Time</h3>
          <p className="text-3xl font-bold text-primary-600">0h 0m</p>
        </div>
      </div>
    </div>
  );
};
