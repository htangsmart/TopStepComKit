//
//  TSRealtimeDanMuLogView.h
//  TopStepComKit_Example
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Rolling record of interface calls made from this page.
 * @chinese 本页发起的接口调用滚动记录。
 *
 * @discussion
 * [EN]: Mirrors what the SDK prints to the console, so a tester can correlate the on-screen
 *       result with the `[TSFitRealtimeDanMu]` / `[TSNpkRealtimeDanMu]` log lines.
 * [CN]: 与 SDK 打到控制台的日志对应，测试时可将屏幕结果与
 *       `[TSFitRealtimeDanMu]` / `[TSNpkRealtimeDanMu]` 日志行对上。
 */
@interface TSRealtimeDanMuLogView : UIView

/** @brief Height required by the current content. @chinese 当前内容所需高度。 */
@property (nonatomic, assign, readonly) CGFloat preferredHeight;

/**
 * @brief Appends one call record.
 * @chinese 追加一条调用记录。
 * @param success EN: Call result. CN: 调用结果。
 * @param action EN: What was called. CN: 调用的动作。
 * @param detail EN: Elapsed time or error text. CN: 耗时或错误描述。
 */
- (void)appendSuccess:(BOOL)success action:(NSString *)action detail:(NSString *)detail;

/**
 * @brief Clears all records.
 * @chinese 清空全部记录。
 */
- (void)clearRecords;

@end

NS_ASSUME_NONNULL_END
