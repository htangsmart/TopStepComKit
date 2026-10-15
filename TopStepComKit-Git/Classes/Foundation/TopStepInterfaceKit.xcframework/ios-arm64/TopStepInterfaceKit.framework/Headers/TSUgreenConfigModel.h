//
//  TSUgreenConfigModel.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/10/14.
//

#import <UIKit/UIKit.h>
#import "TSKitBaseModel.h"
#import "TSUgreenDefines.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief UGREEN device configuration
 * @chinese 绿联设备配置
 *
 * @discussion
 * [EN]: UGREEN customer-specific feature, not part of the public SDK features.
 *       Read with TSUgreenInterface.fetchConfig: and written with setConfig:completion:.
 *       The device stores the configuration as a whole: setConfig:completion: overwrites every field,
 *       so fetch first, change the fields you need, then set the same model back.
 * [CN]: 绿联客户定制能力，不属于公版能力。
 *       通过 TSUgreenInterface.fetchConfig: 读取，setConfig:completion: 设置。
 *       设备按整包保存配置：setConfig:completion: 会覆盖全部字段，
 *       请先 fetch，修改需要的字段，再把同一个模型 set 回去。
 */
@interface TSUgreenConfigModel : TSKitBaseModel <NSCopying>

/**
 * @brief Whether desktop-stand mode is enabled
 * @chinese 是否开启桌搭模式
 */
@property (nonatomic, assign, getter=isDesktopModeEnabled) BOOL desktopModeEnabled;

/**
 * @brief Function entered after pressing the device button three times
 * @chinese 按键三击进入的功能
 *
 * @discussion
 * [EN]: Default is TSUgreenTriplePressFunctionOnSiteRecording.
 * [CN]: 默认 TSUgreenTriplePressFunctionOnSiteRecording。
 */
@property (nonatomic, assign) TSUgreenTriplePressFunction triplePressFunction;

/**
 * @brief Pages that stay always on
 * @chinese 常亮页面
 *
 * @discussion
 * [EN]: Bit mask of TSUgreenAlwaysOnPage. Default is TSUgreenAlwaysOnPageNone.
 * [CN]: TSUgreenAlwaysOnPage 位掩码，默认 TSUgreenAlwaysOnPageNone。
 */
@property (nonatomic, assign) TSUgreenAlwaysOnPage alwaysOnPages;

/**
 * @brief Lyrics theme
 * @chinese 歌词主题
 *
 * @discussion
 * [EN]: Default is TSUgreenLyricsThemeCustom.
 * [CN]: 默认 TSUgreenLyricsThemeCustom。
 */
@property (nonatomic, assign) TSUgreenLyricsTheme lyricsTheme;

/**
 * @brief Lyrics color
 * @chinese 歌词颜色
 *
 * @discussion
 * [EN]: Sent to the device as RGBA. Only used when lyricsTheme is TSUgreenLyricsThemeCustom,
 *       but it is always sent and must not be nil. Default is white.
 * [CN]: 以 RGBA 下发。仅在 lyricsTheme 为 TSUgreenLyricsThemeCustom 时生效，
 *       但每次都会下发，不能为 nil。默认白色。
 */
@property (nonatomic, strong) UIColor *lyricsColor;

@end

NS_ASSUME_NONNULL_END
