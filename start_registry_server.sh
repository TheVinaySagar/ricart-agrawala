#!/bin/bash

# Check for hostname command, install if missing
if ! command -v hostname &> /dev/null; then
    echo "Warning: 'hostname' command not found. Installing inetutils..."
    sudo pacman -S --noconfirm inetutils 2>/dev/null || echo "Please install inetutils manually"
fi

# Get local IP address
LOCAL_IP=$(hostname -I 2>/dev/null | awk '{print $1}')
if [ -z "$LOCAL_IP" ]; then
    LOCAL_IP=$(ip route get 1 | awk '{print $7; exit}')
fi

echo "========================================="
echo "Starting Ricart-Agrawala Registry Server"
echo "========================================="
echo "Registry IP: $LOCAL_IP"
echo "Registry Port: 1099"
echo ""

# Compile if needed
if [ ! -f "NodeRegistry.class" ]; then
    echo "Compiling..."
    javac *.java
    if [ $? -ne 0 ]; then
        echo "Compilation failed!"
        exit 1
    fi
fi

echo "Starting registry server with NodeRegistry service..."
echo ""
echo "Other machines can connect using:"
echo "  ./start_node.sh $LOCAL_IP <node_id>"
echo ""
echo "Press Ctrl+C to stop the server"
echo "========================================="
echo ""

# Set java.rmi.server.hostname to allow remote connections
java -Djava.rmi.server.hostname=$LOCAL_IP \
     -Djava.rmi.server.useCodebaseOnly=false \
     RicartAgrawalaApp registry
