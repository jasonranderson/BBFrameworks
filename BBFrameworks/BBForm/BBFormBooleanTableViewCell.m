//
//  BBFormBooleanTableViewCell.m
//  BBFrameworks
//
//  Created by William Towe on 7/18/15.
//  Copyright (c) 2015 Bion Bilateral, LLC. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "BBFormBooleanTableViewCell.h"
#import "BBFormField.h"

#import <Archimedes/Archimedes.h>

@interface BBFormBooleanTableViewCell ()
@property (strong,nonatomic) UISwitch *switchControl;
@end

@implementation BBFormBooleanTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (!(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]))
        return nil;
    
    [self setSwitchControl:[[UISwitch alloc] initWithFrame:CGRectZero]];
    [self.switchControl addTarget:self action:@selector(_switchControlAction:) forControlEvents:UIControlEventValueChanged];
    [self.contentView addSubview:self.switchControl];
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize size = [self.switchControl sizeThatFits:CGSizeZero];
    CGRect rect = MEDRectCenterInRect(CGRectMake(0, 0, size.width, size.height), self.contentView.bounds);
    
    rect.origin.x = CGRectGetWidth(self.contentView.bounds) - size.width - self.layoutMargins.right;
    
    [self.switchControl setFrame:rect];
}

- (void)setFormField:(BBFormField *)formField {
    [super setFormField:formField];
    
    [self.switchControl setOn:formField.boolValue];
}

- (IBAction)_switchControlAction:(id)sender {
    [self.formField setBoolValue:self.switchControl.isOn];
}

@end
