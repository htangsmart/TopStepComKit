//
//  TSUgreenDefines.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/10/14.
//

#ifndef TSUgreenDefines_h
#define TSUgreenDefines_h

#import <Foundation/Foundation.h>

/**
 * @brief Function entered after pressing the device button three times
 * @chinese 设备按键三击后进入的功能
 *
 * @discussion
 * [EN]: UGREEN customer-specific. Values match the device protocol (FitCloudUgreenTriplePressFunction).
 * [CN]: 绿联定制能力。取值与设备协议一致（FitCloudUgreenTriplePressFunction）。
 */
typedef NS_ENUM(NSInteger, TSUgreenTriplePressFunction) {
    /// 现场录音 （Start on-site recording）
    TSUgreenTriplePressFunctionOnSiteRecording = 0,
    /// 语音助手 （Start the voice assistant）
    TSUgreenTriplePressFunctionVoiceAssistant = 1,
};

/**
 * @brief Device pages that stay always on
 * @chinese 设备常亮页面
 *
 * @discussion
 * [EN]: Bit mask; several pages can be combined. TSUgreenAlwaysOnPageNone means no page stays always on.
 *       Values match the device protocol (FitCloudUgreenAlwaysOnPage).
 * [CN]: 位掩码，可组合多个页面；TSUgreenAlwaysOnPageNone 表示没有常亮页面。
 *       取值与设备协议一致（FitCloudUgreenAlwaysOnPage）。
 */
typedef NS_OPTIONS(NSUInteger, TSUgreenAlwaysOnPage) {
    /// 无常亮页面 （No always-on page）
    TSUgreenAlwaysOnPageNone         = 0,
    /// 音乐控制页 （Music control page）
    TSUgreenAlwaysOnPageMusicControl = 1 << 0,
    /// 状态页 （Status page）
    TSUgreenAlwaysOnPageStatus       = 1 << 1,
};

/// 当前协议定义的全部常亮页面位 （All always-on page bits defined by the current protocol）
static const TSUgreenAlwaysOnPage TSUgreenAlwaysOnPageAll = TSUgreenAlwaysOnPageMusicControl | TSUgreenAlwaysOnPageStatus;

/**
 * @brief Lyrics theme
 * @chinese 歌词主题
 *
 * @discussion
 * [EN]: Only TSUgreenLyricsThemeCustom uses TSUgreenConfigModel.lyricsColor; the preset themes use device colors.
 *       Values match the device protocol (FitCloudUgreenLyricsTheme).
 * [CN]: 仅 TSUgreenLyricsThemeCustom 使用 TSUgreenConfigModel.lyricsColor，预设主题使用设备内置配色。
 *       取值与设备协议一致（FitCloudUgreenLyricsTheme）。
 */
typedef NS_ENUM(NSInteger, TSUgreenLyricsTheme) {
    /// 自定义颜色 （Custom color, see lyricsColor）
    TSUgreenLyricsThemeCustom    = 0,
    /// 深海 （Deep sea）
    TSUgreenLyricsThemeDeepSea   = 1,
    /// 极光 （Aurora）
    TSUgreenLyricsThemeAurora    = 2,
    /// 星空 （Starry sky）
    TSUgreenLyricsThemeStarrySky = 3,
    /// 活力 （Vitality）
    TSUgreenLyricsThemeVitality  = 4,
};

#endif /* TSUgreenDefines_h */
