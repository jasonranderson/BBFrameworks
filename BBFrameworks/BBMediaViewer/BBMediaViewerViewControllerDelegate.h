//
//  BBMediaViewerViewControllerDelegate.h
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
#import "BBMediaViewerDefines.h"

NS_ASSUME_NONNULL_BEGIN

@class BBMediaViewerViewController;

/**
 Protocol describing the delegate of the media viewer.
 */
@protocol BBMediaViewerViewControllerDelegate <NSObject>
@required
/**
 Called when the user taps the done bar button item. The receiver should dismiss the media viewer or pop the containing navigation controller.
 
 @param viewController The media viewer that sent the message
 */
- (void)mediaViewerViewControllerDidFinish:(BBMediaViewerViewController *)viewController;
@optional
/**
 Called when the user swipes left or right to display another media object.
 
 @param viewController The media viewer that sent the message
 @param media The media object that was selected
 */
- (void)mediaViewerViewController:(BBMediaViewerViewController *)viewController didSelectMedia:(id<BBMediaViewerMedia>)media;

/**
 Called for certain media types when the originally provided media object represents a remote resource. The delegate should return the file URL for the media object.
 
 @param viewController The media viewer that sent the message
 @param media The media object for which to provide a file URL
 @return The file URL
 */
- (NSURL *)mediaViewerViewController:(BBMediaViewerViewController *)viewController fileURLForMedia:(id<BBMediaViewerMedia>)media;
/**
 Called after `mediaViewerViewController:fileURLForMedia:` has been called and returns a file URL for which the resource does not exist. The delegate should download the remote resource and invoke the provided completion block when the download completes.
 
 @param viewController The media viewer that sent the message
 @param media The media to download
 @param completion The completion block to invoke when the download completes
 */
- (void)mediaViewerViewController:(BBMediaViewerViewController *)viewController downloadMedia:(id<BBMediaViewerMedia>)media completion:(BBMediaViewerDownloadCompletionBlock)completion;

/**
 Called when the receiver is presented or dismissed modally to determine the frame from which to zoom to or from. The delegate should return a frame either in screen coordinates and leave `sourceView` nil, or set `sourceView` appropriately and return a frame in its coordinate space.
 
 @param viewController The media viewer that sent the message
 @param media The current selected media object
 @param sourceView Optionally, the source view defining the coordinate space for the returned frame
 @return The frame to transition to or from
 */
- (CGRect)mediaViewerViewController:(BBMediaViewerViewController *)viewController frameForMedia:(id<BBMediaViewerMedia>)media inSourceView:(UIView * _Nullable * _Nonnull)sourceView;
/**
 Called when the receiver is presented or dismissed modally to determine the transition view to snapshot during the transition animation. The snapshot will be cross faded with the initially selected media view controller. Optionally, `contentRect` can be set to frame within the returned view that should comprise the snapshot.
 
 @param viewController The media viewer that sent the message
 @param media The current selected media object
 @param contentRect Optionally, the content rect of the returned view to snapshot
 @return The view to snapshot during the transition animation
 */
- (UIView *)mediaViewerViewController:(BBMediaViewerViewController *)viewController transitionViewForMedia:(id<BBMediaViewerMedia>)media contentRect:(CGRect *)contentRect;
@end

NS_ASSUME_NONNULL_END
