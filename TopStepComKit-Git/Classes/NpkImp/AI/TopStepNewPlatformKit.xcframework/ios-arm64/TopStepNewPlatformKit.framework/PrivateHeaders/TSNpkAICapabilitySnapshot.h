//
//  TSNpkAICapabilitySnapshot.h
//  TopStepNewPlatformKit
//
//  Created by Codex on 2026/10/27.
//

#import <Foundation/Foundation.h>

#import <TopStepAIKit/TSAIAudioRouteDefines.h>
#import <TopStepAIKit/TSAICapabilityDefines.h>

#import "TSNpkAISpeechDefines.h"

@class TSMetaPeripheralInfo;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Immutable AI declarations parsed from one NPK device-info response
 * @chinese 从一次 NPK 设备信息响应解析的不可变 AI 声明
 *
 * @discussion
 * [EN]: Declaration and initial input policy checks do not prove connection readiness,
 *       codec readiness, a usable route, business support or Provider authorization.
 * [CN]: 声明及初期输入策略检查不代表连接就绪、解码就绪、路由可用、业务已接入或 Provider 已授权。
 */
@interface TSNpkAICapabilitySnapshot : NSObject <NSCopying>

/**
 * @brief Whether the firmware declares AI audio
 * @chinese 固件是否声明 AI 音频能力
 *
 * @discussion
 * [EN]: Reads bit 38 of the original ability bytes.
 * [CN]: 读取原始 ability 字节的 bit38。
 *
 * @note
 * [EN]: Missing or short ability data yields NO.
 * [CN]: ability 缺失或长度不足时为 NO。
 */
@property (nonatomic, assign, readonly) BOOL hasAIAudio;

/**
 * @brief Whether question answering requires user confirmation
 * @chinese 问答是否要求用户确认
 *
 * @discussion
 * [EN]: Reads bit 39 independently from the AI audio declaration.
 * [CN]: 独立读取 bit39，不由 AI 音频总位推导。
 *
 * @note
 * [EN]: Missing data yields NO; this flag does not start a confirmation flow.
 * [CN]: 数据缺失时为 NO；此标志本身不启动确认流程。
 */
@property (nonatomic, assign, readonly) BOOL requiresQuestionConfirmation;

/**
 * @brief Whether chat text is declared
 * @chinese 是否声明对话文字能力
 *
 * @discussion
 * [EN]: Reads bit 40; question and translation text are separate capabilities.
 * [CN]: 读取 bit40；问答及翻译文字不由此位控制。
 *
 * @note
 * [EN]: Missing data yields NO; this flag does not prove a working text sender.
 * [CN]: 数据缺失时为 NO；此标志不表示文字发送链路已可用。
 */
@property (nonatomic, assign, readonly) BOOL supportsChatText;

/**
 * @brief Raw scene mask for device-origin sessions
 * @chinese 设备发起场景的原始位图
 *
 * @discussion
 * [EN]: Preserves the unsigned bit pattern of DeviceInfo tag 19.
 * [CN]: 保留 DeviceInfo tag19 的无符号位模式。
 *
 * @note
 * [EN]: Missing data is zero; unknown bits never enable known scenes.
 * [CN]: 缺失时为零；未知位不放开已知场景。
 */
@property (nonatomic, assign, readonly) uint32_t deviceSpeechSceneMask;

/**
 * @brief Raw scene mask for App-origin sessions
 * @chinese App 发起场景的原始位图
 *
 * @discussion
 * [EN]: Preserves the unsigned bit pattern of DeviceInfo tag 20.
 * [CN]: 保留 DeviceInfo tag20 的无符号位模式。
 *
 * @note
 * [EN]: Missing data is zero; it is never inferred from the device-origin mask.
 * [CN]: 缺失时为零；不借用设备发起位图推导。
 */
@property (nonatomic, assign, readonly) uint32_t appSpeechSceneMask;

/**
 * @brief Raw Provider recommendation mask
 * @chinese 原始供应商建议位图
 *
 * @discussion
 * [EN]: Preserves the unsigned bit pattern of DeviceInfo tag 21 for diagnostics.
 * [CN]: 保留 DeviceInfo tag21 的无符号位模式用于诊断。
 *
 * @note
 * [EN]: Missing data is zero; unknown bits are not known Provider recommendations.
 * [CN]: 缺失时为零；未知位不属于已知供应商建议。
 */
@property (nonatomic, assign, readonly) uint32_t reportedProviderMask;

/**
 * @brief Known recommended Providers
 * @chinese 已知的供应商建议
 *
 * @discussion
 * [EN]: Keeps only the known bits 0 through 2 from reportedProviderMask.
 * [CN]: 仅保留 reportedProviderMask 中已知的 bit0 至 bit2。
 *
 * @note
 * [EN]: Defaults to None; it does not grant authentication or choose a Provider.
 * [CN]: 默认为 None；不授予鉴权，也不自动选择 Provider。
 */
@property (nonatomic, assign, readonly) TSNpkAIProviderOptions recommendedProviders;

/**
 * @brief Text capacity reported by the device
 * @chinese 设备上报的文字容量
 *
 * @discussion
 * [EN]: Preserves the signed value from DeviceInfo tag 22 in UTF-8 bytes.
 * [CN]: 保留 DeviceInfo tag22 的有符号原值，单位为 UTF-8 字节。
 *
 * @note
 * [EN]: Missing data is zero; invalid values are not used directly as allocation sizes.
 * [CN]: 缺失时为零；非法值不直接用于分配内存。
 */
@property (nonatomic, assign, readonly) int32_t reportedTextCapacityBytes;

/**
 * @brief Locally bounded text capacity
 * @chinese 受本地预算约束的文字容量
 *
 * @discussion
 * [EN]: Positive reports are capped at 16 KiB; nonpositive reports use the 799-byte fallback.
 * [CN]: 正值最多取 16 KiB；非正值使用 799 字节兼容回退。
 *
 * @note
 * [EN]: The 16 KiB cap is local policy; fallback interoperability still requires firmware validation.
 * [CN]: 16 KiB 是本地策略；兼容回退仍需通过固件互操作验收。
 */
@property (nonatomic, assign, readonly) NSUInteger textCapacityBytes;

/**
 * @brief Capture declarations without retaining the mutable protobuf message
 * @chinese 采集设备声明，不持有可变 protobuf 消息
 *
 * @param peripheralInfo
 * EN: Parsed device information; nil produces an empty declaration snapshot.
 * CN: 已解析的设备信息；nil 产生空声明快照。
 *
 * @return
 * EN: An immutable snapshot independent from later message mutations.
 * CN: 不受原消息后续修改影响的不可变快照。
 */
- (instancetype)initWithPeripheralInfo:(nullable TSMetaPeripheralInfo *)peripheralInfo NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/**
 * @brief Query a known scene declaration for the exact initiator
 * @chinese 查询指定发起方的已知场景声明
 *
 * @param scene
 * EN: Unified device scene, mapped explicitly to the NPK wire value.
 * CN: 统一设备场景，会显式映射为 NPK 线协议值。
 *
 * @param initiator
 * EN: App or device; other values are rejected.
 * CN: App 或设备；拒绝其他值。
 *
 * @return
 * EN: YES only when AI audio and the corresponding direction bit are declared.
 * CN: 仅当 AI 音频总位及对应方向场景位均声明时返回 YES。
 */
- (BOOL)declaresScene:(TSAIDeviceAIScene)scene initiator:(TSAISessionInitiator)initiator;

/**
 * @brief Check declarations against the initial Opus-only input policy
 * @chinese 依据初期仅 Opus 输入策略检查声明
 *
 * @param channel
 * EN: Resolved input channel; only Opus is allowed by this local policy.
 * CN: 已解析输入通道；此本地策略仅允许 Opus。
 *
 * @param scene
 * EN: Unified device scene to check.
 * CN: 待检查的统一设备场景。
 *
 * @param initiator
 * EN: The exact initiating side.
 * CN: 实际发起方。
 *
 * @return
 * EN: YES when the declaration and static policy pass; runtime eligibility must still be checked.
 * CN: 声明及静态策略通过时为 YES；仍须检查运行时资格。
 */
- (BOOL)allowsInitialInputChannel:(TSAIAudioInputChannel)channel
                           scene:(TSAIDeviceAIScene)scene
                       initiator:(TSAISessionInitiator)initiator;

/**
 * @brief Map a unified device scene to its NPK wire value
 * @chinese 将统一设备场景映射为 NPK 线协议值
 *
 * @param scene
 * EN: Unified device scene.
 * CN: 统一设备场景。
 *
 * @return
 * EN: The known NPK scene, or Unknown for unsupported values.
 * CN: 已知 NPK 场景；不支持的值返回 Unknown。
 */
+ (TSNpkAISpeechScene)speechSceneForDeviceScene:(TSAIDeviceAIScene)scene;

/**
 * @brief Map an NPK wire scene to a unified device scene
 * @chinese 将 NPK 线协议场景映射为统一设备场景
 *
 * @param scene
 * EN: NPK wire scene.
 * CN: NPK 线协议场景。
 *
 * @return
 * EN: The known unified scene, or Invalid for unsupported values.
 * CN: 已知统一场景；不支持的值返回 Invalid。
 */
+ (TSAIDeviceAIScene)deviceSceneForSpeechScene:(TSNpkAISpeechScene)scene;

@end

NS_ASSUME_NONNULL_END
