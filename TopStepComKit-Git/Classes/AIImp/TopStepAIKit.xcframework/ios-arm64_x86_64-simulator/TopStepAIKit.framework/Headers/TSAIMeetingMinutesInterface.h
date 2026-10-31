#import <Foundation/Foundation.h>
#import "TSAIMeetingMinutesModels.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Main-thread meeting progress callback
 * @chinese 主线程会议进度回调
 * @param progress
 * EN: Correlated upload or processing snapshot.
 * CN: 带任务关联的上传或处理快照。
 */
typedef void (^TSAIMeetingMinutesProgressBlock)(TSAIMeetingMinutesProgress *progress);

/**
 * @brief One-shot main-thread meeting completion
 * @chinese 主线程单次会议完成回调
 * @param result
 * EN: Result or recoverable status; may accompany an error.
 * CN: 结果或可恢复状态，可与错误同时返回。
 * @param error
 * EN: Nil on success. Local timeout does not mean server failure.
 * CN: 成功时为空；本地超时不表示服务端失败。
 */
typedef void (^TSAIMeetingMinutesCompletion)(TSAIMeetingMinutesResult *_Nullable result,
                                            NSError *_Nullable error);

/**
 * @brief Local MP3 upload and resumable meeting summary interface
 * @chinese 本地 MP3 上传及可恢复会议纪要接口
 */
@protocol TSAIMeetingMinutesInterface <NSObject>

/**
 * @brief Whether this service is currently supported
 * @chinese 当前是否支持会议纪要
 * @discussion
 * [EN]: Includes Context availability and service entitlement.
 * [CN]: 包含 Context 可用性及服务开通状态。
 * @note
 * [EN]: Does not guarantee a particular request can start.
 * [CN]: 不保证具体请求一定能启动。
 */
@property (nonatomic, assign, readonly) BOOL isSupported;

/**
 * @brief Available language dictionaries
 * @chinese 可用语言字典列表
 * @discussion
 * [EN]: Each dictionary contains code and name strings.
 * [CN]: 每项包含 code 与 name 字符串。
 * @note
 * [EN]: Empty when unavailable; no vendor model types are exposed.
 * [CN]: 不可用时为空，不暴露厂商模型类型。
 */
@property (nonatomic, copy, readonly) NSArray<NSDictionary<NSString *, NSString *> *> *supportedLanguages;

/**
 * @brief Upload a local MP3 and poll for a complete summary
 * @chinese 上传本地 MP3 并轮询完整纪要
 * @param request
 * EN: Copied request; retain the source file until upload ends.
 * CN: 会复制请求；上传结束前保持源文件可读。
 * @param progress
 * EN: Optional main-thread upload and status callback.
 * CN: 可空的主线程上传与状态回调。
 * @param completion
 * EN: Invoked once on the main thread, including validation errors.
 * CN: 包括参数错误在内，主线程恰好调用一次。
 * @return
 * EN: Local identifier returned synchronously, including rejected requests.
 * CN: 同步返回本地标识，拒绝的请求也有标识。
 */
- (NSString *)startMeetingMinutesWithRequest:(TSAIMeetingMinutesRequest *)request
                                   progress:(nullable TSAIMeetingMinutesProgressBlock)progress
                                 completion:(TSAIMeetingMinutesCompletion)completion;

/**
 * @brief Resume polling an existing server file without reuploading
 * @chinese 恢复已有服务端文件的轮询，不重新上传
 * @param fileId
 * EN: Positive file identifier previously returned by the service.
 * CN: 先前服务返回的正数文件标识。
 * @param request
 * EN: Polling options; upload-only fields are ignored.
 * CN: 轮询参数；忽略仅上传字段。
 * @param progress
 * EN: Optional main-thread processing callback.
 * CN: 可空的主线程处理回调。
 * @param completion
 * EN: Main-thread completion called once; persist returned fileId on timeout.
 * CN: 主线程回调一次；超时时保留返回的 fileId。
 * @return
 * EN: New local task identifier.
 * CN: 新本地任务标识。
 */
- (NSString *)restoreMeetingMinutesWithFileId:(NSInteger)fileId
                                     request:(TSAIMeetingMinutesRequest *)request
                                    progress:(nullable TSAIMeetingMinutesProgressBlock)progress
                                  completion:(TSAIMeetingMinutesCompletion)completion;

/**
 * @brief Fetch one server status snapshot without polling
 * @chinese 单次获取服务端状态，不轮询
 * @param fileId
 * EN: Positive server file identifier.
 * CN: 正数服务端文件标识。
 * @param completion
 * EN: Main-thread result, including nonterminal snapshots, called once.
 * CN: 主线程恰好一次回调，允许返回非终态快照。
 */
- (void)fetchMeetingMinutesWithFileId:(NSInteger)fileId
                          completion:(TSAIMeetingMinutesCompletion)completion;

/**
 * @brief Cancel only the matching local task
 * @chinese 仅取消匹配的本地任务
 * @param taskId
 * EN: Local identifier returned by start or restore.
 * CN: 启动或恢复返回的本地标识。
 * @discussion
 * [EN]: Cancels an upload when possible; after fileId exists only local polling stops.
 * [CN]: 尽可能取消上传；取得 fileId 后仅停止本地查询，不取消服务端生成。
 */
- (void)cancelMeetingMinutesWithTaskId:(NSString *)taskId;

/**
 * @brief Cancel tasks owned by this meeting capability
 * @chinese 取消当前会议能力持有的任务
 */
- (void)cancelAllMeetingMinutes;

/**
 * @brief Read a bounded recent task snapshot, including late upload file identifiers
 * @chinese 读取有限最近任务快照，包含上传迟到返回的文件标识
 * @param taskId
 * EN: Identifier previously issued by this capability.
 * CN: 当前能力先前返回的标识。
 * @return
 * EN: A copied snapshot or nil when unavailable; persist known fileId externally.
 * CN: 独立快照；不可用时 nil，已知 fileId 由宿主持久化。
 */
- (nullable TSAIMeetingMinutesResult *)latestMeetingMinutesResultWithTaskId:(NSString *)taskId;

@end

NS_ASSUME_NONNULL_END
