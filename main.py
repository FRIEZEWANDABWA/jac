# main.py - Root level FastAPI entrypoint for Render deployment

import sys
import os

# Add the services directory to Python path
sys.path.append(os.path.join(os.path.dirname(__file__), 'services'))

# Import the FastAPI app from services/api/main.py
from api.main import app

if __name__ == "__main__":
    import uvicorn
    port = int(os.environ.get("PORT", 8000))
    uvicorn.run(app, host="0.0.0.0", port=port)