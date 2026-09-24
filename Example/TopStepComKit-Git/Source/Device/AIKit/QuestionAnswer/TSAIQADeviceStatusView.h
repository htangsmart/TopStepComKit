//
//  TSAIQADeviceStatusView.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/24.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TSAIQADeviceStatusView;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Which half of the audio route a control refers to
 * @chinese 控件对应的音频路由方向
 */
typedef NS_ENUM(NSInteger, TSAIQARouteKind) {
    /// 拾音（input）
    TSAIQARouteKindInput = 0,
    /// 内容播放（output）
    TSAIQARouteKindOutput,
};

/**
 * @brief Step of the device session timeline
 * @chinese 设备会话时间线的阶段
 */
typedef NS_ENUM(NSInteger, TSAIQATimelineStep) {
    TSAIQATimelineStepNotStarted = 0,
    TSAIQATimelineStepArmed,
    TSAIQATimelineStepQuestion,
    TSAIQATimelineStepAnswer,
    TSAIQATimelineStepCompleted,
};

/**
 * @brief Presentation of the hero block under the timeline
 * @chinese 时间线下方主视觉区的展示方式
 */
typedef NS_ENUM(NSInteger, TSAIQADeviceHeroMode) {
    /// 不显示（已有轮次）
    TSAIQADeviceHeroModeHidden = 0,
    /// 灰色静态（未启动 / 不支持）
    TSAIQADeviceHeroModeIdle,
    /// 主色脉冲（已就绪，等待设备发起）
    TSAIQADeviceHeroModeListening,
};

/**
 * @brief Callbacks of the device status header
 * @chinese 设备状态头部的回调
 */
@protocol TSAIQADeviceStatusViewDelegate <NSObject>

/**
 * @brief A route button was tapped
 * @chinese 点击了路由按钮
 *
 * @param view
 * EN: Source view
 * CN: 来源视图
 *
 * @param kind
 * EN: Input or output
 * CN: 拾音或播放
 */
- (void)deviceStatusView:(TSAIQADeviceStatusView *)view didTapRoute:(TSAIQARouteKind)kind;

@end

/**
 * @brief Table header of the device mode: audio route card, five-step timeline and hero block
 * @chinese 设备模式的表头：音频路由卡、五段时间线与主视觉区
 */
@interface TSAIQADeviceStatusView : UIView

/**
 * @brief Interaction delegate
 * @chinese 交互代理
 */
@property (nonatomic, weak, nullable) id<TSAIQADeviceStatusViewDelegate> delegate;

/**
 * @brief Title of the input route button
 * @chinese 拾音路由按钮标题
 */
@property (nonatomic, copy) NSString *inputRouteTitle;

/**
 * @brief Title of the output route button
 * @chinese 播放路由按钮标题
 */
@property (nonatomic, copy) NSString *outputRouteTitle;

/**
 * @brief Whether the route is frozen by an armed session
 * @chinese 路由是否因会话已就绪而锁定
 */
@property (nonatomic, assign) BOOL routeLocked;

/**
 * @brief Hint text under the route buttons
 * @chinese 路由按钮下方的说明文字
 */
@property (nonatomic, copy, nullable) NSString *routeHint;

/**
 * @brief Current timeline step
 * @chinese 当前时间线阶段
 */
@property (nonatomic, assign) TSAIQATimelineStep timelineStep;

/**
 * @brief Whether the current step failed
 * @chinese 当前阶段是否失败
 */
@property (nonatomic, assign) BOOL timelineFailed;

/**
 * @brief Hero block presentation
 * @chinese 主视觉区展示方式
 */
@property (nonatomic, assign) TSAIQADeviceHeroMode heroMode;

/**
 * @brief Hero title
 * @chinese 主视觉区标题
 */
@property (nonatomic, copy, nullable) NSString *heroTitle;

/**
 * @brief Hero subtitle
 * @chinese 主视觉区副标题
 */
@property (nonatomic, copy, nullable) NSString *heroSubtitle;

/**
 * @brief Session identifier shown under the hero subtitle
 * @chinese 主视觉区副标题下方显示的会话标识
 */
@property (nonatomic, copy, nullable) NSString *sessionIdentifier;

/**
 * @brief Re-render every subview from the current properties
 * @chinese 按当前属性重绘全部子视图
 */
- (void)refresh;

/**
 * @brief Height for a given width and hero mode
 * @chinese 指定宽度与主视觉模式下的高度
 *
 * @param width
 * EN: Available width
 * CN: 可用宽度
 *
 * @param heroMode
 * EN: Hero presentation
 * CN: 主视觉区展示方式
 *
 * @return
 * EN: Height in points
 * CN: 高度（pt）
 */
+ (CGFloat)heightForWidth:(CGFloat)width heroMode:(TSAIQADeviceHeroMode)heroMode;

@end

NS_ASSUME_NONNULL_END
