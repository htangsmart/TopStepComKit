//
//  WMMessageModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/10/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSInteger, WMMessageType) {
    WMMessageTypeMessages           = 1 << 0,
    WMMessageTypeFacebook           = 1 << 1,
    WMMessageTypeGmail              = 1 << 2,
    WMMessageTypeInstagram          = 1 << 3,
    WMMessageTypeiOSMail            = 1 << 4,
    WMMessageTypeLINE               = 1 << 5,
    WMMessageTypeLinkedIn           = 1 << 6,
    WMMessageTypeMessenger          = 1 << 7,
    WMMessageTypeOutlook            = 1 << 8,
    WMMessageTypeQQ                 = 1 << 9,
    WMMessageTypeSkype              = 1 << 10,
    WMMessageTypeSnapchat           = 1 << 11,
    WMMessageTypeTelegram           = 1 << 12,
    WMMessageTypeTwitter            = 1 << 13,
    WMMessageTypeWeChat             = 1 << 14,
    WMMessageTypeWhatsApp           = 1 << 15,
    WMMessageTypeWhatsAppBusiness   = 1 << 16,
};

@interface WMMessageModel : NSObject

/// 接打电话开关 （Make and receive switch）
@property (nonatomic, assign) BOOL isOnCall;
/// 消息总开关 （消息总开关）
@property (nonatomic, assign) BOOL isOpen;
/// 支持的消息类型 （Supported message types）
@property (nonatomic, assign) WMMessageType type;

@end

NS_ASSUME_NONNULL_END
