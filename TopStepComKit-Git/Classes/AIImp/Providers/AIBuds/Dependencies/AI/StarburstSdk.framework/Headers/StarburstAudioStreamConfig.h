//
//  StarburstAudioStreamConfig.h
//  IOT
//
//  Created by ByteDance on 2026/1/29.
//


// StarburstAudioStreamConfig.h
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface StarburstAudioStreamConfig : NSObject

/// "pcm" / "opus" / "aac" ...（由你们协议约定）
/// 建议统一小写
@property (nonatomic, copy) NSString *codec;

/// 通用音频参数（对 pcm 必填；对 opus 视你们服务端要求）
@property (nonatomic, assign) NSInteger sampleRate;      // e.g. 16000
@property (nonatomic, assign) NSInteger channels;        // e.g. 1

/// PCM 专用（codec == "pcm" 时使用）
@property (nonatomic, assign) NSInteger bitsPerSample;   // e.g. 16

@property (nonatomic, assign) NSInteger opusInputPackageSize;
@property (nonatomic, assign) NSInteger opusOutputPackageSize;

@end

NS_ASSUME_NONNULL_END
