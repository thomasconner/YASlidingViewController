//
//  TopViewController.m
//  YASlidingViewControllerDemo
//
//  Created by Thomas Conner on 11/8/13.
//  Copyright (c) 2013 Conner Development. All rights reserved.
//

#import "TopViewController.h"
#import "UIViewController+SlidingView.h"

@interface TopViewController ()

@end

@implementation TopViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"Top View Controller";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
