#import <Foundation/Foundation.h>

@class AVAsset, TSDialVideoRequirements;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Validate prepared video resources without editing their content.
 * @chinese 校验 App 提交的成品视频，不修改视频内容。
 */
@interface TSNpkDialVideoValidator : NSObject

/**
 * @brief Open and validate the complete caller-owned video.
 * @chinese 打开并校验调用方持有的完整视频。
 *
 * @param path EN: Readable local file, unchanged until build ends. CN: 本地可读文件，造包结束前须保持不变。
 * @param requirements EN: Requirements from the captured device and quality. CN: 设备及质量快照对应的素材规格。
 * @param error EN: Specific media validation failure. CN: 可区分原因的媒体校验错误。
 * @return EN: Validated asset or nil; no output file is created. CN: 校验通过的媒体或 nil，不创建输出文件。
 *
 * @discussion
 * [EN]: Checks tracks, duration, oriented dimensions and first-frame decoding.
 *       Pixel composition such as rounded black borders is the App's responsibility.
 *       The encoder must still reject later decoding failures.
 * [CN]: 检查轨道、完整时长、方向校正后的尺寸及首帧解码；圆角黑边等逐像素构图由 App 保证。
 *       编码器仍须在后续帧解码失败时终止，不能仅凭首帧通过就发布产物。
 */
+ (nullable AVAsset *)validatedAssetAtPath:(NSString *)path
                             requirements:(TSDialVideoRequirements *)requirements
                                    error:(NSError *_Nullable *_Nullable)error;

@end

NS_ASSUME_NONNULL_END
