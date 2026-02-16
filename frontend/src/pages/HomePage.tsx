import { Link } from 'react-router-dom';

export const HomePage = () => {
  return (
    <div className="text-center">
      <h1 className="text-5xl font-bold text-gray-900 mb-6">
        Welcome to RiderMate
      </h1>
      <p className="text-xl text-gray-600 mb-8 max-w-2xl mx-auto">
        Track your rides, share memories, and connect with fellow cyclists.
        Your ultimate companion for every cycling adventure.
      </p>
      <div className="flex justify-center space-x-4">
        <Link
          to="/register"
          className="bg-primary-600 text-white px-8 py-3 rounded-lg text-lg font-semibold hover:bg-primary-700 transition"
        >
          Get Started
        </Link>
        <Link
          to="/login"
          className="bg-white text-primary-600 border-2 border-primary-600 px-8 py-3 rounded-lg text-lg font-semibold hover:bg-primary-50 transition"
        >
          Login
        </Link>
      </div>

      {/* Features Section */}
      <div className="grid md:grid-cols-3 gap-8 mt-16">
        <div className="bg-white p-6 rounded-lg shadow-md">
          <div className="text-4xl mb-4">🚴</div>
          <h3 className="text-xl font-bold mb-2">Track Rides</h3>
          <p className="text-gray-600">
            Record your cycling routes, distance, speed, and elevation with GPS tracking.
          </p>
        </div>
        <div className="bg-white p-6 rounded-lg shadow-md">
          <div className="text-4xl mb-4">📸</div>
          <h3 className="text-xl font-bold mb-2">Capture Memories</h3>
          <p className="text-gray-600">
            Create journals with photos and notes from your favorite rides.
          </p>
        </div>
        <div className="bg-white p-6 rounded-lg shadow-md">
          <div className="text-4xl mb-4">🏆</div>
          <h3 className="text-xl font-bold mb-2">Compete & Connect</h3>
          <p className="text-gray-600">
            Challenge friends and climb the leaderboards together.
          </p>
        </div>
      </div>
    </div>
  );
};
