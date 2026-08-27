//
//  TSDeviceInfoTool.h
//  TopStepToolKit
//
//  Created by 磐石 on 2026/6/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSDeviceInfoTool : NSObject

+ (NSString *)brand;
+ (NSString *)model;
+ (NSString *)systemVersion;

@end

NS_ASSUME_NONNULL_END
