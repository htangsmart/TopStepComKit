//
//  TSAIBluetoothHFPAudioIO+Internal.h
//  TopStepAIKit
//
//  Created by Claude on 2026/10/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief AIKit-owned Bluetooth earbuds (HFP) capture with optional same-route playback
 * @chinese AIKit 自持的蓝牙耳机 HFP 采集（可选同路由播放）
 *
 * @discussion
 * EN: For products made of a BLE charging case plus independent classic-Bluetooth
 *     earbuds, the device AI audio channel is not SCO, so the earbuds microphone
 *     can only be captured by the App selecting the HFP port in AVAudioSession.
 * CN: 适用于「充电仓（BLE）+ 独立经典蓝牙耳机」的产品形态：设备 AI 音频通道不是 SCO，
 *     耳机麦克风只能由 App 在 AVAudioSession 中选择 HFP 端口采集。
 *     - 启动：PlayAndRecord + AllowBluetooth，首选输入设为 HFP 端口，激活后以实际路由校验；
 *       不是 HFP 即失败，绝不悄悄改用手机麦克风。
 *     - 采集：AVAudioEngine 输入 tap，转为 16 kHz 单声道 Int16LE。
 *     - 播放：可选。16 kHz 单声道 Int16LE 经同一引擎播放；HFP 输入生效时 iOS 只能从耳机出声。
 *     - 中途断开（入仓 / 断连 / 路由被改写 / 系统打断）：进入等待，宽限期内耳机 HFP 恢复即自动续采，
 *       等待期间以静音帧保持上行连续；超时后经 inputLostHandler 在主线程精确回调一次。
 *     内部状态在私有串行队列维护，公开方法可在任意线程调用。
 */
@interface TSAIBluetoothHFPAudioIO : NSObject

/** @brief Reconnect grace period, default 5 s @chinese 断开后等待耳机恢复的宽限期，默认 5 秒 */
@property (nonatomic, assign) NSTimeInterval reconnectGracePeriod;

/** @brief Whether started and not stopped, including while waiting @chinese 是否已启动且未停止（含等待恢复期间） */
@property (atomic, assign, readonly, getter=isRunning) BOOL running;

/**
 * @brief Start HFP capture
 * @chinese 启动耳机 HFP 采集
 * @param playbackEnabled EN: Also enable HFP playback. CN: 是否同时启用耳机播放。
 * @param pcmHandler EN: Captured 16 kHz mono Int16LE PCM, called on an internal thread.
 *                   CN: 采集到的 16 kHz 单声道 Int16LE PCM，在内部线程回调。
 * @param inputLostHandler EN: Called once on the main queue when the earbuds input is lost
 *                         and does not recover within the grace period. Never called after stop.
 *                         CN: 耳机输入丢失且宽限期内未恢复时，在主线程回调一次；stop 后不再回调。
 * @param error EN: Start failure (TSAIErrorDomain AudioRouteUnavailable / AudioRouteMismatch).
 *              CN: 启动失败原因（TSAIErrorDomain：AudioRouteUnavailable / AudioRouteMismatch）。
 * @return EN: YES once the HFP route is verified and capture is running. CN: 校验到 HFP 路由且采集已开始时返回 YES。
 */
- (BOOL)startWithPlaybackEnabled:(BOOL)playbackEnabled
                      pcmHandler:(void (^)(NSData *pcmData))pcmHandler
                inputLostHandler:(nullable void (^)(NSError *error))inputLostHandler
                           error:(NSError * _Nullable * _Nullable)error;

/**
 * @brief Enqueue playback PCM
 * @chinese 追加播放数据
 * @param pcmData EN: 16 kHz mono Int16LE PCM; dropped when playback is disabled or while waiting.
 *                CN: 16 kHz 单声道 Int16LE PCM；未启用播放或等待恢复期间丢弃。
 */
- (void)enqueuePlaybackPCMData:(NSData *)pcmData;

/** @brief Stop capture and playback and release the audio session (idempotent) @chinese 停止采集与播放并释放音频会话（幂等） */
- (void)stop;

@end

NS_ASSUME_NONNULL_END
