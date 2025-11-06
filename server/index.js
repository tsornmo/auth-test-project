const express = require('express');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3001;

// Middleware
app.use(cors());
app.use(express.json());

// In-memory storage for demonstration (predefined credentials)
// Username: "admin"
// Password: "SecurePass123!" - hashed with bcrypt
const PREDEFINED_USERNAME = 'admin';
const PREDEFINED_PASSWORD_HASH = '$2b$10$o7OMixMNVeFuonIt0hsWleT00faZgaMcFdNzE8Zu7ma3G1XhKDSVy';

// Generate hash for a new password (utility - comment out after generating)
// bcrypt.hash('SecurePass123!', 10).then(hash => console.log('Hash:', hash));

// Authentication endpoint
app.post('/api/auth/login', async (req, res) => {
  try {
    const { username, password } = req.body;
    
    console.log('Login attempt for username:', username);

    if (!username || !password) {
      return res.status(400).json({ 
        success: false, 
        message: 'Username and password are required' 
      });
    }

    // Check username
    if (username !== PREDEFINED_USERNAME) {
      console.log('Invalid username provided');
      return res.status(401).json({ 
        success: false, 
        message: 'Invalid username or password' 
      });
    }

    // Compare provided password with predefined hash
    const isValid = await bcrypt.compare(password, PREDEFINED_PASSWORD_HASH);
    console.log('Password validation result:', isValid);

    if (!isValid) {
      console.log('Password validation failed');
      return res.status(401).json({ 
        success: false, 
        message: 'Invalid username or password' 
      });
    }

    // Generate JWT token
    const token = jwt.sign(
      { 
        authenticated: true, 
        username: username,
        timestamp: Date.now() 
      },
      process.env.JWT_SECRET || 'default-secret-key-change-in-production',
      { expiresIn: '1h' }
    );

    console.log('Login successful for user:', username);
    res.json({ 
      success: true, 
      message: 'Authentication successful',
      token,
      username 
    });

  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Server error' 
    });
  }
});

// Verify token endpoint
app.post('/api/auth/verify', (req, res) => {
  try {
    const token = req.headers.authorization?.split(' ')[1];

    if (!token) {
      return res.status(401).json({ 
        success: false, 
        message: 'No token provided' 
      });
    }

    const decoded = jwt.verify(
      token, 
      process.env.JWT_SECRET || 'default-secret-key-change-in-production'
    );

    res.json({ 
      success: true, 
      message: 'Token is valid',
      data: decoded 
    });

  } catch (error) {
    res.status(401).json({ 
      success: false, 
      message: 'Invalid token' 
    });
  }
});

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
  console.log(`Predefined username: ${PREDEFINED_USERNAME}`);
  console.log(`Predefined password: SecurePass123!`);
  
  // Keep the process alive
  setInterval(() => {
    // Empty interval to keep the process alive
  }, 1000);
});

// Handle unhandled promise rejections
process.on('unhandledRejection', (reason, promise) => {
  console.error('Unhandled Rejection at:', promise, 'reason:', reason);
});

// Handle uncaught exceptions
process.on('uncaughtException', (error) => {
  console.error('Uncaught Exception:', error);
  process.exit(1);
});
