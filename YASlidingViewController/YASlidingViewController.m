//
//  YASlidingViewController.m
//
//  Created by Thomas Conner on 11/7/13.
//  Copyright (c) 2013 Thomas Conner. All rights reserved.
//

#import "YASlidingViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface YASlidingViewController () <UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *topBackgroundView;
@property (nonatomic, strong) UIView *topOverlayView;

- (void)setDefaults;
- (void)removeBackgroundView;
- (void)removeTopBackgroundView;
- (void)removeTopOverlayView;
- (void)updateViewsAnimated:(BOOL)animated;

@end

@implementation YASlidingViewController
@synthesize backgroundView = _backgroundView;
@synthesize topBackgroundView = _topBackgroundView;
@synthesize topOverlayView = _topOverlayView;
@synthesize leftViewController = _leftViewController;
@synthesize topViewController = _topViewController;
@synthesize rightViewController = _rightViewController;
@synthesize allowOverswipe = _allowOverswipe;
@synthesize allowNavigationBarOnly = _allowNavigationBarOnly;
@synthesize topViewOffsetY = _topViewOffsetY;
@synthesize peakAmount = _peakAmount;
@synthesize peakThreshold = _peakThreshold;
@synthesize cornerRadius = _cornerRadius;
@synthesize shadowOpacity = _shadowOpacity;
@synthesize shadowOffsetX = _shadowOffsetX;
@synthesize shadowOffsetY = _shadowOffsetY;
@synthesize shadowRadius = _shadowRadius;
@synthesize shadowColor = _shadowColor;
@synthesize statusBarColor = _statusBarColor;
@synthesize animationDelay = _animationDelay;
@synthesize animationDuration = _animationDuration;
@synthesize viewState = _viewState;

#pragma mark -
#pragma mark Setup

- (id)init {
    self = [super init];
    if (self) {
        [self setDefaults];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setDefaults];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setDefaults];
    }
    return self;
}

- (void)setDefaults {
    _viewState = SlidingViewStateClosed;
    _previousViewStates = [NSMutableArray array];
    
    // iOS 7, offset it below the status bar
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        _topViewOffsetY = 20.0f;
    } else {
        _topViewOffsetY = 0.0f;
    }
    
    _allowOverswipe = NO;
    _allowNavigationBarOnly = NO;
    _peakAmount = 280.0f;
    _peakThreshold = 130.0f;
    _cornerRadius = 0.0f;
    _shadowOpacity = 0.5f;
    _shadowOffsetX = 0.0f;
    _shadowOffsetY = -3.0f;
    _shadowColor = [UIColor blackColor];
    _statusBarColor = [UIColor blackColor];
    _shadowRadius = 5.0f;
    _animationDelay = 0.0f;
    _animationDuration = 0.2f;
}

#pragma mark -
#pragma mark View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Add the background view
    [self.view addSubview:self.backgroundView];
    [self.view sendSubviewToBack:self.backgroundView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Update the views
    [self updateViewsAnimated:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Update _viewAppeared flag
    _viewAppeared = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // Update _viewAppeared flag
    _viewAppeared = NO;
}

#pragma mark -
#pragma mark Properties

- (void)setPeakAmount:(CGFloat)peakAmount {
    // Set the peak amount
    _peakAmount = peakAmount;
    
    // Update the views
    [self updateViewsAnimated:_viewAppeared];
}

#pragma mark -
#pragma mark Views

- (UIView *)backgroundView {
    // Return the background view if we have already created it
    if (_backgroundView) {
        return _backgroundView;
    }
    
    // Create the left underlay view
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
    view.backgroundColor = self.statusBarColor;
    view.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // Set the background view
    self.backgroundView = view;
    
    // Return the view
    return view;
}

- (void)removeBackgroundView {
    if (self.backgroundView) {
        [self.backgroundView removeFromSuperview];
        self.backgroundView = nil;
    }
}

- (UIView *)topBackgroundView {
    // Return the top background view if we have already created it
    if (_topBackgroundView) {
        return _topBackgroundView;
    }
    
    // Create the top underlay view
    CGRect frame = CGRectMake(0.0f, self.topViewOffsetY, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - self.topViewOffsetY);
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = [UIColor clearColor];
    view.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    view.layer.masksToBounds = NO;
    view.layer.shadowColor = self.shadowColor.CGColor;
    view.layer.shadowOffset = CGSizeMake(self.shadowOffsetX, self.shadowOffsetY);
    view.layer.shadowRadius = self.shadowRadius;
    view.layer.shadowOpacity = self.shadowOpacity;
    UIBezierPath *contentUnderlayViewPath = [UIBezierPath bezierPathWithRect:view.bounds];
    view.layer.shadowPath = contentUnderlayViewPath.CGPath;
    view.layer.shouldRasterize = YES;
    view.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    // Set the top background view
    self.topBackgroundView = view;
    
    // Add the pan gesture recognizer
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    panGestureRecognizer.cancelsTouchesInView = YES;
    panGestureRecognizer.delegate = self;
    [view addGestureRecognizer:panGestureRecognizer];
    
    // Return the view
    return view;
}

- (void)removeTopBackgroundView {
    if (self.topBackgroundView) {
        [self.topBackgroundView removeFromSuperview];
        self.topBackgroundView = nil;
    }
}

- (UIView *)topOverlayView {
    // Return the top overlay view if we have already created it
    if (_topOverlayView) {
        return _topOverlayView;
    }
    
    // Create the view
    UIView *view = [[UIView alloc] initWithFrame:self.topViewController.view.bounds];
    view.backgroundColor = [UIColor clearColor];
    view.autoresizingMask = self.topViewController.view.autoresizingMask;
    
    // Set the view
    self.topOverlayView = view;
    
    // Add tap gesture recognizer
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedTopOverlayView)];
    [view addGestureRecognizer:tapGestureRecognizer];
    
    // Return the view
    return view;
}

- (void)removeTopOverlayView {
    if (self.topOverlayView) {
        [self.topOverlayView removeFromSuperview];
        self.topOverlayView = nil;
    }
}

- (void)updateViewsAnimated:(BOOL)animated {
    // Adjust the left and right view controller frame
    CGRect backgroundViewFrame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds));
    self.backgroundView.frame = CGRectIntegral(backgroundViewFrame);
    CGRect leftViewControllerFrame = CGRectMake(0.0f, self.topViewOffsetY, self.peakAmount, CGRectGetHeight(self.backgroundView.bounds) - self.topViewOffsetY);
    self.leftViewController.view.frame = CGRectIntegral(leftViewControllerFrame);
    CGRect rightViewControllerFrame = CGRectMake(0.0f + (CGRectGetWidth(self.backgroundView.bounds) - self.peakAmount), self.topViewOffsetY, self.peakAmount, CGRectGetHeight(self.backgroundView.bounds) - self.topViewOffsetY);
    self.rightViewController.view.frame = CGRectIntegral(rightViewControllerFrame);
    
    // If the left side is open
    if (self.viewState == SlidingViewStateLeftOpened) {
        [self showLeftAnimated:animated];
    }
    // Else if the right side is open
    else if (self.viewState == SlidingViewStateRightOpened) {
        [self showRightAnimated:animated];
    }
}

#pragma mark -
#pragma mark View Rotation

- (BOOL)shouldAutorotate {
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    // Update the views
    [self updateViewsAnimated:_viewAppeared];
}

#pragma mark -
#pragma mark View Controllers

- (void)displayTopViewController:(UIViewController *)viewController animated:(BOOL)animated {
    self.topViewController = viewController;
    
    // If the left side is open
    if (self.viewState == SlidingViewStateLeftOpened) {
        [self hideLeftAnimated:animated];
    }
    // Else if the right side is open
    else if (self.viewState == SlidingViewStateRightOpened) {
        [self hideRightAnimated:animated];
    }
}

- (void)setLeftViewController:(UIViewController *)leftViewController {
    // Remove the old left view controller
    if (self.leftViewController) {
        [self.leftViewController.view removeFromSuperview];
        [self.leftViewController willMoveToParentViewController:nil];
        [self.leftViewController removeFromParentViewController];
    }
    
    // Set the new left view controller
    [leftViewController.view removeFromSuperview];
    [leftViewController willMoveToParentViewController:nil];
    [leftViewController removeFromParentViewController];
    _leftViewController = leftViewController;
    [self addChildViewController:leftViewController];
    [leftViewController didMoveToParentViewController:self];
    
    // Add the view
    if (self.viewState == SlidingViewStateLeftDragging || self.viewState == SlidingViewStateLeftLocked || self.viewState == SlidingViewStateLeftOpened) {
        [self.backgroundView insertSubview:self.leftViewController.view belowSubview:self.topBackgroundView];
    }
    
    // Adjust the frame
    CGRect frame = CGRectMake(0.0f, self.topViewOffsetY, self.peakAmount, CGRectGetHeight(self.backgroundView.bounds) - self.topViewOffsetY);
    leftViewController.view.frame = CGRectIntegral(frame);
    leftViewController.view.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight;
}

- (void)setTopViewController:(UIViewController *)topViewController {
    // Remove the old top view controller
    if (self.topViewController) {
        [self.topViewController.view removeFromSuperview];
        [self.topViewController willMoveToParentViewController:nil];
        [self.topViewController removeFromParentViewController];
    }
    
    // Set the new top view controller
    [topViewController.view removeFromSuperview];
    [topViewController willMoveToParentViewController:nil];
    [topViewController removeFromParentViewController];
    _topViewController = topViewController;
    [self.topBackgroundView addSubview:topViewController.view];
    [self.view addSubview:self.topBackgroundView];
    [self.view bringSubviewToFront:self.topBackgroundView];
    [self addChildViewController:topViewController];
    [topViewController didMoveToParentViewController:self];
    
    // Add a corner radius
    topViewController.view.layer.masksToBounds = YES;
    topViewController.view.layer.cornerRadius = self.cornerRadius;
    
    // Adjust the frame
    topViewController.view.frame = CGRectIntegral(self.topBackgroundView.bounds);
    topViewController.view.autoresizingMask = self.topBackgroundView.autoresizingMask;
}

- (void)setRightViewController:(UIViewController *)rightViewController {
    // Remove the old right view controller
    if (self.rightViewController) {
        [self.rightViewController.view removeFromSuperview];
        [self.rightViewController willMoveToParentViewController:nil];
        [self.rightViewController removeFromParentViewController];
    }
    
    // Set the new right view controller
    [rightViewController.view removeFromSuperview];
    [rightViewController willMoveToParentViewController:nil];
    [rightViewController removeFromParentViewController];
    _rightViewController = rightViewController;
    [self addChildViewController:rightViewController];
    [rightViewController didMoveToParentViewController:self];
    
    // Add the view
    if (self.viewState == SlidingViewStateRightDragging || self.viewState == SlidingViewStateRightLocked || self.viewState == SlidingViewStateRightOpened) {
        [self.backgroundView insertSubview:self.rightViewController.view belowSubview:self.topBackgroundView];
    }
    
    // Adjust the frame
    CGRect frame = CGRectMake(0.0f, self.topViewOffsetY, self.peakAmount, CGRectGetHeight(self.backgroundView.bounds) - self.topViewOffsetY);
    rightViewController.view.frame = CGRectIntegral(frame);
    rightViewController.view.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight;
}

#pragma mark -
#pragma mark View Animation

- (void)tappedTopOverlayView {
    // If the left side is open
    if (self.viewState == SlidingViewStateLeftOpened) {
        [self hideLeftAnimated:YES];
    }
    // Else if the right side is open
    else if (self.viewState == SlidingViewStateRightOpened) {
        [self hideRightAnimated:YES];
    }
}

- (void)toggleLeftAnimated:(BOOL)animated {
    if (self.viewState == SlidingViewStateClosed) {
        [self showLeftAnimated:animated];
    }
    else if (self.viewState == SlidingViewStateLeftOpened) {
        [self hideLeftAnimated:animated];
    }
}

- (void)showLeftAnimated:(BOOL)animated {
    // Return if the view state is locked
    if (self.viewState == SlidingViewStateLeftLocked || self.viewState == SlidingViewStateRightLocked) {
        return;
    }
    
    // Get the rect
    CGRect rect = CGRectMake(0.0f, self.topViewOffsetY, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - self.topViewOffsetY);
    
    // Dismiss the keyboard if it is showing
    [self.view endEditing:YES];
    
    // Remove the right view
    [self.rightViewController.view removeFromSuperview];
    
    // Add the left view
    [self.backgroundView insertSubview:self.leftViewController.view belowSubview:self.topBackgroundView];
    
    if (animated) {
        [UIView animateWithDuration:self.animationDuration
                              delay:self.animationDelay
                            options:UIViewAnimationOptionCurveEaseInOut  | UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             // Adjust the top background view frame
                             self.topBackgroundView.frame = CGRectIntegral(CGRectOffset(rect, self.peakAmount, 0.0f));
                         }
                         completion:^(BOOL finished) {
                             if (finished) {
                                 // Update the view state
                                 [_previousViewStates addObject:[NSNumber numberWithInt:self.viewState]];
                                 _viewState = SlidingViewStateLeftOpened;
                                 
                                 // Remove the overlay view
                                 [self removeTopOverlayView];
                                 
                                 // Add the top overlay view to the view
                                 [self.topViewController.view addSubview:self.topOverlayView];
                                 [self.topViewController.view bringSubviewToFront:self.topOverlayView];
                             }
                         }];
    }
    else {
        // Adjust the top background view frame
        self.topBackgroundView.frame = CGRectIntegral(CGRectOffset(rect, self.peakAmount, 0.0f));
        
        // Update the view state
        [_previousViewStates addObject:[NSNumber numberWithInt:self.viewState]];
        _viewState = SlidingViewStateLeftOpened;

        // Remove the overlay view
        [self removeTopOverlayView];
        
        // Add the top overlay view to the view
        [self.topViewController.view addSubview:self.topOverlayView];
        [self.topViewController.view bringSubviewToFront:self.topOverlayView];
    }
}

- (void)hideLeftAnimated:(BOOL)animated {
    // Return if the view state is locked
    if (self.viewState == SlidingViewStateLeftLocked || self.viewState == SlidingViewStateRightLocked) {
        return;
    }
    
    // Get the rect
    CGRect rect = CGRectMake(0.0f, self.topViewOffsetY, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - self.topViewOffsetY);
    
    // Dismiss the keyboard if it is showing
    [self.view endEditing:YES];
    
    if (animated) {
        [UIView animateWithDuration:self.animationDuration
                              delay:self.animationDelay
                            options:UIViewAnimationOptionCurveEaseInOut  | UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             // Adjust the top background view frame
                             self.topBackgroundView.frame = CGRectIntegral(rect);
                         }
                         completion:^(BOOL finished) {
                             if (finished) {
                                 // Update the view state
                                 [_previousViewStates addObject:[NSNumber numberWithInt:self.viewState]];
                                 _viewState = SlidingViewStateClosed;
                                 
                                 // Remove the overlay view
                                 [self removeTopOverlayView];
                                 
                                 // Remove the left view
                                 [self.leftViewController.view removeFromSuperview];
                             }
                         }];
    }
    else {
        // Adjust the top background view frame
        self.topBackgroundView.frame = CGRectIntegral(rect);
        
        // Update the view state
        [_previousViewStates addObject:[NSNumber numberWithInt:self.viewState]];
        _viewState = SlidingViewStateClosed;
        
        // Remove the overlay view
        [self removeTopOverlayView];
        
        // Remove the left view
        [self.leftViewController.view removeFromSuperview];
    }
}

- (void)toggleRightAnimated:(BOOL)animated {
    if (self.viewState == SlidingViewStateClosed) {
        [self showRightAnimated:animated];
    }
    else if (self.viewState == SlidingViewStateRightOpened) {
        [self showRightAnimated:animated];
    }
}

- (void)showRightAnimated:(BOOL)animated {
    // Return if the view state is locked
    if (self.viewState == SlidingViewStateLeftLocked || self.viewState == SlidingViewStateRightLocked) {
        return;
    }
    
    // Get the rect
    CGRect rect = CGRectMake(0.0f, self.topViewOffsetY, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - self.topViewOffsetY);
    
    // Dismiss the keyboard if it is showing
    [self.view endEditing:YES];
    
    // Remove the left view
    [self.leftViewController.view removeFromSuperview];
    
    // Add the right view
    [self.backgroundView insertSubview:self.rightViewController.view belowSubview:self.topBackgroundView];
    
    if (animated) {
        [UIView animateWithDuration:self.animationDuration
                              delay:self.animationDelay
                            options:UIViewAnimationOptionCurveEaseInOut  | UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             // Adjust the top background view frame
                             self.topBackgroundView.frame = CGRectIntegral(CGRectOffset(rect, -self.peakAmount, 0.0f));
                         }
                         completion:^(BOOL finished) {
                             if (finished) {
                                 // Update the view state
                                 [_previousViewStates addObject:[NSNumber numberWithInt:self.viewState]];
                                 _viewState = SlidingViewStateRightOpened;
                                 
                                 // Remove the overlay view
                                 [self removeTopOverlayView];
                                 
                                 // Add the top overlay view to the view
                                 [self.topViewController.view addSubview:self.topOverlayView];
                                 [self.topViewController.view bringSubviewToFront:self.topOverlayView];
                             }
                         }];
    }
    else {
        // Adjust the top background view frame
        self.topBackgroundView.frame = CGRectIntegral(CGRectOffset(rect, -self.peakAmount, 0.0f));
        
        // Update the view state
        [_previousViewStates addObject:[NSNumber numberWithInt:self.viewState]];
        _viewState = SlidingViewStateRightOpened;
        
        // Remove the overlay view
        [self removeTopOverlayView];
        
        // Add the top overlay view to the view
        [self.topViewController.view addSubview:self.topOverlayView];
        [self.topViewController.view bringSubviewToFront:self.topOverlayView];
    }
}

- (void)hideRightAnimated:(BOOL)animated {
    // Return if the view state is locked
    if (self.viewState == SlidingViewStateLeftLocked || self.viewState == SlidingViewStateRightLocked) {
        return;
    }
    
    // Get the rect
    CGRect rect = CGRectMake(0.0f, self.topViewOffsetY, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - self.topViewOffsetY);
    
    // Dismiss the keyboard if it is showing
    [self.view endEditing:YES];
    
    if (animated) {
        [UIView animateWithDuration:self.animationDuration
                              delay:self.animationDelay
                            options:UIViewAnimationOptionCurveEaseInOut  | UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             // Adjust the top background view frame
                             self.topBackgroundView.frame = CGRectIntegral(rect);
                         }
                         completion:^(BOOL finished) {
                             if (finished) {
                                 // Update the view state
                                 [_previousViewStates addObject:[NSNumber numberWithInt:self.viewState]];
                                 _viewState = SlidingViewStateClosed;
                                 
                                 // Remove the overlay view
                                 [self removeTopOverlayView];
                                 
                                 // Remove the left view
                                 [self.rightViewController.view removeFromSuperview];
                             }
                         }];
    }
    else {
        // Adjust the top background view frame
        self.topBackgroundView.frame = CGRectIntegral(rect);
        
        // Update the view state
        [_previousViewStates addObject:[NSNumber numberWithInt:self.viewState]];
        _viewState = SlidingViewStateClosed;
        
        // Remove the overlay view
        [self removeTopOverlayView];
        
        // Remove the left view
        [self.rightViewController.view removeFromSuperview];
    }
}

#pragma mark -
#pragma mark Swiping

- (void)handleSwipe:(UIPanGestureRecognizer *)gestureRecognizer {
    // Return if the view state is locked
    if (self.viewState == SlidingViewStateLeftLocked || self.viewState == SlidingViewStateRightLocked) {
        return;
    }
    
    // Dismiss the keyboard if it is showing
    [self.view endEditing:YES];
    
    // If we are beginning
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        // Get the velocity
        CGPoint velocity = [gestureRecognizer velocityInView:self.view];
        
        // Get the starting point
        CGPoint startingPoint = [gestureRecognizer locationInView:self.view];
        
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone && UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
            if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
                // we only trigger a swipe if either navigationBarOnly is deactivated
                // or we swiped in the navigationBar
                if (!self.allowNavigationBarOnly || startingPoint.y <= 52.0f) {
                    // If the swipe was to the right
                    if (velocity.x > 0.0f) {
                        if (self.viewState != SlidingViewStateRightOpened) {
                            // Remove the right view
                            [self.rightViewController.view removeFromSuperview];
                            
                            // Add the left view
                            [self.backgroundView insertSubview:self.leftViewController.view belowSubview:self.topBackgroundView];
                        }
                        
                        // Update the view state
                        [_previousViewStates addObject:[NSNumber numberWithInt:self.viewState]];
                        _viewState = SlidingViewStateLeftDragging;
                    }
                    // else is must have been to the left
                    else if (velocity.x <= 0.0f) {
                        if (self.viewState != SlidingViewStateLeftOpened) {
                            // Remove the left view
                            [self.leftViewController.view removeFromSuperview];
                            
                            // Add the right view
                            [self.backgroundView insertSubview:self.rightViewController.view belowSubview:self.topBackgroundView];
                        }
                        
                        // Update the view state
                        [_previousViewStates addObject:[NSNumber numberWithInt:self.viewState]];
                        _viewState = SlidingViewStateRightDragging;
                    }
                }
            }
            else {
                // we only trigger a swipe if either navigationBarOnly is deactivated
                // or we swiped in the navigationBar
                if (!self.allowNavigationBarOnly || startingPoint.y <= 32.0f) {
                    // If the swipe was to the right
                    if (velocity.x > 0.0f) {
                        if (self.viewState != SlidingViewStateRightOpened) {
                            // Remove the right view
                            [self.rightViewController.view removeFromSuperview];
                            
                            // Add the left view
                            [self.backgroundView insertSubview:self.leftViewController.view belowSubview:self.topBackgroundView];
                        }
                        
                        // Update the view state
                        [_previousViewStates addObject:[NSNumber numberWithInt:self.viewState]];
                        _viewState = SlidingViewStateLeftDragging;
                    }
                    // else is must have been to the left
                    else if (velocity.x <= 0.0f) {
                        if (self.viewState != SlidingViewStateLeftOpened) {
                            // Remove the left view
                            [self.leftViewController.view removeFromSuperview];
                            
                            // Add the right view
                            [self.backgroundView insertSubview:self.rightViewController.view belowSubview:self.topBackgroundView];
                        }
                        
                        // Update the view state
                        [_previousViewStates addObject:[NSNumber numberWithInt:self.viewState]];
                        _viewState = SlidingViewStateRightDragging;
                    }
                }
            }
        }
        else {
            if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
                // we only trigger a swipe if either navigationBarOnly is deactivated
                // or we swiped in the navigationBar
                if (!self.allowNavigationBarOnly || startingPoint.y <= 64.0f) {
                    // If the swipe was to the right
                    if (velocity.x > 0.0f) {
                        if (self.viewState != SlidingViewStateRightOpened) {
                            // Remove the right view
                            [self.rightViewController.view removeFromSuperview];
                            
                            // Add the left view
                            [self.backgroundView insertSubview:self.leftViewController.view belowSubview:self.topBackgroundView];
                        }
                        
                        // Update the view state
                        [_previousViewStates addObject:[NSNumber numberWithInt:self.viewState]];
                        _viewState = SlidingViewStateLeftDragging;
                    }
                    // else is must have been to the left
                    else if (velocity.x <= 0.0f) {
                        if (self.viewState != SlidingViewStateLeftOpened) {
                            // Remove the left view
                            [self.leftViewController.view removeFromSuperview];
                            
                            // Add the right view
                            [self.backgroundView insertSubview:self.rightViewController.view belowSubview:self.topBackgroundView];
                        }
                        
                        // Update the view state
                        [_previousViewStates addObject:[NSNumber numberWithInt:self.viewState]];
                        _viewState = SlidingViewStateRightDragging;
                    }
                }
            }
            else {
                // we only trigger a swipe if either navigationBarOnly is deactivated
                // or we swiped in the navigationBar
                if (!self.allowNavigationBarOnly || startingPoint.y <= 44.0f) {
                    // If the swipe was to the right
                    if (velocity.x > 0.0f) {
                        if (self.viewState != SlidingViewStateRightOpened) {
                            // Remove the right view
                            [self.rightViewController.view removeFromSuperview];
                            
                            // Add the left view
                            [self.backgroundView insertSubview:self.leftViewController.view belowSubview:self.topBackgroundView];
                        }
                        
                        // Update the view state
                        [_previousViewStates addObject:[NSNumber numberWithInt:self.viewState]];
                        _viewState = SlidingViewStateLeftDragging;
                    }
                    // else is must have been to the left
                    else if (velocity.x <= 0.0f) {
                        if (self.viewState != SlidingViewStateLeftOpened) {
                            // Remove the left view
                            [self.leftViewController.view removeFromSuperview];
                            
                            // Add the right view
                            [self.backgroundView insertSubview:self.rightViewController.view belowSubview:self.topBackgroundView];
                        }
                        
                        // Update the view state
                        [_previousViewStates addObject:[NSNumber numberWithInt:self.viewState]];
                        _viewState = SlidingViewStateRightDragging;
                    }
                }
            }
        }
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateChanged && (self.viewState == SlidingViewStateLeftDragging || self.viewState == SlidingViewStateRightDragging)) {
        // Get the transaltion
        CGPoint translation = [gestureRecognizer translationInView:self.view];
        [gestureRecognizer setTranslation:CGPointMake(0, 0) inView:self.view];
        
        // Get the velocity
        CGPoint velocity = [gestureRecognizer velocityInView:self.view];
        
        // If the swipe was to the right
        if (velocity.x > 0.0f) {
            // If the swipe has crossed zero
            if (gestureRecognizer.view.frame.origin.x >= 0 && _lastOrigin.x <= 0) {
                // Remove the right view
                [self.rightViewController.view removeFromSuperview];
                
                // Add the left view
                [self.backgroundView insertSubview:self.leftViewController.view belowSubview:self.topBackgroundView];
                
                // Update the view state
                [_previousViewStates addObject:[NSNumber numberWithInt:self.viewState]];
                _viewState = SlidingViewStateLeftDragging;
            }
        }
        // else is must have been to the left
        else if (velocity.x <= 0.0f) {
            // If the swipe has crossed zero
            if (gestureRecognizer.view.frame.origin.x <= 0 && _lastOrigin.x >= 0) {
                // Remove the left view
                [self.leftViewController.view removeFromSuperview];
                
                // Add the right view
                [self.backgroundView insertSubview:self.rightViewController.view belowSubview:self.topBackgroundView];
                
                // Update the view state
                [_previousViewStates addObject:[NSNumber numberWithInt:self.viewState]];
                _viewState = SlidingViewStateRightDragging;
            }
        }
        
        // Update last origin
        _lastOrigin = gestureRecognizer.view.frame.origin;
        
        // Animate
        [UIView animateWithDuration:0.01f
                              delay:0.0f
                            options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             gestureRecognizer.view.center = CGPointMake(gestureRecognizer.view.center.x + translation.x, gestureRecognizer.view.center.y);
                             
                             // Get the rect
                             CGRect rect = CGRectMake(0.0f, self.topViewOffsetY, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - self.topViewOffsetY);
                             
                             // Adjust the view
                             if (self.viewState == SlidingViewStateLeftDragging) {
                                 if (gestureRecognizer.view.frame.origin.x > self.peakAmount) {
                                     gestureRecognizer.view.frame = CGRectIntegral(CGRectOffset(rect, self.peakAmount, 0.0f));
                                 }
                             }
                             else if (self.viewState == SlidingViewStateRightDragging) {
                                 if ((gestureRecognizer.view.frame.origin.x + gestureRecognizer.view.frame.size.width) < (gestureRecognizer.view.frame.size.width - self.peakAmount)) {
                                     gestureRecognizer.view.frame = CGRectIntegral(CGRectOffset(rect, -self.peakAmount, 0.0f));
                                 }
                             }
                         }
                         completion:nil];
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        // Get the velocity
        CGPoint velocity = [gestureRecognizer velocityInView:self.view];
        
        // If we are dragging left
        if (self.viewState == SlidingViewStateLeftDragging) {
            // If the swipe was to the right
            if (velocity.x > 0) {
                if (gestureRecognizer.view.frame.origin.x <= self.peakThreshold) {
                    [self hideLeftAnimated:YES];
                }
                else {
                    [self showLeftAnimated:YES];
                }
            }
            // else is must have been to the left
            else if (velocity.x <= 0.0f) {
                if (gestureRecognizer.view.frame.origin.x >= self.peakThreshold) {
                    [self showLeftAnimated:YES];
                } else {
                    [self hideLeftAnimated:YES];
                }
            }
        }
        else {
            // If the swipe was to the right
            if (velocity.x > 0) {
                if ((gestureRecognizer.view.frame.origin.x + gestureRecognizer.view.frame.size.width) <= self.peakThreshold) {
                    [self showRightAnimated:YES];
                }
                else {
                    [self hideRightAnimated:YES];
                }
            }
            // else is must have been to the left
            else if (velocity.x <= 0.0f) {
                if ((gestureRecognizer.view.frame.origin.x + gestureRecognizer.view.frame.size.width) >= self.peakThreshold) {
                    [self hideRightAnimated:YES];
                } else {
                    [self showRightAnimated:YES];
                }
            }
        }
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)panGestureRecognizer {
    CGPoint startingPoint = [panGestureRecognizer locationInView:self.view];
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone && UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
            // we only trigger a swipe if either navigationBarOnly is deactivated
            // or we swiped in the navigationBar
            if (!self.allowNavigationBarOnly || startingPoint.y <= 52.0f) {
                return YES;
            }
        }
        else {
            // we only trigger a swipe if either navigationBarOnly is deactivated
            // or we swiped in the navigationBar
            if (!self.allowNavigationBarOnly || startingPoint.y <= 32.0f) {
                return YES;
            }
        }
    }
    else {
        if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
            // we only trigger a swipe if either navigationBarOnly is deactivated
            // or we swiped in the navigationBar
            if (!self.allowNavigationBarOnly || startingPoint.y <= 64.0f) {
                return YES;
            }
        }
        else {
            // we only trigger a swipe if either navigationBarOnly is deactivated
            // or we swiped in the navigationBar
            if (!self.allowNavigationBarOnly || startingPoint.y <= 44.0f) {
                return YES;
            }
        }
    }
    
    return NO;
}

@end
