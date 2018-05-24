//
//  TweetInfo.swift
//  AproTwitterTrends
//
//  Created by Nidhi Goyal on 23/05/18.
//  Copyright © 2018 Nidhi Goyal. All rights reserved.
//

import Foundation

@objc class TweetInfo: NSObject {
    var name: String? = nil
    var url: String? = nil
    var promotedContent: String? = nil
    var query: String? = nil
    var tweetVolume: Int? = nil
}

extension TweetInfo{
    
    convenience init(json: [String:Any])  {
        self.init()
        if let name = json["name"] as? String {
            self.name = name
        }
        
        if let promotedContent = json["promoted_content"] as? String {
            self.promotedContent = promotedContent
        }
        
        if let url = json["url"] as? String {
            self.url = url
        }
        
        if let query = json["query"] as? String {
            self.query = query
        }
        
        if let tweetVolume = json["tweet_volume"] as? NSNumber {
            self.tweetVolume = tweetVolume.intValue
        }
    }
}
