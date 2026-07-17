//
//  TSLanguageDefines.h
//  Pods
//
//  Created by 磐石 on 2025/11/24.
//

#ifndef TSLanguageDefines_h
#define TSLanguageDefines_h

/**
 * @brief Supported language types
 * @chinese 支持的语言类型
 *
 * @discussion
 * [EN]: Defines all supported language types in the system.
 *      Used for language switching and localization.
 * [CN]: 定义系统中所有支持的语言类型。
 *      用于语言切换和本地化。
 */
typedef NS_ENUM(NSInteger, TSLanguageType) {
    /// 未设置 （Not set）
    TSLanguage_UNKNOW             = 0,
    /// 简体中文 （Simplified Chinese）
    TSLanguage_CHINESESIMPLIFIED  = 1,
    /// 繁体中文 （Traditional Chinese）
    TSLanguage_CHINESETRADITIONAL = 2,
    /// 英语 （English）
    TSLanguage_ENGLISH            = 3,
    /// 德语 （German）
    TSLanguage_GERMAN             = 4,
    /// 俄语 （Russian）
    TSLanguage_RUSSIAN            = 5,
    /// 西班牙语 （Spanish）
    TSLanguage_SPANISH            = 6,
    /// 葡萄牙语 （Portuguese）
    TSLanguage_PORTUGUESE         = 7,
    /// 法语 （French）
    TSLanguage_FRENCH             = 8,
    /// 日语 （Japanese）
    TSLanguage_JAPANESE           = 9,
    /// 阿拉伯语 （Arabic）
    TSLanguage_ARABIC             = 10,
    /// 荷兰语 （Dutch）
    TSLanguage_DUTCH              = 11,
    /// 意大利语 （Italian）
    TSLanguage_ITALIAN            = 12,
    /// 孟加拉语 （Bengali）
    TSLanguage_BENGALI            = 13,
    /// 克罗地亚语 （Croatian）
    TSLanguage_CROATIAN           = 14,
    /// 捷克语 （Czech）
    TSLanguage_CZECH              = 15,
    /// 丹麦语 （Danish）
    TSLanguage_DANISH             = 16,
    /// 希腊语 （Greek）
    TSLanguage_GREEK              = 17,
    /// 希伯来语 （Hebrew）
    TSLanguage_HEBREW             = 18,
    /// 印度语 （Hindi）
    TSLanguage_HINDI              = 19,
    /// 匈牙利语 （Hungarian）
    TSLanguage_HUN                = 20,
    /// 印度尼西亚语 （Indonesian）
    TSLanguage_INDONESIAN         = 21,
    /// 韩语 （Korean）
    TSLanguage_KOREAN             = 22,
    /// 马来语 （Malay）
    TSLanguage_MALAY              = 23,
    /// 波斯语 （Persian）
    TSLanguage_PERSIAN            = 24,
    /// 波兰语 （Polish）
    TSLanguage_POLISH             = 25,
    /// 罗马尼亚语 （Romanian）
    TSLanguage_RUMANIAN           = 26,
    /// 塞尔维亚语 （Serbian）
    TSLanguage_SERB               = 27,
    /// 瑞典语 （Swedish）
    TSLanguage_SWEDISH            = 28,
    /// 泰语 （Thai）
    TSLanguage_THAI               = 29,
    /// 土耳其语 （Turkish）
    TSLanguage_TURKISH            = 30,
    /// 乌尔都语 （Urdu）
    TSLanguage_URDU               = 31,
    /// 越南语 （Vietnamese）
    TSLanguage_VIETNAMESE         = 32,
    /// 加泰隆语 （Catalan）
    TSLanguage_CATALAN            = 33,
    /// 拉脱维亚语 （Latvian）
    TSLanguage_LATVIAN            = 34,
    /// 立陶宛语 （Lithuanian）
    TSLanguage_LITHUANIAN         = 35,
    /// 挪威语 （Norwegian）
    TSLanguage_NORWEGIAN          = 36,
    /// 斯洛伐克语 （Slovak）
    TSLanguage_SLOVAK             = 37,
    /// 斯洛文尼亚语 （Slovenian）
    TSLanguage_SLOVENIAN          = 38,
    /// 保加利亚语 （Bulgarian）
    TSLanguage_BULGARIAN          = 39,
    /// 乌克兰语 （Ukrainian）
    TSLanguage_UKRAINIAN          = 40,
    /// 菲律宾语 （Filipino）
    TSLanguage_FILIPINO           = 41,
    /// 芬兰语 （Finnish）
    TSLanguage_FINNISH            = 42,
    /// 南非语 （South African）
    TSLanguage_SOUTHAFRICAN       = 43,
    /// 罗曼什语 （Romansh）
    TSLanguage_ROMANSH            = 44,
    /// 缅甸语 （Burmese）
    TSLanguage_BURMESE            = 45,
    /// 柬埔寨语 （Cambodian）
    TSLanguage_CAMBODIAN          = 46,
    /// 阿姆哈拉语 （Amharic）
    TSLanguage_AMHARIC            = 47,
    /// 白俄罗斯语 （Belarusian）
    TSLanguage_BELARUSIAN         = 48,
    /// 爱沙尼亚语 （Estonian）
    TSLanguage_ESTONIAN           = 49,
    /// 斯瓦希里语 （Swahili）
    TSLanguage_SWAHILI            = 50,
    /// 祖鲁语 （Zulu）
    TSLanguage_ZULU               = 51,
    /// 阿塞拜疆语 （Azerbaijani）
    TSLanguage_AZERBAIJANI        = 52,
    /// 亚美尼亚语 （Armenian）
    TSLanguage_ARMENIAN           = 53,
    /// 格鲁吉亚语 （Georgian）
    TSLanguage_GEORGIAN           = 54,
    /// 老挝语 （Lao）
    TSLanguage_LAO                = 55,
    /// 蒙古语 （Mongolian）
    TSLanguage_MONGOLIAN          = 56,
    /// 尼泊尔语 （Nepali）
    TSLanguage_NEPALI             = 57,
    /// 哈萨克语 （Kazakh）
    TSLanguage_KAZAKH             = 58,
    /// 加利西亚语 （Galician）
    TSLanguage_GALICIAN           = 59,
    /// 冰岛语 （Icelandic）
    TSLanguage_ICELANDIC          = 60,
    /// 卡纳达语 （Kannada）
    TSLanguage_KANNADA            = 61,
    /// 吉尔吉斯语 （Kyrgyz）
    TSLanguage_KYRGYZ             = 62,
    /// 马拉雅拉姆语 （Malayalam）
    TSLanguage_MALAYALAM          = 63,
    /// 马拉提语 （Marathi）
    TSLanguage_MARATHI            = 64,
    /// 泰米尔语 （Tamil）
    TSLanguage_TAMIL              = 65,
    /// 马其顿语 （Macedonian）
    TSLanguage_MACEDONIAN         = 66,
    /// 泰卢固语 （Telugu）
    TSLanguage_TELUGU             = 67,
    /// 乌兹别克语 （Uzbek）
    TSLanguage_UZBEK              = 68,
    /// 巴斯克语 （Basque）
    TSLanguage_BASQUE             = 69,
    /// 僧伽罗语 （Sinhala）
    TSLanguage_BERBER             = 70,
    /// 阿尔巴尼亚语 （Albanian）
    TSLanguage_ALBANIAN           = 71,
    /// 豪萨语 （hausa）
    TSLanguage_HAUSA              = 72


};



#endif /* TSLanguageDefines_h */
