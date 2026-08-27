#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 内置 VAD（rsvad）封装。音频由业务侧采集；将 **16kHz、单声道、16bit 小端 PCM** 送入 `acceptWaveform:`。
/// 建议按约 160ms（2560 采样点，即 5120 字节）分块喂入，与官方示例一致。
@interface StarburstVadManager : NSObject

+ (instancetype)sharedManager;

/// 触发一次初始化（含内置 apiKey）。可重复调用，重复调用无效。
- (void)initializeIfNeeded;
/// 初始化流程已完成且底层返回可用时为 YES。
- (BOOL)isReady;
/// 长时间暂停喂音频后，恢复前可调用。
- (void)reset;
/// 一轮说完后重置 VAD 状态机（与 RSVad `vadStatusReset` 一致）。
- (void)resetStatus;
- (void)acceptWaveform:(NSData *)pcmData;
/// 与 RSVad 文档中 `vadStatus` 含义一致。
- (NSInteger)vadStatus;
/// 与 RSVad 文档中 `vadSilenceStatus` 含义一致。
- (NSInteger)vadSilenceStatus;

@end

NS_ASSUME_NONNULL_END
