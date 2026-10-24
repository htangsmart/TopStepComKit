#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
NS_ASSUME_NONNULL_BEGIN
/** @brief 579X LVGL extension, separate from the general AVI container. @chinese 独立于通用 AVI 容器的 579X LVGL 尾块。 */
@interface TSNpkAviLGEXWriter : NSObject
/** @brief Read avih.dwTotalFrames from a completed AVI. @chinese 从完成 AVI 读取 avih.dwTotalFrames。
 * @param path EN: AVI path. CN: AVI 路径。
 * @param error EN: Format error. CN: 格式错误。
 * @return EN: Positive count, zero on error. CN: 正数帧数，错误返回 0。 */
+ (NSUInteger)totalFramesInAVIPath:(NSString *)path error:(NSError **)error;
/** @brief Append the exact 60-byte LVGL tail once. @chinese 仅追加一次精确 60 字节 LVGL 尾块。
 * @param path EN: Completed AVI path. CN: 已完成 AVI 路径。
 * @param screenSize EN: Screen shape, never video encoding size. CN: 屏幕外形尺寸，不能用视频编码尺寸。
 * @param error EN: Format or write error. CN: 格式或写入错误。
 * @return EN: Append success. CN: 是否追加成功。 */
+ (BOOL)appendToAVIPath:(NSString *)path screenSize:(CGSize)screenSize error:(NSError **)error;
@end
NS_ASSUME_NONNULL_END
