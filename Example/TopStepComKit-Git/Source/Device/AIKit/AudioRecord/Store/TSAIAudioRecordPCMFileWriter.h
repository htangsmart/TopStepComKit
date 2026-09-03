//
//  TSAIAudioRecordPCMFileWriter.h
//  TopStepComKit-Git_Example
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// @brief Streams decoded AI recording PCM into a playable temporary WAV file.
/// @chinese 将 AI 录音解码 PCM 流写入可播放的临时 WAV 文件。
@interface TSAIAudioRecordPCMFileWriter : NSObject

/// @brief Wraps a raw 16 kHz mono little-endian Int16 PCM file in a WAV container.
/// @chinese 将原始 16 kHz 单声道小端 Int16 PCM 文件封装为 WAV，保留原文件。
/// @param pcmFileURL Source PCM file URL. / 原始 PCM 文件 URL。
/// @param wavFileURL Destination WAV URL, which must not exist. / 目标 WAV URL，文件必须尚不存在。
/// @return YES on success; NO for invalid PCM or a file operation failure. / 成功返回 YES，PCM 无效或文件操作失败返回 NO。
+ (BOOL)writePCMFileAtURL:(NSURL *)pcmFileURL toWAVFileAtURL:(NSURL *)wavFileURL;

/// @brief Creates a temporary WAV writer for one recording.
/// @chinese 为一条录音创建临时 WAV 写入器。
/// @param recordIdentifier Recording identifier used in the temporary filename. / 临时文件名使用的录音标识。
/// @return An initialized writer, or nil when the temporary file cannot be created. / 初始化完成的写入器，无法创建临时文件时返回 nil。
- (nullable instancetype)initWithRecordIdentifier:(NSString *)recordIdentifier;

/// @brief Appends little-endian mono Int16 PCM received from the recording callback.
/// @chinese 追加录音回调收到的小端单声道 Int16 PCM。
/// @param pcmData Decoded PCM bytes. / 解码后的 PCM 字节。
- (void)appendPCMData:(NSData *)pcmData;

/// @brief Finalizes the WAV header and returns the temporary audio URL.
/// @chinese 完成 WAV 文件头并返回临时音频 URL。
/// @return A playable WAV URL, or nil when no PCM was received. / 可播放 WAV URL，未收到 PCM 时返回 nil。
- (nullable NSURL *)finishWriting;

/// @brief Removes the temporary WAV after it has been copied into Demo storage.
/// @chinese WAV 被复制到 Demo 存储后删除临时文件。
- (void)removeTemporaryFile;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
