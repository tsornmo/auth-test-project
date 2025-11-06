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
   ./start-dev.sh
   ```

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

### Starting the Development Environment
```bash
./start-dev.sh               # Starts both client and server in development mode
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