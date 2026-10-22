//
//  TSNpkPlatform.h
//  TopStepNewPlatformKit
//

#import <Foundation/Foundation.h>

/**
 * @brief Device platform reported by the NPK protocol
 * @chinese NPK 协议上报的设备平台
 *
 * @discussion
 * [EN]: Values match the device information platform field and are shared by
 *       connection handling, dial building and file transfer. These values
 *       are independent of the platform identifiers in a TBUI package header.
 * [CN]: 数值与设备信息中的 platform 字段一致，供连接、表盘造包和文件传输共用。
 *       本枚举与 TBUI 包头中的平台编号属于不同的协议字段。
 */
typedef NS_ENUM(NSInteger, TSNpkPlatform) {
    /**
     * @brief W30 with LVGL
     * @chinese W30 LVGL 平台
     */
    TSNpkPlatformLVGLW30 = 0,
    /**
     * @brief 579X with LVGL
     * @chinese 579X LVGL 平台
     */
    TSNpkPlatformLVGL579X = 1,
    /**
     * @brief 579X with GUI
     * @chinese 579X GUI 平台
     */
    TSNpkPlatformGUI579X = 2,
};
