# Deployment Guide - Digital Bastion

## 🚀 Free Deployment Setup (Render + Vercel)

### **Step 1: Deploy Backend to Render**

1. **Create Render Account**: https://render.com
2. **Connect GitHub**: Link your repository
3. **Create Web Service**:
   - Repository: `https://github.com/FRIEZEWANDABWA/jac.git`
   - Branch: `main`
   - Root Directory: `/`
   - Environment: `Python 3`
   - Build Command: `pip install -r requirements.txt`
   - Start Command: `cd services/api && python main.py`

4. **Environment Variables** (in Render dashboard):
   ```
   PYTHON_VERSION=3.11.0
   PORT=8000
   ```

5. **Deploy**: Click "Create Web Service"
6. **Get URL**: Copy your Render URL (e.g., `https://digital-bastion-api.onrender.com`)

### **Step 2: Deploy Frontend to Vercel**

1. **Create Vercel Account**: https://vercel.com
2. **Import Project**: Connect GitHub repository
3. **Configure Build**:
   - Framework: `Next.js`
   - Root Directory: `web`
   - Build Command: `npm run build`
   - Output Directory: `.next`

4. **Environment Variables** (in Vercel dashboard):
   ```
   NEXT_PUBLIC_API_URL=https://your-render-app.onrender.com
   NEXTAUTH_SECRET=your-secret-key-here
   ```

5. **Deploy**: Vercel auto-deploys on push

### **Step 3: Link Frontend ↔ Backend**

#### **Update Environment Variables**

**Vercel (Frontend)**:
```bash
NEXT_PUBLIC_API_URL=https://digital-bastion-api.onrender.com
```

**Render (Backend)**:
```bash
ALLOWED_ORIGINS=https://your-app.vercel.app
```

#### **Update CORS in Backend**

In `services/api/main.py`, update:
```python
allow_origins=[
    "https://your-app.vercel.app",  # Your Vercel domain
    "http://localhost:3000"        # Local development
]
```

### **Step 4: Test Connection**

1. **Frontend**: `https://your-app.vercel.app`
2. **Backend**: `https://your-render-app.onrender.com/health`
3. **API Docs**: `https://your-render-app.onrender.com/docs`

### **Step 5: Custom Domain (Optional)**

**Vercel**:
1. Go to Project Settings → Domains
2. Add your custom domain
3. Update DNS records

**Render**:
1. Go to Service Settings → Custom Domains
2. Add API subdomain (e.g., `api.digitalbastion.com`)

## 🔧 Local Development

```bash
# Backend
cd services/api
pip install -r ../../requirements.txt
python main.py

# Frontend  
cd web
npm install
npm run dev
```

## 📊 Monitoring

**Render**: Built-in logs and metrics  
**Vercel**: Analytics and performance monitoring  
**Uptime**: Use UptimeRobot for free monitoring

## 🔒 Security

1. **Environment Variables**: Never commit secrets
2. **CORS**: Restrict to your domains only
3. **Rate Limiting**: Implement in FastAPI
4. **HTTPS**: Both platforms provide SSL certificates

## 💰 Cost Breakdown

- **Render**: Free (750 hours/month)
- **Vercel**: Free (unlimited)
- **Total**: $0/month 🎉

## 🚨 Troubleshooting

**CORS Errors**: Check allowed origins in FastAPI  
**Build Failures**: Verify Python/Node versions  
**API Connection**: Check environment variables  
**Cold Starts**: Render free tier has ~30s cold start

---

**Live URLs** (update after deployment):
- Frontend: `https://digitalbastion.vercel.app`
- Backend: `https://digital-bastion-api.onrender.com`
- API Docs: `https://digital-bastion-api.onrender.com/docs`