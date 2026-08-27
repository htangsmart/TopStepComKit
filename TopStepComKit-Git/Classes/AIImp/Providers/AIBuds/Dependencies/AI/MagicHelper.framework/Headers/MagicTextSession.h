//
//  MagicTextSession.h
//  MagicHelper
//
//  Created by ymz on 2026/6/18.
//

#import <Foundation/Foundation.h>
#import "MagicSmartOptionModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MagicTextSessionDelegate<NSObject>

@optional
/// 意图理解回调
- (void)onTextSessionIntentionAction:(NSString *)type params:(NSDictionary *)params;

/// 文本回调
- (void)onTextSessionMessage:(NSDictionary *)message;
/// 文本回调结束
- (void)onTextSessionMessageFinished:(NSDictionary *)message;

/// webSocket开启回调
- (void)onTextSessionOpen;
/// WebSocket关闭回调
- (void)onTextSessionClosed:(NSString *)reason;
/// WebSocket错误回调
- (void)onTextSessionFailure:(NSString *)reason;

@end

@interface MagicTextSession : NSObject

@property (nonatomic, weak) id<MagicTextSessionDelegate> delegate;

/// websocket是否连接
@property (nonatomic, assign, readonly) BOOL isConnected;

/// 创建文本会话。model 可复用 MagicRecognitionSession 的大模型配置；内部会强制 enable_tts = NO。
- (void)createSessionWithConfigCode:(nullable NSString *)configCode model:(nullable MagicSmartOptionModel *)model ext:(nullable NSDictionary *)ext;

/// 输入文本开启对话
- (void)commitText:(NSString *)text;

/// 中断当前文本响应
- (void)cancelResponse;

/// 关闭整个会话（WebSocket）
- (void)stopSession;

@end

NS_ASSUME_NONNULL_END
