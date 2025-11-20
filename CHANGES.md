# Changes Summary - RMI Remote Registration Fix

## Problem
The original implementation failed when trying to register nodes from remote machines with the error:
```
java.rmi.AccessException: Registry.rebind disallowed; origin /192.168.137.149 is non-local host
```

This is a security feature of Java RMI - the standard registry only allows bind/rebind/unbind operations from localhost.

## Solution
Implemented a custom `NodeRegistry` service that:
1. Runs on the registry server machine
2. Provides RMI methods for remote node registration
3. Maintains a directory of all registered nodes
4. Allows nodes to discover each other dynamically

## New Files Created

### 1. `NodeRegistry.java`
- RMI interface for the custom registry service
- Methods: `registerNode()`, `unregisterNode()`, `getNode()`, `getRegisteredNodeIds()`, `isNodeRegistered()`

### 2. `NodeRegistryImpl.java`
- Implementation of the NodeRegistry interface
- Uses `ConcurrentHashMap` for thread-safe node storage
- Handles node registration, unregistration, and lookup

### 3. `start_registry_server.sh`
- Launches the registry server with NodeRegistry service
- Replaces the old `start_registry.sh` for multi-machine deployments
- Automatically detects and displays the local IP address
- Handles missing `hostname` command gracefully

### 4. `cleanup.sh`
- Helper script to clean up all processes and class files
- Useful for resetting the environment

### 5. `QUICKSTART.md`
- Step-by-step guide for multi-machine setup
- Explains the fix and how it works
- Includes troubleshooting section

## Modified Files

### 1. `RicartAgrawalaApp.java`
**Changes:**
- Added `nodeRegistry` field to store custom registry reference
- Added `isRegistryServer` flag to track if this instance created the registry
- Modified `initializeRegistry()` to create/connect to NodeRegistry service
- Added "registry" mode to run as standalone registry server
- Modified `createSingleNode()` to use `nodeRegistry.registerNode()` instead of `registry.rebind()`
- Modified `connectToOtherNodes()` to query NodeRegistry for node list
- Modified `connectToNodeWithRetry()` to use `nodeRegistry.getNode()`
- Modified `cleanup()` to unregister nodes via NodeRegistry

### 2. `start_node.sh`
**Changes:**
- Added fallback for missing `hostname` command
- Uses `ip route get` if `hostname` not available
- Fixed to use `$LOCAL_IP` variable consistently

### 3. `README.md`
**Changes:**
- Updated multi-machine setup instructions
- Changed from `start_registry.sh` to `start_registry_server.sh`
- Added comprehensive troubleshooting section
- Documented the new architecture

## Architecture Changes

### Before:
```
[Node on Machine 2] --registry.rebind()--> [RMI Registry on Machine 1]
                                            ❌ REJECTED (security)
```

### After:
```
[Node on Machine 2] --nodeRegistry.registerNode()--> [NodeRegistry Service] --> [Node Directory]
                                                      [on Machine 1]
                                                      ✅ ALLOWED (RMI call)
```

## How It Works

1. **Registry Server** (Machine 1):
   - Creates standard RMI registry on port 1099
   - Creates and exports `NodeRegistryImpl` as RMI service
   - Binds it to registry as "NodeRegistry"

2. **Node Machines** (Machine 2, 3, 4...):
   - Connect to registry on Machine 1
   - Look up "NodeRegistry" service
   - Export their Node object locally
   - Call `nodeRegistry.registerNode(id, stub)` to register
   - Registry server stores the remote stub

3. **Node Discovery**:
   - Nodes call `nodeRegistry.getRegisteredNodeIds()` to see all nodes
   - Call `nodeRegistry.getNode(id)` to get specific node stubs
   - Background thread refreshes connections every 2 seconds

## Benefits

1. **Security**: No security exceptions - uses proper RMI calls
2. **Dynamic Discovery**: Nodes can join/leave at any time
3. **Centralized Management**: Registry server maintains the directory
4. **Clean Separation**: Registry server can run standalone
5. **Backward Compatible**: Single-machine mode still works

## Usage

### Start Registry Server:
```bash
./start_registry_server.sh
```

### Start Nodes:
```bash
./start_node.sh <REGISTRY_IP> <NODE_ID>
```

### Cleanup:
```bash
./cleanup.sh
```

## Testing

Tested on:
- ✅ Single machine with multiple terminals
- ✅ Multiple machines on same network
- ✅ Handles missing `hostname` command
- ✅ Dynamic node discovery
- ✅ Proper cleanup on shutdown

## Compatibility

- Java 8 or higher
- Works on Linux, macOS, and Windows
- No external dependencies beyond Java RMI
