//
//  TSAIAudioRecordDetailVC.h
//  TopStepComKit-Git_Example
//

#import "TSBaseVC.h"

NS_ASSUME_NONNULL_BEGIN

/// @brief Local AI recording detail and playback page.
/// @chinese AI 录音本地详情与播放页面。
@interface TSAIAudioRecordDetailVC : TSBaseVC

/// @brief Creates a recording detail page from persisted metadata and a verified audio URL.
/// @chinese 使用已保存元数据和校验通过的音频 URL 创建录音详情页。
/// @param metadata Persisted recording metadata. / 已保存的录音元数据。
/// @param audioFileURL Verified local audio file URL. / 校验通过的本地音频文件 URL。
/// @return An initialized recording detail controller. / 初始化完成的录音详情控制器。
- (instancetype)initWithMetadata:(NSDictionary<NSString *, id> *)metadata
                    audioFileURL:(NSURL *)audioFileURL;

/// @brief The default initializer is unavailable because playback input is required.
/// @chinese 默认初始化方法不可用，因为必须提供播放数据。
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
