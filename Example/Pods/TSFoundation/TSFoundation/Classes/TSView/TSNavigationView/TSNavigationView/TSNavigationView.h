//
//  TSNavigationView.h
//  JieliJianKang
//
//  Created by 磐石 on 2023/12/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TSNavigationStyle) {
    eTSNavigationStyleDefault,// 默认黑字白底 ==eTSNavigationStyleBlack
    eTSNavigationStyleBlack,
    eTSNavigationStyleWhite,
};

@protocol TSNavigationViewDelegate <NSObject>

- (void)returnBack;

@optional

- (void)rightButtonEvnet:(UIButton *)sender;

@end


@interface TSNavigationView : UIView

@property (nonatomic,weak) id<TSNavigationViewDelegate> delegate;

-(instancetype)initWithDelegate:(id<TSNavigationViewDelegate>)viewDelegate;

- (void)setNavTitle:(NSString *)title;
- (void)setNavTitleColor:(UIColor *)titleColor;
- (void)setNavStyle:(TSNavigationStyle)style;
- (void)setRightButtonSelected:(BOOL)isSelected;
- (void)setRightButtonTitle:(NSString *)title;
- (void)setRightButtonTitle:(NSString *)title forState:(UIControlState)state;
- (void)setRightButtonTextColor:(UIColor *)color;
- (void)setRightButtonTitleFont:(UIFont *)font;
- (void)setRightButtonImage:(UIImage *)rightImage;
- (void)setRightButtonBackgroundColor:(UIColor *)color;


- (void)setBackButtonHidden:(BOOL)isHidden;
- (void)setRightButtonHidden:(BOOL)isHidden;

@end

NS_ASSUME_NONNULL_END
