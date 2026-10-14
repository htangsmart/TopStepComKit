//
//  TSHsdCapabilityCardView.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/22.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief One Huashengda capability shown on the card
 * @chinese 能力卡上的一项华盛达能力（名称 + 是否支持）
 */
@interface TSHsdCapabilityItem : NSObject

/// 展示名称
@property (nonatomic, copy) NSString *name;
/// 能力条下方的短名（两三个字）
@property (nonatomic, copy) NSString *shortName;
/// 是否支持
@property (nonatomic, assign) BOOL supported;

+ (instancetype)itemWithName:(NSString *)name shortName:(NSString *)shortName supported:(BOOL)supported;

@end

/**
 * @brief Dark device card with a segmented capability bar
 * @chinese 深色设备卡：设备名 + 连接状态 + 一段一功能的能力条（支持绿实心、不支持虚线框），可展开每项能力的支持明细
 *
 * @discussion
 * [CN]: 高度随内容与展开状态变化，通过 -sizeThatFits: 取得；用作 tableHeaderView 时在 onToggle 回调里重新赋值 tableHeaderView。
 */
@interface TSHsdCapabilityCardView : UIView

/// 设备名
@property (nonatomic, copy, nullable) NSString *deviceName;
/// 连接状态副标题，如「已连接 · platform 2」
@property (nonatomic, copy, nullable) NSString *statusText;
/// 是否已连接（决定状态点颜色）
@property (nonatomic, assign, getter=isConnected) BOOL connected;
/// 能力列表（顺序即能力条顺序）
@property (nonatomic, copy) NSArray<TSHsdCapabilityItem *> *items;
/// 展开能力明细
@property (nonatomic, assign, getter=isExpanded) BOOL expanded;
/// 点击「详情」切换展开后的回调（宿主重新布局）
@property (nonatomic, copy, nullable) void (^onToggle)(BOOL expanded);

@end

NS_ASSUME_NONNULL_END
