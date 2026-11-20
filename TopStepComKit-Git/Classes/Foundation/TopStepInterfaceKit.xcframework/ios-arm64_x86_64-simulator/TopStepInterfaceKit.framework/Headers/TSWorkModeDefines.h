#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Audio work mode of a directly connected device.
 * @chinese 直连设备的音频工作模式。
 */
typedef NS_ENUM(NSInteger, TSWorkMode) {
    TSWorkModeUnknown = -1, ///< [EN]: Not observed. [CN]: 尚未获知。
    TSWorkModeNormal = 0,   ///< [EN]: Normal audio mode. [CN]: 普通音频模式。
    TSWorkModeGame = 1,     ///< [EN]: Low-latency game mode. [CN]: 低延迟游戏模式。
};

/**
 * @brief Work-mode read or observation result delivered on the main queue.
 * @chinese 在主队列交付的工作模式读取或观测结果。
 *
 * @param mode
 * EN: Current mode; Unknown is valid when a ready device has no known value.
 * CN: 当前模式；已就绪设备尚未获知模式时，Unknown 是有效结果。
 *
 * @param error
 * EN: Read or connection error; ignore mode when non-nil.
 * CN: 读取或连接错误；非空时忽略 mode。
 */
typedef void (^TSWorkModeResultBlock)(TSWorkMode mode, NSError * _Nullable error);

NS_ASSUME_NONNULL_END
