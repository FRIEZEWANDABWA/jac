# Digital Bastion - Cybersecurity Platform

A comprehensive cybersecurity platform built with **Jac language** + **Jaseci runtime** for backend logic and **Next.js** + **TypeScript** + **Tailwind CSS** for the frontend.

## 🏗️ Architecture

- **Frontend**: Next.js 14 + TypeScript + Tailwind CSS (marketing site, dashboard, admin UI)
- **Backend**: Jac language + Jaseci runtime (security workflows, access control, threat detection)
- **Data Model**: Graph-based (nodes/edges) - users, devices, services, incidents, policies
- **API Layer**: FastAPI Python server bridging frontend ↔ Jac backend

## 📁 Project Structure

```
digital-bastion/
├── web/                    # Next.js frontend
│   ├── app/                # Next.js 14 app routes
│   ├── components/         # React components
│   └── lib/               # Utilities
├── jac/                    # Jac code + Jaseci graphs
│   ├── data.jac           # Node & edge definitions
│   ├── walkers.jac        # Security walkers (auth, scans, policies)
│   ├── abilities.jac      # Reusable abilities
│   └── init.jac           # Platform initialization
├── services/               # Python API layer
│   ├── api/               # FastAPI endpoints
│   └── integrations/      # External service connectors
├── infra/                 # Deployment configs
└── docs/                  # Documentation
```

## 🚀 Quick Start

### Prerequisites

- Python 3.11+
- Node.js 18+
- Jac language (`pip install jaclang`)
- Jaseci runtime (`pip install jaseci`)

### 1. Backend Setup

```bash
# Install Jac and Jaseci
pip install jaclang jaseci

# Install API dependencies
cd services/api
pip install fastapi uvicorn

# Initialize Jac platform
jac run ../../jac/init.jac

# Start API server
python main.py
```

### 2. Frontend Setup

```bash
cd web
npm install
npm run dev
```

### 3. Access the Platform

- **Frontend**: http://localhost:3000
- **API**: http://localhost:8000
- **API Docs**: http://localhost:8000/docs

## 🔐 Core Features

### Security Workflows (Jac)

- **Authentication**: Multi-factor auth with session management
- **Access Control**: Role-based policies with graph traversal
- **Network Scanning**: Automated device risk assessment
- **Threat Detection**: Log analysis and pattern matching
- **Incident Response**: Automated escalation and notifications

### Graph Data Model

**Nodes**: `user`, `device`, `service`, `policy`, `incident`, `network_zone`, `log_entry`

**Edges**: `owns`, `runs`, `controls`, `connected_to`, `violates`, `affects`, `belongs_to`

### API Endpoints

- `POST /api/auth/login` - User authentication
- `POST /api/auth/check-access` - Permission validation
- `GET /api/devices` - Device inventory
- `POST /api/devices/scan` - Security scanning
- `GET /api/incidents` - Security incidents
- `GET /api/threats/analyze` - Threat detection

## 🎨 Frontend Features

- **Dark/Light Mode**: System-aware theme switching
- **Responsive Design**: Mobile-first Tailwind CSS
- **Dashboard**: Real-time security metrics
- **Device Management**: Network inventory and risk scores
- **Incident Tracking**: Security event management
- **Access Control**: User and policy management

## 🔧 Development

### Running Jac Code

```bash
# Test individual walkers
jac run jac/walkers.jac

# Initialize platform
jac run jac/init.jac

# Check syntax
jac check jac/data.jac
```

### API Development

```bash
# Start with auto-reload
uvicorn services.api.main:app --reload --host 0.0.0.0 --port 8000
```

### Frontend Development

```bash
# Development server
npm run dev

# Build for production
npm run build
npm start
```

## 📊 Default Data

The platform initializes with:

- **Admin User**: `admin@digitalbastion.com`
- **Security Policies**: Admin, Operator, Analyst roles
- **Network Zones**: DMZ, Internal, Restricted
- **Sample Devices**: Web server, Database server
- **Services**: Nginx, MySQL with vulnerability data

## 🔒 Security Considerations

- **Input Validation**: All API inputs validated at boundary
- **Authentication**: JWT tokens with role-based access
- **Graph Isolation**: Walker scope containment
- **Rate Limiting**: API throttling and quotas
- **Audit Logging**: All actions logged for compliance

## 🚀 Deployment

### Docker (Recommended)

```bash
# Build and run
docker-compose up -d
```

### Manual Deployment

1. **Backend**: Deploy Jaseci + FastAPI on VPS/cloud
2. **Frontend**: Deploy Next.js on Vercel/Netlify
3. **Database**: Use Jaseci graph persistence or external DB

## 📚 Documentation

- [Jac Language Guide](https://jac-lang.org)
- [Jaseci Documentation](https://github.com/Jaseci-Labs/jaseci)
- [Next.js Documentation](https://nextjs.org/docs)
- [API Reference](./docs/api.md)

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Digital Bastion Ltd** - Advanced Cybersecurity Solutions