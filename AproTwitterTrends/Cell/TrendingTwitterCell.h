//
//  TrendingTwitterCell.h
//  AproTwitterTrends
//
//  Created by Nidhi Goyal on 24/05/18.
//  Copyright © 2018 Nidhi Goyal. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TweetInfo;

@interface TrendingTwitterCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;

- (void)configureCellWith:(TweetInfo *)twitterInfo;

@end
