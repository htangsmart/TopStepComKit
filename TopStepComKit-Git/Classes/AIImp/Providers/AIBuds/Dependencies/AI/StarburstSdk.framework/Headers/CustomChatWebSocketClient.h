//
//  CustomChatWebSocketClient.h
//  IOT
//
//  Created by ByteDance on 2026/1/26.
//
#import <Foundation/Foundation.h>

@class CustomVoiceChatConfig;

NS_ASSUME_NONNULL_BEGIN

@protocol CustomChatWebSocketClientDelegate <NSObject>
@optional
- (void)chatClientDidOpen;
- (void)chatClientDidCloseWithCode:(NSInteger)code reason:(NSString *_Nullable)reason wasClean:(BOOL)wasClean;
- (void)chatClientDidFailWithError:(NSError *)error;

- (void)chatClientDidReceiveText:(NSString *)text;

/// 收到 TTS 二进制（如果服务端有 16字节头：dialogId/index/timestamp）
- (void)chatClientDidReceiveTtsData:(NSData *)data
                           dialogId:(uint32_t)dialogId
                              index:(uint32_t)index
                          timestamp:(uint64_t)timestamp
                           isFinish:(BOOL)isFinish;

- (void)chatClientDidStartStreaming:(NSInteger)dialogId;
- (void)chatClientDidStopStreaming:(NSInteger)dialogId;
- (void)chatClientDidInterrupt:(NSInteger)dialogId;
@end

@interface CustomChatWebSocketClient : NSObject

@property (class, nonatomic, readonly) CustomChatWebSocketClient *shared;

@property (nonatomic, weak) id<CustomChatWebSocketClientDelegate> delegate;
@property (nonatomic, assign) BOOL enableLog;

/// 外部只控 VAD：YES => start，NO => stop
@property (atomic, assign, readonly) BOOL vadActive;
@property (atomic, assign, readonly) BOOL streaming;

/// role 变更 => contextId 变更（保持旧类行为）
@property (nonatomic, copy, readonly) NSString *contextId;

/// 缓存策略：VAD=true 但尚未open/start时缓存少量音频，防起声丢帧
@property (nonatomic, assign) BOOL enablePendingAudioBuffer;     // default YES
@property (nonatomic, assign) NSUInteger maxPendingAudioFrames;  // default 50

/// 统一配置（可更新）
- (void)updateConfig:(void (^)(CustomVoiceChatConfig *config))block;

/// 建连/断连（url内部写死）
- (void)connect;
- (void)disconnect;

/// 音频源持续 push；只有 vadActive=true 才会真正发送
- (void)pushAudioFrame:(NSData *)data;

/// VAD控制
- (void)updateVadActive:(BOOL)active;

/// 主动 stop（等同 VAD=false 的 stop）
- (void)stop;

/// 打断（保留）
- (void)interrupt;

/// （可选）如果你们鉴权header需要外部注入token等：只给一个“注入request”的钩子，不接收URL
- (void)setRequestDecorator:(void (^ _Nullable)(NSMutableURLRequest *request))decorator;

@end

NS_ASSUME_NONNULL_END
