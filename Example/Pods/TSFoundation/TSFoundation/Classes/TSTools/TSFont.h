//
//  TSFont.h
//  JieliJianKang
//
//  Created by 磐石 on 2023/12/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define LFont_PF(size) [TSFont TSFontPingFangLightWithSize:size]
#define MFont_PF(size) [TSFont TSFontPingFangMediumWithSize:size]
#define RFont_PF(size) [TSFont TSFontPingFangRegularWithSize:size]
#define BFont_PF(size) [TSFont TSFontDINAlternateBoldWithSize:size]
#define SBFont_PF(size) [TSFont TSFontPingFangSemiboldWithSize:size]

@interface TSFont : NSObject

+ (UIFont *)TSFontPingFangRegularWithSize:(CGFloat)fontSize;

+ (UIFont *)TSFontPingFangLightWithSize:(CGFloat)fontSize;

+ (UIFont *)TSFontPingFangMediumWithSize:(CGFloat)fontSize;

+ (UIFont *)TSFontPingFangSemiboldWithSize:(CGFloat)fontSize;

+ (UIFont *)TSFontDINAlternateBoldWithSize:(CGFloat)fontSize;

@end

NS_ASSUME_NONNULL_END
