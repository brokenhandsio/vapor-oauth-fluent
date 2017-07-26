import OAuth
import Foundation
import Crypto
import FluentProvider

public struct FluentTokenManager: TokenManager {
    
    public init() {}
    
    public func getAccessToken(_ accessToken: String) -> AccessToken? {
        do {
            return try FluentAccessToken.makeQuery().filter(FluentAccessToken.Properties.tokenString, accessToken).first()
        } catch {
            return nil
        }
    }
    
    public func getRefreshToken(_ refreshToken: String) -> RefreshToken? {
        do {
            return try FluentRefreshToken.makeQuery().filter(FluentRefreshToken.Properties.tokenString, refreshToken).first()
        } catch {
            return nil
        }
    }
    
    public func generateAccessToken(clientID: String, userID: String?, scopes: [String]?, expiryTime: Int) throws -> AccessToken {
        let accessTokenString = try Random.bytes(count: 32).hexString
        let accessToken = FluentAccessToken(tokenString: accessTokenString, clientID: clientID, userID: userID, scopes: scopes, expiryTime: Date().addingTimeInterval(TimeInterval(expiryTime)))
        try accessToken.save()
        return accessToken
    }
    
    public func generateAccessRefreshTokens(clientID: String, userID: String?, scopes: [String]?, accessTokenExpiryTime: Int) throws -> (AccessToken, RefreshToken) {
        let accessTokenString = try Random.bytes(count: 32).hexString
        let accessToken = FluentAccessToken(tokenString: accessTokenString, clientID: clientID, userID: userID, scopes: scopes, expiryTime: Date().addingTimeInterval(TimeInterval(accessTokenExpiryTime)))
        try accessToken.save()
        
        let refreshTokenString = try Random.bytes(count: 32).hexString
        let refreshToken = FluentRefreshToken(tokenString: refreshTokenString, clientID: clientID, userID: userID, scopes: scopes)
        try refreshToken.save()
        
        return (accessToken, refreshToken)
    }
    
    public func updateRefreshToken(_ refreshToken: RefreshToken, scopes: [String]) {
        guard let refreshTokenToUpdate = refreshToken as? FluentRefreshToken else {
            return
        }
        
        refreshTokenToUpdate.scopes = scopes
        try? refreshTokenToUpdate.save()
    }
}
