//
//  TSCustomTableViewCell.m
//  JieliJianKang
//
//  Created by luigi on 2024/3/20.
//

#import "Masonry.h"
#import "NSBundle+TSFoundation.h"
#import "ReactiveObjC.h"
#import "TSChecker.h"
#import "TSCustomTableViewCell.h"
#import "UIImage+Bundle.h"
#import "UIView+TSView.h"

@interface TSCustomTableViewCell ()
@property (nonatomic, copy) NSArray<RACDisposable *> *disposables;
@property (nonatomic, assign) UIEdgeInsets cellEdgeInset;
@property (nonatomic, assign) TSCustomTableViewCellStyle cellStyle;
@property (nonatomic, assign) UILayoutPriority titlePriority;
@property (nonatomic, assign) UILayoutPriority contentPriority;
@end

@implementation TSCustomTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    [self.disposables enumerateObjectsUsingBlock:^(RACDisposable *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        [obj dispose];
    }];
}

- (instancetype)initWithCellStyle:(TSCustomTableViewCellStyle)cellStyle reuseIdentifier:(NSString *)reuseIdentifier cellEdgeInset:(UIEdgeInsets)cellEdgeInset {

    return [self initWithCellStyle:cellStyle reuseIdentifier:reuseIdentifier cellEdgeInset:cellEdgeInset titlePriority:(UILayoutPriorityDefaultLow) contentPriority:(UILayoutPriorityRequired)];
}

- (instancetype)initWithCellStyle:(TSCustomTableViewCellStyle)cellStyle reuseIdentifier:(NSString *)reuseIdentifier cellEdgeInset:(UIEdgeInsets)cellEdgeInset titlePriority:(UILayoutPriority)titlePriority contentPriority:(UILayoutPriority)contentPriority {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.disposables = @[];
        self.cellStyle = cellStyle;
        self.cellEdgeInset = cellEdgeInset;
        self.titlePriority = titlePriority;
        self.contentPriority = contentPriority;
        [self createUI];
        [self layoutUI];
    }

    return self;
}

- (void)setCellModel:(id<TSCustomTableViewCellProtocol>)cellModel {
    [self.disposables enumerateObjectsUsingBlock:^(RACDisposable *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        [obj dispose];
    }];
    _cellModel = cellModel;
    [self bindData];
    [self updateUI];
}

- (void)bindData {
    @weakify(self)
    self.disposables = @[

        [[RACObserve(self, cellModel.titleImage) distinctUntilChanged] subscribeNext:^(id _Nullable x) {
            @strongify(self)
            self.titleImgV.image = x;
        }],

        [[RACObserve(self, cellModel.title) distinctUntilChanged] subscribeNext:^(id _Nullable x) {
            @strongify(self)
            self.titleLab.text = TSSTRING_SAFE(self.cellModel.title);
        }],

        [[RACObserve(self, cellModel.content) distinctUntilChanged] subscribeNext:^(id _Nullable x) {
            @strongify(self)
            self.contentLab.text = TSSTRING_SAFE(self.cellModel.content);
        }],

        [[RACObserve(self, cellModel.detail) distinctUntilChanged] subscribeNext:^(id _Nullable x) {
            @strongify(self)
            self.detailLab.text = TSSTRING_SAFE(self.cellModel.detail);
        }],

        [[RACObserve(self, cellModel.isSelected) distinctUntilChanged] subscribeNext:^(id _Nullable x) {
            @strongify(self)
            self.selectBtn.selected = self.cellModel.isSelected;
        }],

        [[RACObserve(self, cellModel.isOn) distinctUntilChanged] subscribeNext:^(id _Nullable x) {
            @strongify(self)
            [self.aSwitch setOn: self.cellModel.isOn animated: true];
        }],
    ];
}

- (void)selectedBtnClickAction {
    self.cellModel.isSelected = !self.cellModel.isSelected;
}

#pragma mark - setupUI
- (void)updateUI {
    // 计算titleImgV尺寸
    CGFloat titleImageWidth = self.cellModel.titleImage ? self.cellModel.titleImage.size.width : 0;
    CGFloat titleImageHeight = self.cellModel.titleImage ? self.cellModel.titleImage.size.height : 0;
    
    // 更新titleImgV约束
    [self.titleImgV mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(titleImageWidth);
        make.height.mas_equalTo(titleImageHeight);
    }];

    // 更新detailLab约束
    BOOL hiddenDetailLab = TSSTRING_SAFE(self.detailLab.text).length == 0;
    [self.detailLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentLab.mas_bottom).offset(hiddenDetailLab ? 0 : 10);
    }];
    
    // 强制布局更新
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)createUI {
    self.backgroundColor = UIColor.clearColor;
    [self.contentView addSubview:self.cellBGView];
    [self.cellBGView addSubview:self.titleImgV];
    [self.cellBGView addSubview:self.titleLab];
    [self.cellBGView addSubview:self.contentLab];
    [self.cellBGView addSubview:self.detailLab];
    [self.cellBGView addSubview:self.nextIcon];
    [self.cellBGView addSubview:self.aSwitch];
    [self.cellBGView addSubview:self.selectBtn];
}

- (void)layoutUI {
    // cell背景视图约束保持不变
    [self.cellBGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView).insets(self.cellEdgeInset);
    }];

    // 初始化和设置rightView
    UIView *rightView = nil;
    self.nextIcon.hidden = self.aSwitch.hidden = self.selectBtn.hidden = true;
    
    // 根据样式设置rightView
    if (self.cellStyle == TSCustomTableViewCellStyle_next) {
        rightView = self.nextIcon;
        self.nextIcon.hidden = false;
    } else if (self.cellStyle == TSCustomTableViewCellStyle_switch) {
        rightView = self.aSwitch;
        self.aSwitch.hidden = false;
    } else if (self.cellStyle == TSCustomTableViewCellStyle_select) {
        rightView = self.selectBtn;
        self.selectBtn.hidden = false;
    }

    // 设置各个rightView的固定尺寸约束
    [self.nextIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(24, 24));
        make.right.offset(-12);
    }];
    
    [self.aSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(46, 28));
        make.right.offset(-12);
    }];
    
    [self.selectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(24, 24));
        make.right.offset(-12);
    }];

    // 1. rightView优先级最高
    if (rightView) {
        [rightView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [rightView setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [rightView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        [rightView setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        
        [rightView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentLab);
        }];
    }

    // 设置titleImgV约束
    [self.titleImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(14);
        make.centerY.equalTo(self.titleLab);
        make.width.height.mas_equalTo(0); // 默认尺寸为0，在updateUI中动态更新
    }];

    // 3. titleLab优先级最低，允许宽度被压缩
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleImgV.mas_right).offset(6);
        make.height.mas_equalTo(35).priorityHigh(); // 高度不可压缩
        make.width.greaterThanOrEqualTo(@60).priority(self.titlePriority); // 根据self.titlePriority设置优先级
        make.centerY.equalTo(self.contentLab);
    }];
    
    [self.titleLab setContentCompressionResistancePriority:self.titlePriority forAxis:UILayoutConstraintAxisHorizontal];
    [self.titleLab setContentCompressionResistancePriority:self.titlePriority forAxis:UILayoutConstraintAxisVertical];
    UILayoutPriority titleHuggingPriority = self.titlePriority == UILayoutPriorityRequired ? UILayoutPriorityDefaultLow : UILayoutPriorityRequired;
    [self.titleLab setContentHuggingPriority:titleHuggingPriority forAxis:UILayoutConstraintAxisHorizontal];

    // 2. contentLab优先级次之，不可被压缩
    [self.contentLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(10);
        make.height.greaterThanOrEqualTo(@30);
        make.left.equalTo(self.titleLab.mas_right).offset(10);
        if (rightView) {
            make.right.equalTo(rightView.mas_left).offset(-10);
        } else {
            make.right.equalTo(self.cellBGView).offset(-20);
        }
    }];
    
    [self.contentLab setContentCompressionResistancePriority:self.contentPriority forAxis:UILayoutConstraintAxisHorizontal];
    [self.contentLab setContentCompressionResistancePriority:self.contentPriority forAxis:UILayoutConstraintAxisVertical];
    UILayoutPriority contentHuggingPriority = self.contentPriority == UILayoutPriorityRequired ? UILayoutPriorityDefaultLow : UILayoutPriorityRequired;
    [self.contentLab setContentHuggingPriority:contentHuggingPriority forAxis:UILayoutConstraintAxisHorizontal];

    // detailLab约束
    [self.detailLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(14);
        make.right.offset(-20);
        
        make.top.equalTo(self.contentLab.mas_bottom);
        make.bottom.equalTo(self.cellBGView).offset(-20);
        make.height.greaterThanOrEqualTo(@0);
    }];
}

#pragma mark - lazyloading
- (UIView *)cellBGView {
    if (!_cellBGView) {
        _cellBGView = [UIView new];
        _cellBGView.backgroundColor = UIColor.whiteColor;
    }

    return _cellBGView;
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.textColor = TSHEXCOLOR(#333333);
        _titleLab.font = MFont_PF(18);
        _titleLab.adjustsFontSizeToFitWidth = true;
        _titleLab.numberOfLines = 2;
        _titleLab.minimumScaleFactor = 0.62;// 0.62时高度35能显示两行
    }

    return _titleLab;
}

- (UILabel *)contentLab {
    if (!_contentLab) {
        _contentLab = [[UILabel alloc] init];
        _contentLab.textColor = TSHEXCOLOR(#BCC2CF);
        _contentLab.font = RFont_PF(16);
        _contentLab.numberOfLines = 0;
        _contentLab.adjustsFontSizeToFitWidth = true;
        _contentLab.minimumScaleFactor = 0.8;
        _contentLab.textAlignment = NSTextAlignmentRight;
    }

    return _contentLab;
}

- (UILabel *)detailLab {
    if (!_detailLab) {
        _detailLab = [[UILabel alloc] init];
        _detailLab.textColor = TSHEXCOLOR(#999999);
        _detailLab.font = MFont_PF(14);
        _detailLab.numberOfLines = 0;
    }

    return _detailLab;
}

- (UIImageView *)nextIcon {
    if (!_nextIcon) {
        _nextIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_cell_next_nol" inBundle:[NSBundle foundationBundle]]];
        _nextIcon.tintColor = UIColor.whiteColor;
    }

    return _nextIcon;
}

- (UISwitch *)aSwitch {
    if (!_aSwitch) {
        _aSwitch = [[UISwitch alloc] init];
        @weakify(self)
        [[_aSwitch rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl *_Nullable x) {
            @strongify(self)

            if (self.cellModel && [self.cellModel respondsToSelector:@selector(switchChange:)]) {
                [self.cellModel switchChange:self.aSwitch.isOn];
            }
        }];
    }

    return _aSwitch;
}

- (UIButton *)selectBtn {
    if (!_selectBtn) {
        _selectBtn = [[UIButton alloc] init];
        [_selectBtn setImage:[UIImage imageNamed:@"account_privacy_unSelec" inBundle:[NSBundle foundationBundle]] forState:UIControlStateNormal];
        [_selectBtn setImage:[UIImage imageNamed:@"account_privacy_selected" inBundle:[NSBundle foundationBundle]] forState:UIControlStateSelected];
        [_selectBtn addTarget:self action:@selector(selectedBtnClickAction) forControlEvents:UIControlEventTouchUpInside];
        [_selectBtn.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.offset(0);
        }];
    }

    return _selectBtn;
}

- (UIImageView *)titleImgV {
    if (!_titleImgV) {
        _titleImgV = [[UIImageView alloc] init];
    }

    return _titleImgV;
}

@end
