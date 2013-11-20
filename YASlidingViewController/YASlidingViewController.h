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
    SlidingViewStateLeftDragging = 0,
    SlidingViewStateLeftOpened = 1,
    SlidingViewStateLeftLocked = 2,
    SlidingViewStateRightDragging = 3,
    SlidingViewStateRightOpened = 4,
    SlidingViewStateRightLocked = 5,
    SlidingViewStateClosed = 6
};

@interface YASlidingViewController : UIViewController {
@private
    NSMutableArray *_previousViewStates;
    BOOL _viewAppeared;
    CGPoint _lastOrigin;
}

// View Controllers
@property (nonatomic, strong) UIViewController *leftViewController;
@property (nonatomic, strong) UIViewController *topViewController;
@property (nonatomic, strong) UIViewController *rightViewController;

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
- (void)toggleRightAnimated:(BOOL)animated;
- (void)showRightAnimated:(BOOL)animated;
- (void)hideRightAnimated:(BOOL)animated;

@end
