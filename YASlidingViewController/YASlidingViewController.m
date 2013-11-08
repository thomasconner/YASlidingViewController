//
//  YASlidingViewController.m
//
//  Created by Thomas Conner on 11/7/13.
//  Copyright (c) 2013 Thomas Conner. All rights reserved.
//

#import "YASlidingViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface YASlidingViewController () <UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIView *leftUnderlayView;
@property (nonatomic, strong) UIView *topUnderlayView;
@property (nonatomic, strong) UIView *topOverlayView;

- (void)setDefaults;
- (void)removeLeftUnderlayView;
- (void)removeTopUnderlayView;
- (void)removeTopOverlayView;
- (void)updateViewsAnimated:(BOOL)animated;

@end

@implementation YASlidingViewController
@synthesize leftUnderlayView = _leftUnderlayView;
@synthesize topUnderlayView = _topUnderlayView;
@synthesize topOverlayView = _topOverlayView;
@synthesize leftViewController = _leftViewController;
@synthesize topViewController = _topViewController;
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
    _peakAmount = 140.0f;
    _peakThreshold = 0.5f;
    _cornerRadius = 4.0f;
    _shadowOpacity = 0.5f;
    _shadowOffsetX = 0.0f;
    _shadowOffsetY = 3.0f;
    _shadowColor = [UIColor blackColor];
    _shadowRadius = 4.0f;
    _animationDelay = 0.0f;
    _animationDuration = 0.2f;
}

#pragma mark -
#pragma mark View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Update _viewAppeared flag
    _viewAppeared = YES;
    
    // Update the views
    [self updateViewsAnimated:_viewAppeared];
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

- (UIView *)leftUnderlayView {
    // Return the left underlay view if we have already created it
    if (_leftUnderlayView) {
        return _leftUnderlayView;
    }
    
    // Create the left underlay view
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
    view.backgroundColor = self.leftViewController.view.backgroundColor;
    view.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // Set the left underlay view
    self.leftUnderlayView = view;
    
    // Return the view
    return view;
}

- (void)removeLeftUnderlayView {
    if (self.leftUnderlayView) {
        [self.leftUnderlayView removeFromSuperview];
        self.leftUnderlayView = nil;
    }
}

- (UIView *)topUnderlayView {
    // Return the top underlay view if we have already created it
    if (_topUnderlayView) {
        return _topUnderlayView;
    }
    
    // Create the top underlay view
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.topViewOffsetY, self.view.frame.size.width, self.view.frame.size.height - self.topViewOffsetY)];
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
    
    // Set the top underlay view
    self.topUnderlayView = view;
    
    // Add the pan gesture recognizer
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    panGestureRecognizer.cancelsTouchesInView = NO;
    panGestureRecognizer.delegate = self;
    [view addGestureRecognizer:panGestureRecognizer];
    
    // Return the view
    return view;
}

- (void)removeTopUnderlayView {
    if (self.topUnderlayView) {
        [self.topUnderlayView removeFromSuperview];
        self.topUnderlayView = nil;
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
    [self removeLeftUnderlayView];
    [self.leftUnderlayView addSubview:self.leftViewController.view];
    [self.view addSubview:self.leftUnderlayView];
    [self.view sendSubviewToBack:self.leftUnderlayView];
    CGRect leftViewControllerFrame = CGRectMake(0.0f, self.topViewOffsetY, self.peakAmount, CGRectGetHeight(self.leftUnderlayView.bounds) - self.topViewOffsetY);
    self.leftViewController.view.frame = CGRectIntegral(leftViewControllerFrame);
    
    // If the view state is openeed
    if (self.viewState == SlidingViewStateOpened) {
        [self showLeftAnimated:_viewAppeared];
    }
    else {
        [self hideLeftAnimated:_viewAppeared];
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
    [self hideLeftAnimated:animated];
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
    [self.leftUnderlayView addSubview:leftViewController.view];
    [self.view addSubview:self.leftUnderlayView];
    [self.view sendSubviewToBack:self.leftUnderlayView];
    [self addChildViewController:leftViewController];
    [leftViewController didMoveToParentViewController:self];
    
    // Adjust the frame
    CGRect frame = CGRectMake(0.0f, self.topViewOffsetY, self.peakAmount, CGRectGetHeight(self.leftUnderlayView.bounds) - self.topViewOffsetY);
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
    [self.topUnderlayView addSubview:topViewController.view];
    [self.view addSubview:self.topUnderlayView];
    [self.view bringSubviewToFront:self.topUnderlayView];
    [self addChildViewController:topViewController];
    [topViewController didMoveToParentViewController:self];
    
    // Add a corner radius
    topViewController.view.layer.masksToBounds = YES;
    topViewController.view.layer.cornerRadius = self.cornerRadius;
    
    // Adjust the frame
    topViewController.view.frame = CGRectIntegral(self.topUnderlayView.bounds);
    topViewController.view.autoresizingMask = self.topUnderlayView.autoresizingMask;
}

#pragma mark -
#pragma mark Show and Hide Left

- (void)tappedTopOverlayView {
    [self hideLeftAnimated:YES];
}

- (void)toggleLeftAnimated:(BOOL)animated {
    if (self.viewState == SlidingViewStateClosed) {
        [self showLeftAnimated:animated];
    }
    else if (self.viewState == SlidingViewStateOpened) {
        [self hideLeftAnimated:animated];
    }
}

- (void)showLeftAnimated:(BOOL)animated {
    // Return if the view state is locked
    if (self.viewState == SlidingViewStateLocked) {
        return;
    }
    
    // Get the rect
    CGRect rect = CGRectMake(0.0f, self.topViewOffsetY, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - self.topViewOffsetY);
    
    // Dismiss the keyboard if it is showing
    [self.topViewController.view endEditing:YES];
    
    if (animated) {
        [UIView animateWithDuration:self.animationDuration
                              delay:self.animationDelay
                            options:UIViewAnimationOptionCurveEaseInOut  | UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             // Adjust the top underlay view frame
                             self.topUnderlayView.frame = CGRectIntegral(CGRectOffset(rect, self.peakAmount, 0.0f));
                         }
                         completion:^(BOOL finished) {
                             if (finished) {
                                 // Update the view state
                                 [_previousViewStates addObject:[NSNumber numberWithInt:self.viewState]];
                                 _viewState = SlidingViewStateOpened;
                                 
                                 // Remove the overlay view
                                 [self removeTopOverlayView];
                                 
                                 // Add the top overlay view to the view
                                 [self.topViewController.view addSubview:self.topOverlayView];
                                 [self.topViewController.view bringSubviewToFront:self.topOverlayView];
                             }
                         }];
    }
    else {
        // Adjust the top underlay view frame
        self.topUnderlayView.frame = CGRectIntegral(CGRectOffset(rect, self.peakAmount, 0.0f));
        
        // Update the view state
        [_previousViewStates addObject:[NSNumber numberWithInt:self.viewState]];
        _viewState = SlidingViewStateOpened;

        // Remove the overlay view
        [self removeTopOverlayView];
        
        // Add the top overlay view to the view
        [self.topViewController.view addSubview:self.topOverlayView];
        [self.topViewController.view bringSubviewToFront:self.topOverlayView];
    }
}

- (void)hideLeftAnimated:(BOOL)animated {
    // Return if the view state is locked
    if (self.viewState == SlidingViewStateLocked) {
        return;
    }
    
    // Get the rect
    CGRect rect = CGRectMake(0.0f, self.topViewOffsetY, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - self.topViewOffsetY);
    
    if (animated) {
        [UIView animateWithDuration:self.animationDuration
                              delay:self.animationDelay
                            options:UIViewAnimationOptionCurveEaseInOut  | UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             // Adjust the top underlay view frame
                             self.topUnderlayView.frame = CGRectIntegral(rect);
                         }
                         completion:^(BOOL finished) {
                             if (finished) {
                                 // Update the view state
                                 [_previousViewStates addObject:[NSNumber numberWithInt:self.viewState]];
                                 _viewState = SlidingViewStateClosed;
                                 
                                 // Remove the overlay view
                                 [self removeTopOverlayView];
                             }
                         }];
    }
    else {
        // Adjust the top underlay view frame
        self.topUnderlayView.frame = CGRectIntegral(rect);
        
        // Update the view state
        [_previousViewStates addObject:[NSNumber numberWithInt:self.viewState]];
        _viewState = SlidingViewStateClosed;
        
        // Remove the overlay view
        [self removeTopOverlayView];
    }
}


#pragma mark -
#pragma mark Swiping

- (void)handleSwipe:(UIPanGestureRecognizer *)gestureRecognizer {
    // Return if the view state is locked
    if (self.viewState == SlidingViewStateLocked) {
        return;
    }
    
    // If we are beginning
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        // Dismiss the keyboard if it is showing
        [self.topViewController.view endEditing:YES];
        
        CGPoint startingPoint = [gestureRecognizer locationInView:self.view];
        
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone && UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
            if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
                // we only trigger a swipe if either navigationBarOnly is deactivated
                // or we swiped in the navigationBar
                if (!self.allowNavigationBarOnly || startingPoint.y <= 52.0f) {
                    [_previousViewStates addObject:[NSNumber numberWithInt:self.viewState]];
                    _viewState = SlidingViewStateDragging;
                }
            }
            else {
                // we only trigger a swipe if either navigationBarOnly is deactivated
                // or we swiped in the navigationBar
                if (!self.allowNavigationBarOnly || startingPoint.y <= 32.0f) {
                    [_previousViewStates addObject:[NSNumber numberWithInt:self.viewState]];
                    _viewState = SlidingViewStateDragging;
                }
            }
        }
        else {
            if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
                // we only trigger a swipe if either navigationBarOnly is deactivated
                // or we swiped in the navigationBar
                if (!self.allowNavigationBarOnly || startingPoint.y <= 64.0f) {
                    [_previousViewStates addObject:[NSNumber numberWithInt:self.viewState]];
                    _viewState = SlidingViewStateDragging;
                }
            }
            else {
                // we only trigger a swipe if either navigationBarOnly is deactivated
                // or we swiped in the navigationBar
                if (!self.allowNavigationBarOnly || startingPoint.y <= 44.0f) {
                    [_previousViewStates addObject:[NSNumber numberWithInt:self.viewState]];
                    _viewState = SlidingViewStateDragging;
                }
            }
        }
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateChanged && self.viewState == SlidingViewStateDragging) {
        CGPoint translation = [gestureRecognizer translationInView:self.view];
        [gestureRecognizer setTranslation:CGPointMake(0, 0) inView:self.view];
        
        [UIView animateWithDuration:0.01f
                              delay:0.0f
                            options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             gestureRecognizer.view.center = CGPointMake(gestureRecognizer.view.center.x + translation.x, gestureRecognizer.view.center.y);
                             
                             // Get the rect
                             CGRect rect = CGRectMake(0.0f, self.topViewOffsetY, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - self.topViewOffsetY);
                             
                             // Adjust the view
                             if (gestureRecognizer.view.frame.origin.x > self.peakAmount) {
                                 gestureRecognizer.view.frame = CGRectIntegral(CGRectOffset(rect, self.peakAmount, 0.0f));
                             }
                             else if (gestureRecognizer.view.frame.origin.x < 0.0f) {
                                 gestureRecognizer.view.frame = CGRectIntegral(rect);
                             }
                         }
                         completion:^(BOOL finished) {
                             // Nothing to do
                         }];
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateEnded && self.viewState == SlidingViewStateDragging) {
        CGPoint velocity = [gestureRecognizer velocityInView:self.view];
        
        // If the swipe was to the right
        if (velocity.x > 0) {
            if (self.topUnderlayView.frame.origin.x <= self.peakThreshold) {
                [self hideLeftAnimated:YES];
            }
            else {
                [self showLeftAnimated:YES];
            }
        }
        // else is must have been to the left
        else {
            if (self.topUnderlayView.frame.origin.x >= self.peakThreshold) {
                [self showLeftAnimated:YES];
            } else {
                [self hideLeftAnimated:YES];
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
