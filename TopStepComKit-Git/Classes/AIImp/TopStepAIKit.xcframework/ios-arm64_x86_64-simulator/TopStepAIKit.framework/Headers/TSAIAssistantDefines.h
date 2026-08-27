//
//  TSAIAssistantDefines.h
//  TopStepAIKit
//
//  Created by Codex on 2026/7/31.
//

#import <Foundation/Foundation.h>

#import "TSAIChatContent.h"
#import "TSAIChatEvent.h"
#import "TSAIChatReport.h"
#import "TSAISummaryPartialResult.h"
#import "TSAISummaryResult.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^TSAISummaryPartialBlock)(TSAISummaryPartialResult *partial);
typedef void(^TSAISummaryCompletionBlock)(TSAISummaryResult * _Nullable result,
                                          NSError * _Nullable error);
typedef void(^TSAIChatContentBlock)(TSAIChatContent *content);
typedef void(^TSAIChatEventBlock)(TSAIChatEvent *event);
typedef void(^TSAIChatCompletionBlock)(TSAIChatReport * _Nullable report,
                                       NSError * _Nullable error);

/**
 * @brief Device-side AI chat event
 * @chinese 设备端 AI 对话事件
 */
typedef NS_ENUM(NSInteger, TSAIChatDeviceEvent) {
    TSAIChatDeviceEventRequestStart = 0,
    TSAIChatDeviceEventRequestEnd = 1,
    TSAIChatDeviceEventInterrupted = 2,
};

/**
 * @brief AI chat session state
 * @chinese AI 对话会话状态
 */
typedef NS_ENUM(NSInteger, TSAIChatState) {
    TSAIChatStateDeviceClosed = 0,
    TSAIChatStateDeviceOpened = 1,
    TSAIChatStateStarted = 2,
    TSAIChatStateEnded = 3,
    TSAIChatStateInterrupted = 255,
};

typedef void(^TSAIChatStateBlock)(TSAIChatState state);

NS_ASSUME_NONNULL_END
