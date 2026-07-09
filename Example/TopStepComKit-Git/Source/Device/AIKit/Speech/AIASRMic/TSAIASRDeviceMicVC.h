//
//  TSAIASRDeviceMicVC.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/18.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSBaseVC.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Device-microphone streaming ASR test VC ("AI recording")
 * @chinese 设备麦克风流式语音识别测试页（即"AI 录音"）
 *
 * @discussion
 * [EN]: Tests `TSAISpeechInterface` device-mic ASR — the SDK activates AI
 *       capability on the connected device, opens the device microphone
 *       stream, and pipes frames into the recognition pipeline. Caller must
 *       end the session via `stop` (flush + final result) or `cancel`
 *       (discard).
 *
 *       Models an explicit 8-state machine: Idle / Starting / Recognizing /
 *       Stopping / Cancelling / Finished / Cancelled / Failed / Unsupported.
 *       See `docs/TSAIASRDeviceMicVC-PRD.md` for state contracts.
 *
 * [CN]: 用于测试 `TSAISpeechInterface` 的设备麦克风 ASR——SDK 内部激活
 *       已连接设备的 AI 能力，打开设备麦克风音频流，并将音频帧桥接到识别
 *       管道。调用方必须通过 `stop`（冲刷 + 下发最终结果）或 `cancel`
 *       （丢弃结果）显式结束会话。
 *
 *       内部维护 8 状态机：Idle / Starting / Recognizing / Stopping /
 *       Cancelling / Finished / Cancelled / Failed / Unsupported。
 *       状态契约与转移图详见 `docs/TSAIASRDeviceMicVC-PRD.md`。
 */
@interface TSAIASRDeviceMicVC : TSBaseVC

@end

NS_ASSUME_NONNULL_END
