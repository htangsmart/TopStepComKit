//
//  TSSqllitePath.h
//  TopStepToolKit
//
//  Created by 磐石 on 2025/2/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSSqllitePath : NSObject

+ (NSString *)currentDatabasePath ;

+ (NSString *)backupDatabasePath ;

+ (NSString *)sqlPath ;



@end

NS_ASSUME_NONNULL_END
