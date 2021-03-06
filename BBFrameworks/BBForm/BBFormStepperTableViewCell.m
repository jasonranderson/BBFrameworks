//
//  BBFormStepperTableViewCell.m
//  BBFrameworks
//
//  Created by William Towe on 7/19/15.
//  Copyright (c) 2015 Bion Bilateral, LLC. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "BBFormStepperTableViewCell.h"
#import "BBFormField.h"
#import "BBFoundationGeometryFunctions.h"

@interface BBFormStepperTableViewCell ()
@property (strong,nonatomic) UIStepper *stepperControl;
@property (strong,nonatomic) UILabel *valueLabel;

+ (UIFont *)_defaultValueFont;
+ (UIColor *)_defaultValueTextColor;
+ (NSNumberFormatter *)_defaultNumberFormatter;
@end

@implementation BBFormStepperTableViewCell
#pragma mark *** Subclass Overrides ***
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (!(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]))
        return nil;
    
    _valueFont = [self.class _defaultValueFont];
    _valueTextColor = [self.class _defaultValueTextColor];
    
    _numberFormatter = [self.class _defaultNumberFormatter];
    
    [self setStepperControl:[[UIStepper alloc] initWithFrame:CGRectZero]];
    [self.stepperControl addTarget:self action:@selector(_stepperControlAction:) forControlEvents:UIControlEventValueChanged];
    [self.contentView addSubview:self.stepperControl];
    
    [self setValueLabel:[[UILabel alloc] initWithFrame:CGRectZero]];
    [self.valueLabel setTextAlignment:NSTextAlignmentRight];
    [self.valueLabel setFont:_valueFont];
    [self.valueLabel setTextColor:_valueTextColor];
    [self.contentView addSubview:self.valueLabel];
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize size = [self.stepperControl sizeThatFits:CGSizeZero];
    CGRect rect = BBCGRectCenterInRectVertically(CGRectMake(CGRectGetWidth(self.contentView.bounds) - size.width - self.layoutMargins.right, 0, size.width, size.height), self.contentView.bounds);
    
    [self.stepperControl setFrame:rect];
    
    id<UILayoutSupport> guide = self.rightLayoutGuide;
    
    [self.valueLabel setFrame:CGRectMake([guide length] + BBFormTableViewCellMargin, 0, CGRectGetMinX(self.stepperControl.frame) - [guide length] - BBFormTableViewCellMargin - BBFormTableViewCellMargin, CGRectGetHeight(self.contentView.bounds))];
}
#pragma mark *** Public Methods ***
#pragma mark Properties
- (void)setFormField:(BBFormField *)formField {
    [super setFormField:formField];
    
    if (formField.minimumValue) {
        [self.stepperControl setMinimumValue:formField.minimumDoubleValue];
    }
    if (formField.maximumValue) {
        [self.stepperControl setMaximumValue:formField.maximumDoubleValue];
    }
    if (formField.stepValue) {
        [self.stepperControl setStepValue:formField.stepDoubleValue];
    }
    
    [self.stepperControl setValue:formField.doubleValue];
    [self.valueLabel setText:[self.numberFormatter stringFromNumber:formField.value]];
    
    if (formField.numberFormatter) {
        [self setNumberFormatter:formField.numberFormatter];
    }
}

- (void)setValueFont:(UIFont *)valueFont {
    _valueFont = valueFont ?: [self.class _defaultValueFont];
    
    [self.valueLabel setFont:_valueFont];
}
- (void)setValueTextColor:(UIColor *)valueTextColor {
    _valueTextColor = valueTextColor ?: [self.class _defaultValueTextColor];
    
    [self.valueLabel setTextColor:_valueTextColor];
}

- (void)setNumberFormatter:(NSNumberFormatter *)numberFormatter {
    _numberFormatter = numberFormatter ?: [self.class _defaultNumberFormatter];
    
    [self.valueLabel setText:[_numberFormatter stringFromNumber:self.formField.value]];
}
#pragma mark *** Private Methods ***
+ (UIFont *)_defaultValueFont; {
    return [UIFont systemFontOfSize:17.0];
}
+ (UIColor *)_defaultValueTextColor; {
    return [UIColor darkGrayColor];
}

+ (NSNumberFormatter *)_defaultNumberFormatter; {
    static NSNumberFormatter *kRetval;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kRetval = [[NSNumberFormatter alloc] init];
        
        [kRetval setNumberStyle:NSNumberFormatterDecimalStyle];
    });
    return kRetval;
}
#pragma mark Actions
- (IBAction)_stepperControlAction:(id)sender {
    [self.formField setDoubleValue:self.stepperControl.value];
    
    [self.valueLabel setText:[self.numberFormatter stringFromNumber:@(self.stepperControl.value)]];
}

@end
