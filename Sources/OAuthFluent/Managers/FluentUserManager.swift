import OAuth
import FluentProvider
import AuthProvider

public struct FluentUserManager: UserManager {
    
    public init() {}
    
    public func authenticateUser(username: String, password: String) -> Identifier? {
        let credentials = Password(username: username, password: password)
        let user = try? OAuthUser.authenticate(credentials)
        return user?.id
    }
    
    public func getUser(id: Identifier) -> OAuthUser? {
        return (try? OAuthUser.find(id)) ?? nil
    }
}
