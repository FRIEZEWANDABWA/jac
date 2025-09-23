# main.py - FastAPI server bridging Next.js frontend to Jac backend

from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Dict, Optional
import os
import sys

# Add Jaseci imports (install with: pip install jaseci)
try:
    from jaseci.jsorc.live_actions import jaseci_action
    from jaseci.core.machine import JacMachine
    from jaseci.core.element import Element
except ImportError:
    print("Warning: Jaseci not installed. Install with: pip install jaseci")

app = FastAPI(title="Digital Bastion API", version="1.0.0")

# CORS middleware for Next.js frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000", "http://localhost:3001"],
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

# Initialize Jaseci machine
jac_machine = None

def get_jac_machine():
    global jac_machine
    if jac_machine is None:
        jac_machine = JacMachine()
        # Load Jac files
        jac_files = [
            "../jac/data.jac",
            "../jac/abilities.jac", 
            "../jac/walkers.jac",
            "../jac/init.jac"
        ]
        for file_path in jac_files:
            if os.path.exists(file_path):
                jac_machine.load_jac_file(file_path)
    return jac_machine

@app.on_startup
async def startup_event():
    """Initialize the Jac runtime on startup"""
    try:
        machine = get_jac_machine()
        print("✓ Jaseci machine initialized")
        print("✓ Jac files loaded")
    except Exception as e:
        print(f"Error initializing Jaseci: {e}")

# Authentication endpoints
@app.post("/api/auth/login")
async def login(request: LoginRequest):
    """Authenticate user credentials"""
    try:
        machine = get_jac_machine()
        
        # Spawn auth walker
        result = machine.spawn_walker(
            "auth_walker",
            ctx={"username": request.username, "password_hash": request.password}
        )
        
        if result.get("status") == "success":
            return {
                "success": True,
                "user": result.get("user"),
                "roles": result.get("roles"),
                "token": "jwt_token_here"  # Generate actual JWT
            }
        else:
            raise HTTPException(status_code=401, detail=result.get("reason", "Authentication failed"))
            
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/auth/check-access")
async def check_access(request: AccessCheckRequest):
    """Check if user has access to resource"""
    try:
        machine = get_jac_machine()
        
        result = machine.spawn_walker(
            "access_control_walker",
            ctx={
                "actor_id": request.user_id,
                "resource": request.resource,
                "action": request.action
            }
        )
        
        return {
            "allowed": result.get("allowed", False),
            "reason": result.get("reason"),
            "policy": result.get("policy")
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Device management endpoints
@app.get("/api/devices")
async def get_devices():
    """Get all devices with their security status"""
    try:
        machine = get_jac_machine()
        
        # Query all device nodes
        devices = machine.get_nodes("device")
        
        device_list = []
        for device in devices:
            device_list.append({
                "hostname": device.get("hostname"),
                "ip_addr": device.get("ip_addr"),
                "os": device.get("os"),
                "risk_score": device.get("risk_score"),
                "status": device.get("status"),
                "last_seen": device.get("last_seen")
            })
        
        return {"devices": device_list}
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

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
    """Get all security incidents"""
    try:
        machine = get_jac_machine()
        
        incidents = machine.get_nodes("incident")
        
        incident_list = []
        for incident in incidents:
            incident_list.append({
                "id": incident.get("reason"),
                "severity": incident.get("severity"),
                "reason": incident.get("reason"),
                "status": incident.get("status"),
                "timestamp": incident.get("timestamp")
            })
        
        return {"incidents": incident_list}
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

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
    """Get dashboard statistics"""
    try:
        machine = get_jac_machine()
        
        # Get counts of different node types
        users = len(machine.get_nodes("user"))
        devices = len(machine.get_nodes("device"))
        incidents = len(machine.get_nodes("incident"))
        policies = len(machine.get_nodes("policy"))
        
        # Calculate average risk score
        device_nodes = machine.get_nodes("device")
        avg_risk = sum(d.get("risk_score", 0) for d in device_nodes) / max(len(device_nodes), 1)
        
        return {
            "total_users": users,
            "total_devices": devices,
            "open_incidents": incidents,
            "active_policies": policies,
            "average_risk_score": round(avg_risk, 2),
            "system_status": "operational"
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Health check
@app.get("/health")
async def health_check():
    return {"status": "healthy", "service": "Digital Bastion API"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)