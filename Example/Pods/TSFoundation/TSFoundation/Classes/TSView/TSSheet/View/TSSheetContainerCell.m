//
//  TSSheetContainerCell.m
//  TSFoundation
//
//  Created by 磐石 on 2024/8/12.
//

#import "TSSheetContainerCell.h"

#import "TSColor.h"
#import "TSFont.h"
#import "TSFrame.h"
#import "TSChecker.h"

@interface TSSheetContainerCell ()


@property (nonatomic,strong) UILabel * titleLabel;

@property (nonatomic,strong) UIView * sepView;
@end

@implementation TSSheetContainerCell

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
    
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.sepView];

}

- (void)fullValues{
    
}

- (void)layoutViews{
    self.titleLabel.frame = CGRectMake(0, 1, [TSFrame screenWidth]-24, 54);
    
    self.sepView.frame = CGRectMake(12, 55, [TSFrame screenWidth]-24-24, 1);
    
}

- (void)reloadContainerCellWithAction:(TSSheetAction *)action{
    
    self.titleLabel.text = action.actionName;
    [self layoutViews];
    
}


- (UIView *)sepView{
    if (!_sepView) {
        _sepView = [[UIView alloc]init];
        _sepView.backgroundColor = [TSColor colorwithHexString:@"#D9D9D9"];
    }
    return _sepView;
}


- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.textColor = [TSColor colorwithHexString:@"#000000"];
        _titleLabel.font = [TSFont TSFontPingFangMediumWithSize:15];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
    
}



@end
