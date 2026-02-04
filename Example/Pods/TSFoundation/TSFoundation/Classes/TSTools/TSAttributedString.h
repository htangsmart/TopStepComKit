//
//  TSAttributedString.h
//  JieliJianKang
//
//  Created by 磐石 on 2024/1/23.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>  // 添加 UIKit 引用

NS_ASSUME_NONNULL_BEGIN

@interface TSAttributedString : NSObject

+ (NSAttributedString *)attributedStringWithString:(NSString *)targetString font:(UIFont *)font textColor:(UIColor *)textColor;

+ (NSAttributedString *)attributedStringWithString:(NSString *)targetString font:(UIFont *)font textColor:(UIColor *)textColor link:(NSString *)link;

+ (NSAttributedString *)attributedStringWithString:(NSString *)targetString font:(UIFont *)font textColor:(UIColor *)textColor lineSpace:(CGFloat)lineSpace alignment:(NSTextAlignment)alignment ;


+ (NSAttributedString *)attributedStringWithString:(NSString *)targetString subString:(NSString *)subString font:(UIFont *)font textColor:(UIColor *)textColor subFont:(UIFont *)subFont subColor:(UIColor *)subColor ;

@end

NS_ASSUME_NONNULL_END
