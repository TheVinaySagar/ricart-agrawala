#!/bin/bash

echo "Cleaning up Ricart-Agrawala processes..."

# Kill any running Java processes for this application
pkill -f "RicartAgrawalaApp" 2>/dev/null

# Kill any rmiregistry processes
pkill -f "rmiregistry" 2>/dev/null

# Clean up class files
rm -f *.class 2>/dev/null

echo "Cleanup complete!"
echo ""
echo "You can now start fresh with:"
echo "  ./start_registry_server.sh  (on registry server)"
echo "  ./start_node.sh <IP> <ID>   (on each node)"
