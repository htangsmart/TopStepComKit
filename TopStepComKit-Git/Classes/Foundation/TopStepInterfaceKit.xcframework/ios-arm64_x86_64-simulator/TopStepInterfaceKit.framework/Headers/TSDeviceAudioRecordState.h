#import <Foundation/Foundation.h>

/**
 * @brief Device audio recording state, independent of video recording.
 * @chinese 普通设备录音状态，与录像状态独立。
 */
typedef NS_ENUM(NSInteger, TSDeviceAudioRecordState) {
    TSDeviceAudioRecordStateUnknown = -1, ///< Disconnected or unknown / 未连接或状态未知
    TSDeviceAudioRecordStateInactive = 0, ///< Not recording audio / 未录音，不代表设备空闲
    TSDeviceAudioRecordStateActive = 1, ///< Recording audio / 录音中
};
