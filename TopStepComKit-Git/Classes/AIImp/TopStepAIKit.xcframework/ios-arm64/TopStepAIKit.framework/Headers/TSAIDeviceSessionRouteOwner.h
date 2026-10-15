//
//  TSAIDeviceSessionRouteOwner.h
//  TopStepAIKit
//
//  Created by 磐石 on 2026/10/12.
//

#import <Foundation/Foundation.h>

#import "TSAICapabilityDefines.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Who owns the session handler route of one generic device session use case
 * @chinese 一个通用设备会话用例的处理器路由由谁所有
 *
 * @discussion
 * [EN]: Each generic device session use case has exactly one owner besides the
 *       SDK session overrides. SDK-owned use cases are routed by the device
 *       bridge and the SDK session coordinators; the App drives them through
 *       the session interfaces (`TSAIInterpretationInterface`,
 *       `TSAIConversationTranslationInterface`) and never registers handlers
 *       for them. App-owned use cases are routed by handlers the App registers
 *       through `TSAIDeviceAISessionInterface`.
 * [CN]: 每个通用设备会话用例除 SDK 会话覆盖层外只有一个所有者。SDK 自有用例由
 *       设备桥接与 SDK 会话协调器路由，App 通过会话接口
 *       （`TSAIInterpretationInterface`、`TSAIConversationTranslationInterface`）
 *       驱动，不注册处理器；App 自有用例由 App 通过
 *       `TSAIDeviceAISessionInterface` 注册的处理器路由。
 */
typedef NS_ENUM(NSInteger, TSAIDeviceSessionRouteOwner) {
    /// @brief Not a generic device session use case @chinese 不是通用设备会话用例
    TSAIDeviceSessionRouteOwnerNone = 0,
    /// @brief Owned by the SDK (voice translation, watch face) @chinese SDK 自有（语音翻译、表盘）
    TSAIDeviceSessionRouteOwnerSDK = 1,
    /// @brief Owned by the App (voice question-answer, ride hailing) @chinese App 自有（语音问答、打车）
    TSAIDeviceSessionRouteOwnerApp = 2,
};

/**
 * @brief Owner of the session handler route for one use case
 * @chinese 返回一个用例的处理器路由所有者
 *
 * @param useCase
 * EN: Any use case
 * CN: 任意用例
 *
 * @return
 * EN: SDK, App, or None for use cases that are not generic device sessions
 * CN: SDK、App；非通用设备会话用例返回 None
 */
FOUNDATION_EXPORT TSAIDeviceSessionRouteOwner TSAIDeviceSessionRouteOwnerForUseCase(TSAIUseCase useCase);

NS_ASSUME_NONNULL_END
