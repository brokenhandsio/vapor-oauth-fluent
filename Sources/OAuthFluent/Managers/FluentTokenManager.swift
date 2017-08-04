import OAuth
import Foundation
import Crypto
import FluentProvider

public struct FluentTokenManager: TokenManager {

    public init() {}

    public func getAccessToken(_ accessToken: String) -> AccessToken? {
        do {
            return try AccessToken.makeQuery().filter(AccessToken.Properties.tokenString, accessToken).first()
        } catch {
            return nil
        }
    }

    public func getRefreshToken(_ refreshToken: String) -> RefreshToken? {
        do {
            return try RefreshToken.makeQuery().filter(RefreshToken.Properties.tokenString, refreshToken).first()
        } catch {
            return nil
        }
    }

    public func generateAccessToken(clientID: String, userID: Identifier?, scopes: [String]?, expiryTime: Int) throws -> AccessToken {
        let accessTokenString = try Random.bytes(count: 32).hexString
        let accessToken = AccessToken(tokenString: accessTokenString, clientID: clientID, userID: userID, scopes: scopes, expiryTime: Date().addingTimeInterval(TimeInterval(expiryTime)))
        try accessToken.save()
        return accessToken
    }

    public func generateAccessRefreshTokens(clientID: String, userID: Identifier?, scopes: [String]?, accessTokenExpiryTime: Int) throws -> (AccessToken, RefreshToken) {
        let accessTokenString = try Random.bytes(count: 32).hexString
        let accessToken = AccessToken(tokenString: accessTokenString, clientID: clientID, userID: userID, scopes: scopes, expiryTime: Date().addingTimeInterval(TimeInterval(accessTokenExpiryTime)))
        try accessToken.save()

        let refreshTokenString = try Random.bytes(count: 32).hexString
        let refreshToken = RefreshToken(tokenString: refreshTokenString, clientID: clientID, userID: userID, scopes: scopes)
        try refreshToken.save()

        return (accessToken, refreshToken)
    }

    public func updateRefreshToken(_ refreshToken: RefreshToken, scopes: [String]) {
        refreshToken.scopes = scopes
        try? refreshToken.save()
    }
}
