#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
@class TSNpkDialDeviceProfile;
NS_ASSUME_NONNULL_BEGIN

/** @brief Actual package format. @chinese 实际包格式。 */
typedef NS_ENUM(NSUInteger, TSNpkDialPackageFormat) {
    TSNpkDialPackageFormatLVGL,
    TSNpkDialPackageFormatGUI
};

/** @brief Metadata from one verified installation snapshot. @chinese 本次已校验安装快照的元数据。 */
@interface TSNpkDialInspectedPackage : NSObject
/**
 * @brief Package format recognized from the file contents
 * @chinese 根据文件内容识别的包格式
 *
 * @discussion
 * [EN]: GUI for a validated TOPSTEP/TBUI package, LVGL for a validated resource archive.
 *       Recognition does not rely on the filename extension.
 * [CN]: 已验证的 TOPSTEP/TBUI 包为 GUI，已验证的资源归档为 LVGL；
 *       不依赖文件扩展名识别。
 */
@property (nonatomic, assign, readonly) TSNpkDialPackageFormat format;
/**
 * @brief Dial identifier read from the verified package
 * @chinese 从已验证包读取的表盘编号
 *
 * @discussion
 * [EN]: A positive decimal identifier from the TBUI header or LVGL config.json Id.
 *       GUI is limited to 24 bits; LVGL accepts the full unsigned 64-bit range.
 * [CN]: 来自 TBUI 包头或 LVGL config.json 的 Id，为正十进制编号；
 *       GUI 限于 24 位，LVGL 接受完整无符号 64 位范围。
 */
@property (nonatomic, copy, readonly) NSString *dialId;
/**
 * @brief Task-owned file path used for upload
 * @chinese 上传使用的任务自有文件路径
 *
 * @discussion
 * [EN]: Points to the installation snapshot, or to a TAR rebuilt from a ZIP input.
 *       Subsequent upload uses this file instead of rereading the caller's source path.
 * [CN]: 指向安装快照，或由 ZIP 输入重建的 TAR；
 *       后续上传读取本文件，不再读取调用方源路径。
 */
@property (nonatomic, copy, readonly) NSString *uploadPath;
/**
 * @brief Complete upload file length in bytes
 * @chinese 完整上传文件长度，单位字节
 *
 * @discussion
 * [EN]: Measured from uploadPath after preparation. GUI includes the TOPSTEP header
 *       and TBUI body; LVGL is the prepared archive size. Used for slot capacity checks.
 * [CN]: 准备完成后从 uploadPath 读取；GUI 包括 TOPSTEP 头和 TBUI 体，
 *       LVGL 为准备后的归档大小，用于槽位容量判断。
 */
@property (nonatomic, assign, readonly) unsigned long long packageLength;
/**
 * @brief Captured target screen size in pixels
 * @chinese 捕获的目标屏幕像素尺寸
 *
 * @discussion
 * [EN]: Copied from the supplied device profile. GUI inspection also compares the
 *       package header dimensions with this size; LVGL does not derive it from screen.json.
 * [CN]: 从传入的设备快照复制；GUI 检查还会比较包头尺寸是否匹配，
 *       LVGL 不从 screen.json 推导本值。
 */
@property (nonatomic, assign, readonly) CGSize screenSize;
@end

/** @brief Recognize, validate and inspect; never chooses slots or manages task state.
 * @chinese 识别、校验和提取元数据，不选择槽位、不管理任务状态。
 */
@interface TSNpkDialPackageInspector : NSObject
/** @brief Prepare a task-owned package snapshot and validate the real content.
 * @chinese 准备任务所有的包快照并校验真实内容。
 * @param path EN: Caller input. CN: 调用方输入。
 * @param profile EN: Captured target facts. CN: 捕获的目标信息。
 * @param directory EN: Task-owned preparation directory. CN: 任务准备目录。
 * @param error EN: Failure. CN: 错误。
 * @return EN: Verified metadata, or nil. CN: 已校验元数据或 nil。
 */
+ (nullable TSNpkDialInspectedPackage *)inspectPath:(NSString *)path profile:(TSNpkDialDeviceProfile *)profile
                                        directory:(NSString *)directory error:(NSError *_Nullable *_Nullable)error;
@end
NS_ASSUME_NONNULL_END
