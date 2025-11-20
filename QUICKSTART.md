# Quick Start Guide - Multi-Machine Setup

## Problem Fixed
The original error "Registry.rebind disallowed; origin is non-local host" occurred because Java RMI registries don't allow remote bind/rebind operations for security.

**Solution**: We now use a custom `NodeRegistry` service that safely allows remote node registration.

## Setup Instructions

### Prerequisites
- All machines must be on the same network
- Java must be installed on all machines
- Firewall must allow ports 1099 and 5000-5009

### Step 1: Prepare All Machines
On each machine, copy the project files and compile:
```bash
cd ricart-agrawala
javac *.java
```

### Step 2: Start Registry Server (Machine 1)
On the first machine (e.g., IP: 192.168.137.37):
```bash
./start_registry_server.sh
```

This will display:
```
=========================================
Starting Ricart-Agrawala Registry Server
=========================================
Registry IP: 192.168.137.37
Registry Port: 1099

Other machines can connect using:
  ./start_node.sh 192.168.137.37 <node_id>

Press Ctrl+C to stop the server
=========================================
```

**Note the IP address shown!** You'll use it on other machines.

### Step 3: Start Nodes on Other Machines

#### Machine 2 (Node 0):
```bash
./start_node.sh 192.168.137.37 0
# When prompted: Enter node ID (0-9): 0
```

#### Machine 3 (Node 1):
```bash
./start_node.sh 192.168.137.37 1
# When prompted: Enter node ID (0-9): 1
```

#### Machine 4 (Node 2):
```bash
./start_node.sh 192.168.137.37 2
# When prompted: Enter node ID (0-9): 2
```

### Step 4: Watch the Algorithm Work!
You should see output like:
```
2025-11-20 11:52:15.123 [INFO] Node 0 now has 2 connections
2025-11-20 11:52:17.456 [INFO] [Node0] Requesting critical section [timestamp:5]
2025-11-20 11:52:17.789 [INFO] [Node0] *** ENTERED CRITICAL SECTION *** [timestamp:5]
2025-11-20 11:52:19.234 [INFO] [Node0] *** EXITED CRITICAL SECTION *** [timestamp:5]
```

### Step 5: Stop Everything
- Press 'q' and Enter on each node terminal
- Press Ctrl+C on the registry server terminal

Or use the cleanup script on each machine:
```bash
./cleanup.sh
```

## Key Differences from Old Version

### Old (Broken):
- Used standard `rmiregistry` 
- Tried to call `registry.rebind()` from remote machines ❌
- Failed with "Registry.rebind disallowed"

### New (Working):
- Uses custom `NodeRegistry` service ✅
- Nodes register through RMI calls to the service ✅
- Registry server maintains the node directory ✅
- Remote registration is allowed and secure ✅

## Testing on Single Machine (for development)

You can test with multiple terminals on one machine:

**Terminal 1:**
```bash
./start_registry_server.sh
```

**Terminal 2:**
```bash
./start_node.sh localhost 0
# Enter: 0
```

**Terminal 3:**
```bash
./start_node.sh localhost 1
# Enter: 1
```

**Terminal 4:**
```bash
./start_node.sh localhost 2
# Enter: 2
```

## Troubleshooting

### "hostname: command not found"
```bash
sudo pacman -S inetutils  # Arch Linux
```
Or the script will automatically fall back to `ip route`.

### Nodes can't connect
1. Check firewall settings
2. Verify all nodes use the same registry IP
3. Ensure each node has a unique ID
4. Wait 2-3 seconds for discovery

### Port already in use
```bash
./cleanup.sh
```

### Need to restart everything
```bash
# On registry server
pkill -f RicartAgrawalaApp
./start_registry_server.sh

# On each node
pkill -f RicartAgrawalaApp
./start_node.sh <REGISTRY_IP> <NODE_ID>
```
