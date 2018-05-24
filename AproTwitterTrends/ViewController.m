//
//  ViewController.m
//  AproTwitterTrends
//
//  Created by Nidhi Goyal on 19/05/18.
//  Copyright © 2018 Nidhi Goyal. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic) TrendingTweetsViewModel *viewModel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _viewModel = [[TrendingTweetsViewModel alloc] initWith:self.tableView];
    [_viewModel getTrendingTweets];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
