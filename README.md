# Vapor OAuth Fluent

[![Language](https://img.shields.io/badge/Swift-3.1-brightgreen.svg)](http://swift.org)
[![Build Status](https://travis-ci.org/brokenhandsio/vapor-oauth-fluent.svg?branch=master)](https://travis-ci.org/brokenhandsio/vapor-oauth-fluent)
[![codecov](https://codecov.io/gh/brokenhandsio/vapor-oauth-fluent/branch/master/graph/badge.svg)](https://codecov.io/gh/brokenhandsio/vapor-oauth-fluent)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/brokenhandsio/vapor-oauth-fluent/master/LICENSE)

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
