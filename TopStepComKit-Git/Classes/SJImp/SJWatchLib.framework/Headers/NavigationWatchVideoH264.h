//
//  MTWatchVideoH264.h
//  SJWatchLib
//
//  Created by t_t on 2023/10/12.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <h264encoder/h264encoder.h>
#import "MTWatchVideoH264.h"

NS_ASSUME_NONNULL_BEGIN

@interface NavigationWatchVideoH264 : NSObject

@property (nonatomic, weak) id<MTWatchVideoH264EncodeResult> delegate;


+ (instancetype)sharedInstance;

- (void)setWatchWidth: (int)width height: (int)height;

- (void)initVideoToolBox: (CGFloat)width height: (CGFloat)height;

- (void)encode:(CMSampleBufferRef )sampleBuffer;
- (void)close;

- (XEncoderResultModel * _Nonnull)xEncodeNav:(NSData* )nsData width: (int)width height: (int)height;

@end

NS_ASSUME_NONNULL_END
