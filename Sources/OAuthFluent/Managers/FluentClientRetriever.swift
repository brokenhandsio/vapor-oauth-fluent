import OAuth
import FluentProvider

public struct FluentClientRetriever: ClientRetriever {
    
    public init() {}
    
    public func getClient(clientID: String) -> OAuthClient? {        
        return (try? FluentOAuthClient.makeQuery().filter(FluentOAuthClient.Properties.clientID, clientID).first()) ?? nil
    }
}
