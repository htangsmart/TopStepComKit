//
//  TSNpkAIResultSender.h
//  TopStepNewPlatformKit
//
//  Created by Codex on 2026/10/27.
//

#import <Foundation/Foundation.h>

@class TSNpkAISpeechSession;
@class TSNpkAISpeechRequest;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Error domain for owned AI result transmission
 * @chinese 具归属 AI 结果发送的错误域
 */
FOUNDATION_EXPORT NSErrorDomain const TSNpkAIResultErrorDomain;

/**
 * @brief Local result transmission failures
 * @chinese 本地结果发送错误
 */
typedef NS_ENUM(NSInteger, TSNpkAIResultErrorCode) {
    TSNpkAIResultErrorInvalidArgument = 1000,
    TSNpkAIResultErrorCancelled,
    TSNpkAIResultErrorSuperseded,
    TSNpkAIResultErrorBusy,
    TSNpkAIResultErrorTimeout,
    TSNpkAIResultErrorStaleRequest,
    TSNpkAIResultErrorAlreadyFinalized
};

/**
 * @brief Immutable cumulative text snapshot for one result type
 * @chinese 单一结果类型的不可变累计文本快照
 */
@interface TSNpkAIResultSnapshot : NSObject <NSCopying>

/**
 * @brief Wire content type
 * @chinese 协议内容类型
 * @discussion
 * [EN]: Zero is source, one answer, two image and three watch face.
 * [CN]: 零为原文，一为答案，二为图片，三为表盘。
 * @note
 * [EN]: Only values zero through three are accepted by this sender.
 * [CN]: 本发送器仅接纳零至三。
 */
@property (nonatomic, assign, readonly) int32_t type;

/**
 * @brief Wire result error code
 * @chinese 协议结果错误码
 * @discussion
 * [EN]: Preserves zero, one, two, three, four or 255 from the caller.
 * [CN]: 保留调用方提供的零、一、二、三、四或 255。
 * @note
 * [EN]: A nonzero error description is additionally limited to 255 UTF-8 bytes.
 * [CN]: 非零错误说明另受 255 个 UTF-8 字节限制。
 */
@property (nonatomic, assign, readonly) int32_t errorCode;

/**
 * @brief Cumulative text before local capacity truncation
 * @chinese 本地容量裁剪前的累计文本
 * @discussion
 * [EN]: Copied at creation; it is a full snapshot rather than a token delta.
 * [CN]: 创建时复制；表示完整快照而非增量词元。
 * @note
 * [EN]: May be empty; nil passed to initialization becomes an empty string.
 * [CN]: 允许为空字符串；初始化传 nil 时转换为空字符串。
 */
@property (nonatomic, copy, readonly) NSString *text;

/**
 * @brief Whether the entire snapshot is final
 * @chinese 整份快照是否已经定稿
 * @discussion
 * [EN]: Every multipart AiResult carries the same completion flag.
 * [CN]: 同组每份 AiResult 均携带相同的完成标志。
 * @note
 * [EN]: This is independent of the multipart index.
 * [CN]: 此标志与多包序号无关。
 */
@property (nonatomic, assign, readonly, getter=isCompleted) BOOL completed;

/**
 * @brief Copy one cumulative result snapshot
 * @chinese 复制一份累计结果快照
 * @param type
 * EN: Wire result content type.
 * CN: 协议结果内容类型。
 * @param errorCode
 * EN: Wire result error code.
 * CN: 协议结果错误码。
 * @param text
 * EN: Full cumulative text, not an appended delta.
 * CN: 完整累计文本，不是追加增量。
 * @param completed
 * EN: Whether the full result is final.
 * CN: 完整结果是否已经定稿。
 * @return
 * EN: Immutable copied values; validation occurs on submission.
 * CN: 复制值组成的不可变快照；提交时执行校验。
 */
- (instancetype)initWithType:(int32_t)type errorCode:(int32_t)errorCode
                       text:(nullable NSString *)text completed:(BOOL)completed NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end

/**
 * @brief Serialize cumulative result groups for one immutable speech request
 * @chinese 为单个不可变语音请求串行发送累计结果组
 *
 * @discussion
 * [EN]: Uses only the session's admitted owner. A completed send proves local transmission,
 *       not device display or firmware cleanup. Failed multipart groups are never replayed automatically.
 * [CN]: 仅使用会话已准入的所有者；发送完成仅证明本地传输，不代表设备显示或固件清场。
 *       失败的多包组不会自动重放。
 */
@interface TSNpkAIResultSender : NSObject

/**
 * @brief Bind a sender to the original speech request
 * @chinese 将发送器绑定到原语音请求
 * @param session
 * EN: Session owning the original transport lease.
 * CN: 持有原传输租约的会话。
 * @param request
 * EN: Immutable original request whose device capacity is frozen here.
 * CN: 原不可变请求；在此冻结其设备容量。
 * @param callbackQueue
 * EN: Caller-owned serial completion queue.
 * CN: 调用方持有的串行完成队列。
 * @return
 * EN: New single-request sender; create another sender for another request.
 * CN: 新的单请求发送器；其他请求须创建其他实例。
 */
- (instancetype)initWithSession:(TSNpkAISpeechSession *)session
                        request:(TSNpkAISpeechRequest *)request
                  callbackQueue:(dispatch_queue_t)callbackQueue NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/**
 * @brief Submit a full cumulative snapshot
 * @chinese 提交完整累计快照
 * @param snapshot
 * EN: Immutable snapshot; pending partials of the same type may be superseded.
 * CN: 不可变快照；同类型等待中的未定稿快照可能被替换。
 * @param completion
 * EN: Called once on callbackQueue, including supersession, cancellation and local send failure.
 * CN: 在 callbackQueue 回调一次，包含替换、取消及本地发送失败。
 *
 * @discussion
 * [EN]: At most eight pending groups are retained. A group has a fifteen-second local deadline.
 *       Once a final snapshot is accepted, later partials of that type are rejected.
 * [CN]: 最多保留八个等待组，每组本地期限为十五秒。
 *       接纳定稿快照后，拒绝同类型后来的未定稿快照。
 */
- (void)sendSnapshot:(TSNpkAIResultSnapshot *)snapshot
          completion:(nullable void (^)(BOOL success, NSError * _Nullable error))completion;

/**
 * @brief Stop accepting snapshots and finish already accepted groups
 * @chinese 停止接纳快照并完成已经接纳的组
 * @param completion
 * EN: Called once on callbackQueue after accepted groups finish, with the first actual send error if any.
 * CN: 已接纳组结束后在 callbackQueue 回调一次；存在实际发送错误时返回首个错误。
 */
- (void)finishWithCompletion:(nullable void (^)(NSError * _Nullable error))completion;

/**
 * @brief Permanently close this sender and drain its original result group
 * @chinese 永久关闭本发送器并排空其原结果组
 * @param completion
 * EN: Called once on callbackQueue after the original group stops submitting and its local writes drain.
 * CN: 原组停止提交且本地写入排空后，在 callbackQueue 回调一次。
 *
 * @discussion
 * [EN]: Does not cancel the speech owner, heartbeat or another sender's group. Repeated calls are idempotent.
 * [CN]: 不取消语音所有者、心跳或其他发送器的组；重复调用幂等。
 */
- (void)cancelWithCompletion:(nullable dispatch_block_t)completion;
@end

/**
 * @brief Immutable complete AiResult and its protocol multipart identity
 * @chinese 完整 AiResult 及其协议多包身份的不可变对象
 */
@interface TSNpkAIResultFragment : NSObject

/**
 * @brief Complete serialized AiResult payload
 * @chinese 完整序列化 AiResult 载荷
 * @discussion
 * [EN]: Contains one protobuf message whose text is at most 799 UTF-8 bytes.
 * [CN]: 包含一份 protobuf 消息，text 最多 799 个 UTF-8 字节。
 * @note
 * [EN]: Copied and immutable; excludes the protocol header and multipart metadata.
 * [CN]: 复制且不可变；不包含协议头或多包元信息。
 */
@property (nonatomic, copy, readonly) NSData *payloadData;

/**
 * @brief Zero-based part index in one cumulative snapshot
 * @chinese 一份累计快照中从零开始的包序号
 * @discussion
 * [EN]: Maps to the existing wire multipleIndex field.
 * [CN]: 映射至现有协议 multipleIndex 字段。
 * @note
 * [EN]: Always smaller than partCount.
 * [CN]: 始终小于 partCount。
 */
@property (nonatomic, assign, readonly) NSUInteger partIndex;

/**
 * @brief Total parts in one cumulative snapshot
 * @chinese 一份累计快照的总包数
 * @discussion
 * [EN]: Maps to the existing wire multipleCount field and remains equal across the group.
 * [CN]: 映射至现有协议 multipleCount 字段，组内保持一致。
 * @note
 * [EN]: Between one and 32 under the local text budget.
 * [CN]: 在本地文本预算下取值一至 32。
 */
@property (nonatomic, assign, readonly) NSUInteger partCount;

/**
 * @brief Freeze a protocol result part
 * @chinese 冻结一份协议结果分包
 * @param payloadData
 * EN: Complete AiResult protobuf bytes.
 * CN: 完整 AiResult protobuf 字节。
 * @param partIndex
 * EN: Zero-based index.
 * CN: 从零开始的序号。
 * @param partCount
 * EN: Group part count.
 * CN: 同组总包数。
 * @return
 * EN: Immutable part identity.
 * CN: 不可变分包身份。
 */
- (instancetype)initWithPayloadData:(NSData *)payloadData partIndex:(NSUInteger)partIndex
                         partCount:(NSUInteger)partCount NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
