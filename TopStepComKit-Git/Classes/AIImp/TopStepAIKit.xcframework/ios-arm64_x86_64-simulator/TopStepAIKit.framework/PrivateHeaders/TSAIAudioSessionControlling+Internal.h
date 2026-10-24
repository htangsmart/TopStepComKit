//
//  TSAIAudioSessionControlling+Internal.h
//  TopStepAIKit
//
//  Created by Claude on 2026/10/16.
//

#import <AVFoundation/AVFoundation.h>

#import "TSAIAudioRouteDefines.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief One audio session port as seen by AIKit
 * @chinese AIKit 视角下的一个音频会话端口
 *
 * @discussion
 * EN: AVAudioSessionPortDescription conforms. Unit tests supply plain objects.
 * CN: AVAudioSessionPortDescription 已遵循；单测可用普通对象替代。
 */
@protocol TSAIAudioSessionPort <NSObject>

/** @brief Port type @chinese 端口类型 */
@property (nonatomic, readonly, copy) AVAudioSessionPort portType;

/** @brief Port name @chinese 端口名称 */
@property (nonatomic, readonly, copy) NSString *portName;

/** @brief Port UID; Bluetooth ports end with -tacl (A2DP) or -tsco (HFP) @chinese 端口 UID；蓝牙端口以 -tacl（A2DP）或 -tsco（HFP）结尾 */
@property (nonatomic, readonly, copy) NSString *UID;

@end

/**
 * @brief The subset of AVAudioSession used by the arbiter and the earbuds engine
 * @chinese 仲裁者与耳机引擎用到的 AVAudioSession 子集
 *
 * @discussion
 * EN: Exists so that unit tests can replace the shared session. All methods are thread-safe.
 * CN: 便于单测替换系统会话；所有方法线程安全。
 */
@protocol TSAIAudioSessionControlling <NSObject>

/** @brief Current category @chinese 当前类别 */
@property (nonatomic, readonly, copy) AVAudioSessionCategory category;

/** @brief Current mode @chinese 当前模式 */
@property (nonatomic, readonly, copy) AVAudioSessionMode mode;

/** @brief Current category options @chinese 当前类别选项 */
@property (nonatomic, readonly) AVAudioSessionCategoryOptions categoryOptions;

/** @brief Microphone permission, never prompts @chinese 麦克风权限（只读取，不弹窗） */
@property (nonatomic, readonly) TSAIMicrophonePermissionStatus microphonePermissionStatus;

/** @brief Available inputs; complete only after activation (QA1799) @chinese 可用输入；会话激活后才完整（QA1799） */
@property (nonatomic, readonly, copy) NSArray<id<TSAIAudioSessionPort>> *availableInputPorts;

/** @brief Inputs of the current route @chinese 当前路由的输入 */
@property (nonatomic, readonly, copy) NSArray<id<TSAIAudioSessionPort>> *currentInputPorts;

/** @brief Outputs of the current route @chinese 当前路由的输出 */
@property (nonatomic, readonly, copy) NSArray<id<TSAIAudioSessionPort>> *currentOutputPorts;

/** @brief Preferred input, nil when none @chinese 首选输入，未设置时为 nil */
@property (nonatomic, readonly, nullable) id<TSAIAudioSessionPort> preferredInputPort;

/**
 * @brief Set category, mode and options
 * @chinese 设置类别、模式与选项
 */
- (BOOL)setCategory:(AVAudioSessionCategory)category
               mode:(AVAudioSessionMode)mode
            options:(AVAudioSessionCategoryOptions)options
              error:(NSError * _Nullable * _Nullable)error;

/**
 * @brief Activate or deactivate the session
 * @chinese 激活或释放会话
 *
 * @param notifyOthers
 * EN: On deactivation, let interrupted apps resume
 * CN: 释放时通知被打断的其他 App 恢复播放
 */
- (BOOL)setActive:(BOOL)active
    notifyOthersOnDeactivation:(BOOL)notifyOthers
                         error:(NSError * _Nullable * _Nullable)error;

/**
 * @brief Set the preferred input; nil clears it
 * @chinese 设置首选输入；传 nil 清除
 */
- (BOOL)setPreferredInputPort:(nullable id<TSAIAudioSessionPort>)port
                        error:(NSError * _Nullable * _Nullable)error;

/**
 * @brief Request a hardware sample rate
 * @chinese 请求硬件采样率
 */
- (BOOL)setPreferredSampleRate:(double)sampleRate error:(NSError * _Nullable * _Nullable)error;

@end

/**
 * @brief TSAIAudioSessionControlling backed by [AVAudioSession sharedInstance]
 * @chinese 以 [AVAudioSession sharedInstance] 实现的 TSAIAudioSessionControlling
 */
@interface TSAISystemAudioSession : NSObject <TSAIAudioSessionControlling>

/**
 * @brief Shared instance
 * @chinese 共享实例
 */
+ (instancetype)sharedSession;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

/**
 * @brief Pure helpers for Bluetooth port identities
 * @chinese 蓝牙端口身份的纯函数工具
 */
@interface TSAIAudioSessionPortUtilities : NSObject

/**
 * @brief Bluetooth address embedded in a port UID
 * @chinese 端口 UID 中的蓝牙地址
 *
 * @param UID
 * EN: Port UID, e.g. 18:5C:A1:8E:77:6F-tacl
 * CN: 端口 UID，例如 18:5C:A1:8E:77:6F-tacl
 *
 * @return
 * EN: Upper-cased address (18:5C:A1:8E:77:6F); nil when the UID carries no address
 * CN: 大写的地址（18:5C:A1:8E:77:6F）；UID 不含地址时返回 nil
 */
+ (nullable NSString *)bluetoothAddressFromPortUID:(nullable NSString *)UID;

/**
 * @brief Address of the Bluetooth headset currently in the route
 * @chinese 当前路由中蓝牙耳机的地址
 *
 * @discussion
 * EN: Looks at A2DP / HFP / BLE outputs first, then HFP inputs.
 * CN: 先看 A2DP / HFP / BLE 输出，再看 HFP 输入。
 */
+ (nullable NSString *)bluetoothHeadsetAddressInOutputs:(NSArray<id<TSAIAudioSessionPort>> *)outputs
                                                 inputs:(NSArray<id<TSAIAudioSessionPort>> *)inputs;

/**
 * @brief Whether the port is the earbuds microphone (HFP)
 * @chinese 端口是否为耳机麦克风（HFP）
 */
+ (BOOL)isHFPPort:(nullable id<TSAIAudioSessionPort>)port;

/**
 * @brief Short description of ports for logs: type(name|UID),...
 * @chinese 端口的简短描述（日志用）：类型(名称|UID),...
 */
+ (NSString *)descriptionOfPorts:(NSArray<id<TSAIAudioSessionPort>> *)ports;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
