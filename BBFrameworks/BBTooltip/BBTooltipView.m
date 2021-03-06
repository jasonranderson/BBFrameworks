//
//  BBTooltipView.m
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

#import "BBTooltipView.h"
#import "UIView+BBTooltipAttachmentViewExtensions.h"

@interface BBTooltipView ()
@property (strong,nonatomic) UILabel *textLabel;

+ (UIFont *)_defaultTooltipFont;
+ (UIColor *)_defaultTooltipTextColor;
+ (UIColor *)_defaultTooltipBackgroundColor;
+ (UIEdgeInsets)_defaultTooltipEdgeInsets;
+ (CGFloat)_defaultTooltipArrowWidth;
+ (CGFloat)_defaultTooltipArrowHeight;
+ (CGFloat)_defaultTooltipCornerRadius;
@end

@implementation BBTooltipView
#pragma mark *** Subclass Overrides ***
- (instancetype)initWithFrame:(CGRect)frame {
    if (!(self = [super initWithFrame:frame]))
        return nil;
    
    _tooltipFont = [self.class _defaultTooltipFont];
    _tooltipTextColor = [self.class _defaultTooltipTextColor];
    _tooltipBackgroundColor = [self.class _defaultTooltipBackgroundColor];
    _tooltipEdgeInsets = [self.class _defaultTooltipEdgeInsets];
    _tooltipArrowWidth = [self.class _defaultTooltipArrowWidth];
    _tooltipArrowHeight = [self.class _defaultTooltipArrowHeight];
    _tooltipCornerRadius = [self.class _defaultTooltipCornerRadius];
    
    [self setIsAccessibilityElement:NO];
    [self setContentMode:UIViewContentModeRedraw];
    
    [self setTextLabel:[[UILabel alloc] initWithFrame:CGRectZero]];
    [self.textLabel setNumberOfLines:0];
    [self.textLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [self.textLabel setFont:_tooltipFont];
    [self.textLabel setTextColor:_tooltipTextColor];
    [self addSubview:self.textLabel];
    
    return self;
}
#pragma mark Accessibility
- (NSInteger)accessibilityElementCount {
    return [self.accessoryView respondsToSelector:@selector(setDisplayNextTooltipBlock:)] ? 2 : 0;
}
- (id)accessibilityElementAtIndex:(NSInteger)index {
    return index == 0 ? self.textLabel : self.accessoryView;
}
- (NSInteger)indexOfAccessibilityElement:(id)element {
    return element == self.textLabel ? 0 : 1;
}

#pragma mark Layout
- (void)layoutSubviews {
    switch (self.arrowStyle) {
        case BBTooltipViewArrowStyleDefault:
            switch (self.arrowDirection) {
                case BBTooltipViewArrowDirectionUp:
                    [self.textLabel setFrame:CGRectMake(self.tooltipEdgeInsets.left, self.tooltipArrowHeight + self.tooltipEdgeInsets.top, CGRectGetWidth(self.bounds) - self.tooltipEdgeInsets.left - self.tooltipEdgeInsets.right, CGRectGetHeight(self.bounds) - self.tooltipEdgeInsets.bottom - self.tooltipEdgeInsets.top - self.tooltipArrowHeight)];
                    break;
                case BBTooltipViewArrowDirectionLeft:
                    [self.textLabel setFrame:CGRectMake(self.tooltipArrowWidth + self.tooltipEdgeInsets.left, self.tooltipEdgeInsets.top, CGRectGetWidth(self.bounds) - self.tooltipEdgeInsets.left - self.tooltipEdgeInsets.right - self.tooltipArrowWidth, CGRectGetHeight(self.bounds) - self.tooltipEdgeInsets.top - self.tooltipEdgeInsets.bottom)];
                    break;
                case BBTooltipViewArrowDirectionDown:
                    [self.textLabel setFrame:CGRectMake(self.tooltipEdgeInsets.left, self.tooltipEdgeInsets.top, CGRectGetWidth(self.bounds) - self.tooltipEdgeInsets.left - self.tooltipEdgeInsets.right, CGRectGetHeight(self.bounds) - self.tooltipEdgeInsets.top - self.tooltipEdgeInsets.bottom - self.tooltipArrowHeight)];
                    break;
                case BBTooltipViewArrowDirectionRight:
                    [self.textLabel setFrame:CGRectMake(self.tooltipEdgeInsets.left, self.tooltipEdgeInsets.top, CGRectGetWidth(self.bounds) - self.tooltipEdgeInsets.left - self.tooltipEdgeInsets.right - self.tooltipArrowWidth, CGRectGetHeight(self.bounds) - self.tooltipEdgeInsets.left - self.tooltipEdgeInsets.right)];
                    break;
                default:
                    break;
            }
            break;
        case BBTooltipViewArrowStyleNone:
            [self.textLabel setFrame:CGRectMake(self.tooltipEdgeInsets.left, self.tooltipEdgeInsets.top, CGRectGetWidth(self.bounds) - self.tooltipEdgeInsets.left - self.tooltipEdgeInsets.right, CGRectGetHeight(self.bounds) - self.tooltipEdgeInsets.top - self.tooltipEdgeInsets.bottom)];
            break;
        default:
            break;
    }
    
    if (self.accessoryView) {
        [self.accessoryView setFrame:[self accessoryViewRectForBounds:self.bounds]];
        
        [self.textLabel setFrame:CGRectMake(CGRectGetMinX(self.textLabel.frame), CGRectGetMinY(self.textLabel.frame), CGRectGetWidth(self.textLabel.frame), CGRectGetHeight(self.textLabel.frame) - self.accessoryViewEdgeInsets.top - CGRectGetHeight(self.accessoryView.frame) - self.accessoryViewEdgeInsets.bottom)];
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize retval = CGSizeMake(size.width, 0);
    
    switch (self.arrowStyle) {
        case BBTooltipViewArrowStyleDefault:
            switch (self.arrowDirection) {
                case BBTooltipViewArrowDirectionUp:
                case BBTooltipViewArrowDirectionDown:
                    retval.height += self.tooltipArrowHeight;
                    retval.height += self.tooltipEdgeInsets.top;
                    retval.height += ceil([self.textLabel sizeThatFits:CGSizeMake(retval.width - self.tooltipEdgeInsets.left - self.tooltipEdgeInsets.right, CGFLOAT_MAX)].height);
                    retval.height += self.tooltipEdgeInsets.bottom;
                    break;
                case BBTooltipViewArrowDirectionLeft:
                case BBTooltipViewArrowDirectionRight:
                    retval.height += self.tooltipEdgeInsets.top;
                    retval.height += ceil([self.textLabel sizeThatFits:CGSizeMake(retval.width - self.tooltipEdgeInsets.left - self.tooltipEdgeInsets.right - self.tooltipArrowWidth, CGFLOAT_MAX)].height);
                    retval.height += self.tooltipEdgeInsets.bottom;
                    break;
                default:
                    break;
            }
            break;
        case BBTooltipViewArrowStyleNone:
            retval.height += self.tooltipEdgeInsets.top;
            retval.height += ceil([self.textLabel sizeThatFits:CGSizeMake(retval.width - self.tooltipEdgeInsets.left - self.tooltipEdgeInsets.right, CGFLOAT_MAX)].height);
            retval.height += self.tooltipEdgeInsets.bottom;
            break;
        default:
            break;
    }
    
    if (self.accessoryView) {
        retval.height += self.accessoryViewEdgeInsets.top;
        retval.height += [self.accessoryView sizeThatFits:CGSizeMake(retval.width - self.accessoryViewEdgeInsets.left - self.accessoryViewEdgeInsets.right, CGFLOAT_MAX)].height;
        retval.height += self.accessoryViewEdgeInsets.bottom;
    }
    
    return retval;
}
#pragma mark Drawing
- (BOOL)isOpaque {
    return NO;
}
- (void)drawRect:(CGRect)rect {
    CGRect backgroundRect = [self backgroundRectForBounds:self.bounds];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:backgroundRect cornerRadius:self.tooltipCornerRadius];
    
    [self.tooltipBackgroundColor setFill];
    
    [path fill];
    
    if (self.arrowStyle == BBTooltipViewArrowStyleDefault) {
        CGRect arrowRect = [self arrowRectForBounds:self.bounds attachmentView:self.attachmentView];
        
        path = [UIBezierPath bezierPath];
        
        switch (self.arrowDirection) {
            case BBTooltipViewArrowDirectionUp:
                [path moveToPoint:CGPointMake(CGRectGetMidX(arrowRect), CGRectGetMinY(arrowRect))];
                [path addLineToPoint:CGPointMake(CGRectGetMaxX(arrowRect), CGRectGetMaxY(arrowRect))];
                [path addLineToPoint:CGPointMake(CGRectGetMinX(arrowRect), CGRectGetMaxY(arrowRect))];
                [path addLineToPoint:CGPointMake(CGRectGetMidX(arrowRect), CGRectGetMinY(arrowRect))];
                break;
            case BBTooltipViewArrowDirectionLeft:
                [path moveToPoint:CGPointMake(CGRectGetMinX(arrowRect), CGRectGetMidY(arrowRect))];
                [path addLineToPoint:CGPointMake(CGRectGetMaxX(arrowRect), CGRectGetMaxY(arrowRect))];
                [path addLineToPoint:CGPointMake(CGRectGetMaxX(arrowRect), CGRectGetMinY(arrowRect))];
                [path addLineToPoint:CGPointMake(CGRectGetMinX(arrowRect), CGRectGetMidY(arrowRect))];
                break;
            case BBTooltipViewArrowDirectionDown:
                [path moveToPoint:CGPointMake(CGRectGetMidX(arrowRect), CGRectGetMaxY(arrowRect))];
                [path addLineToPoint:CGPointMake(CGRectGetMinX(arrowRect), CGRectGetMinY(arrowRect))];
                [path addLineToPoint:CGPointMake(CGRectGetMaxX(arrowRect), CGRectGetMinY(arrowRect))];
                [path addLineToPoint:CGPointMake(CGRectGetMidX(arrowRect), CGRectGetMaxY(arrowRect))];
                break;
            case BBTooltipViewArrowDirectionRight:
                [path moveToPoint:CGPointMake(CGRectGetMaxX(arrowRect), CGRectGetMidY(arrowRect))];
                [path addLineToPoint:CGPointMake(CGRectGetMinX(arrowRect), CGRectGetMaxY(arrowRect))];
                [path addLineToPoint:CGPointMake(CGRectGetMinX(arrowRect), CGRectGetMinY(arrowRect))];
                [path addLineToPoint:CGPointMake(CGRectGetMaxX(arrowRect), CGRectGetMidY(arrowRect))];
                break;
            default:
                break;
        }
        
        [self.tooltipBackgroundColor setFill];
        
        [path fill];
    }
}
#pragma mark *** Public Methods ***
- (CGRect)backgroundRectForBounds:(CGRect)bounds; {
    CGRect retval = CGRectZero;
    
    switch (self.arrowStyle) {
        case BBTooltipViewArrowStyleDefault:
            switch (self.arrowDirection) {
                case BBTooltipViewArrowDirectionUp:
                    retval = CGRectMake(0, self.tooltipArrowHeight, CGRectGetWidth(bounds), CGRectGetHeight(bounds) - self.tooltipArrowHeight);
                    break;
                case BBTooltipViewArrowDirectionLeft:
                    retval = CGRectMake(self.tooltipArrowWidth, 0, CGRectGetWidth(bounds) - self.tooltipArrowWidth, CGRectGetHeight(bounds));
                    break;
                case BBTooltipViewArrowDirectionDown:
                    retval = CGRectMake(0, 0, CGRectGetWidth(bounds), CGRectGetHeight(bounds) - self.tooltipArrowHeight);
                    break;
                case BBTooltipViewArrowDirectionRight:
                    retval = CGRectMake(0, 0, CGRectGetWidth(bounds) - self.tooltipArrowWidth, CGRectGetHeight(bounds));
                    break;
                default:
                    break;
            }
            break;
        case BBTooltipViewArrowStyleNone:
            retval = bounds;
            break;
        default:
            break;
    }
    
    return retval;
}
- (CGRect)arrowRectForBounds:(CGRect)bounds attachmentView:(UIView *)attachmentView; {
    CGRect retval = CGRectZero;
    
    if (self.arrowStyle == BBTooltipViewArrowStyleDefault) {
        CGRect attachmentBounds = attachmentView.bounds;
        
        if ([attachmentView respondsToSelector:@selector(BB_tooltipAttachmentViewBounds)] &&
            !CGRectIsEmpty([attachmentView BB_tooltipAttachmentViewBounds])) {
            
            attachmentBounds = attachmentView.BB_tooltipAttachmentViewBounds;
        }
        
        CGPoint attachmentPoint = [self convertPoint:[self.window convertPoint:[attachmentView convertPoint:CGPointMake(CGRectGetMidX(attachmentBounds), CGRectGetMidY(attachmentBounds)) toView:nil] fromWindow:attachmentView.window] fromView:nil];
        CGFloat arrowHalfWidth = floor(self.tooltipArrowWidth * 0.5);
        
        switch (self.arrowDirection) {
            case BBTooltipViewArrowDirectionUp:
                retval = CGRectMake(attachmentPoint.x - arrowHalfWidth, 0, self.tooltipArrowWidth, self.tooltipArrowHeight);
                break;
            case BBTooltipViewArrowDirectionLeft:
                retval = CGRectMake(0, attachmentPoint.y - arrowHalfWidth, self.tooltipArrowWidth, self.tooltipArrowHeight);
                break;
            case BBTooltipViewArrowDirectionDown:
                retval = CGRectMake(attachmentPoint.x - arrowHalfWidth, CGRectGetHeight(bounds) - self.tooltipArrowHeight, self.tooltipArrowWidth, self.tooltipArrowHeight);
                break;
            case BBTooltipViewArrowDirectionRight:
                retval = CGRectMake(CGRectGetWidth(bounds) - self.tooltipArrowWidth, attachmentPoint.y - arrowHalfWidth, self.tooltipArrowWidth, self.tooltipArrowHeight);
                break;
            default:
                break;
        }
    }
    
    return retval;
}
- (CGRect)accessoryViewRectForBounds:(CGRect)bounds; {
    CGRect retval = CGRectZero;
    
    if (self.accessoryView) {
        CGFloat width = CGRectGetWidth(bounds) - self.accessoryViewEdgeInsets.left - self.accessoryViewEdgeInsets.right;
        CGFloat height = [self.accessoryView sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)].height;
        
        retval = CGRectMake(self.accessoryViewEdgeInsets.left, CGRectGetMaxY([self backgroundRectForBounds:bounds]) - height - self.accessoryViewEdgeInsets.bottom, width, height);
    }
    
    return retval;
}
#pragma mark Properties
- (void)setArrowDirection:(BBTooltipViewArrowDirection)arrowDirection {
    _arrowDirection = arrowDirection;
    
    [self setNeedsLayout];
}

@dynamic text;
- (NSString *)text {
    return self.attributedText.string;
}
- (void)setText:(NSString *)text {
    [self setAttributedText:[[NSAttributedString alloc] initWithString:text ?: @"" attributes:@{NSFontAttributeName: self.tooltipFont, NSForegroundColorAttributeName: self.tooltipTextColor}]];
}
@dynamic attributedText;
- (NSAttributedString *)attributedText {
    return self.textLabel.attributedText;
}
- (void)setAttributedText:(NSAttributedString *)attributedText {
    [self.textLabel setAttributedText:attributedText];
}

- (void)setTooltipFont:(UIFont *)tooltipFont {
    _tooltipFont = tooltipFont ?: [self.class _defaultTooltipFont];
}
- (void)setTooltipTextColor:(UIColor *)tooltipTextColor {
    _tooltipTextColor = tooltipTextColor ?: [self.class _defaultTooltipTextColor];
}
- (void)setTooltipBackgroundColor:(UIColor *)tooltipBackgroundColor {
    _tooltipBackgroundColor = tooltipBackgroundColor ?: [self.class _defaultTooltipBackgroundColor];
}
- (void)setTooltipArrowWidth:(CGFloat)tooltipArrowWidth {
    _tooltipArrowWidth = tooltipArrowWidth <= 0.0 ? [self.class _defaultTooltipArrowWidth] : tooltipArrowWidth;
}
- (void)setTooltipArrowHeight:(CGFloat)tooltipArrowHeight {
    _tooltipArrowHeight = tooltipArrowHeight <= 0.0 ? [self.class _defaultTooltipArrowHeight] : tooltipArrowHeight;
}

- (void)setAccessoryView:(UIView<BBTooltipAccessoryView> *)accessoryView {
    [_accessoryView removeFromSuperview];
    
    _accessoryView = accessoryView;
    
    if (_accessoryView) {
        [self addSubview:_accessoryView];
    }
}
#pragma mark *** Private Methods ***
+ (UIFont *)_defaultTooltipFont; {
    return [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
}
+ (UIColor *)_defaultTooltipTextColor; {
    return [UIColor whiteColor];
}
+ (UIColor *)_defaultTooltipBackgroundColor; {
    return [UIColor darkGrayColor];
}
+ (UIEdgeInsets)_defaultTooltipEdgeInsets; {
    return UIEdgeInsetsMake(8.0, 8.0, 8.0, 8.0);
}
+ (CGFloat)_defaultTooltipArrowWidth; {
    return 8.0;
}
+ (CGFloat)_defaultTooltipArrowHeight; {
    return 8.0;
}
+ (CGFloat)_defaultTooltipCornerRadius; {
    return 5.0;
}

@end
