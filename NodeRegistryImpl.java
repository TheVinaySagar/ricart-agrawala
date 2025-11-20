import java.rmi.RemoteException;
import java.rmi.server.UnicastRemoteObject;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Implementation of custom node registry that allows remote registration
 */
public class NodeRegistryImpl extends UnicastRemoteObject implements NodeRegistry {
    private final Map<Integer, Node> nodes;
    
    public NodeRegistryImpl() throws RemoteException {
        super();
        this.nodes = new ConcurrentHashMap<>();
    }
    
    @Override
    public synchronized void registerNode(int nodeId, Node node) throws RemoteException {
        nodes.put(nodeId, node);
        Logger.info("Node " + nodeId + " registered with custom registry");
        
        // Notify all existing nodes about the new node
        notifyNodesOfChange();
    }
    
    @Override
    public synchronized void unregisterNode(int nodeId) throws RemoteException {
        nodes.remove(nodeId);
        Logger.info("Node " + nodeId + " unregistered from custom registry");
        
        // Notify remaining nodes about the change
        notifyNodesOfChange();
    }
    
    @Override
    public Node getNode(int nodeId) throws RemoteException {
        return nodes.get(nodeId);
    }
    
    @Override
    public List<Integer> getRegisteredNodeIds() throws RemoteException {
        return new ArrayList<>(nodes.keySet());
    }
    
    @Override
    public boolean isNodeRegistered(int nodeId) throws RemoteException {
        return nodes.containsKey(nodeId);
    }
    
    private void notifyNodesOfChange() {
        // This could be enhanced to actively notify nodes of topology changes
        // For now, nodes will discover changes through periodic polling
    }
}
