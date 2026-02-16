import { Outlet, Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../hooks/useAuth';
import { logout } from '../services/auth';

export const MainLayout = () => {
  const { user } = useAuth();
  const navigate = useNavigate();

  const handleLogout = async () => {
    const result = await logout();
    if (result.success) {
      navigate('/login');
    }
  };

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow-sm">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center py-4">
            <div className="flex items-center space-x-8">
              <Link to="/" className="text-2xl font-bold text-primary-600">
                RiderMate
              </Link>
              {user && (
                <nav className="hidden md:flex space-x-6">
                  <Link
                    to="/dashboard"
                    className="text-gray-700 hover:text-primary-600 transition"
                  >
                    Dashboard
                  </Link>
                  <Link
                    to="/rides"
                    className="text-gray-700 hover:text-primary-600 transition"
                  >
                    My Rides
                  </Link>
                  <Link
                    to="/memories"
                    className="text-gray-700 hover:text-primary-600 transition"
                  >
                    Memories
                  </Link>
                  <Link
                    to="/friends"
                    className="text-gray-700 hover:text-primary-600 transition"
                  >
                    Friends
                  </Link>
                  <Link
                    to="/leaderboard"
                    className="text-gray-700 hover:text-primary-600 transition"
                  >
                    Leaderboard
                  </Link>
                </nav>
              )}
            </div>
            <div className="flex items-center space-x-4">
              {user ? (
                <>
                  <Link
                    to="/profile"
                    className="text-gray-700 hover:text-primary-600 transition"
                  >
                    {user.displayName || user.email}
                  </Link>
                  <button
                    onClick={handleLogout}
                    className="bg-primary-600 text-white px-4 py-2 rounded-lg hover:bg-primary-700 transition"
                  >
                    Logout
                  </button>
                </>
              ) : (
                <>
                  <Link
                    to="/login"
                    className="text-gray-700 hover:text-primary-600 transition"
                  >
                    Login
                  </Link>
                  <Link
                    to="/register"
                    className="bg-primary-600 text-white px-4 py-2 rounded-lg hover:bg-primary-700 transition"
                  >
                    Sign Up
                  </Link>
                </>
              )}
            </div>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <Outlet />
      </main>

      {/* Footer */}
      <footer className="bg-white border-t mt-12">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
          <p className="text-center text-gray-600">
            © {new Date().getFullYear()} RiderMate. All rights reserved.
          </p>
        </div>
      </footer>
    </div>
  );
};
