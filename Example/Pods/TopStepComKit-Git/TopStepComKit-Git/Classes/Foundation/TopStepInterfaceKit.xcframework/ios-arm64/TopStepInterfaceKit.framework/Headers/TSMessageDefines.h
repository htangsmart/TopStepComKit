//
//  TSMessageDefines.h
//  Pods
//
//  Created by 磐石 on 2025/11/5.
//

#ifndef TSMessageDefines_h
#define TSMessageDefines_h

/**
 * @brief Message notification types supported by the device
 * @chinese 设备支持的消息通知类型
 *
 * @discussion
 * [EN]: Defines all possible message notification types that can be supported by the device.
 *      Each type represents a specific notification category.
 * [CN]: 定义设备可能支持的所有消息通知类型。
 *      每种类型代表特定的通知类别。
 */

typedef NS_ENUM(NSInteger, TSMessageType) {
    /// 总数 （Total number of message types）
    TSMessage_Total               = 0,
    /// 电话 （Phone call notifications）
    TSMessage_Phone               = 1,
    /// 短信 （SMS notifications）
    TSMessage_Messages            = 2,
    /// 微信 （WeChat notifications）
    TSMessage_WeChat              = 3,
    /// QQ （QQ notifications）
    TSMessage_QQ                  = 4,
    /// Facebook （Facebook notifications）
    TSMessage_Facebook            = 5,
    /// 推特 （Twitter notifications）
    TSMessage_Twitter             = 6,
    /// Instagram （Instagram notifications）
    TSMessage_Instagram           = 7,
    /// Skype （Skype notifications）
    TSMessage_Skype               = 8,
    /// WhatsApp （WhatsApp notifications）
    TSMessage_WhatsApp            = 9,
    /// Line （Line notifications）
    TSMessage_Line                = 10,
    /// KakaoTalk （KakaoTalk notifications）
    TSMessage_KakaoTalk           = 11,
    /// 邮件 （Email notifications）
    TSMessage_Email               = 12,
    /// Messenger （Facebook Messenger notifications）
    TSMessage_Messenger           = 13,
    /// Zalo （Zalo notifications）
    TSMessage_Zalo                = 14,
    /// Telegram （Telegram notifications）
    TSMessage_Telegram            = 15,
    /// Viber （Viber notifications）
    TSMessage_Viber               = 16,
    /// NateOn （NateOn notifications）
    TSMessage_NateOn              = 17,
    /// Gmail （Gmail notifications）
    TSMessage_Gmail               = 18,
    /// 日历 （Calendar notifications）
    TSMessage_Calendar            = 19,
    /// DailyHunt （DailyHunt notifications）
    TSMessage_DailyHunt           = 20,
    /// Outlook （Outlook notifications）
    TSMessage_Outlook             = 21,
    /// Yahoo （Yahoo notifications）
    TSMessage_Yahoo               = 22,
    /// Inshorts （Inshorts notifications）
    TSMessage_Inshorts            = 23,
    /// Phonepe （Phonepe notifications）
    TSMessage_Phonepe             = 24,
    /// Google Pay （Google Pay notifications）
    TSMessage_Gpay                = 25,
    /// Paytm （Paytm notifications）
    TSMessage_Paytm               = 26,
    /// Swiggy （Swiggy notifications）
    TSMessage_Swiggy              = 27,
    /// Zomato （Zomato notifications）
    TSMessage_Zomato              = 28,
    /// Uber （Uber notifications）
    TSMessage_Uber                = 29,
    /// Ola （Ola notifications）
    TSMessage_Ola                 = 30,
    /// ReflexApp （ReflexApp notifications）
    TSMessage_ReflexApp           = 31,
    /// Snapchat （Snapchat notifications）
    TSMessage_Snapchat            = 32,
    /// YouTube Music （YouTube Music notifications）
    TSMessage_YtMusic             = 33,
    /// YouTube （YouTube notifications）
    TSMessage_YouTube             = 34,
    /// LinkedIn （LinkedIn notifications）
    TSMessage_LinkEdin            = 35,
    /// Amazon （Amazon notifications）
    TSMessage_Amazon              = 36,
    /// Flipkart （Flipkart notifications）
    TSMessage_Flipkart            = 37,
    /// Netflix （Netflix notifications）
    TSMessage_NetFlix             = 38,
    /// Hotstar （Hotstar notifications）
    TSMessage_Hotstar             = 39,
    /// Amazon Prime （Amazon Prime notifications）
    TSMessage_AmazonPrime         = 40,
    /// Google Chat （Google Chat notifications）
    TSMessage_GoogleChat          = 41,
    /// Wynk （Wynk notifications）
    TSMessage_Wynk                = 42,
    /// Google Drive （Google Drive notifications）
    TSMessage_GoogleDrive         = 43,
    /// Dunzo （Dunzo notifications）
    TSMessage_Dunzo               = 44,
    /// Gaana （Gaana notifications）
    TSMessage_Gaana               = 45,
    /// 未接来电 （Missed call notifications）
    TSMessage_MissCall            = 46,
    /// WhatsApp Business （WhatsApp Business notifications）
    TSMessage_WhatsAppBusiness    = 47,
    /// 钉钉 （Dingtalk notifications）
    TSMessage_Dingtalk            = 48,
    /// TikTok （TikTok notifications）
    TSMessage_Tiktok              = 49,
    /// Lyft （Lyft notifications）
    TSMessage_Lyft                = 50,
    /// Google Maps （Google Maps notifications）
    TSMessage_GoogleMaps          = 51,
    /// Slack （Slack notifications）
    TSMessage_Slack               = 52,
    /// Microsoft Teams （Microsoft Teams notifications）
    TSMessage_MicrosoftTeams      = 53,
    /// Mormaii Smartwatches （Mormaii Smartwatches notifications）
    TSMessage_MormaiiSmartwatches = 54,
    /// Reddit （Reddit notifications）
    TSMessage_Reddit              = 55,
    /// Discord （Discord notifications）
    TSMessage_Discord             = 56,
    /// Gojek （Gojek notifications）
    TSMessage_Gojek               = 57,
    /// 飞书 （Lark notifications）
    TSMessage_Lark                = 58,
    /// Garb （Garb notifications）
    TSMessage_Garb                = 59,
    /// Shopee （Shopee notifications）
    TSMessage_Shopee              = 60,
    /// Tokopedia （Tokopedia notifications）
    TSMessage_Tokopedia           = 61,
    /// Hinge通知 （Hinge notifications）
    TSMessage_Hinge               = 62,
    /// Myntra通知 （Myntra notifications）
    TSMessage_Myntra              = 63,
    /// Meesho通知 （Meesho notifications）
    TSMessage_Meesho              = 64,
    /// Zivame通知 （Zivame notifications）
    TSMessage_Zivame              = 65,
    /// Ajio通知 （Ajio notifications）
    TSMessage_Ajio                = 66,
    /// Urbanic通知 （Urbanic notifications）
    TSMessage_Urbanic             = 67,
    /// Nykaa通知 （Nykaa notifications）
    TSMessage_Nykaa               = 68,
    /// Healthifyme通知 （Healthifyme notifications）
    TSMessage_Healthifyme         = 69,
    /// Cultfit通知 （Cultfit notifications）
    TSMessage_Cultfit             = 70,
    /// Flo通知 （Flo notifications）
    TSMessage_Flo                 = 71,
    /// Bumble通知 （Bumble notifications）
    TSMessage_Bumble              = 72,
    /// Tira通知 （Tira notifications）
    TSMessage_Tira                = 73,
    /// Hike通知 （Hike notifications）
    TSMessage_Hike                = 74,
    /// Apple Music通知 （Apple Music notifications）
    TSMessage_AppleMusic          = 75,
    /// Zoom通知 （Zoom notifications）
    TSMessage_Zoom                = 76,
    /// Fastrack通知 （Fastrack notifications）
    TSMessage_Fastrack            = 77,
    /// Titan Smart World通知 （Titan Smart World notifications）
    TSMessage_TitanSmartWorld     = 78,
    /// Pinterest通知 （Pinterest notifications）
    TSMessage_Pinterest           = 79,
    /// 支付宝通知 （Alipay notifications）
    TSMessage_Alipay              = 80,
    /// FaceTime通知 （FaceTime notifications）
    TSMessage_FaceTime            = 81,
    /// Hangouts通知 （Hangouts notifications）
    TSMessage_Hangouts            = 82,
    /// VK通知 （VK notifications）
    TSMessage_VK                  = 83,
    /// 微博通知 （Weibo notifications）
    TSMessage_Weibo               = 84,
    /// 其他APP通知 （Other app notifications）
    TSMessage_Other               = 85
};


#endif /* TSMessageDefines_h */
