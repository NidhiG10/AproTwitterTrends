//
//  TrendingTwitterCell.m
//  AproTwitterTrends
//
//  Created by Nidhi Goyal on 24/05/18.
//  Copyright © 2018 Nidhi Goyal. All rights reserved.
//

#import "TrendingTwitterCell.h"
#import "AproTwitterTrends-Swift.h"

@implementation TrendingTwitterCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)configureCellWith:(TweetInfo *)twitterInfo {
    self.titleLabel.text = twitterInfo.name;
    self.subTitleLabel.text = [NSString stringWithFormat:@"%@ tweets", twitterInfo.tweetVolume];
}

@end
