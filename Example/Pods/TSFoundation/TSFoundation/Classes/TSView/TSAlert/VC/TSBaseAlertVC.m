//
//  TSBaseAlertVC.m
//  JieliJianKang
//
//  Created by 磐石 on 2024/3/4.
//

#import "TSBaseAlertVC.h"
#import "UIView+CBFrameHelpers.h"
@interface TSBaseAlertVC ()


@end

@implementation TSBaseAlertVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self initData];
    [self initViews];
    [self addTapGesture];
    [self setUpAllViews];
    [self layoutViews];
    [self addOtherViews];
}

- (void)initData{
    self.view.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5f];
    self.backView.backgroundColor = [UIColor whiteColor];
}

- (void)initViews{
    [self.view addSubview:self.backView];
    [self.backView addSubview:self.alertTitleLabel];
    
}

- (void)setUpAllViews{
    
    self.backView.layer.cornerRadius = self.configer.alerViewCornerRadius;
    self.backView.layer.masksToBounds = YES;

    self.alertTitleLabel.text = self.configer.title;
    self.alertTitleLabel.textColor = self.configer.titleColor;
    self.alertTitleLabel.font = self.configer.titleFont;
    self.alertTitleLabel.textAlignment = self.configer.titleTextAlignment;
}


- (void)layoutViews{
    
    self.backView.frame = CGRectMake(26, (self.view.frame.size.height-188)/2, CGRectGetWidth(self.view.frame)-52, 188);
    
    self.alertTitleLabel.frame = CGRectMake(24, 28, CGRectGetWidth(self.backView.frame)-48, CGFLOAT_MAX);
    [self.alertTitleLabel sizeToFit];
    self.alertTitleLabel.frame = CGRectMake(24, 28,  CGRectGetWidth(self.backView.frame)-48, CGRectGetHeight(self.alertTitleLabel.frame));
}


- (void)addTapGesture{
    if (_configer.dismissWhenTapBackground) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGestureEvent:)];
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 1;
        [self.view addGestureRecognizer:tap];
    }
}

- (void)tapGestureEvent:(UITapGestureRecognizer *)tapGesture{
    if (_configer.dismissWhenTapBackground) {
        [self dismissViewControllerAnimated:YES completion:^{}];
    }
}


- (void)addOtherViews{
    
    if (self.configer.actions && self.configer.actions.count>0) {
        if (self.configer.actions.count == 1) {
            [self addSingleAction];
        }else if (self.configer.actions.count == 2){
            [self addDoubleAction];
        }else{
            [self addMoreAction];
        }
    }
}

- (void)addSingleAction{
        
    TSAlertAction *action = self.configer.actions.firstObject;
    TSAlertButton *singleButton = [self actionButtonWithAction:action];
    [self.backView addSubview:singleButton];
    singleButton.frame = CGRectMake(24, self.maxY+15, self.backView.frame.size.width-48, 40);
    [singleButton reSizeGradientLayerBounds];

    self.backView.frame = CGRectMake(CGRectGetMinX(self.backView.frame), (self.view.frame.size.height-(singleButton.maxY+28))/2,CGRectGetWidth(self.backView.frame), singleButton.maxY+32);
}


- (void)addDoubleAction{
    
    CGFloat totalWidth = CGRectGetWidth(self.backView.frame);
    CGFloat buttonSpace = 35;
    CGFloat buttonWidth = (totalWidth-24*2-buttonSpace)/2.0f;
    
    
    TSAlertAction *firstAction = self.configer.actions.firstObject;
    TSAlertButton *firstButton = [self actionButtonWithAction:firstAction];
    [self.backView addSubview:firstButton];
    firstButton.frame = CGRectMake(24, self.maxY+15, buttonWidth, 40);
    [firstButton reSizeGradientLayerBounds];

    TSAlertAction *lastAction = self.configer.actions.lastObject;
    TSAlertButton *secondButton = [self actionButtonWithAction:lastAction];
    [self.backView addSubview:secondButton];
    secondButton.frame = CGRectMake(firstButton.maxX+buttonSpace, self.maxY+15, buttonWidth, 40);
    [secondButton reSizeGradientLayerBounds];

    self.backView.frame = CGRectMake(CGRectGetMinX(self.backView.frame), (self.view.frame.size.height-(secondButton.maxY+28))/2, CGRectGetWidth(self.backView.frame), secondButton.maxY+32);
    
}

- (void)addMoreAction{
    
    TSAlertButton *lastButton ;
    for (TSAlertAction *action in self.configer.actions) {
        TSAlertButton *actionButton  = [self actionButtonWithAction:action];
        [self.backView addSubview:actionButton];
        actionButton.frame = CGRectMake(24, (lastButton?lastButton.maxY:self.maxY)+15, self.backView.frame.size.width-48, 40);
        [actionButton reSizeGradientLayerBounds];
        lastButton = actionButton;
    }
    self.backView.frame = CGRectMake(CGRectGetMinX(self.backView.frame), (self.view.frame.size.height-(lastButton.maxY+28))/2,CGRectGetWidth(self.backView.frame), lastButton.maxY+32);
}

-(TSAlertButton *)actionButtonWithAction:(TSAlertAction *)action{
    
    TSAlertButton *actionButton = [TSAlertButton alertButtonWithAction:action];
    [actionButton addTarget:self action:@selector(actionButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    return actionButton;
}

- (void)actionButtonEvent:(TSAlertButton *)sender{
    
    if (![self canBeginAction:sender]) {return;}
    [self dismissViewControllerAnimated:YES completion:^{
        if (sender.buttonAction.actionBlock) {
            sender.buttonAction.actionBlock(nil);
        }
    }];
}

- (BOOL)canBeginAction:(TSAlertButton *)sender{return YES;}

- (UIView *)backView{
    if (!_backView) {
        _backView = [UIView new];
    }
    return _backView;
}

- (UILabel *)alertTitleLabel{
    if (!_alertTitleLabel) {
        _alertTitleLabel = [[UILabel alloc]init];
        _alertTitleLabel.numberOfLines = 0;
    }
    return _alertTitleLabel;
}

@end
