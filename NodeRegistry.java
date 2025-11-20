import java.rmi.Remote;
import java.rmi.RemoteException;
import java.util.List;

/**
 * Custom registry interface for distributed node registration
 */
public interface NodeRegistry extends Remote {
    /**
     * Register a node with the registry
     */
    void registerNode(int nodeId, Node node) throws RemoteException;
    
    /**
     * Unregister a node from the registry
     */
    void unregisterNode(int nodeId) throws RemoteException;
    
    /**
     * Get a specific node by ID
     */
    Node getNode(int nodeId) throws RemoteException;
    
    /**
     * Get all registered node IDs
     */
    List<Integer> getRegisteredNodeIds() throws RemoteException;
    
    /**
     * Check if a node is registered
     */
    boolean isNodeRegistered(int nodeId) throws RemoteException;
}
