//
//  TSDialTemplateSelectionView.m
//  TopStepComKit_Example
//

#import "TSDialTemplateSelectionView.h"
#import "TSDialEditorAppearance.h"

@interface TSDialTemplateSelectionView ()
// 标题、来源标记与文件摘要。
@property (nonatomic, strong) UILabel *headingLabel;
@property (nonatomic, strong) UILabel *sourceLabel;
@property (nonatomic, strong) UIView *cardView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *metadataLabel;
// 详情与更换操作保持独立触控区域。
@property (nonatomic, strong) UIButton *detailsButton;
@property (nonatomic, strong) UIButton *changeButton;
@end

@implementation TSDialTemplateSelectionView

#pragma mark - 生命周期

// 复用编辑器配色与按钮样式，文件名使用中间省略保留后缀。
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.headingLabel];
        [self addSubview:self.sourceLabel];
        [self addSubview:self.cardView];
        for (UIView *view in @[self.nameLabel, self.metadataLabel, self.detailsButton, self.changeButton]) {
            [self.cardView addSubview:view];
        }
        [self configureWithFileURL:nil name:nil importing:NO];
    }
    return self;
}

// 双按钮均至少高 44 点，窄屏时文件名可省略，完整名称通过详情读取。
- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = CGRectGetWidth(self.bounds);
    self.headingLabel.frame = CGRectMake(0, 0, width - 110, 24);
    self.sourceLabel.frame = CGRectMake(width - 110, 0, 110, 24);
    self.cardView.frame = CGRectMake(0, 32, width, 132);
    self.nameLabel.frame = CGRectMake(14, 12, width - 28, 24);
    self.metadataLabel.frame = CGRectMake(14, 39, width - 28, 34);
    CGFloat actionWidth = (width - 38) / 2;
    self.detailsButton.frame = CGRectMake(14, 77, actionWidth, 44);
    self.changeButton.frame = CGRectMake(24 + actionWidth, 77, actionWidth, 44);
}

#pragma mark - 公开方法

// 自动模板不伪造文件名、格式或云端路径，本地模板读取真实元数据。
- (void)configureWithFileURL:(NSURL *)fileURL name:(NSString *)name importing:(BOOL)importing {
    NSDictionary *attributes = fileURL ? [[NSFileManager defaultManager] attributesOfItemAtPath:fileURL.path error:nil] : nil;
    BOOL available = [attributes[NSFileType] isEqual:NSFileTypeRegular] && [attributes fileSize] > 0;
    self.sourceLabel.text = importing ? @"正在导入…" : fileURL ? @"本地文件" : @"默认";
    self.nameLabel.text = fileURL ? (name.length ? name : fileURL.lastPathComponent) : @"SDK 自动匹配";
    NSString *format = fileURL.pathExtension.length ? fileURL.pathExtension.uppercaseString : @"文件";
    NSString *size = [NSByteCountFormatter stringFromByteCount:[attributes fileSize] countStyle:NSByteCountFormatterCountStyleFile];
    self.metadataLabel.text = fileURL ? (available ?
        [NSString stringWithFormat:@"%@ · %@ · 安装前制作校验", format, size] : @"文件不可用，请重新选择模板") :
        @"由 SDK 获取适配当前设备的模板";
    self.metadataLabel.textColor = [TSDialEditorAppearance color:fileURL && !available ? 0xD15D39 : 0x8B9085];
    [self.detailsButton setTitle:fileURL ? @"查看路径" : @"查看来源" forState:UIControlStateNormal];
    self.detailsButton.enabled = !importing;
    self.changeButton.enabled = !importing;
    self.alpha = importing ? 0.6 : 1;
}

// 固定内容块高度，外围面板负责滚动。
- (CGFloat)preferredHeight {
    return 164;
}

#pragma mark - 私有方法

// 转发详情请求。
- (void)showDetails {
    if (self.onDetails) { self.onDetails(); }
}

// 转发更换请求。
- (void)changeTemplate {
    if (self.onChange) { self.onChange(); }
}

#pragma mark - 属性懒加载

// 模板区域标题。
- (UILabel *)headingLabel {
    if (!_headingLabel) {
        _headingLabel = [TSDialEditorAppearance label:@"表盘模板" size:14 color:0x252823];
        _headingLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
    }
    return _headingLabel;
}

// 右侧来源标记。
- (UILabel *)sourceLabel {
    if (!_sourceLabel) {
        _sourceLabel = [TSDialEditorAppearance label:@"" size:11 color:0x82916E];
        _sourceLabel.textAlignment = NSTextAlignmentRight;
    }
    return _sourceLabel;
}

// 浅色文件信息卡片。
- (UIView *)cardView {
    if (!_cardView) {
        _cardView = [[UIView alloc] init];
        _cardView.backgroundColor = [TSDialEditorAppearance color:0xF8F8F4];
        _cardView.layer.cornerRadius = 14;
        _cardView.layer.borderWidth = 1;
        _cardView.layer.borderColor = [TSDialEditorAppearance color:0xE7E8E2].CGColor;
    }
    return _cardView;
}

// 保留长文件名的首尾信息。
- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [TSDialEditorAppearance label:@"" size:14 color:0x252823];
        _nameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    }
    return _nameLabel;
}

// 文件大小、后缀与可用状态。
- (UILabel *)metadataLabel {
    if (!_metadataLabel) {
        _metadataLabel = [TSDialEditorAppearance label:@"" size:11 color:0x8B9085];
        _metadataLabel.numberOfLines = 2;
    }
    return _metadataLabel;
}

// 查看来源或实际使用路径。
- (UIButton *)detailsButton {
    if (!_detailsButton) {
        _detailsButton = [TSDialEditorAppearance button:@"查看来源" primary:NO];
        [_detailsButton addTarget:self action:@selector(showDetails) forControlEvents:UIControlEventTouchUpInside];
    }
    return _detailsButton;
}

// 使用橙色文字突出更换操作。
- (UIButton *)changeButton {
    if (!_changeButton) {
        _changeButton = [TSDialEditorAppearance button:@"更换模板" primary:NO];
        [_changeButton setTitleColor:[TSDialEditorAppearance color:0xD76540] forState:UIControlStateNormal];
        [_changeButton addTarget:self action:@selector(changeTemplate) forControlEvents:UIControlEventTouchUpInside];
    }
    return _changeButton;
}

@end
