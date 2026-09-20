//
//  TSRealtimeDanMuDefines.h
//  TopStepInterfaceKit
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Runtime danmaku owner type.
 * @chinese 实时弹幕归属类型。
 */
typedef NS_ENUM(NSInteger, TSDanMuType) {
    /** @brief Danmaku sent by the current user. @chinese 当前用户发送的弹幕。 */
    TSDanMuTypeMine = 1,
    /** @brief Danmaku sent by a friend. @chinese 好友发送的弹幕。 */
    TSDanMuTypeFriend = 2
};

/**
 * @brief Scope used when clearing runtime danmaku.
 * @chinese 清除实时弹幕时使用的范围。
 */
typedef NS_ENUM(NSInteger, TSDanMuClearScope) {
    /** @brief Clear all danmaku. @chinese 清除全部弹幕。 */
    TSDanMuClearScopeAll = 0,
    /** @brief Clear the current user's danmaku. @chinese 清除当前用户弹幕。 */
    TSDanMuClearScopeMine = 1,
    /** @brief Clear friends' danmaku. @chinese 清除好友弹幕。 */
    TSDanMuClearScopeFriend = 2
};

/**
 * @brief Runtime danmaku animation type.
 * @chinese 实时弹幕动画类型。
 */
typedef NS_ENUM(NSInteger, TSDanMuAnimation) {
    /** @brief No animation. @chinese 无动画。 */
    TSDanMuAnimationNone = 0,
    /** @brief Heart animation. @chinese 爱心动画。 */
    TSDanMuAnimationHeart = 1,
    /** @brief Birthday animation one. @chinese 生日动画一。 */
    TSDanMuAnimationBirthday1 = 2,
    /** @brief Birthday animation two. @chinese 生日动画二。 */
    TSDanMuAnimationBirthday2 = 3
};

/**
 * @brief Y coordinate sentinel requesting a device-selected random position.
 * @chinese 请求设备随机选择纵坐标的位置哨兵值。
 */
FOUNDATION_EXPORT const NSInteger TSDanMuRandomYCoordinate;

/**
 * @brief Stable validation error codes for runtime danmaku.
 * @chinese 实时弹幕稳定校验错误码。
 */
typedef NS_ENUM(NSInteger, TSRealtimeDanMuErrorCode) {
    /** @brief Invalid runtime danmaku item. @chinese 实时弹幕项无效。 */
    TSRealtimeDanMuErrorInvalidItem = 32001,
    /** @brief Invalid clear scope. @chinese 清除范围无效。 */
    TSRealtimeDanMuErrorInvalidClearScope = 32002
};

NS_ASSUME_NONNULL_END
