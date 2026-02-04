//
//  TSDialContainerView.m
//  TSFoundation
//
//  Created by 磐石 on 2024/8/7.
//

#import "TSDialContainerView.h"
#import "MSColorWheelView.h"
#import "MSColorUtils.h"


@interface TSDialContainerView ()

@property (nonatomic,strong) UIView * wheelContainerView;

@property (nonatomic,strong) UIView * buttonContainerView;

@property (nonatomic,strong) UIButton * cancelButton;

@property (nonatomic,strong) UIButton * sureButton;

@property (nonatomic,strong) UIView * sepView;

@property (nonatomic,strong) MSColorWheelView * colorWheelView;

@property (nonatomic,assign)     HSB colorComponents;

@property (nonatomic,strong)  TSColorCancelBlock cancelBlock;

@property (nonatomic,strong)  TSColorSureBlock sureBlock;

@end

@implementation TSDialContainerView


+ (void)showContainOnView:(UIView *)superView cancelBlock:(TSColorCancelBlock)cancelBlock sureBlock:(TSColorSureBlock)sureBlock{
    
    TSDialContainerView *container = [[TSDialContainerView alloc]initWithCancelBlock:cancelBlock sureBlock:sureBlock];
    [superView addSubview:container];
    [container show];
}



- (instancetype)initWithCancelBlock:(TSColorCancelBlock)cancelBlock sureBlock:(TSColorSureBlock)sureBlock{
    self = [super init];
    if (self) {
     
        _cancelBlock = cancelBlock;
        _sureBlock = sureBlock;
        [self initData];
        [self initViews];
        [self layoutViews];

    }
    return self;
}

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

- (void)initData{
    _colorComponents.brightness = 1.0f;
    _colorComponents.alpha = 1.0f;
}

- (void)initViews{
    
    [self addSubview:self.wheelContainerView];
    [self addSubview:self.buttonContainerView];
    
    [self.wheelContainerView addSubview:self.colorWheelView];
    [self.buttonContainerView addSubview:self.cancelButton];
    [self.buttonContainerView addSubview:self.sureButton];
    [self.buttonContainerView addSubview:self.sepView];
}

- (void)layoutViews{
    
    self.wheelContainerView.frame = CGRectMake(12, 0, self.width-24, 245);
    self.buttonContainerView.frame = CGRectMake(12, self.wheelContainerView.maxY+8, self.width-24, 56);
        
    self.colorWheelView.frame = CGRectMake((self.wheelContainerView.width-189)/2, (self.wheelContainerView.height-189)/2, 189, 189);
    self.cancelButton.frame = CGRectMake(0, 0, self.buttonContainerView.width/2-1, 56);
    
    self.sepView.frame = CGRectMake(self.buttonContainerView.width/2, 0, 1, 56);
    
    self.sureButton.frame = CGRectMake(self.buttonContainerView.width/2, 0, self.buttonContainerView.width/2, 56);
}

- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    [self layoutViews];
}

- (void)show{
    self.frame = CGRectMake(0, [TSFrame screenHeight], [TSFrame screenWidth], 310+[TSFrame safeAreaBottom]+34);
    [UIView animateWithDuration:0.35 delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.frame = CGRectMake(0, [TSFrame screenHeight]-self.height, [TSFrame screenWidth],  310+[TSFrame safeAreaBottom]+34);
    } completion:^(BOOL finished) {
    }];
}
- (void)dismiss{
    self.frame = CGRectMake(0, [TSFrame screenHeight]-self.height, [TSFrame screenWidth],  310+[TSFrame safeAreaBottom]+34);
    [UIView animateWithDuration:0.35 delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.frame = CGRectMake(0, [TSFrame screenHeight], [TSFrame screenWidth], 310+[TSFrame safeAreaBottom]+34);
    } completion:^(BOOL finished) {
        
    }];
}

- (void)cancelButtonEvent:(UIButton *)sender{
    [self dismiss];
    if (self.cancelBlock) {self.cancelBlock();}
}

- (void)sureButtonEvent:(UIButton *)sender{
    [self dismiss];
    if (self.sureBlock) {self.sureBlock([self currentColor]);}
}

- (UIColor *)currentColor{
    
    return  [UIColor colorWithHue:_colorComponents.hue saturation:_colorComponents.saturation brightness:_colorComponents.brightness alpha:_colorComponents.alpha];
}

- (void)colorWheelViewDidChangeValue:(MSColorWheelView *)colorView{
    
    _colorComponents.hue = colorView.hue;
    _colorComponents.saturation = colorView.saturation;
}


- (UIView *)wheelContainerView{
    if (!_wheelContainerView ) {
        _wheelContainerView = [[UIView alloc]init];
        _wheelContainerView.backgroundColor = [UIColor whiteColor];
        _wheelContainerView.layer.cornerRadius = 12;
        _wheelContainerView.layer.masksToBounds = YES;
    }
    return _wheelContainerView;
}

- (UIView *)buttonContainerView{
    if (!_buttonContainerView ) {
        _buttonContainerView = [[UIView alloc]init];
        _buttonContainerView.backgroundColor = [UIColor whiteColor];
        _buttonContainerView.layer.cornerRadius = 12;
        _buttonContainerView.layer.masksToBounds = YES;
    }
    return _buttonContainerView;
}

- (UIView *)sepView{
    if (!_sepView ) {
        _sepView = [[UIView alloc]init];
        _sepView.backgroundColor = [TSColor colorwithHexString:@"#D4D5D6"];
    }
    return _sepView;
}

- (MSColorWheelView *)colorWheelView{
    if (!_colorWheelView) {
        _colorWheelView = [[MSColorWheelView alloc]init];
        [_colorWheelView addTarget:self action:@selector(colorWheelViewDidChangeValue:) forControlEvents:UIControlEventValueChanged];

    }
    return _colorWheelView;
}

- (UIButton *)cancelButton{
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton setTitle:kJL_TXT("取消") forState:UIControlStateNormal];
        _cancelButton.titleLabel.font = [TSFont TSFontPingFangMediumWithSize:15];
        [_cancelButton setTitleColor:[TSColor colorwithHexString:@"#999999"] forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(cancelButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

- (UIButton *)sureButton{
    if (!_sureButton) {
        _sureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sureButton setTitle:kJL_TXT("确定") forState:UIControlStateNormal];
        _sureButton.titleLabel.font = [TSFont TSFontPingFangMediumWithSize:15];
        [_sureButton setTitleColor:[TSColor colorwithHexString:@"#000000"] forState:UIControlStateNormal];
        [_sureButton addTarget:self action:@selector(sureButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sureButton;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
