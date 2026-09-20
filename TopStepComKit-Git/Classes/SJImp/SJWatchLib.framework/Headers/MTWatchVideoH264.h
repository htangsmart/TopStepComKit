//
//  MTWatchVideoH264.h
//  SJWatchLib
//
//  Created by t_t on 2023/10/12.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <h264encoder/h264encoder.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, CustomDeviceOrientation) {
    CustomDeviceOrientationPortrait,
    CustomDeviceOrientationPortraitUpsideDown,
    CustomDeviceOrientationLandscapeLeft,
    CustomDeviceOrientationLandscapeRight,
    CustomDeviceOrientationUnknown
};

@interface DeviceOrientationManager : NSObject

@property (nonatomic, assign) CustomDeviceOrientation currentOrientation;

+ (instancetype)sharedManager;

- (void)startDeviceMotionUpdates;

- (void)stopDeviceMotionUpdates;

@end

@protocol MTWatchVideoH264EncodeResult <NSObject>

- (void)encodeResult:(NSData *)data isKeyFrame:(BOOL)isKeyFrame;

@end

@interface MTWatchVideoH264 : NSObject

@property (nonatomic, weak) id<MTWatchVideoH264EncodeResult> delegate;

+ (instancetype)sharedInstance;

- (void)setWatchWidth: (int)width height: (int)height;

- (void)initVideoToolBox: (CGFloat)width height: (CGFloat)height;

- (void)encode:(CMSampleBufferRef )sampleBuffer;

- (XEncoderResultModel * _Nonnull)xEncode:(CMSampleBufferRef )sampleBuffer isBack:(bool)isBack;

@end

NS_ASSUME_NONNULL_END
