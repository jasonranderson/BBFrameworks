//
//  BBMediaViewerPageImageViewController.m
//  BBFrameworks
//
//  Created by William Towe on 2/28/16.
//  Copyright © 2016 Bion Bilateral, LLC. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "BBMediaViewerPageImageViewController.h"
#import "BBMediaViewerPageImageModel.h"
#import "BBMediaViewerPageImageScrollView.h"
#import "BBFoundationGeometryFunctions.h"
#import "BBFrameworksMacros.h"
#import "BBMediaViewerModel.h"
#import "BBMediaViewerTheme.h"

#import <ReactiveCocoa/ReactiveCocoa.h>

@interface BBMediaViewerPageImageViewController ()
@property (strong,nonatomic) BBMediaViewerPageImageScrollView *scrollView;
@property (strong,nonatomic) UIActivityIndicatorView *activityIndicatorView;

@property (readwrite,strong,nonatomic) BBMediaViewerPageImageModel *model;
@end

@implementation BBMediaViewerPageImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setScrollView:[[BBMediaViewerPageImageScrollView alloc] initWithModel:self.model]];
    [self.view addSubview:self.scrollView];
    
    [self setActivityIndicatorView:[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge]];
    [self.activityIndicatorView setHidesWhenStopped:YES];
    [self.activityIndicatorView setColor:self.model.parentModel.theme.foregroundColor];
    [self.view addSubview:self.activityIndicatorView];
    
    BBWeakify(self);
    [[RACObserve(self.model, downloading)
     deliverOn:[RACScheduler mainThreadScheduler]]
     subscribeNext:^(NSNumber *value) {
         BBStrongify(self);
         if (value.boolValue) {
             [self.activityIndicatorView startAnimating];
         }
         else {
             [self.activityIndicatorView stopAnimating];
         }
     }];
}
- (void)viewWillLayoutSubviews {
    [self.scrollView setFrame:self.view.bounds];
    
    CGSize size = [self.activityIndicatorView sizeThatFits:CGSizeZero];
    
    [self.activityIndicatorView setFrame:BBCGRectCenterInRect(CGRectMake(0, 0, size.width, size.height),self.view.bounds)];
}

- (instancetype)initWithMedia:(id<BBMediaViewerMedia>)media parentModel:(BBMediaViewerModel *)parentModel {
    if (!(self = [super initWithMedia:media parentModel:parentModel]))
        return nil;
    
    _model = [[BBMediaViewerPageImageModel alloc] initWithMedia:media parentModel:parentModel];
    
    return self;
}

@synthesize model=_model;

@end
