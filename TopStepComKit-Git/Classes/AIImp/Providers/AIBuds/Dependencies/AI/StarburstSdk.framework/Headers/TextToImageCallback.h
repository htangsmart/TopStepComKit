#import <Foundation/Foundation.h>
#import <StarburstSdk/AIGCErrorCode.h>

/**
 * 文本生成图片回调协议
 *
 * 实现此协议可接收任务创建、进度、成功、失败、取消等事件。
 */
@protocol TextToImageCallback <NSObject>

/**
 * 当任务创建成功时触发
 *
 * @param taskId 唯一任务标识
 */
- (void)onCreated:(NSString *)taskId;

/**
 * 当任务处于进行状态时触发
 *
 * @param taskId 任务标识
*/
- (void)onProcessing:(NSString *)taskId;


/**
 * 当任务成功生成图片时触发
 *
 * @param taskId 任务标识
 * @param images 生成图片的 URL 数组（NSString 类型）
 */
- (void)onSuccess:(NSString *)taskId images:(NSArray<NSString *> *)images;

/**
 * 当任务发生错误时触发
 *
 * @param taskId 任务标识
 * @param code 错误码（AIGCErrorCode）
 * @param message 错误说明
 */
- (void)onError:(NSString *)taskId code:(AIGCErrorCode)code message:(NSString *)message;

/**
 * 当任务被取消时触发
 *
 * @param taskId 任务标识
 * @param success YES 表示取消成功，NO 表示取消失败
 */
- (void)onCanceled:(NSString *)taskId success:(BOOL)success;

@end
