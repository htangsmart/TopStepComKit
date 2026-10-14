//
//  TSRealtimeDanMuPreviewView.h
//  TopStepComKit_Example
//

#import <UIKit/UIKit.h>
#import <TopStepComKit/TopStepComKit.h>

@class TSRealtimeDanMuDraft;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Preview backdrop options.
 * @chinese 预览背景档位。
 */
typedef NS_ENUM(NSInteger, TSRealtimeDanMuBackdrop) {
    /** @brief Bundled sample background. @chinese 内置示例背景。 */
    TSRealtimeDanMuBackdropDefault = 0,
    /** @brief Solid black. @chinese 纯黑。 */
    TSRealtimeDanMuBackdropBlack = 1,
    /** @brief Solid white, reveals unreadable white danmaku. @chinese 纯白，用于暴露白色弹幕不可读。 */
    TSRealtimeDanMuBackdropWhite = 2
};

/**
 * @brief Local danmaku preview shaped after the connected device screen.
 * @chinese 按已连接设备屏幕塑形的本地弹幕预览。
 *
 * @discussion
 * [EN]: The shell follows `screen.shape` / `screenSize` / `screenBorderRadius`, reusing the
 *       geometry rules of TSDialPreviewView without pulling in its dial rendering stack.
 *       Everything drawn here is an approximation, never the device's real output.
 * [CN]: 表壳跟随 `screen.shape` / `screenSize` / `screenBorderRadius`，沿用 TSDialPreviewView
 *       的几何规则，但不引入其表盘渲染栈。此处绘制的一切仅为近似，不代表设备真实输出。
 */
@interface TSRealtimeDanMuPreviewView : UIView

/** @brief Device screen description; nil falls back to a vertical rectangle. @chinese 设备屏幕信息，为空时回退竖向长方形。 */
@property (nonatomic, strong, nullable) TSPeripheralScreen *screen;
/** @brief Current backdrop. @chinese 当前背景档位。 */
@property (nonatomic, assign) TSRealtimeDanMuBackdrop backdrop;
/** @brief Backdrop changed by the user. @chinese 用户切换背景。 */
@property (nonatomic, copy, nullable) void (^onBackdropChanged)(TSRealtimeDanMuBackdrop backdrop);

/**
 * @brief Rebuilds the scrolling danmaku from drafts.
 * @chinese 依据草稿重建滚动弹幕。
 * @param drafts EN: Drafts to render. CN: 要渲染的草稿。
 */
- (void)reloadWithDrafts:(NSArray<TSRealtimeDanMuDraft *> *)drafts;

/**
 * @brief Starts the display link.
 * @chinese 启动刷新驱动。
 */
- (void)resume;

/**
 * @brief Stops the display link.
 * @chinese 停止刷新驱动。
 */
- (void)suspend;

@end

NS_ASSUME_NONNULL_END
