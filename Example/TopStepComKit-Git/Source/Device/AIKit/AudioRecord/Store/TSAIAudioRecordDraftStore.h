//
//  TSAIAudioRecordDraftStore.h
//  TopStepComKit-Git_Example
//

#import <Foundation/Foundation.h>

@class TSAIAudioRecordDraft;

NS_ASSUME_NONNULL_BEGIN

/// @brief Error domain used by the AI recording Demo store.
/// @chinese AI 录音 Demo 存储使用的错误域。
FOUNDATION_EXPORT NSErrorDomain const TSAIAudioRecordDemoErrorDomain;

/// @brief Posted on the main thread after a recording is renamed or deleted; userInfo carries TSAIAudioRecordHistoryChangedIdentifierUserInfoKey.
/// @chinese 录音被重命名或删除后在主线程发出；userInfo 携带 TSAIAudioRecordHistoryChangedIdentifierUserInfoKey。
FOUNDATION_EXPORT NSNotificationName const TSAIAudioRecordHistoryDidChangeNotification;

/// @brief userInfo key for the changed recording identifier (NSString).
/// @chinese 发生变化的录音标识 userInfo 键（NSString）。
FOUNDATION_EXPORT NSString * const TSAIAudioRecordHistoryChangedIdentifierUserInfoKey;

/// @brief Error codes used by the AI audio recording demo store.
/// @chinese AI 录音 Demo 存储使用的错误码。
typedef NS_ERROR_ENUM(TSAIAudioRecordDemoErrorDomain, TSAIAudioRecordDemoErrorCode) {
    TSAIAudioRecordDemoErrorCodeInvalidDraft = 3001,
    TSAIAudioRecordDemoErrorCodeAudioMissing = 3002,
    TSAIAudioRecordDemoErrorCodeCreateDirectoryFailed = 3003,
    TSAIAudioRecordDemoErrorCodeCopyAudioFailed = 3004,
    TSAIAudioRecordDemoErrorCodeWriteMetadataFailed = 3005,
    TSAIAudioRecordDemoErrorCodeRecordingNotFound = 3006,
    TSAIAudioRecordDemoErrorCodeRenameFailed = 3007,
    TSAIAudioRecordDemoErrorCodeDeleteFailed = 3008,
};

/// @brief Persists AI audio recording demo drafts in Application Support.
/// @chinese 将 AI 录音 Demo 草稿保存在 Application Support 中。
@interface TSAIAudioRecordDraftStore : NSObject

/// @brief Returns the root directory used by the demo recording store.
/// @chinese 返回 Demo 录音存储使用的根目录。
/// @return The recording root directory URL. / 录音根目录 URL。
- (NSURL *)recordingsRootDirectory;

/// @brief Saves draft metadata and audio, wrapping raw PCM in a WAV container.
/// @chinese 保存草稿元数据和音频，并将裸 PCM 封装为 WAV。
/// @param draft The draft to save. / 待保存的草稿。
/// @param error The save error, if any. / 保存错误（如有）。
/// @return YES when both metadata and audio are saved. / 元数据和音频均保存成功时返回 YES。
- (BOOL)saveDraft:(TSAIAudioRecordDraft *)draft error:(NSError * _Nullable * _Nullable)error;

/// @brief Loads persisted recording metadata sorted from newest to oldest.
/// @chinese 加载已保存的录音元数据，并按时间从新到旧排序。
/// @return Recording metadata dictionaries. / 录音元数据字典数组。
- (NSArray<NSDictionary<NSString *, id> *> *)loadRecordingMetadata;

/// @brief Resolves local audio, creating a WAV copy for legacy PCM recordings when needed.
/// @chinese 解析本地音频，必要时为历史 PCM 录音创建 WAV 副本。
/// @param metadata Persisted recording metadata. / 已保存的录音元数据。
/// @param error The resolution error, if any. / 解析错误（如有）。
/// @return A verified local audio file URL, or nil when unavailable. / 校验通过的本地音频 URL，不可用时返回 nil。
- (nullable NSURL *)audioFileURLForMetadata:(NSDictionary<NSString *, id> *)metadata
                                      error:(NSError * _Nullable * _Nullable)error;

/// @brief Renames a persisted recording by rewriting its metadata title and posts TSAIAudioRecordHistoryDidChangeNotification.
/// @chinese 重写元数据标题以重命名已保存的录音，并发出 TSAIAudioRecordHistoryDidChangeNotification。
/// @param recordIdentifier The recording identifier (metadata "recordIdentifier"). / 录音标识（元数据 "recordIdentifier"）。
/// @param title The new non-empty title. / 新标题，不能为空。
/// @param error The rename error, if any. / 重命名错误（如有）。
/// @return The updated metadata, or nil on failure. / 更新后的元数据，失败时返回 nil。
- (nullable NSDictionary<NSString *, id> *)renameRecordingWithIdentifier:(NSString *)recordIdentifier
                                                                   title:(NSString *)title
                                                                   error:(NSError * _Nullable * _Nullable)error;

/// @brief Deletes a persisted recording directory (audio + metadata) and posts TSAIAudioRecordHistoryDidChangeNotification.
/// @chinese 删除已保存的录音目录（音频 + 元数据），并发出 TSAIAudioRecordHistoryDidChangeNotification。
/// @param recordIdentifier The recording identifier. / 录音标识。
/// @param error The delete error, if any. / 删除错误（如有）。
/// @return YES when the recording no longer exists. / 录音已不存在时返回 YES。
- (BOOL)deleteRecordingWithIdentifier:(NSString *)recordIdentifier
                                error:(NSError * _Nullable * _Nullable)error;

/// @brief Deletes several recordings, stopping at the first failure.
/// @chinese 批量删除录音，遇到第一个失败即停止。
/// @param recordIdentifiers Recording identifiers to delete. / 待删除的录音标识。
/// @param error The first delete error, if any. / 首个删除错误（如有）。
/// @return The number of recordings deleted. / 实际删除的录音数量。
- (NSUInteger)deleteRecordingsWithIdentifiers:(NSArray<NSString *> *)recordIdentifiers
                                        error:(NSError * _Nullable * _Nullable)error;

@end

NS_ASSUME_NONNULL_END
