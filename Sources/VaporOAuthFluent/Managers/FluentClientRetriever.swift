import VaporOAuth
import FluentProvider

public struct FluentClientRetriever: ClientRetriever {

    public init() {}

    public func getClient(clientID: String) -> OAuthClient? {
        return (try? OAuthClient.makeQuery().filter(OAuthClient.Properties.clientID, clientID).first()) ?? nil
    }
}
