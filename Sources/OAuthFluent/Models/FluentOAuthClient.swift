import OAuth
import FluentProvider

public final class FluentOAuthClient: OAuthClient, Model {
    
    struct Properties {
        static let clientID = "client_id"
        static let clientSecret = "client_secret"
        static let redirectURIs = "redirect_uris"
        static let scopes = "scopes"
        static let confidentialClient = "confidential_client"
        static let firstParty = "first_party"
        static let allowGrantTypes = "allowed_grant_types"
    }
    
    public let storage = Storage()
    
    public init(row: Row) throws {
        let clientID: String = try row.get(Properties.clientID)
        let clientSecret: String? = try? row.get(Properties.clientSecret)
        let redirectURIsString: String? = try? row.get(Properties.redirectURIs)
        let scopeString: String? = try row.get(Properties.scopes)
        let confidentalClient: Bool? = try? row.get(Properties.confidentialClient)
        let firstParty: Bool = try row.get(Properties.firstParty)
        let allowedGrantTypesString: String? = try? row.get(Properties.allowGrantTypes)
        
        let scopes: [String]?
        let redirectURIs: [String]?
        let allowedGrantTypesAsStrings: [String]?
        
        if let scopeStringSet = scopeString {
            scopes = scopeStringSet.components(separatedBy: " ")
        }
        else {
            scopes = nil
        }
        
        if let redirectURIsSet = redirectURIsString {
            redirectURIs = redirectURIsSet.components(separatedBy: " ")
        }
        else {
            redirectURIs = nil
        }
        
        if let allowedGrantTypesSet = allowedGrantTypesString {
            allowedGrantTypesAsStrings = allowedGrantTypesSet.components(separatedBy: " ")
        }
        else {
            allowedGrantTypesAsStrings = nil
        }
        
        let allowedGrantTypes: [OAuthFlowType]?
        
        if let allowedStrings = allowedGrantTypesAsStrings {
            allowedGrantTypes = allowedStrings.flatMap { OAuthFlowType(rawValue: $0) }
        }
        else {
            allowedGrantTypes = nil
        }
        
        super.init(clientID: clientID, redirectURIs: redirectURIs, clientSecret: clientSecret, validScopes: scopes, confidential: confidentalClient, firstParty: firstParty, allowedGrantTypes: allowedGrantTypes)
    }
    
    
    public override init(clientID: String, redirectURIs: [String]?, clientSecret: String? = nil, validScopes: [String]? = nil, confidential: Bool? = nil, firstParty: Bool = false, allowedGrantTypes: [OAuthFlowType]? = nil) {
        super.init(clientID: clientID, redirectURIs: redirectURIs, clientSecret: clientSecret, validScopes: validScopes, confidential: confidential, firstParty: firstParty, allowedGrantTypes: allowedGrantTypes)
    }
    
    public func makeRow() throws -> Row {
        var row = Row()
        
        try row.set(Properties.clientID, clientID)
        try row.set(Properties.clientSecret, clientSecret)
        try row.set(Properties.redirectURIs, redirectURIs?.joined(separator: " "))
        try row.set(Properties.scopes, validScopes?.joined(separator: " "))
        try row.set(Properties.confidentialClient, confidentialClient)
        try row.set(Properties.firstParty, firstParty)
        
        let allowedGrantTypesString = allowedGrantTypes?.map { $0.rawValue }
        try row.set(Properties.allowGrantTypes, allowedGrantTypesString?.joined(separator: " "))
        
        return row
    }
}

extension FluentOAuthClient: Preparation {
    public static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Properties.clientID)
            builder.string(Properties.redirectURIs, optional: true)
            builder.string(Properties.clientSecret, optional: true)
            builder.string(Properties.scopes, optional: true)
            builder.bool(Properties.confidentialClient, optional: true)
            builder.bool(Properties.firstParty)
            builder.string(Properties.allowGrantTypes, optional: true)
        }
    }
    
    public static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}
