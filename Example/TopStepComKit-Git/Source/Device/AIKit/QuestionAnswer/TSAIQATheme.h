//
//  TSAIQATheme.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/24.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Shared colors, fonts and metrics of the AI question-answer pages
 * @chinese AI 问答页面共用的颜色、字体与尺寸
 *
 * @discussion
 * [EN]: The tint #E64A8F is deliberately distinct from the six existing AI Kit sections.
 * [CN]: 主色 #E64A8F 与现有六个 AI Kit 分区色相区分。
 */

/// 问答主色 #E64A8F
static inline UIColor *TSAIQATintColor(void) {
    return [UIColor colorWithRed:0xE6 / 255.0 green:0x4A / 255.0 blue:0x8F / 255.0 alpha:1.0];
}

/// 问答深色 #C2367A（按下态、强调文字）
static inline UIColor *TSAIQADeepTintColor(void) {
    return [UIColor colorWithRed:0xC2 / 255.0 green:0x36 / 255.0 blue:0x7A / 255.0 alpha:1.0];
}

/// 问答浅底色（主色 8% 透明度）
static inline UIColor *TSAIQASoftTintColor(void) {
    return [TSAIQATintColor() colorWithAlphaComponent:0.08];
}

/// 问答浅底色（主色 14% 透明度）
static inline UIColor *TSAIQASoftTintStrongColor(void) {
    return [TSAIQATintColor() colorWithAlphaComponent:0.14];
}

/// 页面背景 #F5F6FB（与 AI Kit 根页一致）
static inline UIColor *TSAIQAPageBackgroundColor(void) {
    return [UIColor colorWithRed:0xF5 / 255.0 green:0xF6 / 255.0 blue:0xFB / 255.0 alpha:1.0];
}

/// 卡片描边 #0000001A
static inline UIColor *TSAIQALineColor(void) {
    return [UIColor colorWithWhite:0 alpha:0.10];
}

/// 主文字 #0E1330
static inline UIColor *TSAIQATextPrimaryColor(void) {
    return [UIColor colorWithRed:0x0E / 255.0 green:0x13 / 255.0 blue:0x30 / 255.0 alpha:1.0];
}

/// 次级文字 #4A5170
static inline UIColor *TSAIQATextSecondaryColor(void) {
    return [UIColor colorWithRed:0x4A / 255.0 green:0x51 / 255.0 blue:0x70 / 255.0 alpha:1.0];
}

/// 三级文字 #8A90AB
static inline UIColor *TSAIQATextTertiaryColor(void) {
    return [UIColor colorWithRed:0x8A / 255.0 green:0x90 / 255.0 blue:0xAB / 255.0 alpha:1.0];
}

/// 成功色 #12967A
static inline UIColor *TSAIQASuccessColor(void) {
    return [UIColor colorWithRed:0x12 / 255.0 green:0x96 / 255.0 blue:0x7A / 255.0 alpha:1.0];
}

/// 失败色 #D6303F
static inline UIColor *TSAIQADangerColor(void) {
    return [UIColor colorWithRed:0xD6 / 255.0 green:0x30 / 255.0 blue:0x3F / 255.0 alpha:1.0];
}

/// 问题标签色 #4F7BFF
static inline UIColor *TSAIQAQuestionColor(void) {
    return [UIColor colorWithRed:0x4F / 255.0 green:0x7B / 255.0 blue:0xFF / 255.0 alpha:1.0];
}

/// 等宽小字（taskId / questionId 等）
static inline UIFont *TSAIQAMonoFont(CGFloat size) {
    if (@available(iOS 13.0, *)) {
        return [UIFont monospacedSystemFontOfSize:size weight:UIFontWeightRegular];
    }
    return [UIFont fontWithName:@"Menlo" size:size] ?: [UIFont systemFontOfSize:size];
}

/// 给卡片加统一阴影
static inline void TSAIQAApplyCardShadow(CALayer *layer) {
    layer.shadowColor = TSAIQATextPrimaryColor().CGColor;
    layer.shadowOpacity = 0.06;
    layer.shadowRadius = 9.0;
    layer.shadowOffset = CGSizeMake(0, 4);
}

NS_ASSUME_NONNULL_END
