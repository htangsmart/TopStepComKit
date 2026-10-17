//
//  TSAIAudioRecordAppCapture.m
//  TopStepComKit-Git_Example
//
//  Created by Claude on 2026/9/21.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIAudioRecordAppCapture.h"

#import <AVFoundation/AVFoundation.h>

NSErrorDomain const TSAIAudioRecordAppCaptureErrorDomain = @"TSAIAudioRecordAppCaptureErrorDomain";

// TopStepAIKit 要求的 PCM 采样率
static const double kTSAIAudioRecordAppCaptureSampleRate = 16000.0;
// 输入节点单次回调的缓冲帧数
static const AVAudioFrameCount kTSAIAudioRecordAppCaptureTapFrames = 1024;

@interface TSAIAudioRecordAppCapture ()

// 当前是否正在采集
@property (nonatomic, assign, readwrite) BOOL isRunning;
// 采集引擎
@property (nonatomic, strong, nullable) AVAudioEngine *engine;
// 输入格式到 16k 单声道 Int16 的转换器
@property (nonatomic, strong, nullable) AVAudioConverter *converter;
// 目标 PCM 格式
@property (nonatomic, strong, nullable) AVAudioFormat *targetFormat;
// 异常停止回调
@property (nonatomic, copy, nullable) void (^errorHandler)(NSError *error);
// 音频会话通知观察者
@property (nonatomic, strong) NSMutableArray<id> *observers;

@end

@implementation TSAIAudioRecordAppCapture

#pragma mark - 生命周期

/**
 * 初始化采集器
 */
- (instancetype)init {
    self = [super init];
    if (self) {
        _observers = [NSMutableArray array];
    }
    return self;
}

/**
 * 释放时停止采集
 */
- (void)dealloc {
    [self stop];
}

#pragma mark - 公开方法

/**
 * 配置音频会话、校验实际输入并启动引擎
 */
- (BOOL)startWithPCMHandler:(void (^)(NSData *pcmData))pcmHandler
               errorHandler:(void (^)(NSError *error))errorHandler
                      error:(NSError **)error {
    [self stop];
    if ([AVAudioSession sharedInstance].recordPermission == AVAudioSessionRecordPermissionDenied) {
        return [self failWithCode:TSAIAudioRecordAppCaptureErrorCodePermissionDenied
                      description:@"麦克风权限已关闭，请在系统设置中开启"
                            error:error];
    }
    if (![self activateSession:error]) {
        return NO;
    }
    if (![self startEngineWithPCMHandler:pcmHandler error:error]) {
        [self deactivateSession];
        return NO;
    }
    self.errorHandler = errorHandler;
    self.isRunning = YES;
    [self registerSessionObservers];
    return YES;
}

/**
 * 停止引擎、移除监听并释放音频会话
 */
- (void)stop {
    [self unregisterSessionObservers];
    self.errorHandler = nil;
    self.isPaused = NO;
    if (self.engine) {
        [self.engine.inputNode removeTapOnBus:0];
        [self.engine stop];
        self.engine = nil;
    }
    self.converter = nil;
    self.targetFormat = nil;
    if (self.isRunning) {
        self.isRunning = NO;
        [self deactivateSession];
    }
}

#pragma mark - 私有方法 - 音频会话

/**
 * 设置类别并选手机内置麦克风，激活后确认实际路由
 */
- (BOOL)activateSession:(NSError **)error {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    // 不开启蓝牙选项，避免系统自动切到已连接的 HFP 耳机（耳机拾音由 SDK 负责）
    if (![session setCategory:AVAudioSessionCategoryPlayAndRecord
                         mode:AVAudioSessionModeDefault
                      options:AVAudioSessionCategoryOptionDefaultToSpeaker
                        error:error]) {
        return NO;
    }
    AVAudioSessionPortDescription *port = [self builtInMicrophonePortInSession:session];
    if (!port) {
        return [self failWithCode:TSAIAudioRecordAppCaptureErrorCodeInputUnavailable
                      description:@"未找到手机内置麦克风"
                            error:error];
    }
    if (![session setPreferredInput:port error:error]) {
        return NO;
    }
    [session setPreferredSampleRate:kTSAIAudioRecordAppCaptureSampleRate error:nil];
    if (![session setActive:YES error:error]) {
        return NO;
    }
    // setPreferredInput 只是请求，必须以激活后的实际路由为准
    if (![self currentRouteUsesBuiltInMicrophone]) {
        [self deactivateSession];
        return [self failWithCode:TSAIAudioRecordAppCaptureErrorCodeRouteMismatch
                      description:@"系统未切换到所选麦克风，请重试或更换拾音方式"
                            error:error];
    }
    return YES;
}

/**
 * 释放音频会话并通知其他 App 恢复播放
 */
- (void)deactivateSession {
    [[AVAudioSession sharedInstance] setActive:NO
                                   withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation
                                         error:nil];
}

/**
 * 返回可用输入中的手机内置麦克风
 */
- (nullable AVAudioSessionPortDescription *)builtInMicrophonePortInSession:(AVAudioSession *)session {
    for (AVAudioSessionPortDescription *port in session.availableInputs) {
        if ([port.portType isEqualToString:AVAudioSessionPortBuiltInMic]) {
            return port;
        }
    }
    return nil;
}

/**
 * 判断当前路由的输入是否为手机内置麦克风
 */
- (BOOL)currentRouteUsesBuiltInMicrophone {
    for (AVAudioSessionPortDescription *port in [AVAudioSession sharedInstance].currentRoute.inputs) {
        if ([port.portType isEqualToString:AVAudioSessionPortBuiltInMic]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - 私有方法 - 采集与转换

/**
 * 创建引擎与格式转换器，安装输入 tap 并启动
 */
- (BOOL)startEngineWithPCMHandler:(void (^)(NSData *pcmData))pcmHandler error:(NSError **)error {
    AVAudioEngine *engine = [[AVAudioEngine alloc] init];
    AVAudioInputNode *inputNode = engine.inputNode;
    AVAudioFormat *inputFormat = [inputNode outputFormatForBus:0];
    if (inputFormat.sampleRate <= 0 || inputFormat.channelCount == 0) {
        return [self failWithCode:TSAIAudioRecordAppCaptureErrorCodeEngineFailed
                      description:@"麦克风输入格式无效"
                            error:error];
    }
    AVAudioFormat *targetFormat = [[AVAudioFormat alloc] initWithCommonFormat:AVAudioPCMFormatInt16
                                                                   sampleRate:kTSAIAudioRecordAppCaptureSampleRate
                                                                     channels:1
                                                                  interleaved:YES];
    AVAudioConverter *converter = [[AVAudioConverter alloc] initFromFormat:inputFormat toFormat:targetFormat];
    if (!converter) {
        return [self failWithCode:TSAIAudioRecordAppCaptureErrorCodeEngineFailed
                      description:@"无法创建音频格式转换器"
                            error:error];
    }
    converter.downmix = YES;
    __weak typeof(self) weakSelf = self;
    [inputNode installTapOnBus:0
                    bufferSize:kTSAIAudioRecordAppCaptureTapFrames
                        format:inputFormat
                         block:^(AVAudioPCMBuffer *buffer, AVAudioTime *when) {
        if (weakSelf.isPaused) {
            return;
        }
        NSData *pcmData = [TSAIAudioRecordAppCapture pcmDataFromBuffer:buffer
                                                             converter:converter
                                                          targetFormat:targetFormat];
        if (pcmData.length > 0 && pcmHandler) {
            pcmHandler(pcmData);
        }
    }];
    [engine prepare];
    if (![engine startAndReturnError:error]) {
        [inputNode removeTapOnBus:0];
        return NO;
    }
    self.engine = engine;
    self.converter = converter;
    self.targetFormat = targetFormat;
    return YES;
}

/**
 * 将一段输入缓冲转换为 16k 单声道 Int16LE 数据
 */
+ (nullable NSData *)pcmDataFromBuffer:(AVAudioPCMBuffer *)buffer
                             converter:(AVAudioConverter *)converter
                          targetFormat:(AVAudioFormat *)targetFormat {
    if (buffer.frameLength == 0) {
        return nil;
    }
    double ratio = targetFormat.sampleRate / buffer.format.sampleRate;
    AVAudioFrameCount capacity = (AVAudioFrameCount)ceil(buffer.frameLength * ratio) + 32;
    AVAudioPCMBuffer *outputBuffer = [[AVAudioPCMBuffer alloc] initWithPCMFormat:targetFormat
                                                                    frameCapacity:capacity];
    __block BOOL didSupplyInput = NO;
    NSError *conversionError = nil;
    AVAudioConverterOutputStatus status =
        [converter convertToBuffer:outputBuffer
                             error:&conversionError
                withInputFromBlock:^AVAudioBuffer *(AVAudioPacketCount packetCount,
                                                     AVAudioConverterInputStatus *inputStatus) {
            // 每次回调只提供这一段数据，保留转换器内部重采样状态以衔接下一段
            if (didSupplyInput) {
                *inputStatus = AVAudioConverterInputStatus_NoDataNow;
                return nil;
            }
            didSupplyInput = YES;
            *inputStatus = AVAudioConverterInputStatus_HaveData;
            return buffer;
        }];
    if (status == AVAudioConverterOutputStatus_Error || outputBuffer.frameLength == 0) {
        return nil;
    }
    return [NSData dataWithBytes:outputBuffer.int16ChannelData[0]
                          length:outputBuffer.frameLength * sizeof(int16_t)];
}

#pragma mark - 私有方法 - 异常监听

/**
 * 监听打断、路由变化、引擎配置变化与媒体服务重置
 */
- (void)registerSessionObservers {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
    __weak typeof(self) weakSelf = self;
    [self.observers addObject:[center addObserverForName:AVAudioSessionInterruptionNotification
                                                  object:nil
                                                   queue:mainQueue
                                              usingBlock:^(NSNotification *notification) {
        NSUInteger type = [notification.userInfo[AVAudioSessionInterruptionTypeKey] unsignedIntegerValue];
        if (type == AVAudioSessionInterruptionTypeBegan) {
            [weakSelf failRunningCaptureWithDescription:@"录音被系统打断（例如来电）"];
        }
    }]];
    [self.observers addObject:[center addObserverForName:AVAudioSessionRouteChangeNotification
                                                  object:nil
                                                   queue:mainQueue
                                              usingBlock:^(NSNotification *notification) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf.isRunning || [strongSelf currentRouteUsesBuiltInMicrophone]) {
            return;
        }
        [strongSelf handleInputLostWithRouteChangeReason:
            [notification.userInfo[AVAudioSessionRouteChangeReasonKey] unsignedIntegerValue]];
    }]];
    [self.observers addObject:[center addObserverForName:AVAudioEngineConfigurationChangeNotification
                                                  object:self.engine
                                                   queue:mainQueue
                                              usingBlock:^(NSNotification *notification) {
        [weakSelf failRunningCaptureWithDescription:@"音频输入配置发生变化，录音已停止"];
    }]];
    [self.observers addObject:[center addObserverForName:AVAudioSessionMediaServicesWereResetNotification
                                                  object:nil
                                                   queue:mainQueue
                                              usingBlock:^(NSNotification *notification) {
        [weakSelf failRunningCaptureWithDescription:@"系统音频服务已重置，录音已停止"];
    }]];
}

/**
 * 移除全部音频会话监听
 */
- (void)unregisterSessionObservers {
    for (id observer in self.observers) {
        [[NSNotificationCenter defaultCenter] removeObserver:observer];
    }
    [self.observers removeAllObjects];
}

/**
 * 手机麦克风从路由中消失（例如被切到外接设备）：结束录音
 */
- (void)handleInputLostWithRouteChangeReason:(AVAudioSessionRouteChangeReason)reason {
    if (reason == AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {
        [self failRunningCaptureWithCode:TSAIAudioRecordAppCaptureErrorCodeInputUnavailable
                             description:@"拾音设备已断开，录音已结束"];
        return;
    }
    [self failRunningCaptureWithCode:TSAIAudioRecordAppCaptureErrorCodeRouteMismatch
                         description:@"拾音设备已被切换，录音已结束"];
}

/**
 * 采集被系统打断或配置变化时结束采集
 */
- (void)failRunningCaptureWithDescription:(NSString *)description {
    [self failRunningCaptureWithCode:TSAIAudioRecordAppCaptureErrorCodeInterrupted
                         description:description];
}

/**
 * 采集意外停止时只回调一次并释放资源
 */
- (void)failRunningCaptureWithCode:(TSAIAudioRecordAppCaptureErrorCode)code
                       description:(NSString *)description {
    if (!self.isRunning) {
        return;
    }
    void (^errorHandler)(NSError *) = self.errorHandler;
    [self stop];
    if (errorHandler) {
        errorHandler([NSError errorWithDomain:TSAIAudioRecordAppCaptureErrorDomain
                                         code:code
                                     userInfo:@{NSLocalizedDescriptionKey: description}]);
    }
}

/**
 * 生成采集错误并返回 NO
 */
- (BOOL)failWithCode:(TSAIAudioRecordAppCaptureErrorCode)code
         description:(NSString *)description
               error:(NSError **)error {
    if (error) {
        *error = [NSError errorWithDomain:TSAIAudioRecordAppCaptureErrorDomain
                                     code:code
                                 userInfo:@{NSLocalizedDescriptionKey: description}];
    }
    return NO;
}

@end
