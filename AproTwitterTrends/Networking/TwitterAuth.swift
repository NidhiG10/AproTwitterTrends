//
//  TwitterAuth.swift
//  AproTwitterTrends
//
//  Created by Nidhi Goyal on 20/05/18.
//  Copyright © 2018 Nidhi Goyal. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let SwifterCallbackNotification: Notification.Name = Notification.Name(rawValue: "SwifterCallbackNotificationName")
}

@objc class TwitterAuth : NSObject {
    let router = Router<TwitterApi>()
}

extension TwitterAuth {
    
    public typealias TokenSuccessHandler = (Credential.OAuthAccessToken?, URLResponse) -> Void
    public typealias FailureHandler = (_ error: Error) -> Void
    
    internal struct CallbackNotification {
        static let optionsURLKey = "SwifterCallbackNotificationOptionsURLKey"
    }
    
    func requestAccess(with success: TokenSuccessHandler?, failure: FailureHandler?) {
        
        postOAuthRequestToken(with: { (token, response) in
            var requestToken = token!
            
            NotificationCenter.default.addObserver(forName: .SwifterCallbackNotification, object: nil, queue: .main) { notification in
                NotificationCenter.default.removeObserver(self)
                let url = notification.userInfo![CallbackNotification.optionsURLKey] as! URL
                
                let parameters = url.query!.queryStringParameters
                requestToken.verifier = parameters["oauth_verifier"]
                
                self.postOAuthAccessToken(with: requestToken, success: { accessToken, response in
                    success?(accessToken!, response)
                }, failure: failure)
            }
            
            self.router.openUrl(.requestAccountAuthourize(token: requestToken))
            
        }) { (error) in
            
        }
    }
    
    public class func handleOpenURL(_ url: URL) {
        let notification = Notification(name: .SwifterCallbackNotification, object: nil, userInfo: [CallbackNotification.optionsURLKey: url])
        NotificationCenter.default.post(notification)
    }
    
    public func postOAuthRequestToken(with success: @escaping TokenSuccessHandler, failure: FailureHandler?) {
        router.request(.requestAccountRequestToken) { (data, response, error) in
            if let response = response as? HTTPURLResponse {
                let responseString = String(data: data!, encoding: .utf8)!
                let accessToken = Credential.OAuthAccessToken(queryString: responseString)
                success(accessToken, response)
            }
        }
    }
    
    public func postOAuthAccessToken(with requestToken: Credential.OAuthAccessToken, success: @escaping TokenSuccessHandler, failure: FailureHandler?) {
        if let verifier = requestToken.verifier {
            router.request(.requestAccountAccessToken(token: requestToken)) { (data, response, error) in
                if let response = response as? HTTPURLResponse {
                    let responseString = String(data: data!, encoding: .utf8)!
                    let accessToken = Credential.OAuthAccessToken(queryString: responseString)
                    success(accessToken, response)
                }
            }
        }
    }
}
