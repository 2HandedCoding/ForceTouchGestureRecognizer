//
//  ForceTouchGestureRecognizer.m
//  ForceTouchGestureRecognizerExample
//
//  Created by Yu Sugawara on 9/25/15.
//  Copyright © 2015 Yu Sugawara. All rights reserved.
//

#import "ForceTouchGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>
#define DEFAULT_SENSITIVITY 1.0f
#define DEFAULT_MIN_TIME 1000.0f


@interface ForceTouchGestureRecognizer ()

@property (nonatomic, readwrite) CGFloat force;
@property (nonatomic, strong) UIImpactFeedbackGenerator * generator;
@end

@implementation ForceTouchGestureRecognizer {
    NSDate * lastRecognized;
}

- (instancetype)init
{
    if (self = [super init]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithTarget:(id)target action:(SEL)action
{
    if (self = [super initWithTarget:target action:action]) {
        [self commonInit];
    }
    return self;
}

- (void)awakeFromNib
{
    [self commonInit];
}

- (void)commonInit
{
    self.forceSensitivity = DEFAULT_SENSITIVITY;
    self.minTime = DEFAULT_MIN_TIME;
}

- (BOOL) shouldRecognize {
    if (!lastRecognized) return true;
    NSInteger msSinceLastReco = abs((NSInteger)([lastRecognized timeIntervalSinceNow]*1000));
    if (msSinceLastReco < self.minTime) {
        return false ;
    } else {
        return true;
    }
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (![self shouldRecognize]) {
        self.state = UIGestureRecognizerStateCancelled;
        return;
    }
    self.force = 0.;
    if (self.generator == nil) {
        self.generator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleHeavy];
        [self.generator prepare];
    }
    self.state = UIGestureRecognizerStatePossible;
    
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (self.state != UIGestureRecognizerStatePossible || ![self shouldRecognize])
    {
        self.state = UIGestureRecognizerStateCancelled;
        return;
    }
    
    UITouch *touch = [touches anyObject];
    UIView *view = self.view;
    
    if (!CGRectContainsPoint(view.bounds, [touch locationInView:view])) {
        self.state = UIGestureRecognizerStateFailed;
        return;
    }
    
    if ([touch respondsToSelector:@selector(force)] &&
        [touch respondsToSelector:@selector(maximumPossibleForce)] &&
        touch.maximumPossibleForce > 0 &&
        touch.force >= touch.maximumPossibleForce*self.forceSensitivity)
    {
        self.force = touch.force;
        self.state = UIGestureRecognizerStateRecognized;
        [self.generator impactOccurred];
        lastRecognized = [NSDate date];
    }
}

- (void) touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.state = UIGestureRecognizerStateCancelled;
    self.generator = nil;
}

- (void) touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.state == UIGestureRecognizerStateRecognized) {
        self.state = UIGestureRecognizerStateEnded;
    }
    self.generator = nil;
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(nonnull UIGestureRecognizer *)otherGestureRecognizer {
    return true;
}

@end
