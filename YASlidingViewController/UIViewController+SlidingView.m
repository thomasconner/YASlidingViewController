//
//  UIViewController+SlidingView.m
//
//  Created by Thomas Conner on 11/7/13.
//  Copyright (c) 2013 Conner Development. All rights reserved.
//

#import "UIViewController+SlidingView.h"
#import "YASlidingViewController.h"

@implementation UIViewController (SlidingView)

- (YASlidingViewController *)slidingViewController {
    UIViewController *viewController = self.parentViewController;
    while (!(viewController == nil || [viewController isKindOfClass:[YASlidingViewController class]])) {
        viewController = viewController.parentViewController;
    }
    return (YASlidingViewController *)viewController;
}

@end
