//
//  TSAIChatRoundModel.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/10/13.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIChatRoundModel.h"

#import <TopStepAIKit/TopStepAIKit.h>

@interface TSAIChatRoundModel ()

@property (nonatomic, copy, readwrite) NSString *roundId;
@property (nonatomic, strong, readwrite) NSMutableArray<TSAIChatIntent *> *intents;
@property (nonatomic, strong, readwrite) NSMutableData *answerPCM;
@property (nonatomic, strong, readwrite) NSMutableData *questionPCM;

@end

@implementation TSAIChatRoundModel

#pragma mark - 公开方法

+ (instancetype)roundWithSource:(TSAIChatRoundSource)source {
    TSAIChatRoundModel *round = [[TSAIChatRoundModel alloc] init];
    round.source = source;
    return round;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _roundId = [NSUUID UUID].UUIDString;
        _state = TSAIChatRoundStateRecording;
        _intents = [NSMutableArray array];
        _answerPCM = [NSMutableData data];
        _questionPCM = [NSMutableData data];
        _sdkRoundIndex = -1;
    }
    return self;
}

- (BOOL)isInProgress {
    return self.state != TSAIChatRoundStateDone && self.state != TSAIChatRoundStateError;
}

/** 保留错误对象和原问题，正文不再默认使用拾音提示 */
- (void)failWithError:(NSError *)error {
    self.error = error;
    self.errorText = [self.class errorTitleForError:error];
    self.errorBodyText = [self.class errorBodyForError:error];
    self.state = TSAIChatRoundStateError;
}

/** 按错误码分类，不依赖厂商英文描述匹配 */
+ (NSString *)errorTitleForError:(NSError *)error {
    if ([error.domain isEqualToString:TSAIErrorDomain]) {
        switch (error.code) {
            case TSAIErrorCodeAuthorizationRequired:
            case TSAIErrorCodeAuthorizationRejected: return @"AI 未鉴权";
            case TSAIErrorCodeContextInactive: return @"AI 尚未就绪";
            case TSAIErrorCodeProviderUnavailable:
            case TSAIErrorCodeServiceTemporarilyUnavailable: return @"AI 服务暂不可用";
            case TSAIErrorCodeNetworkUnavailable: return @"网络连接异常";
            case TSAIErrorCodeAudioRouteUnavailable:
            case TSAIErrorCodeAudioRouteMismatch: return @"语音通道不可用";
            case TSAIErrorCodeRateLimited: return @"请求过于频繁";
            case TSAIErrorCodeContentRejected: return @"问题未被受理";
            case TSAIErrorCodeTimeout: return @"请求超时";
            case TSAIErrorCodeIntentActionRequired: return @"需要补充信息";
            case TSAIErrorCodeInvalidResponse: return @"AI 响应异常";
            default: break;
        }
    }
    return @"请求失败";
}

/** 优先展示原始恢复建议，已知错误给出对应操作 */
+ (NSString *)errorBodyForError:(NSError *)error {
    if (error.localizedRecoverySuggestion.length > 0) {
        return error.localizedRecoverySuggestion;
    }
    if ([error.domain isEqualToString:TSAIErrorDomain]) {
        switch (error.code) {
            case TSAIErrorCodeAuthorizationRequired: return @"AI 尚未完成鉴权，请完成鉴权后重试。";
            case TSAIErrorCodeAuthorizationRejected: return @"AI 鉴权失败，请重新鉴权后重试。";
            case TSAIErrorCodeContextInactive: return @"请等待 AI 初始化完成后重试。";
            case TSAIErrorCodeNetworkUnavailable: return @"请检查网络连接后重试，原问题已保留。";
            case TSAIErrorCodeAudioRouteUnavailable:
            case TSAIErrorCodeAudioRouteMismatch: return @"请在设置中检查拾音和语音播放通道后重试。";
            case TSAIErrorCodeRateLimited: return @"请稍后重试，原问题已保留。";
            case TSAIErrorCodeTimeout: return @"AI 未能及时完成请求，请稍后重试。";
            case TSAIErrorCodeIntentActionRequired: return @"请提供所需信息后重试。";
            default: break;
        }
    }
    return error.localizedDescription.length > 0 ? error.localizedDescription : @"请求失败，请稍后重试。";
}

@end
