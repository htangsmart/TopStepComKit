//
//  TSAlertContentVC.m
//  JieliJianKang
//
//  Created by 磐石 on 2024/3/4.
//

#import "TSAlertContentVC.h"
#import "UIView+CBFrameHelpers.h"

@interface TSAlertContentVC ()

@property (nonatomic,strong) UILabel * alertContentLabel;

@end

@implementation TSAlertContentVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)initViews{
    [super initViews];
    [self.backView addSubview:self.alertContentLabel];

}

- (void)setUpAllViews{
    [super setUpAllViews];
    
    self.alertContentLabel.text = self.configer.content;
    self.alertContentLabel.textColor = self.configer.contentColor;
    self.alertContentLabel.font = self.configer.contentFont;
    self.alertContentLabel.textAlignment = self.configer.contentTextAlignment;

}

- (void)layoutViews{
    [super layoutViews];
    
    
    self.alertContentLabel.frame = CGRectMake(24, self.alertTitleLabel.maxY+ CGRectGetHeight(self.alertTitleLabel.frame)>0?(self.alertTitleLabel.maxY+15):self.alertTitleLabel.frame.origin.y, (CGRectGetWidth(self.backView.frame)-48), CGFLOAT_MAX);
    
    [self.alertContentLabel sizeToFit];
    
    if (CGRectGetHeight(self.alertTitleLabel.frame)>0) {
        if (CGRectGetHeight(self.alertContentLabel.frame)>0) {
            self.alertContentLabel.frame = CGRectMake(24, self.alertTitleLabel.maxY+15, (CGRectGetWidth(self.backView.frame)-48), self.alertContentLabel.frame.size.height);
        }else{
            self.alertContentLabel.frame = CGRectMake(24, self.alertTitleLabel.maxY, (CGRectGetWidth(self.backView.frame)-48), self.alertContentLabel.frame.size.height);
        }
    }else{
        self.alertContentLabel.frame = CGRectMake(24, self.alertTitleLabel.maxY, (CGRectGetWidth(self.backView.frame)-48), self.alertContentLabel.frame.size.height);
    }
}


- (CGFloat)maxY{
    return CGRectGetMaxY(self.alertContentLabel.frame);
}


- (UILabel *)alertContentLabel{
    if (!_alertContentLabel) {
        _alertContentLabel = [[UILabel alloc]init];
        _alertContentLabel.numberOfLines = 0;
    }
    return _alertContentLabel;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
