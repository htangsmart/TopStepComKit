//
//  JLPhoneUISetting.h
//  JieliJianKang
//
//  Created by Topstep on 2022/1/11.
//

#import <Foundation/Foundation.h>
#import "LanguageCls.h"

#ifndef IphoneSize_h
#define IphoneSize_h

/*--- 多语言 ---*/
#define kJL_GET         [LanguageCls checkLanguage]             //[DFUITools systemLanguage]//获取系统语言
#define kJL_SET(lan)    [LanguageCls setLangague:@(lan)]        //设置系统语言
#define kJL_SET_D(lan)    [LanguageCls setLangague:(lan)]        //设置系统语言
#define kJL_TXT(key)    [LanguageCls localizableTxt:@(key)]     //多语言转换,"Localizable"根据项目的多语言包填写。
#define kJL_TXT_chinese(key)    [LanguageCls localizableTxt:@(key)]     //未校对文本多语言


#pragma mark - Tab/Navigate 高度
#define kJL_Dev_width [UIScreen mainScreen].bounds.size.width
#define kJL_Dev_height [UIScreen mainScreen].bounds.size.height

//判断是否是ipad
#define kJL_IS_IPAD ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
//判断iPhone4系列
#define kJL_IS_IPHONE_4 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) && !kJL_IS_IPAD : NO)
//判断iPhone5系列
#define kJL_IS_IPHONE_5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) && !kJL_IS_IPAD : NO)
//判断iPhone6系列
#define kJL_IS_IPHONE_6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) && !kJL_IS_IPAD : NO)
//判断iphone6+系列
#define kJL_IS_IPHONE_6_PLUS ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) && !kJL_IS_IPAD : NO)
//判断iPhoneX
#define kJL_IS_IPHONE_X ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) && !kJL_IS_IPAD : NO)
//判断iPHoneXr
#define kJL_IS_IPHONE_Xr ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(828, 1792), [[UIScreen mainScreen] currentMode].size) && !kJL_IS_IPAD : NO)
//判断iPhoneXs
#define kJL_IS_IPHONE_Xs ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) && !kJL_IS_IPAD : NO)
#define kJL_IS_IPHONE_12P ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1170, 2532), [[UIScreen mainScreen] currentMode].size) && !kJL_IS_IPAD : NO)
//判断iPhoneXs Max
#define kJL_IS_IPHONE_Xs_Max ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2688), [[UIScreen mainScreen] currentMode].size) && !kJL_IS_IPAD : NO)
#define kJL_IS_IPHONE_12P_Max ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1284, 2778), [[UIScreen mainScreen] currentMode].size) && !kJL_IS_IPAD : NO)

#define kJL_HeightStatusBar ([UIApplication sharedApplication].delegate.window.safeAreaInsets.top > 20 ? 44.0 : 20.0)
#define kJL_HeightNavBar ([UIApplication sharedApplication].delegate.window.safeAreaInsets.top > 20 ? 88.0 : 64.0)
#define kJL_HeightTabBar ([UIApplication sharedApplication].delegate.window.safeAreaInsets.top > 20 ? 83.0 : 49.0)
#define kJL_HeightBottomSafeArea ([UIApplication sharedApplication].delegate.window.safeAreaInsets.top > 20 ? 34.0 : 0.0)

#define kDF_RGBA(r,g,b,a)   [UIColor colorWithRed:((r)/255.0) green:((g)/255.0) blue:((b)/255.0) alpha:(a)]
#define kJL_COLOR_MAIN          kDF_RGBA(128, 91, 235, 1)
#define kJL_COLOR_ASSIST_BLUE   kDF_RGBA(85, 140, 255, 1)
#define kJL_COLOR_ASSIST_GREEN  kDF_RGBA(119, 206, 64, 1)
#define kJL_COLOR_ASSIST_RED    kDF_RGBA(224, 109, 99, 1)
#define kJL_COLOR_ASSIST_YELLOW kDF_RGBA(253, 184, 90, 1)
#define kJL_COLOR_ASSIST_BLACK  kDF_RGBA(36, 36, 36, 1)
#define kJL_COLOR_ASSIST_DARK   kDF_RGBA(75, 75, 75, 1)
#define kJL_COLOR_ASSIST_GRAY   kDF_RGBA(145, 145, 145, 1)
#define kJL_COLOR_ASSIST_GRAY_1 kDF_RGBA(247, 247, 247, 1)
#define kJL_COLOR_ASSIST_GRAY_2 kDF_RGBA(246, 247, 248, 1)
#define kColor_0000             [UIColor colorWithRed:137.0/255.0 green:94.0/255.0 blue:233.0/255.0 alpha:1.0]

#define NSLogEx(fmt, ...) NSLog((@"[文件名:%s]" "[函数名:%s]" "[行号:%d]" fmt), __FILE_NAME__, __FUNCTION__, __LINE__, ##__VA_ARGS__);

#endif /* IphoneSize_h */
