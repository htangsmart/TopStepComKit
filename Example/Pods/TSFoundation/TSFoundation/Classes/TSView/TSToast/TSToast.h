//
//  TSToast.h
//  JieliJianKang
//
//  Created by 磐石 on 2024/2/4.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TSToastType) {
    eTSToastText,
    eTSToastLoading,
    eTSToastTextLoading,
    eTSToastProgress,
//    ...
};

typedef NS_ENUM(NSUInteger, TSToastPosition) {
    eTSToastPositionMiddle = 0,
    eTSToastPositionTop,
    eTSToastPositionBottom,
};

@interface TSToastConfiger : NSObject

// type of toast, contain text\IndicatorView, maybe add other type
@property (nonatomic,assign) TSToastType toastType;
// when toast type is text, you can set toast position on superview,
@property (nonatomic,assign) TSToastPosition toastPosition;
// when toast type is text and position is top or botton ,you can set margin
@property (nonatomic,assign) CGFloat positionMargin;

@property (nonatomic,strong) NSString * toastContent;
@property (nonatomic,assign) CGFloat cornerRadius;
@property (nonatomic,weak) UIView * superView;

@property (nonatomic,strong) UIFont * textFont;
@property (nonatomic,strong) UIColor * textColor;

@end

@interface TSToast : UIView


+ (void)showLoadingOnView:(UIView *)superView;

+ (void)showLoadingOnView:(UIView *)superView dismissAfterDelay:(CGFloat)delay;

+ (void)showLoadingOnView:(UIView *)superView dismissAfterDelay:(CGFloat)delay complete:(void(^)(void))complete;

+ (void)showLoadingOnView:(UIView *)superView text:(NSString *)text;

+ (void)showLoadingOnView:(UIView *)superView text:(NSString *)text dismissAfterDelay:(CGFloat)delay;

+ (void)showText:(NSString *)text onView:(UIView *)superView;

+ (void)showText:(NSString *)text onView:(UIView *)superView dismissAfterDelay:(CGFloat)delay;

+ (void)showText:(NSString *)text onView:(UIView *)superView dismissAfterDelay:(CGFloat)delay complete:(void(^)(void))complete;

+ (void)showToastOnView:(UIView *)superView withConfiger:(TSToastConfiger *)configer;

+ (void)dismissLoadingOnView:(UIView *)superView;

+ (void)dismissLoadingOnView:(UIView *)superView afterDelay:(CGFloat)delay;

+ (void)dismissLoadingOnView:(UIView *)superView afterDelay:(CGFloat)delay complete:(void(^)(void))complete;

- (instancetype)initWithToastConfiger:(TSToastConfiger *)configer;

@end

NS_ASSUME_NONNULL_END
