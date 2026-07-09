//
//  TSAIChatReportDialog.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/19.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TSAIChatReport;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Modal dialog displaying the final `TSAIChatReport`
 * @chinese 展示最终 `TSAIChatReport` 的模态弹层
 *
 * @discussion
 * [EN]: Renders task ID, time range, duration, round count and end reason in a
 *       compact card. Optional `errorMessage` (e.g. BLE / network) appears in
 *       red below the standard rows. Provides a `Copy JSON` action that puts a
 *       human-readable JSON snapshot into the system pasteboard for bug
 *       reports. Dismisses on `Done`.
 * [CN]: 紧凑卡片中展示 taskId、时间区间、时长、轮次与结束原因。
 *       可选的 `errorMessage`（如 BLE / 网络）以红色追加在标准字段下方。
 *       提供「复制 JSON」按钮，把可读 JSON 快照写入系统剪贴板，便于贴 bug 单。
 *       点击「好的」关闭弹层。
 */
@interface TSAIChatReportDialog : UIViewController

/**
 * @brief Designated initializer
 * @chinese 指定初始化方法
 *
 * @param report
 * EN: Report to render
 * CN: 待渲染的报告
 *
 * @param errorMessage
 * EN: Optional error description; nil means normal end
 * CN: 可选错误说明；nil 表示正常结束
 */
- (instancetype)initWithReport:(TSAIChatReport *)report
                  errorMessage:(nullable NSString *)errorMessage NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil
                          bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
