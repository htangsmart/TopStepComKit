//
//  WMSupportProtocol.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 是否支持此功能 （Whether this function is supported）
@protocol WMSupportProtocol <NSObject>

/// 是否支持此功能 （Whether this function is supported）
- (BOOL)isSupport;

@end

NS_ASSUME_NONNULL_END
