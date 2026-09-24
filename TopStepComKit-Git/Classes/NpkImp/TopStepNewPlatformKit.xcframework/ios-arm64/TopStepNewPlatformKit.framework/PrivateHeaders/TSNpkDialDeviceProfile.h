//
//  TSNpkDialDeviceProfile.h
//  TopStepNewPlatformKit
//
//  Created on 2026/9/21.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class TSPeripheral;

NS_ASSUME_NONNULL_BEGIN

/** @brief Dial platform of the device @chinese 设备的表盘平台 */
typedef NS_ENUM(NSInteger, TSNpkDialPlatform) {
    /** @brief W30 (res.bin marker "Shenju") @chinese W30（res.bin 标记为 "Shenju"） */
    TSNpkDialPlatformW30 = 0,
    /** @brief 579X (res.bin marker "AB579X") @chinese 579X（res.bin 标记为 "AB579X"） */
    TSNpkDialPlatform579X = 1,
};

/**
 * @brief Snapshot of the device facts dial building depends on
 * @chinese 造包所依赖的设备信息快照
 *
 * @discussion
 * [EN]: Taken once when a build starts, so a disconnect in the middle of a build cannot change or blank these values.
 * [CN]: 造包开始时拍一次快照，造包过程中设备断开也不会让这些值变化或变空。
 */
@interface TSNpkDialDeviceProfile : NSObject

@property (nonatomic, assign, readonly) TSNpkDialPlatform platform;
/** @brief Screen size in pixels @chinese 屏幕像素尺寸 */
@property (nonatomic, assign, readonly) CGSize screenSize;
@property (nonatomic, assign, readonly) CGFloat screenCornerRadius;
/** @brief Dial preview size in pixels @chinese 表盘预览图像素尺寸 */
@property (nonatomic, assign, readonly) CGSize previewSize;
@property (nonatomic, assign, readonly) CGFloat previewCornerRadius;

/**
 * @brief Snapshot of the currently connected peripheral
 * @chinese 对当前已连接设备拍快照
 *
 * @return EN: nil when no device is connected or its screen information is invalid. CN: 未连接设备或屏幕信息无效时返回 nil。
 */
+ (nullable instancetype)currentProfileWithError:(NSError *_Nullable *_Nullable)error;

/**
 * @brief Snapshot of a given peripheral
 * @chinese 对指定设备拍快照
 */
+ (nullable instancetype)profileWithPeripheral:(nullable TSPeripheral *)peripheral
                                         error:(NSError *_Nullable *_Nullable)error;

@end

NS_ASSUME_NONNULL_END
