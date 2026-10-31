//
//  TSNpkAISpeechDefines.h
//  TopStepNewPlatformKit
//
//  Created by Codex on 2026/10/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Speech scenes encoded by the NPK firmware
 * @chinese NPK 固件编码的语音场景
 */
typedef NS_ENUM(NSInteger, TSNpkAISpeechScene) {
    /**
     * @brief Unknown scene
     * @chinese 未知场景
     */
    TSNpkAISpeechSceneUnknown = -1,
    /**
     * @brief Chat
     * @chinese 对话
     */
    TSNpkAISpeechSceneChat = 0,
    /**
     * @brief AI recording
     * @chinese AI 录音
     */
    TSNpkAISpeechSceneRecording = 1,
    /**
     * @brief Call recording
     * @chinese 通话录音
     */
    TSNpkAISpeechSceneCallRecording = 2,
    /**
     * @brief Voice translation
     * @chinese 语音翻译
     */
    TSNpkAISpeechSceneTranslation = 3,
    /**
     * @brief Ride hailing
     * @chinese 打车
     */
    TSNpkAISpeechSceneRideHailing = 4,
    /**
     * @brief Voice watch-face creation
     * @chinese 语音表盘制作
     */
    TSNpkAISpeechSceneWatchFace = 5,
    /**
     * @brief Question answering
     * @chinese 问答
     */
    TSNpkAISpeechSceneQuestionAnswer = 6,
    /**
     * @brief Self-side conversation translation
     * @chinese 对话翻译自身侧
     */
    TSNpkAISpeechSceneTranslationSelf = 7,
    /**
     * @brief Peer-side conversation translation
     * @chinese 对话翻译对方侧
     */
    TSNpkAISpeechSceneTranslationPeer = 8,
};

/**
 * @brief AI service providers recommended by the device
 * @chinese 设备建议使用的 AI 服务供应商
 *
 * @discussion
 * [EN]: These flags are recommendations, not authentication or service authorization.
 * [CN]: 这些标志仅为供应商建议，不表示鉴权成功或服务授权。
 */
typedef NS_OPTIONS(NSUInteger, TSNpkAIProviderOptions) {
    /**
     * @brief No known recommendation
     * @chinese 无已知供应商建议
     */
    TSNpkAIProviderNone = 0,
    /**
     * @brief StarBurst
     * @chinese StarBurst 供应商
     */
    TSNpkAIProviderStarBurst = 1UL << 0,
    /**
     * @brief MltCloud
     * @chinese MltCloud 供应商
     */
    TSNpkAIProviderMltCloud = 1UL << 1,
    /**
     * @brief EyeEar
     * @chinese EyeEar 供应商
     */
    TSNpkAIProviderEyeEar = 1UL << 2,
};

NS_ASSUME_NONNULL_END
