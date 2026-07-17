//
//  TSSqlliteBackup.h
//  TopStepToolKit
//
//  Created by 磐石 on 2025/2/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSSqlliteBackup : NSObject

+ (void)backupDatabase ;

+ (void)restoreDatabase;

@end

NS_ASSUME_NONNULL_END
