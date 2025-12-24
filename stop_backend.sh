#!/bin/bash
# Find the process ID running on port 8000
PID=$(lsof -t -i:8000)

if [ -z "$PID" ]; then
    echo "⚠️  No backend server found running on port 8000."
else
    echo "🛑 Stopping backend server (PID: $PID)..."
    kill -9 $PID
    echo "✅ Backend stopped successfully."
fi
