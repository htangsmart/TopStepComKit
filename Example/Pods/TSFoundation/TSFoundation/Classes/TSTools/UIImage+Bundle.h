//
//  UIImage+Bundle.h
//  TSFoundation
//
//  Created by 磐石 on 2024/8/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Bundle)

+(UIImage *)imageNamed:(NSString *)name inBundle:(NSBundle *)bundle;

@end

NS_ASSUME_NONNULL_END
