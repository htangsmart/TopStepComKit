#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Supported meeting summary templates
 * @chinese 会议纪要模板
 */
typedef NS_ENUM(NSInteger, TSAIMeetingMinutesTemplateType) {
    TSAIMeetingMinutesTemplateTypeMeeting = 1,
    TSAIMeetingMinutesTemplateTypeInterview = 2,
    TSAIMeetingMinutesTemplateTypeSpeech = 3,
};

/**
 * @brief Meeting file task stages
 * @chinese 会议文件任务阶段
 */
typedef NS_ENUM(NSInteger, TSAIMeetingMinutesStage) {
    TSAIMeetingMinutesStageWaiting = 0,
    TSAIMeetingMinutesStageUploading,
    TSAIMeetingMinutesStageTranscribing,
    TSAIMeetingMinutesStageSummarizing,
    TSAIMeetingMinutesStageCompleted,
    TSAIMeetingMinutesStageFailed,
    TSAIMeetingMinutesStageCancelled,
};

/**
 * @brief Error metadata containing a recoverable server file identifier
 * @chinese 错误中可恢复的服务端文件标识
 */
FOUNDATION_EXPORT NSErrorUserInfoKey const TSAIMeetingMinutesFileIdErrorKey;

/**
 * @brief Error metadata indicating an upload may still hold the source file
 * @chinese 错误中表示上传仍可能占用源文件的标记
 */
FOUNDATION_EXPORT NSErrorUserInfoKey const TSAIMeetingMinutesUploadMayContinueErrorKey;

/**
 * @brief Copyable upload and polling options
 * @chinese 可复制的上传及轮询参数
 */
@interface TSAIMeetingMinutesRequest : NSObject <NSCopying>

/**
 * @brief Local MP3 URL
 * @chinese 本地 MP3 文件地址
 * @discussion
 * [EN]: The caller retains the source file during upload.
 * [CN]: 上传期间由调用方保持源文件可读。
 * @note
 * [EN]: Required for upload; an error marked UploadMayContinue does not release this file.
 * [CN]: 上传时必填；错误标有 UploadMayContinue 时不代表源文件已可删除。
 */
@property (nonatomic, copy, nullable) NSURL *fileURL;

/**
 * @brief Service language code
 * @chinese 服务语言短码
 * @discussion
 * [EN]: Select a code from supportedLanguages.
 * [CN]: 从 supportedLanguages 选择短码。
 * @note
 * [EN]: Defaults to zh; only required when uploading.
 * [CN]: 默认 zh；仅上传时校验。
 */
@property (nonatomic, copy) NSString *language;

/**
 * @brief Meeting title
 * @chinese 会议标题
 * @discussion
 * [EN]: Sent with the upload request.
 * [CN]: 随上传请求提交。
 * @note
 * [EN]: Defaults to Meeting minutes.
 * [CN]: 默认 Meeting minutes。
 */
@property (nonatomic, copy) NSString *title;

/**
 * @brief Summary template
 * @chinese 总结模板
 * @discussion
 * [EN]: Selects meeting, interview or speech processing.
 * [CN]: 选择会议、采访或演讲处理。
 * @note
 * [EN]: Defaults to Meeting.
 * [CN]: 默认会议模板。
 */
@property (nonatomic, assign) TSAIMeetingMinutesTemplateType templateType;

/**
 * @brief Polling interval in seconds
 * @chinese 轮询间隔，单位秒
 * @discussion
 * [EN]: A positive finite interval between completed status requests.
 * [CN]: 两次完成状态请求之间的有限正数间隔。
 * @note
 * [EN]: Defaults to the vendor recommendation of 3 seconds.
 * [CN]: 默认采用厂商建议的 3 秒。
 */
@property (nonatomic, assign) NSTimeInterval pollingInterval;

/**
 * @brief Maximum local task wait in seconds
 * @chinese 本地任务最大等待时长，单位秒
 * @discussion
 * [EN]: Expiry stops local waiting and preserves any received file identifier.
 * [CN]: 到期停止本地等待，保留已取得的文件标识。
 * @note
 * [EN]: Defaults to 600; this is not a server processing limit.
 * [CN]: 默认 600；不表示服务端处理时限。
 */
@property (nonatomic, assign) NSTimeInterval maximumWaitDuration;

/**
 * @brief Validate request values without uploading
 * @chinese 不执行上传，仅校验请求参数
 * @param requiresFile
 * EN: YES for a new upload; NO for restoring a file identifier.
 * CN: 新上传传 YES；按文件标识恢复传 NO。
 * @param error
 * EN: Receives a standard invalid-parameter error.
 * CN: 接收标准参数错误。
 * @return
 * EN: YES when local validation succeeds.
 * CN: 本地校验成功时返回 YES。
 */
- (BOOL)validateRequiringFile:(BOOL)requiresFile error:(NSError *_Nullable *_Nullable)error;

@end

/**
 * @brief Correlated progress of one local meeting task
 * @chinese 单个本地会议任务的关联进度
 */
@interface TSAIMeetingMinutesProgress : NSObject

/**
 * @brief Local task identifier
 * @chinese 本地任务标识
 * @discussion
 * [EN]: Matches the identifier returned by start or restore.
 * [CN]: 与启动或恢复返回的标识一致。
 * @note
 * [EN]: Independent of vendor upload and server identifiers.
 * [CN]: 与厂商上传、服务端标识独立。
 */
@property (nonatomic, copy) NSString *taskId;

/**
 * @brief Recoverable server file identifier
 * @chinese 可恢复的服务端文件标识
 * @discussion
 * [EN]: Becomes positive after upload succeeds.
 * [CN]: 上传成功后为正数。
 * @note
 * [EN]: Zero means the identifier has not been received.
 * [CN]: 零表示尚未取得标识。
 */
@property (nonatomic, assign) NSInteger fileId;

/**
 * @brief Current task stage
 * @chinese 当前任务阶段
 * @discussion
 * [EN]: Describes upload or server processing.
 * [CN]: 描述上传或服务端处理阶段。
 * @note
 * [EN]: A stage alone does not indicate final success.
 * [CN]: 单独的阶段不证明最终成功。
 */
@property (nonatomic, assign) TSAIMeetingMinutesStage stage;

/**
 * @brief Upload fraction
 * @chinese 上传进度比例
 * @discussion
 * [EN]: Applies only to the upload stage.
 * [CN]: 仅用于上传阶段。
 * @note
 * [EN]: Range 0 through 1; 1 does not mean summary completion.
 * [CN]: 范围 0 到 1；1 不代表总结完成。
 */
@property (nonatomic, assign) double uploadProgress;

@end

/**
 * @brief Meeting summary or recoverable status snapshot
 * @chinese 会议总结或可恢复状态快照
 */
@interface TSAIMeetingMinutesResult : NSObject <NSCopying>

/**
 * @brief Local task identifier
 * @chinese 本地任务标识
 * @discussion
 * [EN]: Correlates this result with its request.
 * [CN]: 将结果关联到请求。
 * @note
 * [EN]: A single fetch also has an independent local identifier.
 * [CN]: 单次查询也有独立本地标识。
 */
@property (nonatomic, copy) NSString *taskId;

/**
 * @brief Server file identifier
 * @chinese 服务端文件标识
 * @discussion
 * [EN]: Persist this positive identifier to resume status queries.
 * [CN]: 持久化正数标识可恢复查询。
 * @note
 * [EN]: Zero means no server identifier was obtained.
 * [CN]: 零表示没有取得服务端标识。
 */
@property (nonatomic, assign) NSInteger fileId;

/**
 * @brief Current processing stage
 * @chinese 当前处理阶段
 * @discussion
 * [EN]: Completed requires the vendor's outer and inner success states.
 * [CN]: 完成要求厂商外层与内层状态同时成功。
 * @note
 * [EN]: Timeout may return a nonterminal snapshot together with an error.
 * [CN]: 超时可同时返回非终态快照和错误。
 */
@property (nonatomic, assign) TSAIMeetingMinutesStage stage;

/**
 * @brief Meeting title
 * @chinese 会议标题
 * @discussion
 * [EN]: Copied from the service result.
 * [CN]: 从服务结果复制。
 * @note
 * [EN]: May be nil before a result exists.
 * [CN]: 结果生成前可空。
 */
@property (nonatomic, copy, nullable) NSString *title;

/**
 * @brief Summary language code
 * @chinese 总结语言短码
 * @discussion
 * [EN]: Copied from the service result.
 * [CN]: 从服务结果复制。
 * @note
 * [EN]: May be nil.
 * [CN]: 可空。
 */
@property (nonatomic, copy, nullable) NSString *language;

/**
 * @brief Transcribed original text
 * @chinese 转录原文
 * @discussion
 * [EN]: May arrive before the summary is completed.
 * [CN]: 可先于总结完成返回。
 * @note
 * [EN]: May be nil; do not treat it as summary completion.
 * [CN]: 可空；不代表总结完成。
 */
@property (nonatomic, copy, nullable) NSString *transcribeText;

/**
 * @brief Summary text
 * @chinese 总结正文
 * @discussion
 * [EN]: Text returned by the summary service.
 * [CN]: 总结服务返回的文本。
 * @note
 * [EN]: May be nil while processing.
 * [CN]: 处理中可空。
 */
@property (nonatomic, copy, nullable) NSString *summary;

/**
 * @brief Mind-map source text
 * @chinese 思维导图源文本
 * @discussion
 * [EN]: Preserves the service representation without inventing a schema.
 * [CN]: 保留服务格式，不臆造结构。
 * @note
 * [EN]: May be nil.
 * [CN]: 可空。
 */
@property (nonatomic, copy, nullable) NSString *mindMap;

@end

NS_ASSUME_NONNULL_END
