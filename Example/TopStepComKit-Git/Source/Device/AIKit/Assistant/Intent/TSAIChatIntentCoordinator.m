//
//  TSAIChatIntentCoordinator.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/10/14.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIChatIntentCoordinator.h"

#import <TopStepAIKit/TopStepAIKit.h>
#import <TopStepComKit/TopStepComKit.h>

#import "TSAIChatDeviceSessionCoordinator.h"
#import "TSAIChatLocationService.h"
#import "TSAIChatRoundModel.h"

/// 重发文本模板：位置 + 原问题（与 aibuds Flutter 的 location_replay_question 一致）
static NSString *const kTSAIChatLocationReplayFormat = @"我现在的位置在%@，%@";
/// initialPrompt 中的位置段（文案沿用 aibuds `getCustomPrompt`）
static NSString *const kTSAIChatLocationPromptFormat =
    @"用户当前位置是%@。响应所有需求时，若用户明确指定位置，使用该位置作为核心定位依据，完全忽略IP自动识别的位置信息。";
/// 执行不了的指令意图：等迟到回答的宽限时长（秒）。StarBurst 命中指令意图后只回 prefetchHit，不再回答
static NSTimeInterval const kTSAIChatUnsupportedIntentGraceInterval = 1.0;
/// 执行不了的指令意图：状态行文案
static NSString *const kTSAIChatUnsupportedIntentReason = @"暂不支持";
/// 执行不了的指令意图：提示文案模板（参数为指令描述，如「播放《西安人的歌》」）
static NSString *const kTSAIChatUnsupportedIntentNoticeFormat = @"已识别：%@ · 当前设备暂不支持";

@interface TSAIChatIntentCoordinator ()

// 正在处理定位意图的轮次（互斥）
@property (nonatomic, strong, nullable) TSAIChatRoundModel *handlingRound;
// 正在处理的意图
@property (nonatomic, strong, nullable) TSAIChatIntent *handlingIntent;
// 等待收口的「暂不支持」指令意图所在轮次（同一时间只有一个）
@property (nonatomic, strong, nullable) TSAIChatRoundModel *unsupportedRound;
// 等待收口的「暂不支持」指令意图
@property (nonatomic, strong, nullable) TSAIChatIntent *unsupportedIntent;
// 收口令牌：宽限到期时比对，已取消 / 已替换的收口不再触发
@property (nonatomic, copy, nullable) NSString *unsupportedToken;

@end

@implementation TSAIChatIntentCoordinator

#pragma mark - 生命周期

- (instancetype)initWithSessionCoordinator:(TSAIChatDeviceSessionCoordinator *)sessionCoordinator {
    self = [super init];
    if (self) {
        _sessionCoordinator = sessionCoordinator;
    }
    return self;
}

#pragma mark - 公开方法

/// 分发意图：定位意图走定位流程，执行不了的指令意图收口本轮，其它只记录展示
- (void)handleIntent:(TSAIChatIntent *)intent round:(TSAIChatRoundModel *)round {
    if (!intent || !round) {
        return;
    }
    TSLog(@"[TSAIChatIntentCoordinator] intent: type=%ld, intentId=%@, requiresClientAction=%d, round=%@",
          (long)intent.type, intent.intentId, intent.requiresClientAction, round.roundId);
    if (intent.requiresClientAction || intent.type == TSAIChatIntentTypeLocationQuery) {
        [self handleLocationIntent:intent round:round];
        return;
    }
    if (intent.type == TSAIChatIntentTypeDialogExit) {
        [self handleDialogExitIntent:intent round:round];
        return;
    }
    if ([self isUnsupportedCommandIntent:intent]) {
        [self handleUnsupportedIntent:intent round:round];
        return;
    }
    // 未知意图：仅展示
    if (round.intentStatus == TSAIChatRoundIntentStatusNone) {
        [self.delegate intentCoordinator:self didUpdateRound:round];
    }
}

/// 本轮收到回答：清除处理中状态；待收口的「暂不支持」指令保留回答
- (void)roundDidReceiveAnswer:(TSAIChatRoundModel *)round {
    if (!round) {
        return;
    }
    if (self.unsupportedRound == round) {
        // 云端对该指令给了回答：保留回答、不再收口，意图仍标为暂不支持
        TSLog(@"[TSAIChatIntentCoordinator] unsupported intent answered, keep answer: round=%@", round.roundId);
        [self clearUnsupportedIntent];
        [self.delegate intentCoordinator:self didUpdateRound:round];
        return;
    }
    if (round.intentStatus != TSAIChatRoundIntentStatusPending) {
        return;
    }
    round.intentStatus = TSAIChatRoundIntentStatusExecuted;
    round.statusText = nil;
    if (self.handlingRound == round) {
        TSLog(@"[TSAIChatIntentCoordinator] location intent answered: round=%@", round.roundId);
        self.handlingRound = nil;
        self.handlingIntent = nil;
    }
    [self.delegate intentCoordinator:self didUpdateRound:round];
}

/// SDK 等待超时：按失败收口
- (void)handleIntentActionTimedOutForRound:(TSAIChatRoundModel *)round {
    if (!round) {
        return;
    }
    TSLog(@"[TSAIChatIntentCoordinator] intent action timed out: round=%@", round.roundId);
    [self failRound:round
             reason:@"等待位置信息超时"
           bodyText:@"补充位置后仍没有收到回答，请稍后再试。"
        actionTitle:nil
             action:nil
        endsSession:NO];
}

/// 是否正在处理定位意图
- (BOOL)isHandlingLocationIntent {
    return self.handlingRound != nil;
}

/// 静默预热：已有权限才取定位，不弹框
- (void)prepareLocationContextSilently {
    TSAIChatLocationService *service = [TSAIChatLocationService sharedService];
    if (!service.isAuthorized) {
        TSLog(@"[TSAIChatIntentCoordinator] location warm-up skipped: not authorized");
        return;
    }
    __weak typeof(self) weakSelf = self;
    [service fetchLocationAllowingPrompt:NO completion:^(CLLocation *location, NSString *placeName, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        if (!location) {
            TSLog(@"[TSAIChatIntentCoordinator] location warm-up failed: %@", error);
            return;
        }
        TSLog(@"[TSAIChatIntentCoordinator] location warm-up done: place=%@", placeName);
        [strongSelf.sessionCoordinator updateCurrentLocationFromApp:location];
    }];
}

/// 追加位置段到 initialPrompt
+ (nullable NSString *)initialPromptByAppendingLocationToPrompt:(nullable NSString *)prompt {
    NSString *placeName = [TSAIChatLocationService sharedService].lastPlaceName;
    if (placeName.length == 0) {
        return prompt;
    }
    NSString *segment = [NSString stringWithFormat:kTSAIChatLocationPromptFormat, placeName];
    if (prompt.length == 0) {
        return segment;
    }
    if ([prompt containsString:segment]) {
        return prompt;
    }
    return [NSString stringWithFormat:@"%@\n%@", prompt, segment];
}

/// 重置（会话结束 / 离开页面）：只清状态，不再回调 UI
- (void)reset {
    self.handlingRound = nil;
    self.handlingIntent = nil;
    [self clearUnsupportedIntent];
}

#pragma mark - 私有方法 - 执行不了的指令意图

/// 是否为本 Demo / 当前设备执行不了的指令意图（定位、退出对话、未知意图不在此列）
- (BOOL)isUnsupportedCommandIntent:(TSAIChatIntent *)intent {
    switch (intent.type) {
        case TSAIChatIntentTypePhotoCapture:
        case TSAIChatIntentTypePhotoUnderstand:
        case TSAIChatIntentTypeVideoStart:
        case TSAIChatIntentTypeVideoStop:
        case TSAIChatIntentTypeAudioRecord:
        case TSAIChatIntentTypeVolumeUp:
        case TSAIChatIntentTypeVolumeDown:
        case TSAIChatIntentTypeVolumeSet:
        case TSAIChatIntentTypeMusicPlay:
        case TSAIChatIntentTypeMusicStop:
        case TSAIChatIntentTypeMusicNext:
        case TSAIChatIntentTypeMusicPrev:
        case TSAIChatIntentTypeCallAnswer:
        case TSAIChatIntentTypeCallDecline:
        case TSAIChatIntentTypeCallRecord:
        case TSAIChatIntentTypeDeviceBatteryQuery:
        case TSAIChatIntentTypeDevicePowerOff:
        case TSAIChatIntentTypeAgentSwitch:
        case TSAIChatIntentTypeVoiceClone:
        case TSAIChatIntentTypeFindPhone:
        case TSAIChatIntentTypeStopFindPhone:
            return YES;
        default:
            return NO;
    }
}

/// 退出对话（dialog.exit）：本轮记为已执行，交给页面退出 AI 对话（SDK 会以 DialogExit 结束会话）
- (void)handleDialogExitIntent:(TSAIChatIntent *)intent round:(TSAIChatRoundModel *)round {
    if (self.unsupportedRound == round) {
        // 同一轮先前安排的「暂不支持」收口作废
        [self clearUnsupportedIntent];
    }
    if (self.handlingRound == round) {
        self.handlingRound = nil;
        self.handlingIntent = nil;
    }
    round.intentStatus = TSAIChatRoundIntentStatusExecuted;
    round.statusText = nil;
    TSLog(@"[TSAIChatIntentCoordinator] dialog exit intent: intentId=%@, round=%@", intent.intentId, round.roundId);
    [self.delegate intentCoordinator:self didRequestExitForRound:round];
}

/// 执行不了的指令意图：已有回答只标记；否则宽限片刻等迟到的回答，仍没有就收口本轮
- (void)handleUnsupportedIntent:(TSAIChatIntent *)intent round:(TSAIChatRoundModel *)round {
    if (round.intentStatus == TSAIChatRoundIntentStatusPending) {
        // 本轮正在补充定位，由定位流程收口
        TSLog(@"[TSAIChatIntentCoordinator] unsupported intent ignored: round is handling location, round=%@", round.roundId);
        return;
    }
    if (self.unsupportedRound == round) {
        // 同一轮重复 / 多个指令意图：沿用已安排的收口
        return;
    }
    round.intentStatus = TSAIChatRoundIntentStatusUnsupported;
    round.statusText = nil;
    if (round.answer.length > 0 || ![round isInProgress]) {
        TSLog(@"[TSAIChatIntentCoordinator] unsupported intent marked only: intentId=%@, hasAnswer=%d, round=%@",
              intent.intentId, round.answer.length > 0, round.roundId);
        [self.delegate intentCoordinator:self didUpdateRound:round];
        return;
    }
    // 上一个还在宽限期的轮次（畅聊里已进入下一轮）先收口，再安排本轮
    [self closeUnsupportedRoundIfNeeded];
    NSString *token = [NSUUID UUID].UUIDString;
    self.unsupportedRound = round;
    self.unsupportedIntent = intent;
    self.unsupportedToken = token;
    TSLog(@"[TSAIChatIntentCoordinator] unsupported intent: intentId=%@, round=%@, grace=%.1fs",
          intent.intentId, round.roundId, kTSAIChatUnsupportedIntentGraceInterval);
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kTSAIChatUnsupportedIntentGraceInterval * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf || ![strongSelf.unsupportedToken isEqualToString:token]) {
            return;
        }
        [strongSelf closeUnsupportedRoundIfNeeded];
    });
}

/// 收口待处理的「暂不支持」轮次：仍在进行且没有回答 → 交给 UI 立即结束本轮
- (void)closeUnsupportedRoundIfNeeded {
    TSAIChatRoundModel *round = self.unsupportedRound;
    TSAIChatIntent *intent = self.unsupportedIntent;
    [self clearUnsupportedIntent];
    if (!round || !intent) {
        return;
    }
    if (![round isInProgress] || round.answer.length > 0) {
        // 宽限期内本轮已被别的路径结束 / 已有回答：只刷新意图标签
        [self.delegate intentCoordinator:self didUpdateRound:round];
        return;
    }
    NSString *notice = [NSString stringWithFormat:kTSAIChatUnsupportedIntentNoticeFormat,
                        [self actionTextForIntent:intent]];
    BOOL endsSession = [self isSingleRoundSession];
    TSLog(@"[TSAIChatIntentCoordinator] unsupported intent closed: intentId=%@, round=%@, endsSession=%d, notice=%@",
          intent.intentId, round.roundId, endsSession, notice);
    [self.delegate intentCoordinator:self
            didCloseUnsupportedRound:round
                              reason:kTSAIChatUnsupportedIntentReason
                              notice:notice
                         endsSession:endsSession];
}

/// 清除待收口状态（令牌置空后，已排队的宽限回调自然失效）
- (void)clearUnsupportedIntent {
    self.unsupportedRound = nil;
    self.unsupportedIntent = nil;
    self.unsupportedToken = nil;
}

/// 指令描述（用于「已识别：{指令}」）
- (NSString *)actionTextForIntent:(TSAIChatIntent *)intent {
    NSDictionary *slots = [self slotsForIntent:intent];
    switch (intent.type) {
        case TSAIChatIntentTypePhotoCapture:       return @"拍照";
        case TSAIChatIntentTypePhotoUnderstand:    return @"拍照识图";
        case TSAIChatIntentTypeVideoStart:         return @"开始录像";
        case TSAIChatIntentTypeVideoStop:          return @"停止录像";
        case TSAIChatIntentTypeAudioRecord:        return @"开始录音";
        case TSAIChatIntentTypeVolumeUp:           return @"调高音量";
        case TSAIChatIntentTypeVolumeDown:         return @"调低音量";
        case TSAIChatIntentTypeVolumeSet: {
            NSString *level = [self slotStringInSlots:slots keys:@[@"volume", @"level", @"value"]];
            if (level.length == 0 && slots.count == 0) {
                // 纯字符串槽位，如「音量调到 80」中的「80」
                level = [intent.value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            }
            return level.length > 0 ? [NSString stringWithFormat:@"把音量调到 %@", level] : @"设置音量";
        }
        case TSAIChatIntentTypeMusicPlay:          return [self musicPlayActionTextWithSlots:slots];
        case TSAIChatIntentTypeMusicStop:          return @"停止播放音乐";
        case TSAIChatIntentTypeMusicNext:          return @"播放下一首";
        case TSAIChatIntentTypeMusicPrev:          return @"播放上一首";
        case TSAIChatIntentTypeCallAnswer:         return @"接听电话";
        case TSAIChatIntentTypeCallDecline:        return @"拒接电话";
        case TSAIChatIntentTypeCallRecord:         return @"通话录音";
        case TSAIChatIntentTypeDeviceBatteryQuery: return @"查询设备电量";
        case TSAIChatIntentTypeDevicePowerOff:     return @"关机";
        case TSAIChatIntentTypeAgentSwitch:        return @"切换 AI 角色";
        case TSAIChatIntentTypeVoiceClone:         return @"声音克隆";
        case TSAIChatIntentTypeFindPhone:          return @"查找手机";
        case TSAIChatIntentTypeStopFindPhone:      return @"停止查找手机";
        default:
            return intent.intentId.length > 0 ? intent.intentId : @"指令";
    }
}

/// 播放音乐的描述：歌名 > 专辑 > 歌手 > 风格 / 场景
- (NSString *)musicPlayActionTextWithSlots:(nullable NSDictionary *)slots {
    NSString *song = [self slotStringInSlots:slots keys:@[@"song"]];
    NSString *singer = [self slotStringInSlots:slots keys:@[@"singer"]];
    if (song.length > 0) {
        return singer.length > 0
            ? [NSString stringWithFormat:@"播放%@的《%@》", singer, song]
            : [NSString stringWithFormat:@"播放《%@》", song];
    }
    NSString *album = [self slotStringInSlots:slots keys:@[@"album"]];
    if (album.length > 0) {
        return [NSString stringWithFormat:@"播放专辑《%@》", album];
    }
    if (singer.length > 0) {
        return [NSString stringWithFormat:@"播放%@的歌", singer];
    }
    NSString *style = [self slotStringInSlots:slots keys:@[@"style", @"scene"]];
    if (style.length > 0) {
        return [NSString stringWithFormat:@"播放音乐（%@）", style];
    }
    return @"播放音乐";
}

/// 槽位字典：优先 valueDictionary，否则尝试把 value 当 JSON 解析
- (nullable NSDictionary *)slotsForIntent:(TSAIChatIntent *)intent {
    if (intent.valueDictionary.count > 0) {
        return intent.valueDictionary;
    }
    NSData *data = [intent.value dataUsingEncoding:NSUTF8StringEncoding];
    if (data.length == 0) {
        return nil;
    }
    id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    return [object isKindOfClass:[NSDictionary class]] ? object : nil;
}

/// 按顺序取第一个非空槽位文本
- (nullable NSString *)slotStringInSlots:(nullable NSDictionary *)slots keys:(NSArray<NSString *> *)keys {
    for (NSString *key in keys) {
        id value = slots[key];
        NSString *text = nil;
        if ([value isKindOfClass:[NSString class]]) {
            text = value;
        } else if ([value isKindOfClass:[NSNumber class]]) {
            text = [(NSNumber *)value stringValue];
        }
        text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (text.length > 0) {
            return text;
        }
    }
    return nil;
}

#pragma mark - 私有方法 - 定位意图

/// 定位意图：互斥 → 取定位（允许弹权限框）→ 下发 SDK → 重发
- (void)handleLocationIntent:(TSAIChatIntent *)intent round:(TSAIChatRoundModel *)round {
    if (self.handlingRound) {
        // 同一轮重复意图 / 重发后再次命中：不再递归处理，交给 SDK 的 intentActionTimeout
        TSLog(@"[TSAIChatIntentCoordinator] location intent ignored: already handling round=%@",
              self.handlingRound.roundId);
        return;
    }
    if (![round isInProgress]) {
        TSLog(@"[TSAIChatIntentCoordinator] location intent ignored: round not in progress");
        return;
    }
    self.handlingRound = round;
    self.handlingIntent = intent;
    round.intentStatus = TSAIChatRoundIntentStatusPending;
    round.statusText = @"正在获取位置…";
    [self.delegate intentCoordinator:self didUpdateRound:round];

    __weak typeof(self) weakSelf = self;
    [[TSAIChatLocationService sharedService] fetchLocationAllowingPrompt:YES
                                                               completion:^(CLLocation *location, NSString *placeName, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf || strongSelf.handlingRound != round) {
            return;
        }
        if (!location || placeName.length == 0) {
            [strongSelf handleLocationFailure:error round:round];
            return;
        }
        [strongSelf replayRound:round intent:intent location:location placeName:placeName];
    }];
}

/// 拿到定位：先交给 SDK，再以「位置 + 原问题」重发本轮
- (void)replayRound:(TSAIChatRoundModel *)round
             intent:(TSAIChatIntent *)intent
           location:(CLLocation *)location
          placeName:(NSString *)placeName {
    [self.sessionCoordinator updateCurrentLocationFromApp:location];
    NSString *question = round.question.length > 0 ? round.question : intent.query;
    if (question.length == 0) {
        [self failRound:round reason:@"没有可重发的问题" bodyText:@"没有识别到问题内容，请再问一次。"
            actionTitle:nil action:nil endsSession:[self isSingleRoundSession]];
        return;
    }
    NSString *text = [NSString stringWithFormat:kTSAIChatLocationReplayFormat, placeName, question];
    BOOL accepted = [self.sessionCoordinator replayPendingIntentRoundFromApp:text];
    TSLog(@"[TSAIChatIntentCoordinator] replay with location: place=%@, accepted=%d", placeName, accepted);
    if (!accepted) {
        [self failRound:round reason:@"补充位置失败" bodyText:@"会话已结束或暂不支持补充位置，请再问一次。"
            actionTitle:nil action:nil endsSession:[self isSingleRoundSession]];
        return;
    }
    round.statusText = [NSString stringWithFormat:@"已补充位置（%@），等待回答…", placeName];
    [self.delegate intentCoordinator:self didUpdateRound:round];
}

/// 定位失败：按错误码给出可操作的提示
- (void)handleLocationFailure:(nullable NSError *)error round:(TSAIChatRoundModel *)round {
    BOOL endsSession = [self isSingleRoundSession];
    void (^openSettings)(void) = ^{
        [[TSAIChatLocationService sharedService] openSystemSettings];
    };
    if ([error.domain isEqualToString:TSAIChatLocationErrorDomain]) {
        switch (error.code) {
            case TSAIChatLocationErrorCodePermissionDenied:
            case TSAIChatLocationErrorCodePermissionNotDetermined:
                [self failRound:round reason:@"需要定位权限"
                       bodyText:@"这个问题需要你的位置才能回答。请在设置中允许「定位」后再试。"
                    actionTitle:@"去设置" action:openSettings endsSession:endsSession];
                return;
            case TSAIChatLocationErrorCodeServicesDisabled:
                [self failRound:round reason:@"定位服务已关闭"
                       bodyText:@"这个问题需要你的位置才能回答。请先在系统设置中打开定位服务。"
                    actionTitle:@"去设置" action:openSettings endsSession:endsSession];
                return;
            default:
                break;
        }
    }
    [self failRound:round reason:@"获取位置失败"
           bodyText:@"暂时拿不到你的位置，请稍后再问一次。"
        actionTitle:nil action:nil endsSession:endsSession];
}

/// 统一失败收口
- (void)failRound:(TSAIChatRoundModel *)round
           reason:(NSString *)reason
         bodyText:(NSString *)bodyText
      actionTitle:(nullable NSString *)actionTitle
           action:(nullable void (^)(void))action
      endsSession:(BOOL)endsSession {
    if (self.handlingRound == round) {
        self.handlingRound = nil;
        self.handlingIntent = nil;
    }
    round.intentStatus = TSAIChatRoundIntentStatusFailed;
    round.statusText = nil;
    TSLog(@"[TSAIChatIntentCoordinator] intent failed: round=%@, reason=%@, endsSession=%d",
          round.roundId, reason, endsSession);
    [self.delegate intentCoordinator:self
                        didFailRound:round
                              reason:reason
                            bodyText:bodyText
                         actionTitle:actionTitle
                              action:action
                         endsSession:endsSession];
}

/// 当前会话是否单轮（失败后应结束会话）
- (BOOL)isSingleRoundSession {
    TSAIChatConfig *config = self.sessionCoordinator.activeSessionConfig;
    return config == nil || config.conversationMode == TSAIChatConversationModeSingleRound;
}

@end
