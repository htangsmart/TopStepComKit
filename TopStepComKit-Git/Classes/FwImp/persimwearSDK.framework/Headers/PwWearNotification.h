//
//  PwWearNotification.h
//  persimwearSDK
//
//  Created by rtt on 2023/6/11.
//

@interface MsgType : NSObject

@property (class, nonatomic, copy) NSString *textMsg;
@property (class, nonatomic, copy) NSString *PictureMsg;
@property (class, nonatomic, copy) NSString *ScheduleMsg;

@end


@interface NotificationWay : NSObject

@property (class, nonatomic, copy) NSString *Shock;
@property (class, nonatomic, copy) NSString *Voice;
@property (class, nonatomic, copy) NSString *ShockAndVoice;
@property (class, nonatomic, copy) NSString *NoPrompt;

@end


@interface PwWearNotification : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *icon_path;
@property (nonatomic, copy) NSString *sender;
@property (nonatomic, copy) NSString *text_content;
@property (nonatomic, copy) NSString *image_context_path;
@property (nonatomic, copy) NSString *msg_type;
@property (nonatomic, copy) NSString *notification_way;
@property (nonatomic) NSInteger priority;
@property (nonatomic) NSInteger arrived_time;

@end
