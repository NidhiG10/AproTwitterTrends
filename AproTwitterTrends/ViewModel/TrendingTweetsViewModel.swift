//
//  TrendingTweetsViewModel.swift
//  AproTwitterTrends
//
//  Created by Nidhi Goyal on 24/05/18.
//  Copyright © 2018 Nidhi Goyal. All rights reserved.
//

import UIKit

class TrendingTweetsViewModel: NSObject {
    let cellReuseIdentifier = "TrendingTwitterCell"
    var twitterNetworkManager = TwitterNetworkManager()
    var trendingTweets = [TweetInfo]()
    
    var tableView: UITableView?
    
    convenience init(with tableView:UITableView?) {
        self.init()
        
        tableView?.dataSource = self
        tableView?.delegate = self
        tableView?.registerNib(fromClass: TrendingTwitterCell.self)
        self.tableView = tableView
        
    }
    
    func getTrendingTweets() {
        twitterNetworkManager.getTrendingTweets {[weak self] (tweets, error) in
            if let tweets = tweets {
                self?.trendingTweets = tweets
                DispatchQueue.main.async {
                    self?.tableView?.reloadData()
                }
                
            }
        }
    }
}

extension TrendingTweetsViewModel: UITableViewDataSource {

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.trendingTweets.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(withClass: TrendingTwitterCell.self, forIndexPath: indexPath)
        let tweet = self.trendingTweets[indexPath.row]
        cell.configureCell(with: tweet)
        return cell
    }
}

extension TrendingTweetsViewModel: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
}
