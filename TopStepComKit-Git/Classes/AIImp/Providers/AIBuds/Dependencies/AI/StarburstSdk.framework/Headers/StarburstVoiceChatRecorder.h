//
//  StarburstVoiceChatRecorder.h
//  IOT
//
//  Created by ByteDance on 2026/1/29.
//

#import <Foundation/Foundation.h>
@class StarburstAudioStreamConfig;

NS_ASSUME_NONNULL_BEGIN

/// 自定义录音机协议。
///
/// SDK 通过该协议从业务侧获取“输入音频流”，用于语音对话。
/// 业务侧需要实现本协议，并在 `start/stop` 中驱动采集或读取音频数据，然后通过
/// `setUpStart:stop:data:finished:` 提供的回调把数据推给 SDK。
///
/// 基本调用关系：
/// 1. SDK 调用 `setUpStart:stop:data:finished:` 注入回调（业务侧保存这些 block）；
/// 2. SDK 调用 `start` 表示开始一次对话/采集；
/// 3. 业务侧在合适时机调用：
///    - onStart(config)：告知 SDK 本次输入流的参数（采样率/声道/编码格式等）；
///    - onData(data)：持续推送音频数据包；
///    - onStop()：告知本次输入结束（不再发送 onData）；
///    - onFinished(filePath)：本次录音/输入结束后的文件路径（如不落盘可传空字符串）。
///
/// 注意：
/// - onStart/onStop 语义是“一次会话”的边界：一次会话只调用一次 onStart 与一次 onStop。
/// - onData 的数据格式、包大小/时长需与 StarburstAudioStreamConfig 保持一致（例如 PCM16/Opus 等）。
/// - 若实现了基于 VAD 的门控：应在检测到“开始说话”时触发 onStart；检测到“说话结束”时触发 onStop。
@protocol StarburstVoiceChatRecorder <NSObject>

/// VAD 类型/模式（由业务侧或 SDK 配置）。
/// 具体枚举含义以 SDK 文档/实现为准（例如：0=关闭 VAD，1=VAD），这个是startPhoneChat的时候传入的参数透传。
///
/// SDK 可能在 start 前设置该值，业务侧可在录音策略中读取并决定是否启用 VAD 门控。
@property (nonatomic, assign) NSInteger vadType;

/// SDK 注入回调，业务侧需要保存并在合适时机调用。
///
/// @param start    开始回调：业务侧调用一次，传入本次输入音频流配置（编码、采样率、声道、包大小等）。
/// @param stop     停止回调：业务侧调用一次，表示本次输入结束，不再继续发送 data。
/// @param data     数据回调：业务侧持续调用，将音频数据包推送给 SDK（NSData 为一包数据）。
/// @param path     完成回调：业务侧调用一次，返回本次录音/输入对应的文件路径；不落盘可传空字符串。
- (void)setUpStart:(void(^)(StarburstAudioStreamConfig *config))start
              stop:(void(^)(void))stop
              data:(void(^)(NSData *data))data
          finished:(void(^)(NSString *filePath))path;

/// 开始一次输入（由 SDK 触发）。
/// 业务侧一般在该方法内：启动音频采集/读取文件，并在合适时机回调 start/data。
- (void)start;

/// 停止当前输入（由 SDK 触发）。
/// 业务侧一般在该方法内：停止采集/读取，并回调 stop/finished（按实现需要）。
- (void)stop;

@end

NS_ASSUME_NONNULL_END
