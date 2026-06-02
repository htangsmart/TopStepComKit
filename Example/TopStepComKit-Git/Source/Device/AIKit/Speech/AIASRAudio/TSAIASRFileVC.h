//
//  TSAIASRFileVC.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/18.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSBaseVC.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief File-based streaming ASR test VC
 * @chinese 文件流式语音识别测试页
 *
 * @discussion
 * [EN]: Tests `TSAISpeechInterface` file-ASR capability. Pick a local audio
 *       file, configure language / format / scene, and observe streaming
 *       cumulative partial results and the final transcription.
 * [CN]: 用于测试 `TSAISpeechInterface` 的文件 ASR 能力。选择本地音频文件，
 *       配置语言 / 格式 / 场景，观察流式累积 partial 与最终识别结果。
 */
@interface TSAIASRFileVC : TSBaseVC

@end

NS_ASSUME_NONNULL_END
