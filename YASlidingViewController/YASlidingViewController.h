//
//  YASlidingViewController.h
//
//  Created by Thomas Conner on 11/7/13.
//  Copyright (c) 2013 Thomas Conner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+SlidingView.h"

typedef enum SlidingViewState : NSInteger SlidingViewState;
enum SlidingViewState : NSInteger {
    SlidingViewStateDragging = 0,
    SlidingViewStateOpened = 1,
    SlidingViewStateClosed = 2,
    SlidingViewStateLocked = 3
};

@interface YASlidingViewController : UIViewController {
@private
    NSMutableArray *_previousViewStates;
    BOOL _viewAppeared;
}

// View Controllers
@property (nonatomic, strong) UIViewController *leftViewController;
@property (nonatomic, strong) UIViewController *topViewController;

// Settings
@property (nonatomic) BOOL allowOverswipe;
@property (nonatomic) BOOL allowNavigationBarOnly;
@property (nonatomic) CGFloat topViewOffsetY;
@property (nonatomic) CGFloat peakAmount;
@property (nonatomic) CGFloat peakThreshold;
@property (nonatomic) CGFloat cornerRadius;
@property (nonatomic) CGFloat shadowOpacity;
@property (nonatomic) CGFloat shadowOffsetX;
@property (nonatomic) CGFloat shadowOffsetY;
@property (nonatomic) CGFloat shadowRadius;
@property (nonatomic, strong) UIColor *shadowColor;
@property (nonatomic, strong) UIColor *statusBarColor;
@property (nonatomic) CGFloat animationDelay;
@property (nonatomic) CGFloat animationDuration;
@property (nonatomic, readonly) SlidingViewState viewState;

- (void)displayTopViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)toggleLeftAnimated:(BOOL)animated;
- (void)showLeftAnimated:(BOOL)animated;
- (void)hideLeftAnimated:(BOOL)animated;

@end
