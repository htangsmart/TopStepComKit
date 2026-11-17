#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 单次设备录音的输入就绪事实；不持有 Provider，不负责设备启动超时。
@interface TSAIAudioRecordInputReadiness : NSObject
@property (nonatomic, copy, readonly) NSString *requestIdentifier;
- (instancetype)initWithRequestIdentifier:(NSString *)requestIdentifier;
/// 确认设备启动成功；重复确认或失效确认不延长输入窗口。
- (BOOL)confirmAtTime:(NSTimeInterval)time;
- (void)invalidate;
/// 超时触发时只读获取诊断事实，不改变输入窗口。
- (NSDictionary *)diagnosticAtTime:(NSTimeInterval)now lastPCMTime:(NSTimeInterval)lastPCMTime receivedPCM:(BOOL)receivedPCM;
/// 由会话在其串行上下文提供真实收包时间，使用单调时钟。
- (BOOL)hasTimedOutAtTime:(NSTimeInterval)now
             lastPCMTime:(NSTimeInterval)lastPCMTime
             receivedPCM:(BOOL)receivedPCM;
@end

NS_ASSUME_NONNULL_END
