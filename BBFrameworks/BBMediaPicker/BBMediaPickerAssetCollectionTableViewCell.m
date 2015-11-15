//
//  BBMediaPickerAssetCollectionTableViewCell.m
//  BBFrameworks
//
//  Created by William Towe on 11/13/15.
//  Copyright © 2015 Bion Bilateral, LLC. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "BBMediaPickerAssetCollectionTableViewCell.h"
#import "BBMediaPickerAssetCollectionThumbnailView.h"
#import "BBFrameworksMacros.h"

@interface BBMediaPickerAssetCollectionTableViewCell ()
@property (weak,nonatomic) IBOutlet BBMediaPickerAssetCollectionThumbnailView *thumbnailView1;
@property (weak,nonatomic) IBOutlet BBMediaPickerAssetCollectionThumbnailView *thumbnailView2;
@property (weak,nonatomic) IBOutlet BBMediaPickerAssetCollectionThumbnailView *thumbnailView3;
@property (weak,nonatomic) IBOutlet UILabel *titleLabel;
@end

@implementation BBMediaPickerAssetCollectionTableViewCell

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [_model cancelAllThumbnailRequests];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    [self setAccessoryType:selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone];
}

- (void)setModel:(BBMediaPickerAssetCollectionModel *)model {
    _model = model;
    
    [self.titleLabel setText:_model.title];
    
    BBWeakify(self);
    [_model requestFirstThumbnailImageOfSize:self.thumbnailView1.frame.size completion:^(UIImage *thumbnailImage) {
        BBStrongify(self);
        [self.thumbnailView1.thumbnailImageView setImage:thumbnailImage];
    }];
}

@end
