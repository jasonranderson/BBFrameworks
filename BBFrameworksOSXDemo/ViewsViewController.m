//
//  ViewsViewController.m
//  BBFrameworks
//
//  Created by William Towe on 6/24/15.
//  Copyright (c) 2015 Bion Bilateral, LLC. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "ViewsViewController.h"

#import <BBFrameworks/BBKit.h>

@interface ViewsViewController ()
@property (weak,nonatomic) IBOutlet NSImageView *blurImageView;
@property (weak,nonatomic) IBOutlet NSImageView *tintImageView;
@property (strong,nonatomic) BBBadgeView *badgeView;
@end

@implementation ViewsViewController

- (NSString *)title {
    return @"Views";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.blurImageView setImage:[self.blurImageView.image BB_imageByBlurringWithRadius:0.33]];
    
    [self.tintImageView setImage:[self.tintImageView.image BB_imageByTintingWithColor:BBColorWA(0.0,0.75)]];
    
    [self setBadgeView:[[BBBadgeView alloc] initWithFrame:NSZeroRect]];
    [self.badgeView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.badgeView setBadge:@"Badge View"];
    [self.view addSubview:self.badgeView];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[imageView]-[badgeView]" options:0 metrics:nil views:@{@"badgeView": self.badgeView, @"imageView": self.tintImageView}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[badgeView]" options:0 metrics:nil views:@{@"badgeView": self.badgeView}]];
}

@end