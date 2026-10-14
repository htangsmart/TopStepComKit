//
//  TSAIChatRoutePill.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/10/13.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Capsule showing the effective pick-up / playback and opening the audio sheet (spec §2.4 v1.2)
 * @chinese 显示当前生效的拾音 / 播放并作为音频设置入口的状态胶囊（规范 §2.4 v1.2）
 */
@interface TSAIChatRoutePill : UIControl

/** @brief Short name of the effective input, e.g. 耳机 / 手机 @chinese 生效拾音项短名 */
@property (nonatomic, copy) NSString *inputTitle;

/** @brief SF Symbol for the effective input @chinese 生效拾音项图标 */
@property (nonatomic, copy) NSString *inputSymbol;

/** @brief Short name of the effective output, e.g. 耳机 / 手机 @chinese 生效播放项短名 */
@property (nonatomic, copy) NSString *outputTitle;

/** @brief Voice playback off → shows 「不播放语音」 @chinese 语音播放关闭 → 显示「不播放语音」 */
@property (nonatomic, assign) BOOL voiceOff;

/** @brief Locked while busy (violet tint, lock badge, no chevron) @chinese 会话中锁定（紫色底、锁标、无 chevron） */
@property (nonatomic, assign) BOOL locked;

/** @brief Fixed height 26 @chinese 固定高度 26 */
+ (CGFloat)preferredHeight;

@end

NS_ASSUME_NONNULL_END
