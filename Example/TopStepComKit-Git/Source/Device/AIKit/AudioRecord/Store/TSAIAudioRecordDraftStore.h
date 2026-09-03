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

/// @brief Error codes used by the AI audio recording demo store.
/// @chinese AI 录音 Demo 存储使用的错误码。
typedef NS_ERROR_ENUM(TSAIAudioRecordDemoErrorDomain, TSAIAudioRecordDemoErrorCode) {
    TSAIAudioRecordDemoErrorCodeInvalidDraft = 3001,
    TSAIAudioRecordDemoErrorCodeAudioMissing = 3002,
    TSAIAudioRecordDemoErrorCodeCreateDirectoryFailed = 3003,
    TSAIAudioRecordDemoErrorCodeCopyAudioFailed = 3004,
    TSAIAudioRecordDemoErrorCodeWriteMetadataFailed = 3005,
    TSAIAudioRecordDemoErrorCodeConvertAudioFailed = 3006,
};

/// @brief Persists AI audio recording demo drafts in Application Support.
/// @chinese 将 AI 录音 Demo 草稿保存在 Application Support 中。
@interface TSAIAudioRecordDraftStore : NSObject

/// @brief Returns the root directory used by the demo recording store.
/// @chinese 返回 Demo 录音存储使用的根目录。
/// @return The recording root directory URL. / 录音根目录 URL。
- (NSURL *)recordingsRootDirectory;

/// @brief Saves draft metadata and audio, wrapping raw PCM in a WAV container.
/// @chinese 保存草稿元数据与音频，原始 PCM 会封装为 WAV。
/// @param draft The draft to save. / 待保存的草稿。
/// @param error The save error, if any. / 保存错误（如有）。
/// @return YES when both metadata and audio are saved. / 元数据和音频均保存成功时返回 YES。
- (BOOL)saveDraft:(TSAIAudioRecordDraft *)draft error:(NSError * _Nullable * _Nullable)error;

/// @brief Loads persisted recording metadata sorted from newest to oldest.
/// @chinese 加载已保存的录音元数据，并按时间从新到旧排序。
/// @return Recording metadata dictionaries. / 录音元数据字典数组。
- (NSArray<NSDictionary<NSString *, id> *> *)loadRecordingMetadata;

/// @brief Resolves local audio and creates a WAV copy for legacy PCM recordings on demand.
/// @chinese 解析本地音频，旧版 PCM 录音按需生成 WAV 副本，保留原文件和元数据。
/// @param metadata Persisted recording metadata. / 已保存的录音元数据。
/// @param error The resolution error, if any. / 解析错误（如有）。
/// @return A verified local audio file URL, or nil when unavailable. / 校验通过的本地音频 URL，不可用时返回 nil。
- (nullable NSURL *)audioFileURLForMetadata:(NSDictionary<NSString *, id> *)metadata
                                      error:(NSError * _Nullable * _Nullable)error;

@end

NS_ASSUME_NONNULL_END
