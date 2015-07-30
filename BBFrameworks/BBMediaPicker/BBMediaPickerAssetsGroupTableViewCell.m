//
//  BBMediaPickerAssetsGroupTableViewCell.m
//  BBFrameworks
//
//  Created by William Towe on 7/29/15.
//  Copyright (c) 2015 Bion Bilateral, LLC. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "BBMediaPickerAssetsGroupTableViewCell.h"
#import "BBFoundationGeometryFunctions.h"
#import "BBMediaPickerAssetsGroupViewModel.h"
#import "UIImage+BBKitExtensions.h"

#import <ReactiveCocoa/ReactiveCocoa.h>

static CGFloat const kSubviewMargin = 8.0;
static CGFloat const kSubviewMarginHalf = 4.0;
static CGSize const kImageViewSize = {.width=70.0, .height=70.0};

@interface BBMediaPickerAssetsGroupTableViewCell ()
@property (strong,nonatomic) UIImageView *badgeImageView;
@property (strong,nonatomic) UIImageView *firstThumbnailImageView;
@property (strong,nonatomic) UIImageView *secondThumbnailImageView;
@property (strong,nonatomic) UIImageView *thirdThumbnailImageView;
@property (strong,nonatomic) UILabel *nameLabel;
@property (strong,nonatomic) UILabel *countLabel;

+ (UIColor *)_defaultContentBackgroundColor;
+ (UIFont *)_defaultNameFont;
+ (UIColor *)_defaultNameTextColor;
+ (UIFont *)_defaultCountFont;
+ (UIColor *)_defaultCountTextColor;
@end

@implementation BBMediaPickerAssetsGroupTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (!(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]))
        return nil;
    
    _contentBackgroundColor = [self.class _defaultContentBackgroundColor];
    _nameFont = [self.class _defaultNameFont];
    _nameTextColor = [self.class _defaultNameTextColor];
    _countFont = [self.class _defaultCountFont];
    _countTextColor = [self.class _defaultCountTextColor];
    
    [self setBackgroundColor:_contentBackgroundColor];
    [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    [self setThirdThumbnailImageView:[[UIImageView alloc] initWithFrame:CGRectZero]];
    [self.contentView addSubview:self.thirdThumbnailImageView];
    
    [self setSecondThumbnailImageView:[[UIImageView alloc] initWithFrame:CGRectZero]];
    [self.contentView addSubview:self.secondThumbnailImageView];
    
    [self setFirstThumbnailImageView:[[UIImageView alloc] initWithFrame:CGRectZero]];
    [self.contentView addSubview:self.firstThumbnailImageView];
    
    [self setBadgeImageView:[[UIImageView alloc] initWithFrame:CGRectZero]];
    [self.contentView addSubview:self.badgeImageView];
    
    [self setNameLabel:[[UILabel alloc] initWithFrame:CGRectZero]];
    [self.nameLabel setFont:_nameFont];
    [self.nameLabel setTextColor:_nameTextColor];
    [self.contentView addSubview:self.nameLabel];
    
    [self setCountLabel:[[UILabel alloc] initWithFrame:CGRectZero]];
    [self.countLabel setFont:_countFont];
    [self.countLabel setTextColor:_countTextColor];
    [self.contentView addSubview:self.countLabel];
    
    @weakify(self);
    RAC(self.badgeImageView,image) = [[RACObserve(self, viewModel.badgeImage)
                                       map:^id(UIImage *value) {
                                           return [value BB_imageByRenderingWithColor:[UIColor whiteColor]];
                                       }]
                                      doNext:^(id _) {
                                          @strongify(self);
                                          [self setNeedsLayout];
                                      }];
    RAC(self.firstThumbnailImageView,image) = RACObserve(self, viewModel.posterImage);
    RAC(self.secondThumbnailImageView,image) = RACObserve(self, viewModel.secondPosterImage);
    RAC(self.thirdThumbnailImageView,image) = RACObserve(self, viewModel.thirdPosterImage);
    RAC(self.nameLabel,text) = RACObserve(self, viewModel.name);
    RAC(self.countLabel,text) = RACObserve(self, viewModel.countString);
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.firstThumbnailImageView setFrame:BBCGRectCenterInRectVertically(CGRectMake(kSubviewMargin, 0, kImageViewSize.width, kImageViewSize.height), self.contentView.bounds)];
    [self.secondThumbnailImageView setFrame:CGRectOffset(CGRectInset(self.firstThumbnailImageView.frame, 2.0, 0), 0, -2.0)];
    [self.thirdThumbnailImageView setFrame:CGRectOffset(CGRectInset(self.secondThumbnailImageView.frame, 2.0, 0), 0, -2.0)];
    
    [self.badgeImageView setFrame:CGRectMake(CGRectGetMinX(self.firstThumbnailImageView.frame) + kSubviewMarginHalf,
                                             CGRectGetMaxY(self.firstThumbnailImageView.frame) - self.badgeImageView.image.size.height - kSubviewMarginHalf,
                                             self.badgeImageView.image.size.width,
                                             self.badgeImageView.image.size.height)];
    
    CGRect rect = BBCGRectCenterInRectVertically(CGRectMake(CGRectGetMaxX(self.firstThumbnailImageView.frame) + kSubviewMargin, 0, CGRectGetWidth(self.contentView.bounds) - CGRectGetMaxX(self.firstThumbnailImageView.frame) - kSubviewMargin - kSubviewMargin, ceil(self.nameLabel.font.lineHeight + self.countLabel.font.lineHeight)), self.contentView.bounds);
    
    [self.nameLabel setFrame:CGRectMake(CGRectGetMinX(rect), CGRectGetMinY(rect), CGRectGetWidth(rect), ceil(self.nameLabel.font.lineHeight))];
    [self.countLabel setFrame:CGRectMake(CGRectGetMinX(rect), CGRectGetMaxY(self.nameLabel.frame), CGRectGetWidth(rect), ceil(self.countLabel.font.lineHeight))];
}

+ (CGFloat)rowHeight {
    return 90.0;
}

- (void)setContentBackgroundColor:(UIColor *)contentBackgroundColor {
    _contentBackgroundColor = contentBackgroundColor ?: [self.class _defaultContentBackgroundColor];
    
    [self setBackgroundColor:_contentBackgroundColor];
}
- (void)setSelectedContentBackgroundColor:(UIColor *)selectedContentBackgroundColor {
    _selectedContentBackgroundColor = selectedContentBackgroundColor;
    
    if (_selectedContentBackgroundColor) {
        [self setSelectedBackgroundView:({
            UIView *retval = [[UIView alloc] initWithFrame:CGRectZero];
            
            [retval setBackgroundColor:selectedContentBackgroundColor];
            
            retval;
        })];
    }
    else {
        [self setSelectedBackgroundView:nil];
    }
}
- (void)setNameFont:(UIFont *)nameFont {
    _nameFont = nameFont ?: [self.class _defaultNameFont];
    
    [self.nameLabel setFont:_nameFont];
}
- (void)setNameTextColor:(UIColor *)nameTextColor {
    _nameTextColor = nameTextColor ?: [self.class _defaultNameTextColor];
    
    [self.nameLabel setTextColor:_nameTextColor];
}
- (void)setCountFont:(UIFont *)countFont {
    _countFont = countFont ?: [self.class _defaultCountFont];
    
    [self.countLabel setFont:_countFont];
}
- (void)setCountTextColor:(UIColor *)countTextColor {
    _countTextColor = countTextColor ?: [self.class _defaultCountTextColor];
    
    [self.countLabel setTextColor:_countTextColor];
}

+ (UIColor *)_defaultContentBackgroundColor; {
    return [UIColor whiteColor];
}
+ (UIFont *)_defaultNameFont; {
    return [UIFont systemFontOfSize:17.0];
}
+ (UIColor *)_defaultNameTextColor; {
    return [UIColor blackColor];
}
+ (UIFont *)_defaultCountFont; {
    return [UIFont systemFontOfSize:12.0];
}
+ (UIColor *)_defaultCountTextColor; {
    return [UIColor lightGrayColor];
}

@end
