//
//  TSAlertConfiger.h
//  JieliJianKang
//
//  Created by 磐石 on 2024/3/4.
//

#import <Foundation/Foundation.h>
#import "TSAlertAction.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TSAlertType) {
    eTSAlertTypeShowText,
    eTSAlertTypeInputView,
    eTSAlertTypeCustomView,
};

@interface TSAlertConfiger : NSObject


@property (nonatomic,assign) TSAlertType alertType;

@property (nonatomic,strong) NSString * title;
@property (nonatomic,strong) UIColor * titleColor;
@property (nonatomic,strong) UIFont * titleFont;
@property (nonatomic,assign) NSTextAlignment titleTextAlignment;

@property (nonatomic,strong) NSString * content;
@property (nonatomic,strong) UIColor * contentColor;
@property (nonatomic,strong) UIColor * contentBackgroundColor;
@property (nonatomic,strong) UIFont * contentFont;
@property (nonatomic,assign) NSTextAlignment contentTextAlignment;

// 背景圆角
@property (nonatomic,assign) CGFloat alerViewCornerRadius;
// 点击灰色区域是否取消
@property (nonatomic,assign) BOOL dismissWhenTapBackground;
// 所有按钮
@property (nonatomic,strong) NSArray <TSAlertAction *>* actions;


/*
 maybe you will set contentCornerRadius if alertType == eTSAlertTypeInputView
*/
@property (nonatomic,assign) CGFloat contentCornerRadius;

@property (nonatomic,assign) UIKeyboardType keyboardType;


@property (nonatomic,strong) NSArray * alertItemArray;
@property (nonatomic,assign) CGFloat cellHeight;
//@property (nonatomic,assign) CGFloat cellHeight;

@end

NS_ASSUME_NONNULL_END
