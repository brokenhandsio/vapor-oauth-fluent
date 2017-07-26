import FluentProvider
import OAuth
import Foundation

public final class FluentRefreshToken: RefreshToken, Model {
    
    struct Properties {
        static let tokenString = "token_string"
        static let clientID = "client_id"
        static let userID = "user_id"
        static let scopes = "scopes"
    }
    
    public let storage = Storage()
    
    public init(row: Row) throws {
        let tokenString: String = try row.get(Properties.tokenString)
        let clientID: String = try row.get(Properties.clientID)
        let userID: String? = try? row.get(Properties.userID)
        let scopesString: String? = try? row.get(Properties.scopes)
        
        let scopes: [String]?
        
        if let scopesSet = scopesString {
            scopes = scopesSet.components(separatedBy: " ")
        }
        else {
            scopes = nil
        }
        
        super.init(tokenString: tokenString, clientID: clientID, userID: userID, scopes: scopes)
    }
    
    override public init(tokenString: String, clientID: String, userID: String?, scopes: [String]?) {
        super.init(tokenString: tokenString, clientID: clientID, userID: userID, scopes: scopes)
    }
    
    public func makeRow() throws -> Row {
        var row = Row()
        try row.set(Properties.tokenString, tokenString)
        try row.set(Properties.clientID, clientID)
        try row.set(Properties.userID, userID)
        try row.set(Properties.scopes, scopes?.joined(separator: " "))
        return row
    }
}

extension FluentRefreshToken: Preparation {
    public static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Properties.tokenString)
            builder.string(Properties.clientID)
            builder.string(Properties.userID, optional: true)
            builder.string(Properties.scopes, optional: true)
        }
    }
    
    public static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}
