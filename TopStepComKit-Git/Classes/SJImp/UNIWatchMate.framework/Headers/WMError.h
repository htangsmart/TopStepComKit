//
//  WMError.h
//  UNIWatchMate
//
//  Created by t_t on 2024/1/20.
//

#import <Foundation/Foundation.h>

#ifndef WMError_h
#define WMError_h

// 更新后的枚举，用作错误代码
typedef NS_ENUM(NSInteger, WMErrorCode) {
    WMErrorCodeDisconnect,            // 设备未连接（Device not connected）
    WMErrorCodeBusy,                  // 设备繁忙（Equipment busy）
    WMErrorCodeSport,                 // 运动中 （During the exercise）
    WMErrorCodeLowBattery,            // 设备电量低 （Low power of equipment）
    WMErrorCodeLowStorage,            // 内存不足 （Out of memory）
    WMErrorCodeReady,                 // 准备好 （Get ready）
    WMErrorCodeDialHasItsLimit,       // 表盘数量已达上限 （The number of dials has reached its limit）
    WMErrorCodeCustomDialFail,        // 自定义表盘失败 （Failed to customize the watch face）
    WMErrorCodeFileError,             // 文件有误 （File error）
    WMErrorCodeOther                  // 其他状态 （Other states）
};

NSError * WMErrorMake(WMErrorCode code, NSString *description);

#endif /* WMError_h */
