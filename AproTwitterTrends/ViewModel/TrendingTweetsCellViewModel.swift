//
//  TrendingTweetsCellViewModel.swift
//  AproTwitterTrends
//
//  Created by Nidhi Goyal on 24/05/18.
//  Copyright © 2018 Nidhi Goyal. All rights reserved.
//

import Foundation

@objc class TrendingTweetsCellViewModel : NSObject {
    
    var _title:String = ""
    
    private var twitterInfo: TweetInfo?
    
    convenience init(with twitterInfo:TweetInfo) {
        self.init()
        
        self.twitterInfo = twitterInfo
    }
    
    func titleString() -> String {
        return twitterInfo?.name ?? ""
    }
    
    func subTitleString() -> String {
        return String(format: "%@ tweets", twitterInfo?.tweetVolume ?? "0")
    }
}
