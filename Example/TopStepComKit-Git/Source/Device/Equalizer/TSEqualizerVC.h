//
//  TSEqualizerVC.h
//  TopStepComKit-Git_Example
//
//  Created by 磐石 on 2026/5/8.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSBaseVC.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Equalizer management view controller
 * @chinese 设备均衡器管理页
 *
 * @discussion
 * [EN]: Provides current equalizer status, six built-in preset cards (Default / Pop /
 *       Rock / Jazz / Classical / Country) and per-band gain sliders for custom EQ.
 *       Backed by TSEqualizerInterface, all changes are committed by tapping Apply.
 * [CN]: 展示当前均衡器状态、六个内置预设卡片（默认 / 流行 / 摇滚 / 爵士 / 古典 / 乡村）
 *       以及按频段调节的滑条，用于自定义 EQ。底层依赖 TSEqualizerInterface，
 *       所有改动均通过 Apply 按钮统一下发。
 */
@interface TSEqualizerVC : TSBaseVC

@end

NS_ASSUME_NONNULL_END
