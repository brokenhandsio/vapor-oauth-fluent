import OAuth
import FluentProvider
import AuthProvider

public struct FluentUserManager: UserManager {
    
    public init() {}
    
    public func authenticateUser(username: String, password: String) -> String? {
        let credentials = Password(username: username, password: password)
        let user = try? OAuthUser.authenticate(credentials)
        return user?.userID
    }
    
    public func getUser(id: String) -> OAuthUser? {
        return (try? OAuthUser.makeQuery().filter(OAuthUser.Properties.userID, id).first()) ?? nil
    }
}
