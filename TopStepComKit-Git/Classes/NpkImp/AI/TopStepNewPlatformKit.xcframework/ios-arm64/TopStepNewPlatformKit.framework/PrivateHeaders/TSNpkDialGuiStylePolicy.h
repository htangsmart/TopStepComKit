#import <Foundation/Foundation.h>
@class TSNpkDialDeviceProfile;
NS_ASSUME_NONNULL_BEGIN
/** @brief GUI cloud and identifier policy. @chinese GUI 云资源和编号策略。 */
@interface TSNpkDialGuiStylePolicy : NSObject
/** @brief Resolve the Android LCD table. @chinese 查询 Android LCD 映射表。
 * @param profile EN: Immutable device facts. CN: 不可变设备快照。
 * @param error EN: Unsupported size error. CN: 未知屏幕映射错误。
 * @return EN: LCD number or nil. CN: LCD 编号，失败返回 nil。 */
+ (nullable NSNumber *)lcdForProfile:(TSNpkDialDeviceProfile *)profile error:(NSError **)error;
/** @brief Resolve a generated package identifier. @chinese 确定新生成包的编号。
 * @param identifier EN: Optional decimal identifier. CN: 可选十进制编号。
 * @param lcd EN: Resolved LCD number. CN: 已解析 LCD 编号。
 * @param error EN: Invalid identifier error. CN: 非法编号错误。
 * @return EN: Nonzero identifier on success. CN: 成功时返回非零编号。 */
+ (NSUInteger)generatedIdentifier:(nullable NSString *)identifier lcd:(NSUInteger)lcd error:(NSError **)error;
@end
NS_ASSUME_NONNULL_END
