//
//  WMDialModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 表盘 （Dial plate）
@interface WMDialModel : NSObject

/// 表盘ID （Dial ID）
@property (nonatomic, copy) NSString *identifier;
/// 是否内置 （uilt-in or not）
@property (nonatomic, assign) BOOL isBuiltIn;
/// 是否当前 （Whether current）
@property (nonatomic, assign) BOOL isCurrent;

@end

NS_ASSUME_NONNULL_END
