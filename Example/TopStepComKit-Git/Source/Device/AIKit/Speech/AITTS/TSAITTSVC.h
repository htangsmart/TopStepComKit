//
//  TSAITTSVC.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/18.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSBaseVC.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief AI text-to-speech test VC
 * @chinese AI 文本转语音测试页
 *
 * @discussion
 * [EN]: Tests `TSAISpeechInterface` TTS capability. Input text, choose speaker
 *       and trigger one-shot synthesis; the resulting audio is played via the
 *       shared `TSAIAudioPlayer`.
 * [CN]: 用于测试 `TSAISpeechInterface` 的文本转语音能力。输入文本，选择
 *       发音人，触发一次性合成；合成结果通过 `TSAIAudioPlayer` 播放。
 */
@interface TSAITTSVC : TSBaseVC

@end

NS_ASSUME_NONNULL_END
