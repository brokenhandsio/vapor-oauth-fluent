import FluentProvider
import OAuth
import AuthProvider

public final class FluentOAuthUser: OAuthUser, Model {
    
    struct Properties {
        static let username = "username"
        static let emailAddress = "email_address"
        static let password = "password"
    }
    
    public let storage = Storage()
    
    public init(username: String, emailAddress: String, password: Bytes) {
        super.init(userID: nil, username: username, emailAddress: emailAddress, password: password)
    }
    
    required public init(row: Row) throws {
        let username: String = try row.get(Properties.username)
        let emailAddress: String? = try? row.get(Properties.emailAddress)
        let passwordAsString: String = try row.get(Properties.password)
        super.init(userID: nil, username: username, emailAddress: emailAddress, password: passwordAsString.makeBytes())
    }
    
    public func makeRow() throws -> Row {
        var row = Row()
        
        try row.set(Properties.username, username)
        try row.set(Properties.password, password.makeString())
        try row.set(Properties.emailAddress, emailAddress)
        
        return row
    }
    
    override public var userID: String? {
        get {
            guard let storageIDNode = try? id.makeNode(in: nil), let storageID = storageIDNode.string else {
                return "IDENTIFIER"
            }
            
            return storageID
        }
        set {
            if let newID = newValue {
                self.id = Identifier(newID)
            }
        }
        
    }
}

extension FluentOAuthUser: Preparation {
    public static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Properties.username)
            builder.string(Properties.password)
            builder.string(Properties.emailAddress, optional: true)
        }
    }
    
    public static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension FluentOAuthUser: SessionPersistable {}

public protocol PasswordHasherVerifier: PasswordVerifier, HashProtocol {}

extension BCryptHasher: PasswordHasherVerifier {}

extension FluentOAuthUser: PasswordAuthenticatable {
    public static let usernameKey = "username"
    public static let passwordVerifier: PasswordVerifier? = FluentOAuthUser.passwordHasher
    public var hashedPassword: String? {
        return password.makeString()
    }
    public internal(set) static var passwordHasher: PasswordHasherVerifier = BCryptHasher(cost: 10)
}
