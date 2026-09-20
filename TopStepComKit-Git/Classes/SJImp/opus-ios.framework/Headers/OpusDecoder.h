#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OpusAudioDecoder : NSObject

// 创建解码器
- (instancetype)initWithSampleRate:(int)sampleRate channels:(int)channels;

// 解码音频数据
- (int)decodeOpusData:(NSData *)opusData 
              toPCMData:(NSMutableData *)pcmData
             frameSize:(int)frameSize;

// 销毁解码器
- (void)destroyDecoder;

@end

NS_ASSUME_NONNULL_END 