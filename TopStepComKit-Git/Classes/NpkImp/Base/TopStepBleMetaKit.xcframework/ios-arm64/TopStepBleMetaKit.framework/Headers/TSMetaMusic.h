//
//  TSMetaMusic.h
//  TopStepBleMetaKit
//
//  Created by 磐石 on 2025/7/30.
//

#import "TSBusinessBase.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Device-originated phone media actions
 * @chinese 设备发起的手机媒体动作
 */
typedef NS_ENUM(NSInteger, TSMetaMediaControlAction) {
    /**
     * @brief Set an absolute media volume
     * @chinese 设置绝对媒体音量
     */
    TSMetaMediaControlActionSetVolume = 0,
    /**
     * @brief Increase media volume
     * @chinese 增加媒体音量
     */
    TSMetaMediaControlActionIncreaseVolume = -1,
    /**
     * @brief Decrease media volume
     * @chinese 降低媒体音量
     */
    TSMetaMediaControlActionDecreaseVolume = -2,
    /**
     * @brief Mute during a phone call
     * @chinese 通话时静音
     */
    TSMetaMediaControlActionMuteCall = -3,
    /**
     * @brief Unmute during a phone call
     * @chinese 退出通话静音
     */
    TSMetaMediaControlActionUnmuteCall = -4,
    /**
     * @brief Start or resume playback
     * @chinese 开始或恢复播放
     */
    TSMetaMediaControlActionPlay = -5,
    /**
     * @brief Pause playback
     * @chinese 暂停播放
     */
    TSMetaMediaControlActionPause = -6,
    /**
     * @brief Play the previous track
     * @chinese 播放上一首
     */
    TSMetaMediaControlActionPreviousTrack = -7,
    /**
     * @brief Play the next track
     * @chinese 播放下一首
     */
    TSMetaMediaControlActionNextTrack = -8,
};

/**
 * @brief Callback for a device request to control phone media
 * @chinese 设备请求控制手机媒体的回调
 *
 * @param action
 * EN: Requested media action.
 * CN: 请求执行的媒体动作。
 *
 * @param volume
 * EN: Volume from 0 through 100 for SetVolume; otherwise zero and ignored.
 * CN: SetVolume 时为0至100的音量，其他动作时为0且应忽略。
 */
typedef void (^TSMetaMediaControlActionBlock)(TSMetaMediaControlAction action, NSInteger volume);

/**
 * @brief Phone media synchronization and device control notifications
 * @chinese 手机媒体同步与设备控制通知
 */
@interface TSMetaMusic : TSBusinessBase

/**
 * @brief Synchronize the current phone media volume to the peripheral
 * @chinese 将手机当前媒体音量同步给外设
 *
 * @param volume
 * EN: Current phone media volume, clamped to 0 through 100.
 * CN: 手机当前媒体音量，超出范围时截断至0至100。
 *
 * @param completion
 * EN: Optional completion delivered once on the main queue; nil still sends.
 * CN: 主线程执行一次的可选完成回调，nil时仍发送。
 *
 * @discussion
 * [EN]: Sends 0x02/0x46 without a business response; success only confirms transmission.
 * [CN]: 通过0x02/0x46发送且不等待业务应答，成功仅代表传输完成。
 */
+ (void)updatePeripheralMediaVolume:(NSInteger)volume
                        completion:(nullable TSMetaCompletionBlock)completion;

/**
 * @brief Replace the listener for device requests to control phone media
 * @chinese 替换设备控制手机媒体请求的监听
 *
 * @param mediaControlActionBlock
 * EN: Main-queue listener; nil unregisters it.
 * CN: 主线程执行的监听回调，nil时注销。
 *
 * @discussion
 * [EN]: Listens to 0x02/0x47. Registration is retained across disconnects, while
 *       pending deliveries are invalidated. Actions are requests, not execution results.
 * [CN]: 监听0x02/0x47。断连保留监听登记并使待交付事件失效；动作是请求，不代表执行结果。
 */
+ (void)registerMetaMediaControledByDevice:
    (nullable TSMetaMediaControlActionBlock)mediaControlActionBlock;

@end

NS_ASSUME_NONNULL_END
