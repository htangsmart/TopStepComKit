//
//  StarburstAsrModel.h
//  StarburstSdk
//
//  Created by incar on 2024/9/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 说话人分离结果（单段）
@interface StarburstSpeakerSegment : NSObject
@property (nonatomic, copy, nullable) NSString *speakerId;     /// 说话人ID（字符串，如 "1"）
@property (nonatomic, assign) NSInteger startTime;             /// 起始时间(ms)
@property (nonatomic, assign) NSInteger endTime;               /// 结束时间(ms)
@property (nonatomic, copy, nullable) NSString *text;          /// 该段文本
@property (nonatomic, assign) NSInteger definiteIndex;         /// 该段确定序号
/// 工厂方法
+ (instancetype)modelWith:(NSDictionary *)dict;
@end

/// 翻译结果
@interface StarburstTranslateResult : NSObject
@property (nonatomic, copy, nullable) NSString *text;  /// 语音识别后翻译的结果片段
@property (nonatomic, assign) BOOL definite;           /// 当前翻译片段是否确定
@property (nonatomic, assign) int definiteIndex;       /// 已翻译片段序号
/// 工厂方法
+ (instancetype)modelWith:(NSDictionary *)dict;
@end

/// tts音频流
@interface StarburstAsrTtsResult : NSObject
@property (nonatomic, assign) NSInteger index;            /// 音频数据片段的序号
@property (nonatomic, assign) NSInteger translateIndex;   /// 翻译的序号
@property (nonatomic, copy, nullable) NSString *streamPiece; /// 音频流（Base64/文本）
+ (instancetype)modelWith:(NSDictionary *)dict;
@end

/// 识别结果
@interface StarburstAsrModel : NSObject
@property (nonatomic, assign) NSInteger channel;            /// 0非立体声，1左声道，2右声道
@property (nonatomic, assign) NSInteger code;               /// 状态码
@property (nonatomic, copy, nullable) NSString *msg;        /// 提示语
@property (nonatomic, copy, nullable) NSString *requestId;  /// 请求id
@property (nonatomic, copy, nullable) NSString *textResult; /// 语音识别结果片段内容
@property (nonatomic, assign) NSInteger sequence;           /// 响应的编号
@property (nonatomic, assign) BOOL definite;                /// 语音识别结果片段是否已确定，后序不会有变化
@property (nonatomic, assign) NSInteger definiteIndex;      /// 已确定的识别结果序列号
@property (nonatomic, assign) BOOL isLastPackage;           /// 是否为最后一包，后续没有数据(包括asr、tts、翻译结果)

@property (nonatomic, strong, nullable) StarburstTranslateResult *translateResult; /// 翻译结果
@property (nonatomic, strong, nullable) StarburstAsrTtsResult *ttsResult;          /// tts音频流

@property (nonatomic, copy, nullable) NSArray<StarburstSpeakerSegment *> *speakerResult; /// 说话人分离结果数组

+ (instancetype)modelWith:(NSDictionary *)dict;
@end

NS_ASSUME_NONNULL_END
