# Auth Test Project

A full-stack authentication application with comprehensive testing setup, built with React, Node.js/Express, and featuring both web and mobile testing capabilities.

## 🏗️ Project Structure

```
auth-test-project/
├── client/                 # React frontend (Vite)
│   ├── src/
│   │   ├── components/
│   │   │   ├── LoginForm.jsx
│   │   │   └── Dashboard.jsx
│   │   ├── utils/
│   │   │   └── api.js
│   │   └── App.jsx
│   └── package.json
├── server/                 # Node.js/Express backend
│   ├── index.js
│   └── package.json
├── test/                   # Comprehensive testing suite
│   ├── web/               # Playwright web tests
│   ├── mobile/            # Maestro mobile tests
│   └── package.json
├── start-dev.sh           # Development startup script
└── start.sh              # Production startup script
```

## 🚀 Quick Start

### Prerequisites
- Node.js (v16 or later)
- npm or yarn
- Java 17+ (for mobile testing)

### Installation & Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd auth-test-project
   ```

2. **Install dependencies**
   ```bash
   # Install server dependencies
   cd server && npm install && cd ..
   
   # Install client dependencies
   cd client && npm install && cd ..
   
   # Install test dependencies
   cd test && npm install && cd ..
   ```

3. **Start development environment**
   ```bash
   ./manage.sh start
   ```

4. **Set up environment variables**
   - Copy `.env.example` to `.env` in both client and server directories.
   - Fill in the values, especially for GitHub OAuth app client ID and secret.

5. **Run the application**
   ```bash
   npm run dev
   ```

6. **Access the application**
   - Open `http://localhost:3000` in your browser.
   - Use `/auth/github` to sign in with GitHub.

## 🛠️ Management Commands

The project uses a single unified management script for all operations:

### Core Operations
```bash
./manage.sh start                  # Start development environment (default)
./manage.sh start-prod             # Start production environment  
./manage.sh stop                   # Stop all services
./manage.sh restart [dev|prod]     # Restart services (default: dev)
./manage.sh status                 # Check service status
```

### Log Management
```bash
./manage.sh logs view [server|client|all]    # View logs
./manage.sh logs tail [server|client|all]    # Follow logs in real-time
./manage.sh logs clear [server|client|all]   # Clear logs
./manage.sh logs-list                        # List log files
```

### Maintenance
```bash
./manage.sh cleanup [--all|--logs|--builds|--deps|--temp]
./manage.sh install                          # Install all dependencies
./manage.sh build                           # Build client for production
```

### Testing
```bash
./manage.sh test-web                        # Run web tests (Playwright)
./manage.sh test-mobile                     # Run mobile tests (Maestro)
./manage.sh test-all                        # Run all tests
```

### Quick Examples
```bash
# Start development (shows real-time startup progress)
./manage.sh start

# Check what's running (with recent log activity)
./manage.sh status

# View server logs in real-time
./manage.sh logs tail server

# Restart in production mode
./manage.sh restart prod

# Clean up everything
./manage.sh cleanup --all

# Stop everything
./manage.sh stop
```

### Command Aliases
For convenience, several commands have short aliases:
- `start` = `start-dev` = `dev` (development is default)
- `start-prod` = `prod` = `production`
- `status` = `st` = `ps`
- `stop` = `shutdown` = `down`
- `test` = `test-all`

Plus a shorter script: `./app <command>` = `./manage.sh <command>`

## 🧪 Testing

This project includes comprehensive testing for both web and mobile platforms:

### Web Testing (Playwright)
```bash
cd test
npm run test:web              # Run web tests
npm run test:web:headed       # Run with browser visible
npm run test:web:ui           # Interactive test UI
```

### Mobile Testing (Maestro)
```bash
cd test
npm run test:mobile           # Run mobile tests
npm run maestro:studio       # Interactive mobile test development
```

### Run All Tests
```bash
cd test
npm test                     # Run both web and mobile tests
```

## 🛠️ Development

### Unified Management Script

The project uses a single `manage.sh` script for all operations:

| Command | Purpose | Usage |
|---------|---------|--------|
| `start-dev` | Start development environment | `./manage.sh start-dev` |
| `start-prod` | Start production environment | `./manage.sh start-prod` |
| `stop` | Stop all services | `./manage.sh stop` |
| `status` | Check service status | `./manage.sh status` |
| `restart` | Restart services | `./manage.sh restart [dev\|prod]` |
| `logs` | Manage logs | `./manage.sh logs [view\|tail\|clear] [service]` |
| `cleanup` | Clean artifacts | `./manage.sh cleanup [options]` |
| `test-*` | Run tests | `./manage.sh test-web\|test-mobile\|test-all` |

### Development Workflow

1. **Start Development**
   ```bash
   ./manage.sh start-dev    # Starts both client and server, exits
   ./manage.sh status       # Check if services are running
   ```

2. **Monitor Services**
   ```bash
   ./manage.sh logs tail    # Follow all logs
   ./manage.sh status       # Check service health
   ```

3. **Make Changes**
   - Edit code (hot reload is enabled)
   - Services automatically restart on changes

4. **Restart if Needed**
   ```bash
   ./manage.sh restart      # Restart development environment
   ```

5. **Stop Services**
   ```bash
   ./manage.sh stop         # Stop all services cleanly
   ```

### Available Scripts

#### Client (React/Vite)
- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run preview` - Preview production build

#### Server (Node.js/Express)
- `npm start` - Start production server
- `npm run dev` - Start development server with nodemon

#### Testing
- `npm test` - Run all tests
- `npm run test:web` - Web tests only
- `npm run test:mobile` - Mobile tests only

## 🔧 Technology Stack

### Frontend
- **React** - UI library
- **Vite** - Build tool and dev server
- **CSS3** - Styling

### Backend
- **Node.js** - Runtime environment
- **Express** - Web framework

### Testing
- **Playwright** - Web end-to-end testing
- **Maestro** - Mobile UI automation testing

## 📱 Features

- **User Authentication** - Login/logout functionality
- **Responsive Design** - Works on desktop and mobile
- **Dashboard** - User dashboard after login
- **Comprehensive Testing** - Both web and mobile test coverage
- **Development Tools** - Hot reload, easy setup scripts

## 🔒 Authentication Flow

1. User accesses the application
2. Login form validates user input
3. Successful authentication redirects to dashboard
4. Dashboard provides user interface and logout functionality

## 📋 API Endpoints

- `POST /api/login` - User authentication
- `POST /api/logout` - User logout
- `GET /api/user` - Get user information

## 🎯 Testing Coverage

### Web Tests
- Login form validation
- Authentication flow
- Dashboard navigation
- User journey testing

### Mobile Tests
- Mobile login flow
- Form validation on mobile
- Mobile navigation
- Cross-platform compatibility

## 🚀 Deployment

### Production Build
```bash
# Build client
cd client && npm run build

# Start production server
cd server && npm start
```

### Environment Variables
Create `.env` files in client and server directories as needed:

```env
# Server .env
PORT=3001
NODE_ENV=production

# Client .env
VITE_API_URL=http://localhost:3001
```

## 📄 License

This project is licensed under the MIT License.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

## 📞 Support

For questions or issues, please open an issue in the GitHub repository.