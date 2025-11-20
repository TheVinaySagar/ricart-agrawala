#!/bin/bash

if [ $# -lt 1 ]; then
    echo "Usage: $0 <registry_ip> [node_id]"
    echo "Example: $0 192.168.1.100"
    echo "Example: $0 192.168.1.100 1"
    exit 1
fi

REGISTRY_IP=$1
NODE_ID=${2:-0}

# Get local IP address (handle missing hostname command)
if command -v hostname &> /dev/null; then
    LOCAL_IP=$(hostname -I 2>/dev/null | awk '{print $1}')
else
    LOCAL_IP=$(ip route get 1 2>/dev/null | awk '{print $7; exit}')
fi

if [ -z "$LOCAL_IP" ]; then
    LOCAL_IP="localhost"
fi

echo "Starting Node on $LOCAL_IP"
echo "Connecting to registry at: $REGISTRY_IP:1099"
echo "Node ID: $NODE_ID"
echo ""

# Compile if needed
if [ ! -f "*.class" ]; then
    echo "Compiling..."
    javac *.java
fi

echo "Starting Ricart-Agrawala Node in multi-machine mode..."
echo ""

java -Djava.rmi.server.hostname=$LOCAL_IP \
     -Dregistry.host=$REGISTRY_IP \
     -Dregistry.port=1099 \
     RicartAgrawalaApp multi
