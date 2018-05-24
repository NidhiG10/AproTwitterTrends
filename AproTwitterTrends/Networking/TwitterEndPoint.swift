//
//  TwitterEndPoint.swift
//  AproTwitterTrends
//
//  Created by Nidhi Goyal on 19/05/18.
//  Copyright © 2018 Nidhi Goyal. All rights reserved.
//

import Foundation

let baseUrl = "https://api.twitter.com"
let dataEncoding: String.Encoding = .utf8

public enum TwitterApi {
    case requestAccountRequestToken
    case requestAccountAuthourize(token: Credential.OAuthAccessToken)
    case requestAccountAccessToken(token: Credential.OAuthAccessToken)
    case trendingTweets(woeid:String, token: Credential.OAuthAccessToken)
}

struct OAuth {
    static let version = "1.0"
    static let signatureMethod = "HMAC-SHA1"
    static let consumerKey = "hkT8SGNKUHKm7dHPOC8V1E1zi"
    static let consumerSecretKey = "U3cIgrv0yAT6WQFR8PL6jF1LDrvWs1b5de4WEhlW4CsGbMQdzM"
    static let callBackUrl = "swifter://success"
}

extension TwitterApi: EndPointType {
    
    var baseURL: URL {
        var baseUrl = ""
        switch self {
        case .trendingTweets(_):
            baseUrl = "https://api.twitter.com/1.1"
        default:
            baseUrl = "https://api.twitter.com"
        }
         
        guard let url = URL(string: baseUrl) else { fatalError("baseURL could not be configured.")}
        return url
    }
    
    var path: String {
        switch self {
        case .requestAccountRequestToken:
            return "oauth/request_token"
        case .requestAccountAuthourize(_):
            return "oauth/authorize"
        case .requestAccountAccessToken(_):
            return "oauth/access_token"
        case .trendingTweets(_):
            return "trends/place.json"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .requestAccountRequestToken:
            return .post
        case .requestAccountAccessToken(_):
            return .post
        case .trendingTweets(_):
            return .get
            
        default:
            return .get
        }
    }
    
    var task: HTTPTask {
        switch self {
        case .requestAccountRequestToken():
            return .requestParametersAndHeaders(bodyParameters: nil,
                                                bodyEncoding: .urlEncoding,
                                                urlParameters: nil,
                                                additionHeaders:self.headers)
        default:
            return .requestParametersAndHeaders(bodyParameters: nil,
                                                       bodyEncoding: .urlEncoding,
                                                       urlParameters: self.parameters,
                                                       additionHeaders:self.headers)
        }
    }
    
    var parameters: [String:Any]? {
        switch self {
        case .requestAccountRequestToken():
            return ["oauth_callback": OAuth.callBackUrl]
        case .requestAccountAuthourize(let token):
            return ["oauth_token": token.key]
        case .requestAccountAccessToken(let token):
            if let verifier = token.verifier {
                return ["oauth_token": token.key, "oauth_verifier": verifier]
            }
        case let .trendingTweets(woeid, _):
            return ["id": woeid]
        }
        
        return nil
    }
    
    
    var headers: HTTPHeaders? {
        switch self {
        case .requestAccountRequestToken():
            return ["Authorization": authorizationHeader(for: self.baseURL.appendingPathComponent(self.path), token: nil , parameters: self.parameters)]
        case .requestAccountAccessToken(let token):
            return ["Authorization": authorizationHeader(for: self.baseURL.appendingPathComponent(self.path), token:token, parameters: self.parameters)]
        case let .trendingTweets(_, token):
            return ["Authorization": authorizationHeader(for: self.baseURL.appendingPathComponent(self.path), token:token, parameters: self.parameters)]
            
        default:
            return nil
        }
    }
    
    func authorizationHeader(for url: URL, token: Credential.OAuthAccessToken?, parameters: Dictionary<String, Any>?) -> String {
        var authorizationParameters = Dictionary<String, Any>()
        authorizationParameters["oauth_version"] = OAuth.version
        authorizationParameters["oauth_signature_method"] =  OAuth.signatureMethod
        authorizationParameters["oauth_consumer_key"] = OAuth.consumerKey
        authorizationParameters["oauth_timestamp"] = String(Int(Date().timeIntervalSince1970))
        authorizationParameters["oauth_nonce"] = UUID().uuidString
        
        authorizationParameters["oauth_token"] ??= token?.key
        
        if let parameters = parameters {
            for (key, value) in parameters where key.hasPrefix("oauth_") {
                authorizationParameters.updateValue(value, forKey: key)
            }
        }
        
        let combinedParameters = (parameters != nil) ? authorizationParameters +| parameters! : authorizationParameters
        
        authorizationParameters["oauth_signature"] = self.oauthSignature(for: url, parameters: combinedParameters, accessToken: token)
        
        let authorizationParameterComponents = authorizationParameters.urlEncodedQueryString(using: dataEncoding).components(separatedBy: "&").sorted()
        
        var headerComponents = [String]()
        for component in authorizationParameterComponents {
            let subcomponent = component.components(separatedBy: "=")
            if subcomponent.count == 2 {
                headerComponents.append("\(subcomponent[0])=\"\(subcomponent[1])\"")
            }
        }
        
        return "OAuth " + headerComponents.joined(separator: ", ")
    }
    
    func oauthSignature(for url: URL, parameters: Dictionary<String, Any>, accessToken token: Credential.OAuthAccessToken?) -> String {
        let tokenSecret = token?.secret.urlEncodedString() ?? ""
        let encodedConsumerSecret = OAuth.consumerSecretKey.urlEncodedString()
        let signingKey = "\(encodedConsumerSecret)&\(tokenSecret)"
        
        let parameterComponents = parameters.urlEncodedQueryString(using: dataEncoding).components(separatedBy: "&").sorted()
        let parameterString = parameterComponents.joined(separator: "&")
        let encodedParameterString = parameterString.urlEncodedString()
        let encodedURL = url.absoluteString.urlEncodedString()
        let signatureBaseString = "\(self.httpMethod.rawValue)&\(encodedURL)&\(encodedParameterString)"
        
        let key = signingKey.data(using: .utf8)!
        let msg = signatureBaseString.data(using: .utf8)!
        let sha1 = HMAC.sha1(key: key, message: msg)!
        return sha1.base64EncodedString(options: [])
    }
}
