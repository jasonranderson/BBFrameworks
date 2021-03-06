//
//  BBMediaPickerAssetCollectionModel.h
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

#import <UIKit/UIKit.h>
#import "BBMediaPickerDefines.h"

#if (BB_MEDIA_PICKER_USE_PHOTOS_FRAMEWORK)
#import <Photos/PHCollection.h>
#import <Photos/PHFetchResult.h>
#else
#import <AssetsLibrary/ALAssetsGroup.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@class BBMediaPickerModel,BBMediaPickerAssetModel;

@interface BBMediaPickerAssetCollectionModel : NSObject

#if (BB_MEDIA_PICKER_USE_PHOTOS_FRAMEWORK)
@property (readonly,strong,nonatomic) PHAssetCollection *assetCollection;
@property (readonly,strong,nonatomic) PHFetchResult<PHAsset *> *fetchResult;
#else
@property (readonly,strong,nonatomic) ALAssetsGroup *assetCollection;
#endif

@property (readonly,weak,nonatomic) BBMediaPickerModel *model;

@property (readonly,nonatomic) NSString *identifier;
@property (readonly,nonatomic) BBMediaPickerAssetCollectionSubtype subtype;
@property (readonly,nonatomic) NSString *title;
@property (readonly,nonatomic) NSString *subtitle;
@property (readonly,nonatomic) UIImage *typeImage;

@property (readonly,nonatomic) NSUInteger countOfAssetModels;
- (BBMediaPickerAssetModel *)assetModelAtIndex:(NSUInteger)index;

- (NSUInteger)indexOfAssetModel:(BBMediaPickerAssetModel *)assetModel;

- (void)requestThumbnailImageOfSize:(CGSize)size thumbnailIndex:(NSUInteger)thumbnailIndex completion:(void(^)(UIImage * _Nullable thumbnailImage))completion;
- (void)cancelAllThumbnailRequests;

- (void)reloadFetchResult;

#if (BB_MEDIA_PICKER_USE_PHOTOS_FRAMEWORK)
- (instancetype)initWithAssetCollection:(PHAssetCollection *)assetCollection model:(BBMediaPickerModel *)model;
#else
- (instancetype)initWithAssetCollection:(ALAssetsGroup *)assetCollection model:(BBMediaPickerModel *)model;
#endif

@end

NS_ASSUME_NONNULL_END
