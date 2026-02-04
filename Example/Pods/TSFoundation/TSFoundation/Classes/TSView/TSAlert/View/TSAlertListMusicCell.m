//
//  TSAlertListMusicCell.m
//  JieliJianKang
//
//  Created by 磐石 on 2024/3/4.
//

#import "TSAlertListMusicCell.h"
#import "TSColor.h"
#import "TSFont.h"
#import "TSFrame.h"
#import "TSShake.h"
#import "TSLoading.h"
#import "TSChecker.h"
#import "TSAttributedString.h"
#import "TSBezierPath.h"
#import "UIView+CBFrameHelpers.h"
#import "JLPhoneUISetting.h"
#import "UIImage+Bundle.h"
#import "NSBundle+TSFoundation.h"

@interface TSAlertListMusicCell ()

@property (nonatomic,strong) UIImageView * iconImageView;
@property (nonatomic,strong) UILabel * titleLabel;
@property (nonatomic,strong) UILabel * descLabel;


@end

@implementation TSAlertListMusicCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initData];
        [self initViews];
        [self fullValues];
        [self layoutViews];
    }
    return self;
}


- (void)initData{
    self.contentView.backgroundColor = [TSColor colorwithHexString:@"#F2F2F2"];
}

- (void)initViews{
    
    [self.contentView addSubview:self.iconImageView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.descLabel];


}

- (void)fullValues{

}

- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    [self layoutViews];
}

- (void)layoutViews{

    self.iconImageView.frame = CGRectMake(12, 11,32, 32);

    CGFloat totalWidth = [TSFrame screenWidth]-26*2-10*2;
    
    self.descLabel.frame = CGRectMake(totalWidth-12-100, 17, totalWidth, CGFLOAT_MAX);
    [self.descLabel sizeToFit];
    self.descLabel.frame = CGRectMake(totalWidth-12-CGRectGetWidth(self.descLabel.frame), (54-CGRectGetHeight(self.descLabel.frame))/2, CGRectGetWidth(self.descLabel.frame), CGRectGetHeight(self.titleLabel.frame));

    
    totalWidth = CGRectGetMinX(self.descLabel.frame) - CGRectGetMaxX(self.iconImageView.frame)-12-12;
   
    self.titleLabel.frame = CGRectMake(CGRectGetMaxX(self.iconImageView.frame)+12,11 ,totalWidth,CGFLOAT_MAX);
    [self.titleLabel sizeToFit];
    self.titleLabel.frame = CGRectMake(CGRectGetMaxX(self.iconImageView.frame)+12,(54-CGRectGetHeight(self.titleLabel.frame))/2, totalWidth, CGRectGetHeight(self.titleLabel.frame));

}

- (void)reloadItemCellWith:(NSString *)songName{
    
    self.titleLabel.text = songName;
    self.descLabel.text = kJL_TXT("暂不支持该文件");
    [self layoutViews];
}

- (UIImageView *)iconImageView{
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc]init];
        _iconImageView.image = [UIImage imageNamed:@"device_musicmng_icon" inBundle:[NSBundle foundationBundle]];
    }
    return _iconImageView;

}


- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.textColor = [TSColor colorwithHexString:@"#222222"];
        _titleLabel.font = [TSFont TSFontPingFangMediumWithSize:16];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _titleLabel;

}

- (UILabel *)descLabel{
    if (!_descLabel) {
        _descLabel = [[UILabel alloc]init];
        _descLabel.textColor = [TSColor colorwithHexString:@"#9D9D9D"];
        _descLabel.font = [TSFont TSFontPingFangMediumWithSize:12];
        _descLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _descLabel;

}




@end
