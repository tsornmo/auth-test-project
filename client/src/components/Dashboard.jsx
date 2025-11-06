import './Dashboard.css';

const Dashboard = ({ token, onLogout }) => {
  return (
    <div className="dashboard-container">
      <div className="dashboard-card">
        <div className="dashboard-header">
          <h1>✅ Authentication Successful!</h1>
          <button onClick={onLogout} className="logout-btn">
            Logout
          </button>
        </div>
        
        <div className="dashboard-content">
          <div className="success-icon">🎉</div>
          <h2>Welcome to the Secure System</h2>
          <p>You have successfully authenticated using the predefined password.</p>
          
          <div className="token-info">
            <h3>🔑 Your Session Token:</h3>
            <div className="token-display">
              <code>{token.substring(0, 50)}...</code>
            </div>
            <small className="token-note">
              This JWT token is used for stateless authentication
            </small>
          </div>

          <div className="info-cards">
            <div className="info-card">
              <h4>🔒 Secure</h4>
              <p>Password encrypted with bcrypt</p>
            </div>
            <div className="info-card">
              <h4>�� Stateless</h4>
              <p>JWT-based authentication</p>
            </div>
            <div className="info-card">
              <h4>⚡ Fast</h4>
              <p>React + Vite frontend</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;
