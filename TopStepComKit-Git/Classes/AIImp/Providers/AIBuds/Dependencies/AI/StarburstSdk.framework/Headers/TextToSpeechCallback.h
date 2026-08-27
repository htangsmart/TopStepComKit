#import <Foundation/Foundation.h>

/**
 * 文本转语音回调协议
 *
 * 客户端实现此协议，用于接收 TTS（Text To Speech）服务的结果或错误信息。
 */
@protocol TextToSpeechCallback <NSObject>

@required

/**
 * 当云端成功返回语音数据（或语音下载地址等）时回调
 *
 * @param response 云端返回的完整响应字符串，通常为 JSON 格式或语音文件的 URL。
 *
 * @discussion 调用方可以在此方法中解析响应内容，例如：
 *             - 获取语音文件下载地址
 *             - 获取 Base64 编码的音频数据
 */
- (void)onResult:(NSString *)response;

/**
 * 当调用 TTS 服务发生错误时回调
 *
 * @param code    错误码（整数），具体含义由服务端定义
 * @param message 错误提示信息，便于问题排查
 *
 * @discussion 常见错误：
 *             - 网络连接失败
 *             - 请求参数错误
 *             - 服务端内部错误
 *             - 授权失败
 */
- (void)onError:(NSInteger)code message:(NSString *)message;

@end
