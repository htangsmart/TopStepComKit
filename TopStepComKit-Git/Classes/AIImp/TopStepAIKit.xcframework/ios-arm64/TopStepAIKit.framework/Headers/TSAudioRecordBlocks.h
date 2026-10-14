//
//  TSAudioRecordBlocks.h
//  TopStepAIKit
//
//  Created by Codex on 2026/7/31.
//

#import <Foundation/Foundation.h>

#import "TSAudioRecordDefines.h"

@class TSAIAudioRecordDeviceRequest;

NS_ASSUME_NONNULL_BEGIN

typedef void(^TSAudioRecordMaximumDurationResultBlock)(NSUInteger maximumDuration,
                                                        NSError * _Nullable error);
typedef void(^TSAudioRecordDataReceivedBlock)(NSData *audioData);
typedef void(^TSAudioRecordVoiceDataReceivedBlock)(NSData * _Nullable opusData,
                                                    NSData * _Nullable pcmData);
typedef void(^TSAudioRecordFinishHandler)(TSAudioRecordStopReason stopReason,
                                          NSError * _Nullable error);
typedef void(^TSAIAudioRecordRequestStartBlock)(TSAIAudioRecordScene scene);
/// Device start request carrying scene, input channel and request identifier / 携带场景、输入通道与请求标识的设备启动请求
typedef void(^TSAIAudioRecordDeviceRequestBlock)(TSAIAudioRecordDeviceRequest *request);
typedef void(^TSAIAudioRecordInterruptBlock)(TSAIAudioRecordInterruptReason reason);
typedef void(^TSAIAudioRecordStateBlock)(TSAIAudioRecordState state);

NS_ASSUME_NONNULL_END
