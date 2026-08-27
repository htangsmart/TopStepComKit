//
//  TSPeripheralAIAbility.h
//  TopStepInterfaceKit
//
//  Created by Codex on 2026/8/14.
//

#import <Foundation/Foundation.h>
#import "TSAIVendor.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief AI audio stream scenes supported by a peripheral
 * @chinese 外设支持的 AI 音频流场景
 */
typedef NS_OPTIONS(NSUInteger, TSPeripheralAIScene) {
    /// @brief No scene.
    /// @chinese 不支持任何场景。
    TSPeripheralAISceneNone = 0,
    /// @brief AI chat.
    /// @chinese AI 对话。
    TSPeripheralAISceneChat = 1 << 0,
    /// @brief Audio recording.
    /// @chinese 录音。
    TSPeripheralAISceneRecording = 1 << 1,
    /// @brief Call recording.
    /// @chinese 通话录音。
    TSPeripheralAISceneCallRecording = 1 << 2,
    /// @brief AI translation.
    /// @chinese AI 翻译。
    TSPeripheralAISceneTranslation = 1 << 3,
    /// @brief Ride-hailing.
    /// @chinese 打车。
    TSPeripheralAISceneRideHailing = 1 << 4,
    /// @brief AI watch face.
    /// @chinese AI 表盘。
    TSPeripheralAISceneWatchFace = 1 << 5,
    /// @brief AI question and answer.
    /// @chinese AI 问答。
    TSPeripheralAISceneQuestionAnswer = 1 << 6,
    /// @brief Conversation translation with self as the audio source.
    /// @chinese 对话翻译，声音来源为自身。
    TSPeripheralAISceneTranslationSelf = 1 << 7,
    /// @brief Conversation translation with the peer as the audio source.
    /// @chinese 对话翻译，声音来源为对方。
    TSPeripheralAISceneTranslationPeer = 1 << 8,
    /// @brief All currently defined scenes. @chinese 当前已定义的全部场景。
    TSPeripheralAISceneAll = (1 << 9) - 1,
};

/**
 * @brief Direction-aware AI capability declared by a peripheral
 * @chinese 外设声明的带发起方向 AI 能力
 *
 * @discussion
 * [EN]: This immutable model only describes firmware capability. It does not
 *       represent AI provider initialization, authentication, permissions, or
 *       runtime availability.
 * [CN]: 此不可变模型只描述固件能力，不表示 AI Provider 初始化、鉴权、
 *       权限或运行时可用状态。
 */
@interface TSPeripheralAIAbility : NSObject

/**
 * @brief Scenes whose audio stream can be initiated by the peripheral
 * @chinese 可由外设发起音频流的场景
 */
@property (nonatomic, assign, readonly) TSPeripheralAIScene deviceInitiatedScenes;

/**
 * @brief Scenes whose audio stream can be initiated by the App
 * @chinese 可由 App 发起音频流的场景
 */
@property (nonatomic, assign, readonly) TSPeripheralAIScene appInitiatedScenes;

/**
 * @brief Preferred AI vendor suggested by the peripheral
 * @chinese 外设建议优先使用的 AI 方案商
 *
 * @discussion
 * [EN]: TSAIVendorUnknown means that the peripheral did not report a suggestion.
 * [CN]: TSAIVendorUnknown 表示外设未上报方案建议。
 */
@property (nonatomic, assign, readonly) TSAIVendor preferredAIVendor;

/**
 * @brief Initialize an ability with no supported scenes
 * @chinese 初始化一个不支持任何场景的能力对象
 * @return EN: Initialized ability. CN: 初始化后的能力对象。
 */
- (instancetype)init;

/**
 * @brief Initialize with direction-aware scene masks
 * @chinese 使用带发起方向的场景掩码初始化
 * @param deviceInitiatedScenes EN: Peripheral-initiated scenes. CN: 外设发起的场景。
 * @param appInitiatedScenes EN: App-initiated scenes. CN: App 发起的场景。
 * @return EN: Initialized ability. CN: 初始化后的能力对象。
 */
- (instancetype)initWithDeviceInitiatedScenes:(TSPeripheralAIScene)deviceInitiatedScenes
                           appInitiatedScenes:(TSPeripheralAIScene)appInitiatedScenes;

/**
 * @brief Initialize with direction-aware scene masks and a preferred AI vendor
 * @chinese 使用带发起方向的场景掩码和首选 AI 方案商初始化
 * @param deviceInitiatedScenes EN: Peripheral-initiated scenes. CN: 外设发起的场景。
 * @param appInitiatedScenes EN: App-initiated scenes. CN: App 发起的场景。
 * @param preferredAIVendor EN: Preferred AI vendor reported by the peripheral. CN: 外设上报的首选 AI 方案商。
 * @return EN: Initialized ability. CN: 初始化后的能力对象。
 */
- (instancetype)initWithDeviceInitiatedScenes:(TSPeripheralAIScene)deviceInitiatedScenes
                           appInitiatedScenes:(TSPeripheralAIScene)appInitiatedScenes
                            preferredAIVendor:(TSAIVendor)preferredAIVendor NS_DESIGNATED_INITIALIZER;

/**
 * @brief Check whether all requested peripheral-initiated scenes are supported
 * @chinese 检查是否支持全部指定的外设发起场景
 * @param scene EN: One or more scenes. CN: 一个或多个场景。
 * @return EN: YES when every requested scene is supported. CN: 全部指定场景均支持时返回 YES。
 */
- (BOOL)supportDeviceInitiatedScene:(TSPeripheralAIScene)scene;

/**
 * @brief Check whether all requested App-initiated scenes are supported
 * @chinese 检查是否支持全部指定的 App 发起场景
 * @param scene EN: One or more scenes. CN: 一个或多个场景。
 * @return EN: YES when every requested scene is supported. CN: 全部指定场景均支持时返回 YES。
 */
- (BOOL)supportAppInitiatedScene:(TSPeripheralAIScene)scene;

@end

NS_ASSUME_NONNULL_END
