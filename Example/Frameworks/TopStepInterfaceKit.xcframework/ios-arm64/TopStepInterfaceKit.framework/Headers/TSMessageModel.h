//
//  TSMessageModel.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Message notification types supported by the device
 */
typedef NS_ENUM(NSUInteger, TSMessageType) {
    TSMessageTypeNone = 0,              // No notifications
    TSMessageTypeTelephony = 1,         // Phone call notifications
    TSMessageTypeSMS = 2,               // SMS notifications
    TSMessageTypeMail = 3,              // Mail notifications
    TSMessageTypeWeChat = 4,            // WeChat notifications
    TSMessageTypeQQ = 5,                // QQ notifications
    TSMessageTypeFacebook = 6,          // Facebook notifications
    TSMessageTypeTwitter = 7,           // Twitter notifications
    TSMessageTypeWhatsApp = 8,          // WhatsApp notifications
    TSMessageTypeLinkedIn = 9,          // LinkedIn notifications
    TSMessageTypeInstagram = 10,        // Instagram notifications
    TSMessageTypeFacebookMessenger = 11, // Facebook Messenger notifications
    TSMessageTypeSnapchat = 12,         // Snapchat notifications
    TSMessageTypeLine = 13,             // Line notifications
    TSMessageTypeKakaoTalk = 14,        // KakaoTalk notifications
    TSMessageTypeViber = 15,            // Viber notifications
    TSMessageTypeSkype = 16,            // Skype notifications
    TSMessageTypeTelegram = 17,         // Telegram notifications
    TSMessageTypePinterest = 18,        // Pinterest notifications
    TSMessageTypeYouTube = 19,          // YouTube notifications
    TSMessageTypeAppleMusic = 20,       // Apple Music notifications
    TSMessageTypeZoom = 21,             // Zoom notifications
    TSMessageTypeTikTok = 22,           // TikTok notifications
    TSMessageTypeHike = 23,             // Hike notifications
    TSMessageTypeWhatsAppBusiness = 24, // WhatsApp Business notifications
    TSMessageTypeOutlook = 25,          // Outlook notifications
    TSMessageTypeGmail = 26,            // Gmail notifications
    TSMessageTypeDefault = 27           // Default notification type
};

/**
 * @brief 消息通知模型
 * @discussion 用于管理设备的各类消息通知设置
 */
@interface TSMessageModel : NSObject

/**
 * @brief 消息类型
 * @discussion 表示当前消息的类型，详见TSMessageType枚举
 */
@property (nonatomic, assign) TSMessageType type;

/**
 * @brief 消息名称
 * @discussion 消息类型的显示名称，用于UI展示
 */
@property (nonatomic, strong) NSString *name;

/**
 * @brief 是否启用
 * @discussion YES表示启用该类型的通知，NO表示禁用
 */
@property (nonatomic, assign) BOOL enable;

/**
 * @brief 创建消息模型
 * @param type 消息类型
 * @param name 消息名称
 * @param enable 是否启用
 * @return 消息模型实例
 */
+ (instancetype)messageWithType:(TSMessageType)type name:(NSString * _Nullable)name enable:(BOOL)enable;


@end

NS_ASSUME_NONNULL_END
