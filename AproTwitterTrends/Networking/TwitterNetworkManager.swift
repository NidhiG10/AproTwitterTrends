//
//  TwitterNetworkManager.swift
//  AproTwitterTrends
//
//  Created by Nidhi Goyal on 19/05/18.
//  Copyright © 2018 Nidhi Goyal. All rights reserved.
//

import Foundation
import CoreLocation

enum NetworkResponse:String {
    case success
    case authenticationError = "You need to be authenticated first."
    case badRequest = "Bad request"
    case outdated = "The url you requested is outdated."
    case failed = "Network request failed."
    case noData = "Response returned with no data to decode."
    case unableToDecode = "We could not decode the response."
}

enum Result<String>{
    case success
    case failure(String)
}

@objc class TwitterNetworkManager : NSObject {
    typealias CompletionHandler = (_ tweets: [TweetInfo]?,_ error: String?)->()
    
    static let oAuthtoken = "oauth_token"
    static let oAuthtokenSecret = "oauth_token_secret"
    
    let twitterAuth = TwitterAuth()
    let router = Router<TwitterApi>()
    var credential: Credential?
    var locationManager = CLLocationManager()
    
    override init() {
        super.init()
        if let tokenSecret = UserDefaults.standard.value(forKey: TwitterNetworkManager.oAuthtokenSecret) as? String {
            let token = UserDefaults.standard.value(forKey: TwitterNetworkManager.oAuthtoken) as? String
            let oAuth = Credential.OAuthAccessToken(key: token!, secret: tokenSecret)
            credential = Credential(accessToken: oAuth)
        }
        
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.startUpdatingLocation()
    }
    
    func requestAccess(completion: @escaping CompletionHandler) {
        
        twitterAuth.requestAccess(with: {[weak self] (token, response) in
            if let token = token {
                self?.credential = Credential(accessToken: token)
                
                let defaults = UserDefaults.standard
                defaults.set(self?.credential?.accessToken?.key, forKey: TwitterNetworkManager.oAuthtoken)
                defaults.set(self?.credential?.accessToken?.secret, forKey: TwitterNetworkManager.oAuthtokenSecret)
                defaults.synchronize()
                
                self?.getTrendingTweets(completion: completion)
            }
        }) { (error) in
            
        }
    }
    
    func getCurrentLocationWoeid(completion: @escaping CompletionHandler) {
        if let token = self.credential?.accessToken {
            let lat = locationManager.location?.coordinate.latitude ?? 0.0;
            let long = locationManager.location?.coordinate.longitude ?? 0.0;
            
            router.request(.getWoeid(lat:lat, long:long, token:token)) {[weak self] (data, response, error) in
                var finalWoeid = "1"
                
                if let response = response as? HTTPURLResponse {
                    let result = self?.handleNetworkResponse(response)
                    switch result {
                    case .success?:
                        
                        do {
                            if let responseData = data {
                                print(responseData)
                                let jsonData = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                                print(jsonData)
                                
                                if let json = jsonData as? Array<Any> {
                                    if let data = json[0] as? [String:Any] {
                                        if let woeid = data["woeid"] as? NSNumber {
                                            finalWoeid = String(woeid.int64Value)
                                        }
                                    }
                                }
                            }
                        }catch {
                            finalWoeid = "1"
                        }
                    
                    default:
                        finalWoeid = "1"
                    }
                }
                
                self?.requestTrendingTweets(token: token, woeid: finalWoeid, completion: completion)
                
            }
        }
        else {
            requestAccess(completion:completion)
        }
    }
    
    func getTrendingTweets(completion: @escaping CompletionHandler){
        guard self.credential?.accessToken != nil else {
            requestAccess(completion:completion)
            return
        }
        
        getCurrentLocationWoeid(completion: completion)
    }
    
    func requestTrendingTweets(token:Credential.OAuthAccessToken, woeid:String, completion: @escaping CompletionHandler) {
        router.request(.trendingTweets(woeid:woeid, token:token)) { (data, response, error) in
            if error != nil {
                completion(nil, "Please check your network connection.")
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        print(responseData)
                        let jsonData = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                        print(jsonData)
                        
                        if let json = jsonData as? Array<Any> {
                            if let data = json[0] as? [String:Any] {
                                var twitterTrendsArray = [TweetInfo]()
                                
                                if let trends = data["trends"] as? Array<Any> {
                                    for trend in trends {
                                        let tweetInfo = TweetInfo(json: trend as! [String : Any])
                                        twitterTrendsArray.append(tweetInfo)
                                    }
                                }
                                completion(twitterTrendsArray,nil)
                                return
                            }
                        }
                        
                        completion(nil,nil)
                    }catch {
                        print(error)
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let networkFailureError):
                    completion(nil, networkFailureError)
                }
            }
        }
    }
    

    fileprivate func handleNetworkResponse(_ response: HTTPURLResponse) -> Result<String>{
        switch response.statusCode {
        case 200...299: return .success
        case 401...500: return .failure(NetworkResponse.authenticationError.rawValue)
        case 501...599: return .failure(NetworkResponse.badRequest.rawValue)
        case 600: return .failure(NetworkResponse.outdated.rawValue)
        default: return .failure(NetworkResponse.failed.rawValue)
        }
    }
}
