//
//  TSAIChatAudioPreference.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/10/13.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIChatAudioPreference.h"

#import <AVFoundation/AVFoundation.h>

#import "TSAIEarbudsMicrophoneUI.h"

/// 旧版（对话与畅聊共用）的持久化键：仅用于首次迁移
static NSString * const kTSAIChatAudioLegacyInputKey = @"TSAIChatAudioPreference.input";
static NSString * const kTSAIChatAudioLegacyOutputKey = @"TSAIChatAudioPreference.output";

@interface TSAIChatAudioPreference ()
@property (nonatomic, assign, readwrite) TSAIChatConversationMode conversationMode;
@property (nonatomic, copy) NSString *inputKey;
@property (nonatomic, copy) NSString *outputKey;
@end

@implementation TSAIChatAudioPreference

#pragma mark - 实例

+ (instancetype)preferenceForConversationMode:(TSAIChatConversationMode)mode {
    static TSAIChatAudioPreference *chatPreference = nil;
    static TSAIChatAudioPreference *flowPreference = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        chatPreference = [[TSAIChatAudioPreference alloc] initWithConversationMode:TSAIChatConversationModeSingleRound];
        flowPreference = [[TSAIChatAudioPreference alloc] initWithConversationMode:TSAIChatConversationModeContinuous];
    });
    return mode == TSAIChatConversationModeContinuous ? flowPreference : chatPreference;
}

- (instancetype)initWithConversationMode:(TSAIChatConversationMode)mode {
    self = [super init];
    if (self) {
        _conversationMode = mode;
        NSString *line = mode == TSAIChatConversationModeContinuous ? @"flow" : @"chat";
        _inputKey = [NSString stringWithFormat:@"TSAIChatAudioPreference.%@.input", line];
        _outputKey = [NSString stringWithFormat:@"TSAIChatAudioPreference.%@.output", line];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        // 首次使用分线路的键：以旧版共用设置作为两条线路的初始值
        NSInteger input = [defaults objectForKey:_inputKey] != nil
            ? [defaults integerForKey:_inputKey]
            : [defaults integerForKey:kTSAIChatAudioLegacyInputKey];
        NSInteger output;
        if ([defaults objectForKey:_outputKey] != nil) {
            output = [defaults integerForKey:_outputKey];
        } else if ([defaults objectForKey:kTSAIChatAudioLegacyOutputKey] != nil) {
            output = [defaults integerForKey:kTSAIChatAudioLegacyOutputKey];
        } else {
            output = self.offersCaseOptions ? TSAIChatAudioOutputOptionDevice : TSAIChatAudioOutputOptionSystem;
        }
        _input = [self normalizedInput:(TSAIChatAudioInputOption)input];
        _output = [self normalizedOutput:(TSAIChatAudioOutputOption)output];
    }
    return self;
}

#pragma mark - 公开方法

- (BOOL)offersCaseOptions {
    return self.conversationMode == TSAIChatConversationModeContinuous;
}

- (void)setInput:(TSAIChatAudioInputOption)input {
    _input = [self normalizedInput:input];
    [[NSUserDefaults standardUserDefaults] setInteger:_input forKey:self.inputKey];
}

- (void)setOutput:(TSAIChatAudioOutputOption)output {
    _output = [self normalizedOutput:output];
    [[NSUserDefaults standardUserDefaults] setInteger:_output forKey:self.outputKey];
}

/// 显示顺序：自动 → 耳机 → 耳机仓（仅畅聊）→ 手机麦克风
- (NSArray<NSNumber *> *)orderedInputOptions {
    NSMutableArray *options = [NSMutableArray arrayWithObjects:@(TSAIChatAudioInputOptionAuto),
                                                               @(TSAIChatAudioInputOptionSCO), nil];
    if (self.offersCaseOptions) [options addObject:@(TSAIChatAudioInputOptionDevice)];
    [options addObject:@(TSAIChatAudioInputOptionPhone)];
    return options;
}

/// 显示顺序：跟随系统 → 耳机 → 耳机仓（仅畅聊）→ 手机播放器 → 不播放
- (NSArray<NSNumber *> *)orderedOutputOptions {
    NSMutableArray *options = [NSMutableArray arrayWithObjects:@(TSAIChatAudioOutputOptionSystem),
                                                               @(TSAIChatAudioOutputOptionA2DP), nil];
    if (self.offersCaseOptions) [options addObject:@(TSAIChatAudioOutputOptionDevice)];
    [options addObject:@(TSAIChatAudioOutputOptionPhone)];
    [options addObject:@(TSAIChatAudioOutputOptionNone)];
    return options;
}

/// 系统音频里是否挂着蓝牙耳机：当前路由的输入 / 输出端口或可用输入里有 HFP / A2DP / LE 端口
+ (BOOL)isSystemBluetoothAudioConnected {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSMutableArray<AVAudioSessionPortDescription *> *ports = [NSMutableArray array];
    [ports addObjectsFromArray:session.currentRoute.outputs ?: @[]];
    [ports addObjectsFromArray:session.currentRoute.inputs ?: @[]];
    [ports addObjectsFromArray:session.availableInputs ?: @[]];
    for (AVAudioSessionPortDescription *port in ports) {
        if ([port.portType isEqualToString:AVAudioSessionPortBluetoothA2DP] ||
            [port.portType isEqualToString:AVAudioSessionPortBluetoothHFP] ||
            [port.portType isEqualToString:AVAudioSessionPortBluetoothLE]) {
            return YES;
        }
    }
    return NO;
}

/// SDK 给出的 AI 对话耳机麦克风状态
+ (nullable TSAIEarbudsMicrophoneStatus *)earbudsMicrophoneStatus {
    return [TSAIEarbudsMicrophoneUI statusForFeature:TSAIFeatureAIChat];
}

/// 「耳机」拾音项是否可选：完全由 SDK 判断（产品、Provider、会话策略、权限、佩戴、蓝牙路由）
+ (BOOL)isEarbudsMicrophoneSelectable {
    return [TSAIEarbudsMicrophoneUI isSelectableStatus:[self earbudsMicrophoneStatus]];
}

/// 自动 → 耳机（SDK 判定大概率可用）> 耳机仓（仅畅聊）> 手机；依赖的链路不可用 → 手机
- (TSAIChatAudioInputOption)effectiveInputWithHeadset:(BOOL)caseConnected {
    BOOL earbudsMicrophone = [[self class] isEarbudsMicrophoneSelectable];
    if (self.input == TSAIChatAudioInputOptionAuto) {
        if ([[self class] earbudsMicrophoneStatus].isUsable) return TSAIChatAudioInputOptionSCO;
        return (self.offersCaseOptions && caseConnected) ? TSAIChatAudioInputOptionDevice : TSAIChatAudioInputOptionPhone;
    }
    if ([[self class] inputOptionRequiresCase:self.input] && !caseConnected) {
        return TSAIChatAudioInputOptionPhone;
    }
    if ([[self class] inputOptionRequiresBluetoothHeadset:self.input] && !earbudsMicrophone) {
        return TSAIChatAudioInputOptionPhone;
    }
    return self.input;
}

/// 耳机仓未连接 → 手机播放器；耳机未配对系统蓝牙 → 跟随系统
- (TSAIChatAudioOutputOption)effectiveOutputWithHeadset:(BOOL)caseConnected {
    if ([[self class] outputOptionRequiresCase:self.output] && !caseConnected) {
        return TSAIChatAudioOutputOptionPhone;
    }
    if ([[self class] outputOptionRequiresBluetoothHeadset:self.output] &&
        ![[self class] isSystemBluetoothAudioConnected]) {
        return TSAIChatAudioOutputOptionSystem;
    }
    return self.output;
}

- (TSAIAudioInputChannel)inputChannelWithHeadset:(BOOL)caseConnected {
    switch ([self effectiveInputWithHeadset:caseConnected]) {
        case TSAIChatAudioInputOptionDevice: return TSAIAudioInputChannelOpus;
        case TSAIChatAudioInputOptionSCO:    return TSAIAudioInputChannelSCO;
        case TSAIChatAudioInputOptionPhone:
        default:                             return TSAIAudioInputChannelBuiltInMic;
    }
}

- (TSAIAudioOutputChannel)outputChannelWithHeadset:(BOOL)caseConnected {
    switch ([self effectiveOutputWithHeadset:caseConnected]) {
        case TSAIChatAudioOutputOptionDevice: return TSAIAudioOutputChannelOpus;
        case TSAIChatAudioOutputOptionA2DP:   return TSAIAudioOutputChannelA2DP;
        case TSAIChatAudioOutputOptionSystem: return TSAIAudioOutputChannelSystemDefault;
        case TSAIChatAudioOutputOptionNone:   return TSAIAudioOutputChannelNone;
        case TSAIChatAudioOutputOptionPhone:
        default:                              return TSAIAudioOutputChannelBuiltInSpeaker;
    }
}

#pragma mark - 私有方法

/// 越界值 → 自动；AI 对话线路不提供耳机仓拾音 → 自动
- (TSAIChatAudioInputOption)normalizedInput:(TSAIChatAudioInputOption)input {
    if (input < TSAIChatAudioInputOptionAuto || input > TSAIChatAudioInputOptionPhone) {
        return TSAIChatAudioInputOptionAuto;
    }
    if (!self.offersCaseOptions && [[self class] inputOptionRequiresCase:input]) {
        return TSAIChatAudioInputOptionAuto;
    }
    return input;
}

/// 越界值 → 线路默认；AI 对话线路不提供耳机仓播放 → 跟随系统
- (TSAIChatAudioOutputOption)normalizedOutput:(TSAIChatAudioOutputOption)output {
    if (output < TSAIChatAudioOutputOptionDevice || output > TSAIChatAudioOutputOptionNone) {
        return self.offersCaseOptions ? TSAIChatAudioOutputOptionDevice : TSAIChatAudioOutputOptionSystem;
    }
    if (!self.offersCaseOptions && [[self class] outputOptionRequiresCase:output]) {
        return TSAIChatAudioOutputOptionSystem;
    }
    return output;
}

#pragma mark - 选项属性

+ (BOOL)inputOptionRequiresCase:(TSAIChatAudioInputOption)option {
    return option == TSAIChatAudioInputOptionDevice;
}

+ (BOOL)inputOptionRequiresBluetoothHeadset:(TSAIChatAudioInputOption)option {
    return option == TSAIChatAudioInputOptionSCO;
}

+ (BOOL)outputOptionRequiresCase:(TSAIChatAudioOutputOption)option {
    return option == TSAIChatAudioOutputOptionDevice;
}

+ (BOOL)outputOptionRequiresBluetoothHeadset:(TSAIChatAudioOutputOption)option {
    return option == TSAIChatAudioOutputOptionA2DP;
}

/// SDK 生效输入通道 → 显示项（None / 未知按「手机」显示，仅用于胶囊文案）
+ (TSAIChatAudioInputOption)inputOptionForChannel:(TSAIAudioInputChannel)channel {
    switch (channel) {
        case TSAIAudioInputChannelOpus:       return TSAIChatAudioInputOptionDevice;
        case TSAIAudioInputChannelSCO:        return TSAIChatAudioInputOptionSCO;
        case TSAIAudioInputChannelBuiltInMic:
        default:                              return TSAIChatAudioInputOptionPhone;
    }
}

/// SDK 生效输出通道 → 显示项（SCO 播放归到「耳机」）
+ (TSAIChatAudioOutputOption)outputOptionForChannel:(TSAIAudioOutputChannel)channel {
    switch (channel) {
        case TSAIAudioOutputChannelOpus:          return TSAIChatAudioOutputOptionDevice;
        case TSAIAudioOutputChannelA2DP:
        case TSAIAudioOutputChannelSCO:           return TSAIChatAudioOutputOptionA2DP;
        case TSAIAudioOutputChannelSystemDefault: return TSAIChatAudioOutputOptionSystem;
        case TSAIAudioOutputChannelNone:          return TSAIChatAudioOutputOptionNone;
        case TSAIAudioOutputChannelBuiltInSpeaker:
        default:                                  return TSAIChatAudioOutputOptionPhone;
    }
}

#pragma mark - 文案（规范 §2.8）

+ (NSString *)titleForInputOption:(TSAIChatAudioInputOption)option {
    switch (option) {
        case TSAIChatAudioInputOptionDevice: return @"耳机仓";
        case TSAIChatAudioInputOptionSCO:    return @"耳机";
        case TSAIChatAudioInputOptionPhone:  return @"手机麦克风";
        case TSAIChatAudioInputOptionAuto:
        default:                             return @"自动";
    }
}

+ (NSString *)shortTitleForInputOption:(TSAIChatAudioInputOption)option {
    switch (option) {
        case TSAIChatAudioInputOptionDevice: return @"耳机仓";
        case TSAIChatAudioInputOptionSCO:    return @"耳机";
        case TSAIChatAudioInputOptionPhone:  return @"手机";
        case TSAIChatAudioInputOptionAuto:
        default:                             return @"自动";
    }
}

+ (NSString *)subtitleForInputOption:(TSAIChatAudioInputOption)option {
    switch (option) {
        case TSAIChatAudioInputOptionDevice: return @"耳机仓拾音，Opus 经 BLE 上传";
        case TSAIChatAudioInputOptionSCO:    return @"系统蓝牙耳机通话麦（HFP/SCO），需在 iOS 蓝牙中配对";
        case TSAIChatAudioInputOptionPhone:  return @"对着手机说话";
        case TSAIChatAudioInputOptionAuto:
        default:                             return @"耳机优先，没连就用手机";
    }
}

+ (NSString *)codeForInputOption:(TSAIChatAudioInputOption)option {
    switch (option) {
        case TSAIChatAudioInputOptionDevice: return @"Opus";
        case TSAIChatAudioInputOptionSCO:    return @"SCO";
        case TSAIChatAudioInputOptionPhone:  return @"BuiltInMic";
        case TSAIChatAudioInputOptionAuto:
        default:                             return @"Automatic";
    }
}

+ (NSString *)symbolForInputOption:(TSAIChatAudioInputOption)option {
    switch (option) {
        case TSAIChatAudioInputOptionDevice: return @"earbuds.case.fill";
        case TSAIChatAudioInputOptionSCO:    return @"headphones";
        case TSAIChatAudioInputOptionPhone:  return @"iphone";
        case TSAIChatAudioInputOptionAuto:
        default:                             return @"arrow.triangle.2.circlepath";
    }
}

+ (NSString *)titleForOutputOption:(TSAIChatAudioOutputOption)option {
    switch (option) {
        case TSAIChatAudioOutputOptionA2DP:   return @"耳机";
        case TSAIChatAudioOutputOptionPhone:  return @"手机播放器";
        case TSAIChatAudioOutputOptionSystem: return @"跟随系统";
        case TSAIChatAudioOutputOptionNone:   return @"不播放语音";
        case TSAIChatAudioOutputOptionDevice:
        default:                              return @"耳机仓";
    }
}

+ (NSString *)shortTitleForOutputOption:(TSAIChatAudioOutputOption)option {
    switch (option) {
        case TSAIChatAudioOutputOptionA2DP:   return @"耳机";
        case TSAIChatAudioOutputOptionPhone:  return @"手机";
        case TSAIChatAudioOutputOptionSystem: return @"系统";
        case TSAIChatAudioOutputOptionNone:   return @"不播放";
        case TSAIChatAudioOutputOptionDevice:
        default:                              return @"耳机仓";
    }
}

+ (NSString *)subtitleForOutputOption:(TSAIChatAudioOutputOption)option {
    switch (option) {
        case TSAIChatAudioOutputOptionA2DP:   return @"系统蓝牙音频（A2DP），需在 iOS 蓝牙中配对";
        case TSAIChatAudioOutputOptionPhone:  return @"手机扬声器外放";
        case TSAIChatAudioOutputOptionSystem: return @"跟随系统当前媒体输出";
        case TSAIChatAudioOutputOptionNone:   return @"只看文字回答";
        case TSAIChatAudioOutputOptionDevice:
        default:                              return @"PCM 经 BLE 推给耳机仓播放";
    }
}

+ (NSString *)codeForOutputOption:(TSAIChatAudioOutputOption)option {
    switch (option) {
        case TSAIChatAudioOutputOptionA2DP:   return @"A2DP";
        case TSAIChatAudioOutputOptionPhone:  return @"BuiltInSpeaker";
        case TSAIChatAudioOutputOptionSystem: return @"SystemDefault";
        case TSAIChatAudioOutputOptionNone:   return @"None";
        case TSAIChatAudioOutputOptionDevice:
        default:                              return @"Opus";
    }
}

+ (NSString *)symbolForOutputOption:(TSAIChatAudioOutputOption)option {
    switch (option) {
        case TSAIChatAudioOutputOptionA2DP:   return @"headphones";
        case TSAIChatAudioOutputOptionPhone:  return @"speaker.wave.2.fill";
        case TSAIChatAudioOutputOptionSystem: return @"arrow.triangle.2.circlepath";
        case TSAIChatAudioOutputOptionNone:   return @"speaker.slash.fill";
        case TSAIChatAudioOutputOptionDevice:
        default:                              return @"earbuds.case.fill";
    }
}

@end
