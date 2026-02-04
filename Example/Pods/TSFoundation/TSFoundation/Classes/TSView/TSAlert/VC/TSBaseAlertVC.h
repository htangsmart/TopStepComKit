//
//  TSBaseAlertVC.h
//  JieliJianKang
//
//  Created by 磐石 on 2024/3/4.
//

#import <UIKit/UIKit.h>
#import "TSAlertAction.h"
#import "TSAlertButton.h"
#import "TSAlertConfiger.h"
#import "TSAlertAction.h"
#import "TSAlertError.h"

#import "TSFont.h"
#import "TSColor.h"
#import "TSToast.h"

@interface TSBaseAlertVC : UIViewController

@property (nonatomic,strong) UIView * backView;

@property (nonatomic,strong) UILabel * alertTitleLabel;

@property (nonatomic,strong) TSAlertConfiger * configer;

@property (nonatomic,assign) CGFloat maxY;

- (void)initViews;
- (void)setUpAllViews;
- (void)layoutViews;

- (void)actionButtonEvent:(TSAlertButton *)sender;


@end

