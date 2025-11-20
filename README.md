# Ricart-Agrawala Distributed Mutual Exclusion Algorithm

Implementation of the Ricart-Agrawala algorithm for distributed mutual exclusion using Java RMI.

## Overview

This implementation provides a distributed mutual exclusion algorithm where multiple nodes coordinate access to a shared critical section without a central coordinator. The algorithm uses:

- **Logical clocks** (Lamport timestamps) for event ordering
- **Request-defer-reply** mechanism for coordination
- **Priority-based access** using timestamps and node IDs

## Files

- `Node.java` - RMI interface for node communication
- `NodeImpl.java` - Algorithm implementation with state management
- `RicartAgrawalaApp.java` - Main application and node coordination
- `Config.java` - Configuration parameters
- `Logger.java` - Logging utility
- `run.sh` - Local execution script
- `demo.sh` - 30-second local demo
- `start_registry.sh` - Start RMI registry for network
- `start_node.sh` - Start node on network

## Usage

### Single Machine (Local)

```bash
# Interactive mode
./run.sh

# Quick 30-second demo
./demo.sh
```

### Multiple Machines (Network) - UPDATED

In network mode, each process runs **one node**, and all nodes connect to a **single registry server** on Machine 1.

#### Machine 1 (Registry Server):
```bash
# Start the registry server with custom NodeRegistry service
./start_registry_server.sh
```

This will output the IP address that other machines should use to connect.

#### Machine 2 (Node 0):
```bash
./start_node.sh <MACHINE1_IP> 0
# When prompted: Enter node ID (0-9): 0
```

#### Machine 3 (Node 1):
```bash
./start_node.sh <MACHINE1_IP> 1
# When prompted: Enter node ID (0-9): 1
```

#### Machine 4 (Node 2):
```bash
./start_node.sh <MACHINE1_IP> 2
# When prompted: Enter node ID (0-9): 2
```

**Notes:**
- Replace `<MACHINE1_IP>` with the actual IP address of Machine 1 (shown by `start_registry_server.sh`), e.g. `192.168.137.37`.
- Each machine must use a **unique node ID** (0–9). The ID you type at the prompt must match the second argument to `start_node.sh`.
- The new implementation uses a custom NodeRegistry service to allow remote node registration.
- Nodes can dynamically discover each other through the registry server.

### Simulating Multi-Machine on Same Machine

**Important:** Do NOT run `rmiregistry &` manually. The first node will automatically create the registry.

**Option 1: Using localhost (simplest for same-machine testing)**
```bash
# Terminal 1 (Node 0 - creates registry automatically):
java -Djava.rmi.server.hostname=localhost -Dregistry.host=localhost RicartAgrawalaApp multi
# Enter: 0

# Terminal 2 (Node 1 - connects to existing registry):
java -Djava.rmi.server.hostname=localhost -Dregistry.host=localhost RicartAgrawalaApp multi
# Enter: 1

# Terminal 3 (Node 2 - connects to existing registry):
java -Djava.rmi.server.hostname=localhost -Dregistry.host=localhost RicartAgrawalaApp multi
# Enter: 2
```

**Option 2: Using network IP (for actual network testing)**
```bash
# First, find your machine's IP address:
ipconfig getifaddr en0  # macOS
# or: hostname -I        # Linux

# Terminal 1 (Node 0 - creates registry automatically):
java -Djava.rmi.server.hostname=YOUR_IP -Dregistry.host=YOUR_IP RicartAgrawalaApp multi
# Enter: 0

# Terminal 2 (Node 1 - connects to existing registry):
java -Djava.rmi.server.hostname=YOUR_IP -Dregistry.host=YOUR_IP RicartAgrawalaApp multi
# Enter: 1

# Terminal 3 (Node 2 - connects to existing registry):
java -Djava.rmi.server.hostname=YOUR_IP -Dregistry.host=YOUR_IP RicartAgrawalaApp multi
# Enter: 2
```

**Note:** Replace `YOUR_IP` with your actual IP address (e.g., `192.168.137.37`). Using the wrong IP will cause connection failures.

### Manual Execution

```bash
# Compile
javac *.java

# Start RMI registry
rmiregistry &

# Run application (single machine mode)
java RicartAgrawalaApp

# Run application (multi-machine mode)
java RicartAgrawalaApp multi
```

## How It Works

1. Each node maintains a logical clock to order events
2. When requesting the critical section, a node:
   - Increments its logical clock
   - Broadcasts request to all other nodes with timestamp
   - Waits for replies from all other nodes
3. Nodes grant permission if they:
   - Are not requesting/in the critical section, OR
   - Have lower priority (higher timestamp or higher node ID)
4. Upon exiting the critical section, a node releases and sends deferred replies

## Configuration

Edit `Config.java` to adjust:

- `MIN_REQUEST_DELAY` / `MAX_REQUEST_DELAY` - Time between requests
- `MIN_CS_WORK_TIME` / `MAX_CS_WORK_TIME` - Time in critical section
- `MIN_NODES` / `MAX_NODES` - Number of nodes (2-10)

## Example Output

### Local (Single Machine):
```
[Node0][INFO] Requesting critical section [timestamp:1]
[Node1][INFO] Received request from Node 0 [timestamp:2]
[Node1][INFO] Grants permission to Node 0
[Node0][INFO] *** ENTERED CRITICAL SECTION *** [timestamp:1]
[Node0][INFO] *** EXITED CRITICAL SECTION *** [timestamp:1]
```

### Network (Multiple Machines):
```
# Machine 1:
[Node0][INFO] Requesting critical section [timestamp:1]
[Node0][INFO] *** ENTERED CRITICAL SECTION *** [timestamp:1]

# Machine 2:
[Node1][INFO] Received request from Node 0 [timestamp:2]
[Node1][INFO] Grants permission to Node 0
[Node1][INFO] Requesting critical section [timestamp:3]

# Machine 3:
[Node2][INFO] Received request from Node 0 [timestamp:3]
[Node2][INFO] Grants permission to Node 0
```

## Algorithm Properties

- **Mutual Exclusion**: Only one node can be in the critical section at a time
- **No Deadlocks**: Requests are granted based on priority
- **Fairness**: Nodes are served in priority order (timestamp, then node ID)

## Troubleshooting

### "hostname: command not found"
**Issue**: The `hostname` command is missing on your system.

**Solution**: Install `inetutils`:
```bash
# Arch Linux
sudo pacman -S inetutils

# Ubuntu/Debian
sudo apt-get install inetutils-ping

# Or the script will fall back to using `ip route` command
```

### "Registry.rebind disallowed; origin is non-local host"
**Issue**: The standard RMI registry doesn't allow remote bind/rebind operations for security reasons.

**Solution**: This is now fixed! The new implementation uses a custom `NodeRegistry` service that allows remote node registration. Make sure to:
1. Use `./start_registry_server.sh` instead of `./start_registry.sh` on Machine 1
2. Recompile all files: `javac *.java`

### Firewall Issues
If nodes can't connect across machines, ensure:
- Port 1099 (RMI registry) is open
- Ports 5000-5009 (node ports) are open
- Firewall allows Java RMI connections

**Linux (iptables)**:
```bash
sudo iptables -A INPUT -p tcp --dport 1099 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 5000:5009 -j ACCEPT
```

**Linux (firewalld)**:
```bash
sudo firewall-cmd --permanent --add-port=1099/tcp
sudo firewall-cmd --permanent --add-port=5000-5009/tcp
sudo firewall-cmd --reload
```

### "NodeRegistry service not found"
**Issue**: Trying to connect to an old-style registry without the custom NodeRegistry service.

**Solution**: 
1. Stop any existing `rmiregistry` processes: `pkill -f rmiregistry`
2. Start the new registry server: `./start_registry_server.sh`
3. Then start nodes on other machines

### Connection Issues Between Nodes
If nodes can't discover each other:
1. Verify all nodes are using the same registry IP
2. Check that each node has a unique ID (0-9)
3. Wait a few seconds - nodes refresh connections every 2 seconds
4. Check network connectivity: `ping <REGISTRY_IP>`
