import FluentProvider
import OAuth
import Foundation

extension AccessToken: Model {
    
    struct Properties {
        static let tokenString = "token_string"
        static let clientID = "client_id"
        static let userID = "user_id"
        static let expiryTime = "expiry_time"
        static let scopes = "scopes"
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
        let tokenString: String = try row.get(Properties.tokenString)
        let clientID: String = try row.get(Properties.clientID)
        let userID: String? = try? row.get(Properties.userID)
        let expiryTime: Date = try row.get(Properties.expiryTime)
        let scopesString: String? = try? row.get(Properties.scopes)
        
        let scopes: [String]?
        
        if let scopesSet = scopesString {
            scopes = scopesSet.components(separatedBy: " ")
        }
        else {
            scopes = nil
        }
        
        self.init(tokenString: tokenString, clientID: clientID, userID: userID, scopes: scopes, expiryTime: expiryTime)
    }
    
    public func makeRow() throws -> Row {
        var row = Row()
        try row.set(Properties.tokenString, tokenString)
        try row.set(Properties.clientID, clientID)
        try row.set(Properties.userID, userID)
        try row.set(Properties.expiryTime, expiryTime)
        try row.set(Properties.scopes, scopes?.joined(separator: " "))
        return row
    }
}

extension AccessToken: Preparation {
    public static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Properties.tokenString)
            builder.string(Properties.clientID)
            builder.string(Properties.userID, optional: true)
            builder.date(Properties.expiryTime)
            builder.string(Properties.scopes, optional: true)
        }
    }
    
    public static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}
