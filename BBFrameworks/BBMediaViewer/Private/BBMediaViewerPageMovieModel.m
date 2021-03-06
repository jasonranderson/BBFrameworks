//
//  BBMediaViewerPageMovieModel.m
//  BBFrameworks
//
//  Created by William Towe on 2/29/16.
//  Copyright © 2016 Bion Bilateral, LLC. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "BBMediaViewerPageMovieModel.h"
#import "BBFrameworksMacros.h"
#import "BBMediaViewerModel.h"
#import "BBFoundationFunctions.h"
#import "UIAlertController+BBKitExtensions.h"
#import "BBReachability.h"

#import <ReactiveCocoa/ReactiveCocoa.h>

#import <AVFoundation/AVFoundation.h>

float const BBMediaViewerPageMovieModelRatePlay = 1.0;
float const BBMediaViewerPageMovieModelRatePause = 0.0;
float const BBMediaViewerPageMovieModelRateSlowForward = 0.5;
float const BBMediaViewerPageMovieModelRateFastForward = 2.0;
float const BBMediaViewerPageMovieModelRateSlowReverse = -0.5;
float const BBMediaViewerPageMovieModelRateFastReverse = -2.0;

@interface BBMediaViewerPageMovieModel ()
@property (readwrite,strong,nonatomic) AVPlayer *player;

@property (readwrite,strong,nonatomic) RACSignal *enabledSignal;
@property (readwrite,strong,nonatomic) RACSignal *loadingSignal;

@property (readwrite,strong,nonatomic) RACCommand *playPauseCommand;
@property (readwrite,strong,nonatomic) RACCommand *slowForwardCommand;
@property (readwrite,strong,nonatomic) RACCommand *fastForwardCommand;
@property (readwrite,strong,nonatomic) RACCommand *slowReverseCommand;
@property (readwrite,strong,nonatomic) RACCommand *fastReverseCommand;

- (void)_seekToBeginningIfNecessary;
@end

@implementation BBMediaViewerPageMovieModel

- (instancetype)initWithMedia:(id<BBMediaViewerMedia>)media parentModel:(BBMediaViewerModel *)parentModel {
    if (!(self = [super initWithMedia:media parentModel:parentModel]))
        return nil;
    
    _player = [[AVPlayer alloc] init];
    [_player setActionAtItemEnd:AVPlayerActionAtItemEndPause];
    
    BBWeakify(self);
    
    if ([self.parentModel shouldRequestAssetForMedia:self.media]) {
        AVAsset *asset = [self.parentModel assetForMedia:self.media];
        
        if (asset == nil) {
            [self.parentModel createAssetForMedia:self.media completion:^(AVAsset * _Nullable asset, NSError * _Nullable error) {
                BBStrongify(self);
                BBDispatchMainAsync(^{
                    if (asset == nil) {
                        if (error != nil) {
                            [self.parentModel reportError:error];
                        }
                    }
                    else {
                        [self.player replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithAsset:asset]];
                    }
                });
            }];
        }
        else {
            [_player replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithAsset:asset]];
        }
    }
    else {
        if ([BBReachability reachabilityForInternetConnection].isReachable) {
            [_player replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithURL:self.URL]];
        }
    }
    
    RACSignal *statusSignal = [RACObserve(self.player, status)
                               distinctUntilChanged];
    
    [[[statusSignal
       filter:^BOOL(NSNumber *value) {
           return value.integerValue == AVPlayerStatusFailed;
       }]
      deliverOn:[RACScheduler mainThreadScheduler]]
     subscribeNext:^(id _) {
         BBStrongify(self);
         if (self.player.error != nil) {
             [self.parentModel reportError:self.player.error];
         }
     }];
    
    _enabledSignal =
    [RACSignal combineLatest:@[statusSignal,RACObserve(self.player, currentItem.duration)] reduce:^id(NSNumber *status, NSValue *duration){
        return @(status.integerValue == AVPlayerStatusReadyToPlay && CMTIME_IS_NUMERIC(duration.CMTimeValue));
    }];
    
    _loadingSignal =
    [RACSignal combineLatest:@[RACObserve(self.player, currentItem),statusSignal,RACObserve(self.player, currentItem.duration)] reduce:^id(AVPlayerItem *currentItem, NSNumber *status, NSValue *duration){
        return @(currentItem != nil && status.integerValue == AVPlayerStatusUnknown && !CMTIME_IS_NUMERIC(duration.CMTimeValue));
    }];
    
    _playPauseCommand =
    [[RACCommand alloc] initWithEnabled:_enabledSignal signalBlock:^RACSignal *(id input) {
        BBStrongify(self);
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            if (self.currentPlaybackRate == BBMediaViewerPageMovieModelRatePause) {
                [self play];
            }
            else {
                [self pause];
            }
            
            [subscriber sendCompleted];
            
            return nil;
        }];
    }];
    
    _slowForwardCommand =
    [[RACCommand alloc] initWithEnabled:_enabledSignal signalBlock:^RACSignal *(id input) {
        BBStrongify(self);
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            if (self.currentPlaybackRate == BBMediaViewerPageMovieModelRateSlowForward) {
                [self play];
            }
            else {
                [self slowForward];
            }
            
            [subscriber sendCompleted];
            
            return nil;
        }];
    }];
    
    _fastForwardCommand =
    [[RACCommand alloc] initWithEnabled:_enabledSignal signalBlock:^RACSignal *(id input) {
        BBStrongify(self);
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            if (self.currentPlaybackRate == BBMediaViewerPageMovieModelRateFastForward) {
                [self play];
            }
            else {
                [self fastForward];
            }
            
            [subscriber sendCompleted];
            
            return nil;
        }];
    }];
    
    _slowReverseCommand =
    [[RACCommand alloc] initWithEnabled:_enabledSignal signalBlock:^RACSignal *(id input) {
        BBStrongify(self);
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            if (self.currentPlaybackRate == BBMediaViewerPageMovieModelRateSlowReverse) {
                [self play];
            }
            else {
                [self slowReverse];
            }
            
            [subscriber sendCompleted];
            
            return nil;
        }];
    }];
    
    _fastReverseCommand =
    [[RACCommand alloc] initWithEnabled:_enabledSignal signalBlock:^RACSignal *(id input) {
        BBStrongify(self);
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            if (self.currentPlaybackRate == BBMediaViewerPageMovieModelRateFastReverse) {
                [self play];
            }
            else {
                [self fastReverse];
            }
            
            [subscriber sendCompleted];
            
            return nil;
        }];
    }];
    
    [[[[[RACSignal combineLatest:@[self.didBecomeActiveSignal,_enabledSignal] reduce:^id(id _, NSNumber *enabled){
        return enabled;
    }]
        filter:^BOOL(NSNumber *value) {
            return value.boolValue;
        }]
       take:1]
      deliverOn:[RACScheduler mainThreadScheduler]]
     subscribeNext:^(id _) {
         BBStrongify(self);
         [self play];
     }];
    
    [[self.didBecomeActiveSignal
      deliverOn:[RACScheduler mainThreadScheduler]]
     subscribeNext:^(id _) {
         BBStrongify(self);
         if (self.player.currentItem == nil) {
             [self.parentModel reportError:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorNotConnectedToInternet userInfo:@{NSURLErrorFailingURLErrorKey: self.URL}]];
         }
     }];
    
    [[[[NSNotificationCenter defaultCenter]
       rac_addObserverForName:AVPlayerItemDidPlayToEndTimeNotification object:_player.currentItem]
      takeUntil:[self rac_willDeallocSignal]]
     subscribeNext:^(id _) {
         BBStrongify(self);
         [self _seekToBeginningIfNecessary];
     }];
    
    return self;
}

- (void)play; {
    [self setCurrentPlaybackRate:BBMediaViewerPageMovieModelRatePlay];
}
- (void)slowForward; {
    [self setCurrentPlaybackRate:BBMediaViewerPageMovieModelRateSlowForward];
}
- (void)fastForward; {
    [self setCurrentPlaybackRate:BBMediaViewerPageMovieModelRateFastForward];
}
- (void)slowReverse; {
    [self setCurrentPlaybackRate:BBMediaViewerPageMovieModelRateSlowReverse];
}
- (void)fastReverse; {
    [self setCurrentPlaybackRate:BBMediaViewerPageMovieModelRateFastReverse];
}
- (void)pause; {
    [self setCurrentPlaybackRate:BBMediaViewerPageMovieModelRatePause];
}
- (void)stop; {
    [self pause];
    [self setCurrentPlaybackTime:0.0];
}

- (RACSignal *)periodicTimeObserverWithIntervalSignal:(NSTimeInterval)interval; {
    BBWeakify(self);
    return
    [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        BBStrongify(self);
        id observer = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC) queue:NULL usingBlock:^(CMTime time) {
            [subscriber sendNext:@(CMTimeGetSeconds(time))];
        }];
        
        [subscriber sendNext:@0.0];
        
        return [RACDisposable disposableWithBlock:^{
            [self.player removeTimeObserver:observer];
        }];
    }]
     takeUntil:[self rac_willDeallocSignal]];
}

- (NSTimeInterval)duration {
    CMTime time = self.player.currentItem.duration;
    
    if (CMTIME_IS_NUMERIC(time)) {
        return floor(CMTimeGetSeconds(time));
    }
    else {
        return NAN;
    }
}

@dynamic currentPlaybackRate;
- (float)currentPlaybackRate {
    return self.player.rate;
}
- (void)setCurrentPlaybackRate:(float)currentPlaybackRate {
    if (currentPlaybackRate == BBMediaViewerPageMovieModelRatePause) {
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    }
    else {
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    }
    
    [self.player setRate:currentPlaybackRate];
}
@dynamic currentPlaybackTime;
- (NSTimeInterval)currentPlaybackTime {
    return CMTimeGetSeconds(self.player.currentTime);
}
- (void)setCurrentPlaybackTime:(NSTimeInterval)currentPlaybackTime {
    [self.player seekToTime:CMTimeMakeWithSeconds(currentPlaybackTime, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

- (void)_seekToBeginningIfNecessary; {
    if (CMTIME_IS_NUMERIC(self.player.currentItem.duration) &&
        CMTimeCompare(self.player.currentTime, self.player.currentItem.duration) >= 0) {
        
        [self setCurrentPlaybackTime:0.0];
        [self setCurrentPlaybackRate:0.0];
    }
}

@end
