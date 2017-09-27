import VaporOAuth

public struct FluentResourceServerRetriever: ResourceServerRetriever {

    public init() { }

    public func getServer(_ username: String) -> OAuthResourceServer? {
        return (try? OAuthResourceServer.makeQuery().filter(OAuthResourceServer.Properties.username, username).first()) ?? nil
    }

}
