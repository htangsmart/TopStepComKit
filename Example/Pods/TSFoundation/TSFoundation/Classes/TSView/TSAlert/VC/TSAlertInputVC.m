//
//  TSAlertInputVC.m
//  JieliJianKang
//
//  Created by 磐石 on 2024/3/4.
//

#import "TSAlertInputVC.h"
#import "UIView+CBFrameHelpers.h"

@interface TSAlertInputVC ()<UITextFieldDelegate>

@property (nonatomic,strong) UITextField * alertInputView;


@end

@implementation TSAlertInputVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self beginEditting];
}

- (void)initViews{
    [super initViews];
    [self.backView addSubview:self.alertInputView];

}

- (void)setUpAllViews{
    
    [super setUpAllViews];
    
    
    
    self.alertInputView.text = self.configer.content;
    self.alertInputView.textColor = self.configer.contentColor;
    self.alertInputView.backgroundColor = self.configer.contentBackgroundColor;
    self.alertInputView.font = self.configer.contentFont;
    self.alertInputView.textAlignment = self.configer.contentTextAlignment;
    self.alertInputView.layer.cornerRadius = self.configer.contentCornerRadius;
    self.alertInputView.keyboardType = self.configer.keyboardType;
}

- (void)layoutViews{
    [super layoutViews];
    
    
    self.alertInputView.frame = CGRectMake(24, self.alertTitleLabel.maxY+ CGRectGetHeight(self.alertTitleLabel.frame)>0?(self.alertTitleLabel.maxY+15):self.alertTitleLabel.frame.origin.y, (CGRectGetWidth(self.backView.frame)-48), 50);
    
}

- (CGFloat)maxY{
    
    return CGRectGetMaxY(self.alertInputView.frame);
}

- (void)beginEditting{
    if (self.configer.alertType == eTSAlertTypeInputView) {
        [self.alertInputView becomeFirstResponder];
    }
}

- (void)actionButtonEvent:(TSAlertButton *)sender{
    
    if (![self canBeginAction:sender]) {return;}
    [self dismissViewControllerAnimated:YES completion:^{
        if (sender.buttonAction.actionBlock) {
            NSString *actionValue = self.configer.alertType == eTSAlertTypeInputView?self.alertInputView.text:nil;
            sender.buttonAction.actionBlock(actionValue);
        }
    }];
}

- (BOOL)canBeginAction:(TSAlertButton *)sender{
    if (sender.buttonAction.valueVerifyBlock) {
       TSAlertError *error =  sender.buttonAction.valueVerifyBlock(self.alertInputView.text);
        if (error && error.isError) {
            [TSToast showText:error.errorMsg onView:self.backView dismissAfterDelay:1.5f];
            return NO;
        }
    }
    return YES;
}

- (UITextField *)alertInputView{
    if (!_alertInputView) {
        _alertInputView = [[UITextField alloc]init];
        _alertInputView.delegate = self;
        _alertInputView.textColor = self.configer.contentColor;
        
    }
    return _alertInputView;
}

@end
