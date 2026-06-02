//
//  TSAIKitRootCapability.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/20.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Icon variant for AI capability cards
 * @chinese AI 能力卡片图标类型
 */
typedef NS_ENUM(NSInteger, TSAIKitRootCapabilityIcon) {
    TSAIKitRootCapabilityIconSummary = 0,
    TSAIKitRootCapabilityIconVoiceChat,
    TSAIKitRootCapabilityIconInterpreter,
    TSAIKitRootCapabilityIconTTS,
    TSAIKitRootCapabilityIconASRFile,
    TSAIKitRootCapabilityIconASRMic,
    TSAIKitRootCapabilityIconTranslate,
};

/**
 * @brief Visual width style of a capability card in the grid
 * @chinese 卡片在网格中的视觉宽度样式
 */
typedef NS_ENUM(NSInteger, TSAIKitRootCapabilityWidth) {
    /// 半宽（2 列网格中的一格）
    TSAIKitRootCapabilityWidthHalf = 0,
    /// 全宽（横跨整行）
    TSAIKitRootCapabilityWidthFull,
};

/**
 * @brief Data model for a single AI capability entry
 * @chinese AI 能力测试入口的数据模型
 */
@interface TSAIKitRootCapability : NSObject

/**
 * @brief Display title
 * @chinese 显示标题
 */
@property (nonatomic, copy) NSString *title;

/**
 * @brief Display subtitle / description
 * @chinese 显示副标题/描述
 */
@property (nonatomic, copy) NSString *subtitle;

/**
 * @brief Section-level tint color used by icon, glow and arrow
 * @chinese 与所属 section 一致的主色，用于图标背景、光晕、箭头
 */
@property (nonatomic, strong) UIColor *tintColor;

/**
 * @brief Which icon to render
 * @chinese 卡片图标类型
 */
@property (nonatomic, assign) TSAIKitRootCapabilityIcon iconType;

/**
 * @brief Visual width style in the grid
 * @chinese 网格中卡片占据的宽度样式
 */
@property (nonatomic, assign) TSAIKitRootCapabilityWidth widthStyle;

/**
 * @brief View controller class to push when tapped
 * @chinese 点击时 push 的 VC 类
 */
@property (nonatomic, strong) Class vcClass;

/**
 * @brief Convenience constructor
 * @chinese 便捷构造方法
 */
+ (instancetype)capabilityWithTitle:(NSString *)title
                           subtitle:(NSString *)subtitle
                          tintColor:(UIColor *)tintColor
                           iconType:(TSAIKitRootCapabilityIcon)iconType
                         widthStyle:(TSAIKitRootCapabilityWidth)widthStyle
                            vcClass:(Class)vcClass;

@end

NS_ASSUME_NONNULL_END
