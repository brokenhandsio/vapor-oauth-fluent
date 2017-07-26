# Vapor OAuth Fluent

This repo contains a Fluent implementations for the required protocols for [Vapor OAuth](https://github.com/brokenhandsio/vapor-oauth).

# Usage

Vapor OAuth can Fluent be added to your Vapor add with a simple provider. To get started, first add the library to your `Package.swift` dependencies:

```swift
dependencies: [
    ...,
    .Package(url: "https://github.com/brokenhandsio/vapor-oauth-fluent", majorVersion: 0)
]
```

Next import the library into where you set up your `Droplet`:

```swift
import OAuthFluent
```

Then choose the implementations you wish to add the provider you add in your `Config`. For example:

```swift
try addProvider(OAuth.Provider(codeManager: FluentCodeManager(), tokenManager: FluentTokenManager(), clientRetriever: FluentClientRetriever(), authorizeHandler: MyAuthHandler(), userManager: FluentUserManager(), validScopes: ["view_profile", "edit_profile"]))
```

You can choose which implementations to use, or write your custom ones. For instance you may choose to use Fluent for Tokens and Users, but hard code the clients and use JWT to manage Codes.

# Models Included

The following models are included with this repository:

* FluentAccessToken
* FluentRefreshToken
* FluentOAuthCode
* FluentOAuthUser
* FluentOAuthClient

**Note** you will need to add these models to your preparations if you wish to use any of these.

# Managers Included

As well as models, Vapor OAuth Fluent includes implementations for the Managers required to interact with the models. The included managers are:

* FluentClientRetriever
* FluentCodeManager
* FluentTokenManager
* FluentUserManager
