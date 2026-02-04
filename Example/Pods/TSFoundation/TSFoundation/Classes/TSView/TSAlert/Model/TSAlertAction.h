//
//  TSAlertAction.h
//  JieliJianKang
//
//  Created by 磐石 on 2024/3/4.
//

#import <Foundation/Foundation.h>
#import "TSAlertError.h"

typedef TSAlertError*(^TSAlertValueVerifyBlock)(id actionValue);
typedef void(^TSAlertActionBlock)(id actionValue);

@interface TSAlertAction : NSObject

@property (nonatomic,strong) NSString * actionString;
@property (nonatomic,strong) UIColor * actionStringCorlor;
@property (nonatomic,strong) UIFont * actionFont;
// 背景颜色 和渐变色 二选一
@property (nonatomic,strong) UIColor * actionBackCorlor;
// 设置渐变色
@property (nonatomic,assign) BOOL isGradientColor;
// you will must set isGradientColor == yes before you set gradientBeginCorlor and gradientEndCorlor
@property (nonatomic,strong) UIColor * gradientBeginCorlor;
@property (nonatomic,strong) UIColor * gradientEndCorlor;
// 圆角
@property (nonatomic,assign) CGFloat actionCornerRadius;
// 执行
@property (nonatomic,copy) TSAlertActionBlock actionBlock;
@property (nonatomic,copy) TSAlertValueVerifyBlock valueVerifyBlock;



@end

