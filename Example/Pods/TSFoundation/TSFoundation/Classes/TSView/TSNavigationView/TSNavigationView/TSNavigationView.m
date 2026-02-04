//
//  TSNavigationView.m
//  JieliJianKang
//
//  Created by 磐石 on 2023/12/26.
//

#import "TSNavigationView.h"
#import "TSFont.h"
#import "TSFoundation/TSColor.h"
#import "TSFrame.h"
#import "UIImage+Bundle.h"
#import "NSBundle+TSFoundation.h"

@interface TSNavigationView ()

@property (nonatomic,strong) UIButton * backButton;

@property (nonatomic,strong) UILabel * navTitleLabel;

@property (nonatomic,strong) UIButton * rightButton;

@end

@implementation TSNavigationView


- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initData];
        [self initViews];
        [self layoutViews];
    }
    return self;
}

- (instancetype)initWithDelegate:(id)viewDelegate{
    self = [super init];
    if (self) {
        _delegate = viewDelegate;
        [self initData];
        [self initViews];
        [self layoutViews];
    }
    return self;
}

- (void)initData{
    
    self.backgroundColor = [UIColor whiteColor];
}

- (void)initViews{
    
    [self addSubview:self.navTitleLabel];
    [self addSubview:self.backButton];
    [self addSubview:self.rightButton];
}

- (void)layoutViews{
    
    self.backButton.frame = CGRectMake(6, [TSFrame safeAreaTop], 44, 44);
    self.navTitleLabel.frame = CGRectMake(self.backButton.maxX+15,  [TSFrame safeAreaTop], [TSFrame screenWidth]-(2*(self.backButton.maxX+15)),44);
    self.rightButton.frame = CGRectMake([TSFrame screenWidth]-15-44,[TSFrame safeAreaTop] , 44, 44);
}

- (void)setNavTitle:(NSString *)title{
    
    self.navTitleLabel.text = title;
    
}

- (void)setNavTitleColor:(UIColor *)titleColor{
    self.navTitleLabel.textColor = titleColor;
}
- (void)setNavStyle:(TSNavigationStyle)style{
    if (style == eTSNavigationStyleWhite) {
        [self.backButton setImage:[UIImage imageNamed:@"icon_return_nol_white" inBundle:[NSBundle foundationBundle]] forState:UIControlStateNormal];
    }else{
        [self.backButton setImage:[UIImage imageNamed:@"icon_return_nol_black" inBundle:[NSBundle foundationBundle]] forState:UIControlStateNormal];
    }
}

- (void)setBackButtonHidden:(BOOL)isHidden{
    _backButton.hidden = isHidden;
}

- (void)setRightButtonHidden:(BOOL)isHidden{
    _rightButton.hidden = isHidden;
}

- (void)setRightButtonSelected:(BOOL)isSelected{
    [self.rightButton setSelected:isSelected];
}
- (void)setRightButtonTitle:(NSString *)title forState:(UIControlState)state{
    if (title && title.length>0) {
        [self.rightButton setTitle:title forState:state];
    }
}
- (void)setRightButtonTitle:(NSString *)title{
    if (title && title.length>0) {
        [self.rightButton setTitle:title forState:UIControlStateNormal];
    }
}
- (void)setRightButtonTextColor:(UIColor *)color{
    if (color) {
        [self.rightButton setTitleColor:color forState:UIControlStateNormal];
    }
}
- (void)setRightButtonTitleFont:(UIFont *)font{
    if (font) {
        [self.rightButton.titleLabel setFont:font];
    }
}
- (void)setRightButtonBackgroundColor:(UIColor *)color{
    if (color) {
        [self.rightButton setBackgroundColor:color];
    }
}

- (void)setRightButtonImage:(UIImage *)rightImage{
    if (rightImage) {
        [self.rightButton setImage:rightImage forState:UIControlStateNormal];
    }
}

- (void)backButtonEvent:(UIButton *)sender{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(returnBack)]) {
        [self.delegate returnBack];
    }
}

- (void)rigthButtonEvent:(UIButton *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(rightButtonEvnet:)]) {
        [self.delegate rightButtonEvnet:sender];
    }
}

- (UILabel *)navTitleLabel{
    if (!_navTitleLabel) {
        _navTitleLabel = [[UILabel alloc]init];
        _navTitleLabel.textColor = [TSColor colorwithHexString:@"#222222"];
        _navTitleLabel.font = [TSFont TSFontPingFangSemiboldWithSize:16];
        _navTitleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _navTitleLabel;
}

- (UIButton *)backButton{
    
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setImage:[UIImage imageNamed:@"icon_return_nol_black" inBundle:[NSBundle foundationBundle]] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(backButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (UIButton *)rightButton{
    if (!_rightButton) {
        _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_rightButton addTarget:self action:@selector(rigthButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
        _rightButton.hidden = YES;
    }
    return _rightButton;
}

@end
