//
//  TwitterNetworkManager.swift
//  AproTwitterTrends
//
//  Created by Nidhi Goyal on 19/05/18.
//  Copyright © 2018 Nidhi Goyal. All rights reserved.
//

import Foundation

enum Result<String>{
    case success
    case failure(String)
}

@objc class TwitterNetworkManager : NSObject {
    static let oAuthtoken = "oauth_token"
    static let oAuthtokenSecret = "oauth_token_secret"
    
    let twitterAuth = TwitterAuth()
    let router = Router<TwitterApi>()
    var credential: Credential?
    
    override init() {
        super.init()
        if let token = UserDefaults.standard.value(forKey: TwitterNetworkManager.oAuthtoken) as? String {
            let tokenSecret = UserDefaults.standard.value(forKey: TwitterNetworkManager.oAuthtoken) as? String
            let oAuth = Credential.OAuthAccessToken(key: token, secret: tokenSecret!)
            credential = Credential(accessToken: oAuth)
        }
    }
    
    func requestAccess() {
        
        twitterAuth.requestAccess(with: { (token, response) in
            if let token = token {
                self.credential = Credential(accessToken: token)
                
                let defaults = UserDefaults.standard
                defaults.set(self.credential?.accessToken?.key, forKey: TwitterNetworkManager.oAuthtoken)
                defaults.set(self.credential?.accessToken?.secret, forKey: TwitterNetworkManager.oAuthtokenSecret)
                defaults.synchronize()
            }
        }) { (error) in
            
        }
    }
    
}
