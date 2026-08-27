//
//  ASRLongFileIntlRequestBody.h
//  MagicHelper
//
//  Created by ymz on 2025/12/16.
//

#import <Foundation/Foundation.h>
#import "ASRIntlRequestBody.h"

NS_ASSUME_NONNULL_BEGIN

@interface ASRLongFileIntlRequestBody : NSObject

/// 请求id，有默认值，调用方也可自定,该值也会在结果回调中返回
@property (nonatomic, strong) NSString *qid;

/// 音频对应语种 支持的语种见文档
@property (nonatomic, strong) NSString *language;

/// 需要翻译成的语种
@property (nonatomic, strong, nullable) NSString *targetLanguage;

/// 音频文件路径
/// 音频数据长度小于 2 小时且大小小于 300 MB
@property (nonatomic, strong, nullable) NSString *path;

/// 文件数据
@property (nonatomic, strong, nullable) NSData *data;

/// 音频格式
@property (nonatomic, assign) MGAudioEncodingFormat encodingFormat;

/// 最大识别人数， 默认2,范围2~20
@property (nonatomic, assign) NSInteger maxSpeaker;
@end

NS_ASSUME_NONNULL_END
