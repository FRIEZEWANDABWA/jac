// API client for connecting Vercel frontend to Render backend

const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000';

class ApiClient {
  private baseUrl: string;

  constructor() {
    this.baseUrl = API_BASE_URL;
  }

  private async request(endpoint: string, options: RequestInit = {}) {
    const url = `${this.baseUrl}${endpoint}`;
    
    const config: RequestInit = {
      headers: {
        'Content-Type': 'application/json',
        ...options.headers,
      },
      ...options,
    };

    try {
      const response = await fetch(url, config);
      
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      
      return await response.json();
    } catch (error) {
      console.error('API request failed:', error);
      throw error;
    }
  }

  // Authentication
  async login(username: string, password: string) {
    return this.request('/api/auth/login', {
      method: 'POST',
      body: JSON.stringify({ username, password }),
    });
  }

  async checkAccess(userId: string, resource: string, action: string) {
    return this.request('/api/auth/check-access', {
      method: 'POST',
      body: JSON.stringify({ user_id: userId, resource, action }),
    });
  }

  // Devices
  async getDevices() {
    return this.request('/api/devices');
  }

  async scanDevices(deviceIds?: string[]) {
    return this.request('/api/devices/scan', {
      method: 'POST',
      body: JSON.stringify({ device_ids: deviceIds }),
    });
  }

  // Incidents
  async getIncidents() {
    return this.request('/api/incidents');
  }

  async createIncident(severity: string, reason: string, affectedResource?: string) {
    return this.request('/api/incidents', {
      method: 'POST',
      body: JSON.stringify({ severity, reason, affected_resource: affectedResource }),
    });
  }

  // Threats
  async analyzeThreats() {
    return this.request('/api/threats/analyze');
  }

  // Dashboard
  async getDashboardStats() {
    return this.request('/api/dashboard/stats');
  }

  // Health check
  async healthCheck() {
    return this.request('/health');
  }
}

export const apiClient = new ApiClient();