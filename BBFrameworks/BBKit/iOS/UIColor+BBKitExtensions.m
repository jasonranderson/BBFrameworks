//
//  UIColor+BBKitExtensions.m
//  BBFrameworks
//
//  Created by William Towe on 5/15/15.
//  Copyright (c) 2015 Bion Bilateral, LLC. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "UIColor+BBKitExtensions.h"
#import "BBFoundationMacros.h"

@implementation UIColor (BBKitExtensions)

+ (UIColor *)BB_colorRandomRGB; {
    u_int32_t max = 255;
    u_int32_t red = arc4random_uniform(max);
    u_int32_t green = arc4random_uniform(max);
    u_int32_t blue = arc4random_uniform(max);
    
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0];
}
+ (UIColor *)BB_colorRandomRGBA; {
    u_int32_t max = 255;
    u_int32_t red = arc4random_uniform(max);
    u_int32_t green = arc4random_uniform(max);
    u_int32_t blue = arc4random_uniform(max);
    u_int32_t alpha = arc4random_uniform(max);
    
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha/255.0];
}

+ (UIColor *)BB_colorWithHexadecimalString:(NSString *)hexadecimalString; {
    if (hexadecimalString.length == 0) {
        return nil;
    }
    
    hexadecimalString = [hexadecimalString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    
    UIColor *retval = nil;
    NSScanner *scanner = [NSScanner scannerWithString:hexadecimalString];
    
    uint32_t hexadecimalColor;
    if (![scanner scanHexInt:&hexadecimalColor]) {
        return retval;
    }
    
    uint8_t red = (uint8_t)(hexadecimalColor >> 16);
    uint8_t green = (uint8_t)(hexadecimalColor >> 8);
    uint8_t blue = (uint8_t)hexadecimalColor;
    
    retval = [UIColor colorWithRed:(CGFloat)red/0xff green:(CGFloat)green/0xff blue:(CGFloat)blue/0xff alpha:1.0];
    
    return retval;
}

+ (UIColor *)BB_colorByAdjustingBrightnessOfColor:(UIColor *)color delta:(CGFloat)delta; {
    CGFloat hue, saturation, brightness, alpha;
    
    if ([color getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha]) {
        brightness += delta - 1.0;
        brightness = BBBoundedValue(brightness, 0.0, 1.0);
        
        return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:alpha];
    }
    
    CGFloat white;
    
    if ([color getWhite:&white alpha:&alpha]) {
        white += delta - 1.0;
        white = BBBoundedValue(white, 0.0, 1.0);
        
        return [UIColor colorWithWhite:white alpha:alpha];
    }
    
    return nil;
}

- (UIColor *)BB_colorByAdjustingBrightnessBy:(CGFloat)delta; {
    return [self.class BB_colorByAdjustingBrightnessOfColor:self delta:delta];
}

@end
