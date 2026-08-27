////
////  Startburst.h
////  StarburstSdk
////
////  Created by liangshi on 2025/6/11.
////
//
#import <Foundation/Foundation.h>

@interface StartburstDecoderConfig : NSObject
@property (nonatomic, assign)NSInteger sampleRate;/// 采样率
@property (nonatomic, assign)NSInteger numChannels;/// 声道数
@property (nonatomic, assign)NSInteger encodedFrameLength;/// 编码后每帧字节数
@property (nonatomic, assign)NSInteger originalSamplesPerFrame;/// 编码前每帧采样点数
@property (nonatomic, assign)NSInteger bitDepth;/// 采样位深（16/24/32）
@end


