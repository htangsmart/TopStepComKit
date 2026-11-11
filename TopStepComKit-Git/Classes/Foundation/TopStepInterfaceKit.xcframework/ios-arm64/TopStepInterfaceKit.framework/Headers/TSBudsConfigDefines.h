//
//  TSBudsConfigDefines.h
//  TopStepInterfaceKit
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief AI image resolution mode
 * @chinese AI 识图清晰度档位
 */
typedef NS_ENUM(NSInteger, TSBudsImageResolutionMode) {
    TSBudsImageResolutionModeUnknown = -1, ///< 未知
    TSBudsImageResolutionModeUltraFast = 0, ///< 最快速度
    TSBudsImageResolutionModeSpeed = 1, ///< 速度优先
    TSBudsImageResolutionModeBalancedSpeed = 2, ///< 偏重速度
    TSBudsImageResolutionModeBalancedQuality = 3, ///< 偏重质量
    TSBudsImageResolutionModeQuality = 4, ///< 质量优先
    TSBudsImageResolutionModeUltraQuality = 5, ///< 最高质量
};

/**
 * @brief Video frame direction
 * @chinese 设备录像画幅方向
 */
typedef NS_ENUM(NSInteger, TSBudsVideoRecordDirection) {
    TSBudsVideoRecordDirectionUnknown = -1, ///< 未知
    TSBudsVideoRecordDirectionLandscape = 0, ///< 横向
    TSBudsVideoRecordDirectionPortrait = 1, ///< 纵向
};

/**
 * @brief Physical operation type
 * @chinese 设备物理操作类型
 */
typedef NS_ENUM(NSInteger, TSBudsPhysicalOperation) {
    TSBudsPhysicalOperationUnknown = -1, ///< 未知
    TSBudsPhysicalOperationLeftSingleClick = 0x01, ///< 左侧单击
    TSBudsPhysicalOperationRightSingleClick = 0x02, ///< 右侧单击
    TSBudsPhysicalOperationLeftDoubleClick = 0x03, ///< 左侧双击
    TSBudsPhysicalOperationRightDoubleClick = 0x04, ///< 右侧双击
    TSBudsPhysicalOperationLeftTripleClick = 0x05, ///< 左侧三击
    TSBudsPhysicalOperationRightTripleClick = 0x06, ///< 右侧三击
    TSBudsPhysicalOperationLeftLongPress = 0x07, ///< 左侧长按
    TSBudsPhysicalOperationRightLongPress = 0x08, ///< 右侧长按
    TSBudsPhysicalOperationLeftTouchSingleClick = 0x10, ///< 左侧触摸单击
    TSBudsPhysicalOperationRightTouchSingleClick = 0x11, ///< 右侧触摸单击
    TSBudsPhysicalOperationLeftTouchDoubleClick = 0x12, ///< 左侧触摸双击
    TSBudsPhysicalOperationRightTouchDoubleClick = 0x13, ///< 右侧触摸双击
    TSBudsPhysicalOperationLeftTouchLongPress = 0x14, ///< 左侧触摸长按
    TSBudsPhysicalOperationRightTouchLongPress = 0x15, ///< 右侧触摸长按
    TSBudsPhysicalOperationLeftPrimaryButtonClick = 0x16, ///< 左主按键单击
    TSBudsPhysicalOperationRightPrimaryButtonClick = 0x17, ///< 右主按键单击
    TSBudsPhysicalOperationLeftPrimaryButtonDoubleClick = 0x18, ///< 左主按键双击
    TSBudsPhysicalOperationRightPrimaryButtonDoubleClick = 0x19, ///< 右主按键双击
    TSBudsPhysicalOperationLeftPrimaryButtonLongPress = 0x1A, ///< 左主按键长按
    TSBudsPhysicalOperationRightPrimaryButtonLongPress = 0x1B, ///< 右主按键长按
    TSBudsPhysicalOperationLeftSecondaryButtonClick = 0x1C, ///< 左副按键单击
    TSBudsPhysicalOperationRightSecondaryButtonClick = 0x1D, ///< 右副按键单击
    TSBudsPhysicalOperationLeftSecondaryButtonDoubleClick = 0x1E, ///< 左副按键双击
    TSBudsPhysicalOperationRightSecondaryButtonDoubleClick = 0x1F, ///< 右副按键双击
    TSBudsPhysicalOperationLeftSecondaryButtonLongPress = 0x20, ///< 左副按键长按
    TSBudsPhysicalOperationRightSecondaryButtonLongPress = 0x21, ///< 右副按键长按
    TSBudsPhysicalOperationTouchSlideForward = 0x22, ///< 触摸由后向前滑动
    TSBudsPhysicalOperationTouchSlideBackward = 0x23, ///< 触摸由前向后滑动
};

/**
 * @brief Physical operation function
 * @chinese 可分配给物理操作的设备功能
 */
typedef NS_ENUM(NSInteger, TSBudsPhysicalFunction) {
    TSBudsPhysicalFunctionNone = 0, ///< 无动作
    TSBudsPhysicalFunctionRedial = 1, ///< 重拨
    TSBudsPhysicalFunctionVoiceAssistant = 2, ///< 语音助手
    TSBudsPhysicalFunctionPreviousTrack = 3, ///< 上一曲
    TSBudsPhysicalFunctionNextTrack = 4, ///< 下一曲
    TSBudsPhysicalFunctionVolumeUp = 5, ///< 增大音量
    TSBudsPhysicalFunctionVolumeDown = 6, ///< 减小音量
    TSBudsPhysicalFunctionPlayPause = 7, ///< 播放暂停
    TSBudsPhysicalFunctionGameMode = 8, ///< 游戏模式
    TSBudsPhysicalFunctionNoiseReduction = 9, ///< 降噪
    TSBudsPhysicalFunctionTakePhoto = 10, ///< 拍照
    TSBudsPhysicalFunctionContinuousShooting = 11, ///< 连拍
    TSBudsPhysicalFunctionVideoRecordToggle = 12, ///< 录像启停
    TSBudsPhysicalFunctionAudioRecordToggle = 13, ///< 录音启停
    TSBudsPhysicalFunctionLocalBluetoothToggle = 14, ///< 本地与蓝牙播放切换
};

NS_ASSUME_NONNULL_END
