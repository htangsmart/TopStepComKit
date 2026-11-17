//
//  TSAIVendor.h
//  TopStepInterfaceKit
//
//  Created by Codex on 2026/8/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief AI solution vendor
 * @chinese AI 解决方案供应商
 */
typedef NS_ENUM(NSInteger, TSAIVendor) {
    /**
     * @brief No AI vendor specified.
     * @chinese 未指定 AI 方案商。
     */
    TSAIVendorUnknown = 0,
    /**
     * @brief StarBurst AI solution.
     * @chinese StarBurst AI 方案。
     */
    TSAIVendorStarBurst,
    /**
     * @brief MltCloud AI solution.
     * @chinese MltCloud AI 方案。
     */
    TSAIVendorMltCloud,
    /**
     * @brief WoQi AI solution.
     * @chinese 沃奇 AI 方案。
     */
    TSAIVendorWoQi NS_SWIFT_NAME(woQi) = 3,
    /**
     * @brief XKSmart AI solution.
     * @chinese XKSmart AI 方案，由岩界提供。
     */
    TSAIVendorXKSmart NS_SWIFT_NAME(xkSmart) = 4,
    /**
     * @brief TopStep AI solution.
     * @chinese 拓步自研 AI 方案。
     */
    TSAIVendorTopStep NS_SWIFT_NAME(topStep) = 5,
};

NS_ASSUME_NONNULL_END
