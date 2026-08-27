//
//  StarburstConfig.h
//  StarburstSdk
//
//  Created by liangshi on 2025/6/18.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSInteger,StarburstSdkType) {
    StarburstSdkType_Ble = 1,/// 设备鉴权+设备拾音（对话sdk内部封装耳机录音ble传输）
    StarburstSdkType_Phone = 2,/// 账号鉴权+手机拾音（对话sdk内部封装手机录音）
    StarburstSdkType_Mix = 3,/// 设备鉴权+手机拾音（对话sdk内部封装手机录音）
    StarburstSdkType_Glasses_Ble = 4,/// 眼镜板+设备鉴权（对话需要外部喂音频流）
    StarburstSdkType_Glasses_Account = 5,/// 眼镜板+账号鉴权（对话需要外部喂音频流）
};


@interface StarburstConfig : NSObject
@property (nonatomic, readonly)NSString *logs;/// 获取日志
@property (nonatomic, strong)void (^logCallback)(NSString *log);/// 日志输出回调
@property (nonatomic, assign)BOOL isDebug;/// 是否打印日志，默认false
@property (nonatomic, strong)NSString *logPath;/// 日志路径，不设置不保存日志
@property (nonatomic, strong)NSString *sdkFolder;/// sdk路径，可以自定义
@property (nonatomic, strong)NSDictionary *debugInfo;/// 调试信息
@property (nonatomic, strong)NSString *user_custom_prompt_init;/// voicechat配置
@property (nonatomic, assign) CGFloat ttsSpeed;//默认1.0，范围[0.8,2]

@property (nonatomic, assign)BOOL enableEarbudsSwitchSync;/// 主从耳机切换是否同步sdk信息到耳机，默认false
@property (nonatomic, assign)BOOL enableTextSyncToDevice;/// 是否下发文字到耳机仓，默认false
@property (nonatomic, assign)BOOL enableEmotionSyncToDevice;/// 耳机仓表情下发开关，默认false
@property (nonatomic, assign)BOOL enableSpeakerSeparate;/// 是否开启人话分离，默认false
@property (nonatomic, assign)NSInteger callRecordChannel;/// 通话录音声道数。1：单声道 ；2：⽴体声；默认单声道
//enableExternalOpusDecoder
@property (nonatomic, strong)NSString *appId;/// 分配的id
@property (nonatomic, readonly)StarburstSdkType sdkType;/// sdk类型

/// 单利
+ (instancetype)shared;

/// 切换sdk
- (void)switchTo:(StarburstSdkType)type;
@end

