//
//  BBTooltipViewController.m
//  BBFrameworks
//
//  Created by Willam Towe on 6/17/15.
//  Copyright (c) 2015 Bion Bilateral, LLC. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "BBTooltipViewController.h"
#import "BBTooltipView.h"
#import "BBKitColorMacros.h"

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <Archimedes/Archimedes.h>

#import <objc/runtime.h>

@class _BBTooltipViewControllerDataSource;

@interface UIViewController (BBTooltipViewControllerExtensionsPrivate)
@property (strong,nonatomic) _BBTooltipViewControllerDataSource *_BB_dataSource;
@end

@interface _BBTooltipViewControllerDataSource : NSObject <BBTooltipViewControllerDataSource,BBTooltipViewControllerDelegate>

@property (copy,nonatomic) NSString *text;
@property (copy,nonatomic) NSAttributedString *attributedText;
@property (strong,nonatomic) UIView *attachmentView;

@end

@implementation _BBTooltipViewControllerDataSource

- (NSInteger)numberOfTooltipsForTooltipViewController:(BBTooltipViewController *)viewController {
    return 1;
}
- (UIView *)tooltipViewController:(BBTooltipViewController *)viewController attachmentViewForTooltipAtIndex:(NSInteger)index {
    return self.attachmentView;
}
- (NSString *)tooltipViewController:(BBTooltipViewController *)viewController textForTooltipAtIndex:(NSInteger)index {
    return self.text;
}
- (NSAttributedString *)tooltipViewController:(BBTooltipViewController *)viewController attributedTextForTooltipAtIndex:(NSInteger)index {
    return self.attributedText;
}

- (void)tooltipViewControllerDidDismiss:(BBTooltipViewController *)viewController {
    [viewController set_BB_dataSource:nil];
}

@end

static CGFloat const kSpringDamping = 0.5;

@interface BBTooltipViewController () <UIViewControllerTransitioningDelegate,UIViewControllerAnimatedTransitioning>
@property (strong,nonatomic) BBTooltipView *tooltipView;

@property (strong,nonatomic) UITapGestureRecognizer *tapGestureRecognizer;

@property (assign,nonatomic) NSInteger tooltipIndex;
- (void)setTooltipIndex:(NSInteger)tooltipIndex animated:(BOOL)animated completion:(void(^)(void))completion;

+ (NSTimeInterval)_defaultTooltipAnimationDuration;
+ (UIEdgeInsets)_defaultTooltipMinimumEdgeInsets;
+ (UIColor *)_defaultTooltipOverlayBackgroundColor;
@end

@implementation BBTooltipViewController
#pragma mark *** Subclass Overrides ***
- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.presentingViewController.preferredStatusBarStyle;
}
- (UIModalPresentationStyle)modalPresentationStyle {
    return UIModalPresentationOverFullScreen;
}

- (instancetype)init {
    if (!(self = [super init]))
        return nil;
    
    _tooltipAnimationDuration = [self.class _defaultTooltipAnimationDuration];
    _tooltipMinimumEdgeInsets = [self.class _defaultTooltipMinimumEdgeInsets];
    _tooltipOverlayBackgroundColor = [self.class _defaultTooltipOverlayBackgroundColor];
    
    [self setTransitioningDelegate:self];
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor clearColor]];
    
    [self setTapGestureRecognizer:[[UITapGestureRecognizer alloc] init]];
    [self.tapGestureRecognizer setNumberOfTapsRequired:1];
    [self.tapGestureRecognizer setNumberOfTouchesRequired:1];
    [self.view addGestureRecognizer:self.tapGestureRecognizer];
    
    @weakify(self);
    [[[self.tapGestureRecognizer
     rac_gestureSignal]
     deliverOn:[RACScheduler mainThreadScheduler]]
     subscribeNext:^(id _) {
         @strongify(self);
         [self setTooltipIndex:self.tooltipIndex + 1 animated:YES completion:nil];
     }];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self setTooltipIndex:0 animated:YES completion:nil];
}
#pragma mark UIViewControllerTransitioningDelegate
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return self;
}
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return self;
}
#pragma mark UIViewControllerAnimatedTransitioning
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return self.tooltipAnimationDuration * 0.5;
}
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIView *containerView = [transitionContext containerView];
    UIView *toView = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey].view;
    UIView *fromView = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view;
    
    if (toView == self.view) {
        [containerView addSubview:toView];
        
        [toView setFrame:containerView.bounds];
        
        if ([transitionContext isAnimated]) {
            @weakify(self);
            [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                @strongify(self);
                [toView setBackgroundColor:self.tooltipOverlayBackgroundColor];
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:YES];
            }];
        }
        else {
            [toView setBackgroundColor:self.tooltipOverlayBackgroundColor];
            
            [transitionContext completeTransition:YES];
        }
    }
    else {
        if ([transitionContext isAnimated]) {
            @weakify(self);
            [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                @strongify(self);
                [fromView setBackgroundColor:[UIColor clearColor]];
                
                [self.tooltipView setAlpha:0.0];
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:YES];
            }];
        }
        else {
            [transitionContext completeTransition:YES];
        }
    }
}
#pragma mark *** Private Methods ***
+ (NSTimeInterval)_defaultTooltipAnimationDuration; {
    return 0.5;
}
+ (UIEdgeInsets)_defaultTooltipMinimumEdgeInsets; {
    return UIEdgeInsetsMake(8.0, 8.0, 8.0, 8.0);
}
+ (UIColor *)_defaultTooltipOverlayBackgroundColor; {
    return BBColorWA(0.0, 0.33);
}
#pragma mark Properties
- (void)setTooltipIndex:(NSInteger)tooltipIndex {
    [self setTooltipIndex:tooltipIndex animated:NO completion:nil];
}
- (void)setTooltipIndex:(NSInteger)tooltipIndex animated:(BOOL)animated completion:(void(^)(void))completion; {
    [self willChangeValueForKey:@keypath(self,tooltipIndex)];
    _tooltipIndex = tooltipIndex;
    [self didChangeValueForKey:@keypath(self,tooltipIndex)];
    
    @weakify(self);
    void(^animateInTooltipViewBlock)(BBTooltipView *) = ^(BBTooltipView *tooltipView){
        @strongify(self);
        [UIView performWithoutAnimation:^{
            [tooltipView setTransform:CGAffineTransformMakeScale(0.25, 0.25)];
            [tooltipView setAlpha:0.0];
        }];
        
        [UIView animateWithDuration:self.tooltipAnimationDuration delay:0 usingSpringWithDamping:kSpringDamping initialSpringVelocity:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            [tooltipView setTransform:CGAffineTransformIdentity];
            [tooltipView setAlpha:1.0];
        } completion:^(BOOL finished) {
            if (completion) {
                completion();
            }
        }];
    };
    
    void(^animateOutTooltipViewBlock)(BBTooltipView *) = ^(BBTooltipView *tooltipView){
        @strongify(self);
        [UIView animateWithDuration:self.tooltipAnimationDuration delay:0 usingSpringWithDamping:kSpringDamping initialSpringVelocity:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            [tooltipView setTransform:CGAffineTransformMakeScale(0.25, 0.25)];
            [tooltipView setAlpha:0.0];
        } completion:^(BOOL finished) {
            [tooltipView removeFromSuperview];
            
            if (completion) {
                completion();
            }
        }];
    };
    
    if (self.tooltipIndex == [self.dataSource numberOfTooltipsForTooltipViewController:self]) {
        if ([self.delegate respondsToSelector:@selector(tooltipViewControllerWillDismiss:)]) {
            [self.delegate tooltipViewControllerWillDismiss:self];
        }
        
        @weakify(self);
        [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
            @strongify(self);
            if ([self.delegate respondsToSelector:@selector(tooltipViewControllerDidDismiss:)]) {
                [self.delegate tooltipViewControllerDidDismiss:self];
            }
        }];
    }
    else {
        BBTooltipView *oldTooltipView = self.tooltipView;
        
        [self setTooltipView:[[BBTooltipView alloc] initWithFrame:CGRectZero]];
        [self.view addSubview:self.tooltipView];
        
        if ([self.dataSource respondsToSelector:@selector(tooltipViewController:attributedTextForTooltipAtIndex:)] &&
            [self.dataSource tooltipViewController:self attributedTextForTooltipAtIndex:self.tooltipIndex].length > 0) {
            
            [self.tooltipView setAttributedText:[self.dataSource tooltipViewController:self attributedTextForTooltipAtIndex:self.tooltipIndex]];
        }
        else {
            [self.tooltipView setText:[self.dataSource tooltipViewController:self textForTooltipAtIndex:self.tooltipIndex]];
        }
        
        UIView *attachmentView = [self.dataSource tooltipViewController:self attachmentViewForTooltipAtIndex:self.tooltipIndex];
        CGRect attachmentViewFrame = [self.view convertRect:[self.view.window convertRect:[attachmentView convertRect:attachmentView.bounds toView:nil] fromWindow:nil] fromView:nil];
        CGSize tooltipSize = [self.tooltipView sizeThatFits:CGSizeMake(CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
        CGRect tooltipFrame = MEDRectCenterInRect(CGRectMake(0, 0, tooltipSize.width, tooltipSize.height), attachmentViewFrame);
        
        tooltipFrame.origin.y = CGRectGetMaxY(attachmentViewFrame);
        
        // check left edge
        if (CGRectGetMinX(tooltipFrame) < self.tooltipMinimumEdgeInsets.left) {
            tooltipFrame.origin.x = self.tooltipMinimumEdgeInsets.left;
        }
        // check right edge
        else if (CGRectGetMaxX(tooltipFrame) > CGRectGetWidth(self.view.bounds) - self.tooltipMinimumEdgeInsets.right) {
            tooltipFrame.origin.x = CGRectGetWidth(self.view.bounds) - CGRectGetWidth(tooltipFrame) - self.tooltipMinimumEdgeInsets.right;
        }
        
        // check top edge
        if (CGRectGetMinY(tooltipFrame) < self.tooltipMinimumEdgeInsets.top) {
            tooltipFrame.origin.y = self.tooltipMinimumEdgeInsets.top;
        }
        // check bottom edge
        else if (CGRectGetMaxY(tooltipFrame) > CGRectGetHeight(self.view.bounds) - self.tooltipMinimumEdgeInsets.bottom) {
            tooltipFrame.origin.y = CGRectGetHeight(self.view.bounds) - CGRectGetHeight(tooltipFrame) - self.tooltipMinimumEdgeInsets.bottom;
            
            if (CGRectIntersectsRect(tooltipFrame, attachmentViewFrame)) {
                tooltipFrame.origin.y = CGRectGetMinY(attachmentViewFrame) - CGRectGetHeight(tooltipFrame);
                
                [self.tooltipView setArrowDirection:BBTooltipViewArrowDirectionDown];
            }
        }
        
        [self.tooltipView setFrame:tooltipFrame];
        [self.tooltipView setAttachmentView:attachmentView];
        
        animateInTooltipViewBlock(self.tooltipView);
        
        if (oldTooltipView) {
            animateOutTooltipViewBlock(oldTooltipView);
        }
    }
}

@end

@implementation UIViewController (BBTooltipViewControllerExtensions)

- (void)BB_presentTooltipViewControllerWithText:(NSString *)text attachmentView:(UIView *)attachmentView; {
    BBTooltipViewController *viewController = [[BBTooltipViewController alloc] init];
    _BBTooltipViewControllerDataSource *dataSource = [[_BBTooltipViewControllerDataSource alloc] init];
    
    [dataSource setText:text];
    [dataSource setAttachmentView:attachmentView];
    
    [viewController setDataSource:dataSource];
    [viewController setDelegate:dataSource];
    [viewController set_BB_dataSource:dataSource];
    
    [self presentViewController:viewController animated:YES completion:nil];
}
- (void)BB_presentTooltipViewControllerWithAttributedText:(NSAttributedString *)attributedText attachmentView:(UIView *)attachmentView; {
    BBTooltipViewController *viewController = [[BBTooltipViewController alloc] init];
    _BBTooltipViewControllerDataSource *dataSource = [[_BBTooltipViewControllerDataSource alloc] init];
    
    [dataSource setAttributedText:attributedText];
    [dataSource setAttachmentView:attachmentView];
    
    [viewController setDataSource:dataSource];
    [viewController setDelegate:dataSource];
    [viewController set_BB_dataSource:dataSource];
    
    [self presentViewController:viewController animated:YES completion:nil];
}

@end

@implementation UIViewController (BBTooltipViewControllerExtensionsPrivate)

static void *_BB_dataSourceKey = &_BB_dataSourceKey;

@dynamic _BB_dataSource;
- (_BBTooltipViewControllerDataSource *)_BB_dataSource {
    return objc_getAssociatedObject(self, _BB_dataSourceKey);
}
- (void)set_BB_dataSource:(_BBTooltipViewControllerDataSource *)_BB_dataSource {
    objc_setAssociatedObject(self, _BB_dataSourceKey, _BB_dataSource, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end