import FluentProvider
import OAuth
import AuthProvider

//public final class FluentOAuthUser: OAuthUser, Model {

extension OAuthUser: Model {

    struct Properties {
        static let userID = "user_id"
        static let username = "username"
        static let emailAddress = "email_address"
        static let password = "password"
    }
    
    public var storage: Storage {
        get {
            if let storage = extend["fluent-storage"] as? Storage {
                return storage
            }
            else {
                let storage = Storage()
                extend["fluent-storage"] = storage
                return storage
            }
        }
    }
    
    public convenience init(row: Row) throws {
        let userID: String = try row.get(Properties.userID)
        let username: String = try row.get(Properties.username)
        let emailAddress: String? = try? row.get(Properties.emailAddress)
        let passwordAsString: String = try row.get(Properties.password)
        self.init(userID: userID, username: username, emailAddress: emailAddress, password: passwordAsString.makeBytes())
    }
    
    public func makeRow() throws -> Row {
        var row = Row()
        
        try row.set(Properties.userID, userID)
        try row.set(Properties.username, username)
        try row.set(Properties.password, password.makeString())
        try row.set(Properties.emailAddress, emailAddress)
        
        return row
    }
}

extension OAuthUser: Preparation {
    public static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Properties.userID)
            builder.string(Properties.username)
            builder.string(Properties.password)
            builder.string(Properties.emailAddress, optional: true)
        }
    }
    
    public static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension OAuthUser: SessionPersistable {}

public protocol PasswordHasherVerifier: PasswordVerifier, HashProtocol {}

extension BCryptHasher: PasswordHasherVerifier {}

extension OAuthUser: PasswordAuthenticatable {
    public static let usernameKey = "username"
    public static let passwordVerifier: PasswordVerifier? = OAuthUser.passwordHasher
    public var hashedPassword: String? {
        return password.makeString()
    }
    public internal(set) static var passwordHasher: PasswordHasherVerifier = BCryptHasher(cost: 10)
}
