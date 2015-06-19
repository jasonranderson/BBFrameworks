//
//  BBTooltipView.h
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

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, BBTooltipViewArrowDirection) {
    BBTooltipViewArrowDirectionUp,
    BBTooltipViewArrowDirectionLeft,
    BBTooltipViewArrowDirectionDown,
    BBTooltipViewArrowDirectionRight
};

/**
 BBTooltipView is a UIView subclass that is responsible for displaying a tooltip with BBTooltipViewController.
 */
@interface BBTooltipView : UIView

/**
 Set and get the arrow direction of the receiver.
 */
@property (assign,nonatomic) BBTooltipViewArrowDirection arrowDirection;

/**
 Set and get the text of the receiver.
 
 Calls `-[self setAttributedText:[[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName: self.tooltipFont, NSForegroundColorAttributeName: self.tooltipTextColor}]]`.
 */
@property (copy,nonatomic) NSString *text;
/**
 Set and get the attributed text of the receiver.
 */
@property (copy,nonatomic) NSAttributedString *attributedText;

/**
 Set and get the attachment view of the receiver.
 */
@property (weak,nonatomic) UIView *attachmentView;

/**
 Set and get the tooltip font of the receiver.
 */
@property (strong,nonatomic) UIFont *tooltipFont UI_APPEARANCE_SELECTOR;
/**
 Set and get the tooltip text color of the receiver.
 */
@property (strong,nonatomic) UIColor *tooltipTextColor UI_APPEARANCE_SELECTOR;
/**
 Set and get the tooltip background color.
 */
@property (strong,nonatomic) UIColor *tooltipBackgroundColor UI_APPEARANCE_SELECTOR;
/**
 Set and get the tooltip edge insets.
 */
@property (assign,nonatomic) UIEdgeInsets tooltipEdgeInsets UI_APPEARANCE_SELECTOR;
/**
 Set and get the tooltip arrow height.
 */
@property (assign,nonatomic) CGFloat tooltipArrowHeight UI_APPEARANCE_SELECTOR;
/**
 Set and get the tooltip corner radius.
 */
@property (assign,nonatomic) CGFloat tooltipCornerRadius UI_APPEARANCE_SELECTOR;

/**
 Returns the background rect for the provided bounds.
 
 @param bounds The bounds of the receiver
 @return The background rect
 */
- (CGRect)backgroundRectForBounds:(CGRect)bounds;
/**
 Returns the arrow rect for the provided bounds and attachment view.
 
 @param The bounds of the receiver
 @param attachmentView The attachment view for the receiver
 @return The arrow rect
 */
- (CGRect)arrowRectForBounds:(CGRect)bounds attachmentView:(UIView *)attachmentView;

@end