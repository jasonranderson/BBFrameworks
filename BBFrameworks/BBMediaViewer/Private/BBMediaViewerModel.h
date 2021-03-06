//
//  BBMediaViewerModel.h
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

#import <Foundation/Foundation.h>
#import "BBMediaViewerModelDataSource.h"
#import "BBMediaViewerModelDelegate.h"
#import "BBMediaViewerDefines.h"

NS_ASSUME_NONNULL_BEGIN

@class BBMediaViewerTheme,BBMediaViewerPageModel;
@class RACCommand;

@interface BBMediaViewerModel : NSObject

@property (weak,nonatomic,nullable) id<BBMediaViewerModelDataSource> dataSource;
@property (weak,nonatomic,nullable) id<BBMediaViewerModelDelegate> delegate;

@property (strong,nonatomic,null_resettable) BBMediaViewerTheme *theme;

@property (readonly,copy,nonatomic) NSString *title;

@property (readonly,strong,nonatomic) BBMediaViewerPageModel *selectedPageModel;

@property (readonly,strong,nonatomic) RACCommand *doneCommand;
@property (readonly,strong,nonatomic) RACCommand *actionCommand;

- (NSInteger)numberOfMedia;
- (id<BBMediaViewerMedia>)mediaAtIndex:(NSInteger)index;
- (NSInteger)indexOfMedia:(id<BBMediaViewerMedia>)media;

- (void)reportError:(NSError *)error;

- (NSURL *)fileURLForMedia:(id<BBMediaViewerMedia>)media;
- (void)downloadMedia:(id<BBMediaViewerMedia>)media completion:(BBMediaViewerDownloadCompletionBlock)completion;

- (BOOL)shouldRequestAssetForMedia:(id<BBMediaViewerMedia>)media;
- (nullable AVAsset *)assetForMedia:(id<BBMediaViewerMedia>)media;
- (void)createAssetForMedia:(id<BBMediaViewerMedia>)media completion:(BBMediaViewerCreateAssetCompletionBlock)completion;

- (void)selectPageModel:(BBMediaViewerPageModel *)pageModel;
- (void)selectPageModel:(BBMediaViewerPageModel *)pageModel notifyDelegate:(BOOL)notifyDelegate;

@end

NS_ASSUME_NONNULL_END
