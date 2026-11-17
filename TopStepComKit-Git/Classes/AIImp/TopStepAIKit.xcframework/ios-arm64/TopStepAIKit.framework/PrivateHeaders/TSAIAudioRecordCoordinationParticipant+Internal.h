#import "TSAIAudioRecordProvider.h"
#import "TSAIAudioRecordInputReadiness+Internal.h"

NS_ASSUME_NONNULL_BEGIN
/// 支持单次设备协同输入就绪标记的本地录音 Provider；旧入口保持原有计时。
@protocol TSAIAudioRecordCoordinationParticipant <NSObject>
- (void)startAIAudioRecordingWithConfig:(nullable TSAIAudioRecordConfig *)config
                       inputReadiness:(nullable TSAIAudioRecordInputReadiness *)inputReadiness
                      startCompletion:(TSAICompletionBlock)startCompletion
                  didReceiveAudioData:(nullable TSAudioRecordDataReceivedBlock)didReceiveAudioData
              didReceiveSessionResult:(nullable TSAIAudioRecordSessionResultHandler)didReceiveSessionResult
                        finishHandler:(nullable TSAudioRecordFinishHandler)finishHandler;
@end
NS_ASSUME_NONNULL_END
