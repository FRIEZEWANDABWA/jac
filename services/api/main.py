# main.py - FastAPI server bridging Next.js frontend to Jac backend

from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Dict, Optional
import os
import sys

# Simplified version without Jaseci for initial deployment
# TODO: Add Jaseci integration after successful deployment
print("Digital Bastion API starting without Jaseci (demo mode)")

app = FastAPI(title="Digital Bastion API", version="1.0.0")

# CORS middleware for Next.js frontend (Vercel + local)
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:3000", 
        "http://localhost:3001",
        "https://*.vercel.app",
        "https://digitalbastion.vercel.app"  # Replace with your domain
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Pydantic models for API requests
class LoginRequest(BaseModel):
    username: str
    password: str

class AccessCheckRequest(BaseModel):
    user_id: str
    resource: str
    action: str

class DeviceScanRequest(BaseModel):
    device_ids: Optional[List[str]] = None

class IncidentRequest(BaseModel):
    severity: str
    reason: str
    affected_resource: Optional[str] = None

# Mock data for demo deployment
mock_users = [{"username": "admin", "roles": ["admin"]}]
mock_devices = [{"hostname": "web-01", "risk_score": 0.2, "status": "active"}]
mock_incidents = [{"severity": "medium", "reason": "demo_incident", "status": "open"}]

@app.on_startup
async def startup_event():
    """Initialize demo data"""
    print("✓ Digital Bastion API initialized (demo mode)")
    print("✓ Mock data loaded")

# Authentication endpoints
@app.post("/api/auth/login")
async def login(request: LoginRequest):
    """Demo authentication"""
    if request.username == "admin" and request.password == "demo":
        return {
            "success": True,
            "user": "admin",
            "roles": ["admin"],
            "token": "demo_jwt_token"
        }
    else:
        raise HTTPException(status_code=401, detail="Invalid credentials")

@app.post("/api/auth/check-access")
async def check_access(request: AccessCheckRequest):
    """Demo access control"""
    return {
        "allowed": True,
        "reason": "demo_mode",
        "policy": "demo_policy"
    }

# Device management endpoints
@app.get("/api/devices")
async def get_devices():
    """Get demo devices"""
    return {"devices": mock_devices}

@app.post("/api/devices/scan")
async def scan_devices(request: DeviceScanRequest):
    """Run security scan on devices"""
    try:
        machine = get_jac_machine()
        
        result = machine.spawn_walker(
            "network_scanner",
            ctx={"device_ids": request.device_ids or []}
        )
        
        return {
            "scan_results": result,
            "timestamp": "2024-01-01T00:00:00Z"
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Incident management endpoints
@app.get("/api/incidents")
async def get_incidents():
    """Get demo incidents"""
    return {"incidents": mock_incidents}

@app.post("/api/incidents")
async def create_incident(request: IncidentRequest):
    """Create new security incident"""
    try:
        machine = get_jac_machine()
        
        result = machine.spawn_walker(
            "incident_walker",
            ctx={
                "reason": request.reason,
                "severity": request.severity,
                "target_resource": request.affected_resource
            }
        )
        
        return {
            "incident_created": True,
            "incident_id": result.get("incident_id")
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Threat detection endpoints
@app.get("/api/threats/analyze")
async def analyze_threats():
    """Run threat detection analysis"""
    try:
        machine = get_jac_machine()
        
        result = machine.spawn_walker("threat_detection_walker")
        
        return {
            "threats_found": result,
            "analysis_time": "2024-01-01T00:00:00Z"
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Dashboard data endpoints
@app.get("/api/dashboard/stats")
async def get_dashboard_stats():
    """Get demo dashboard stats"""
    return {
        "total_users": 1,
        "total_devices": 1,
        "open_incidents": 1,
        "active_policies": 3,
        "average_risk_score": 0.2,
        "system_status": "operational"
    }

# Health check
@app.get("/health")
async def health_check():
    return {"status": "healthy", "service": "Digital Bastion API"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)