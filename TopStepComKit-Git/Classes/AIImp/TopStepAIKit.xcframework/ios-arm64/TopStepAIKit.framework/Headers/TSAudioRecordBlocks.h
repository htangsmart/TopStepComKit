//
//  TSAudioRecordBlocks.h
//  TopStepAIKit
//
//  Created by Codex on 2026/7/31.
//

#import <Foundation/Foundation.h>

#import "TSAudioRecordDefines.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^TSAudioRecordMaximumDurationResultBlock)(NSUInteger maximumDuration,
                                                        NSError * _Nullable error);
typedef void(^TSAudioRecordDataReceivedBlock)(NSData *audioData);
typedef void(^TSAudioRecordVoiceDataReceivedBlock)(NSData * _Nullable opusData,
                                                    NSData * _Nullable pcmData);
typedef void(^TSAudioRecordFinishHandler)(TSAudioRecordStopReason stopReason,
                                          NSError * _Nullable error);
typedef void(^TSAIAudioRecordRequestStartBlock)(TSAIAudioRecordScene scene);
typedef void(^TSAIAudioRecordInterruptBlock)(TSAIAudioRecordInterruptReason reason);
typedef void(^TSAIAudioRecordStateBlock)(TSAIAudioRecordState state);

NS_ASSUME_NONNULL_END
