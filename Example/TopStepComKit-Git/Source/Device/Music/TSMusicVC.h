//
//  TSMusicVC.h
//  TopStepComKit-Git_Example
//
//  Created by 磐石 on 2026/5/8.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSBaseVC.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Music management view controller
 * @chinese 设备音乐管理页
 *
 * @discussion
 * [EN]: Provides device music list (with swipe-to-delete), local file push with
 *       progress and cancel, playback control (play/pause/prev/next) and volume
 *       control (slider/±/mute) backed by TSMusicInterface.
 * [CN]: 提供设备音乐列表（右滑删除）、本地音频推送（带进度与取消）、
 *       播放控制（播放/暂停/上下一首）以及音量控制（滑块/±/静音）。
 *       底层依赖 TSMusicInterface。
 */
@interface TSMusicVC : TSBaseVC

@end

NS_ASSUME_NONNULL_END
