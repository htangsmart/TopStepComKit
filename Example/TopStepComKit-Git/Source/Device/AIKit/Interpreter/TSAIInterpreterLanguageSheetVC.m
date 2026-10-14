//
//  TSAIInterpreterLanguageSheetVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/19.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIInterpreterLanguageSheetVC.h"

#import <TopStepAIKit/TSAILanguageMapper.h>

#import "TSAIInterpreterFormatter.h"
#import "TSAIInterpreterTheme.h"
#import "TSRootVC.h"

/// 最近使用语言的持久化 key（NSNumber 数组，最新在前，最多 4 个）
static NSString *const kTSAIInterpreterRecentLanguagesKey = @"TSAIInterpreterRecentLanguages";
/// 最近使用的最大数量
static const NSUInteger kTSAIInterpreterRecentLimit = 4;


#pragma mark - 列表行

/// 列表行：名 16px / 500 + 原生名 12px muted，选中为 cobalt50 底 + 钴蓝 √
@interface TSAIInterpreterLanguageRow : UIControl

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *nativeLabel;
@property (nonatomic, strong) UIImageView *checkView;
@property (nonatomic, strong) UIView *separator;

/// 设置选中态（√ 与底色）
- (void)setChecked:(BOOL)checked;

@end

@implementation TSAIInterpreterLanguageRow

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [TSAIInterpreterTheme fontOfSize:16.0 cssWeight:500];
        _nameLabel.textColor = [TSAIInterpreterTheme ink];
        _nameLabel.userInteractionEnabled = NO;
        [self addSubview:_nameLabel];
        _nativeLabel = [[UILabel alloc] init];
        _nativeLabel.font = [TSAIInterpreterTheme fontOfSize:12.0 cssWeight:400];
        _nativeLabel.textColor = [TSAIInterpreterTheme muted];
        _nativeLabel.userInteractionEnabled = NO;
        [self addSubview:_nativeLabel];
        _separator = [[UIView alloc] init];
        _separator.backgroundColor = [TSAIInterpreterTheme paper];
        _separator.userInteractionEnabled = NO;
        [self addSubview:_separator];
    }
    return self;
}

- (void)setChecked:(BOOL)checked {
    if (checked && self.checkView == nil) {
        self.checkView = [TSAIInterpreterTheme symbolViewNamed:@"checkmark" pointSize:18.0 tint:[TSAIInterpreterTheme cobalt]];
        [self addSubview:self.checkView];
    } else if (!checked) {
        [self.checkView removeFromSuperview];
        self.checkView = nil;
    }
    self.backgroundColor = checked ? [TSAIInterpreterTheme cobalt50] : [TSAIInterpreterTheme panel];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    self.alpha = highlighted ? 0.7 : 1.0;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat w = CGRectGetWidth(self.bounds);
    CGFloat h = CGRectGetHeight(self.bounds);
    // 内边距 10 16，两行文字 gap 2，纵向居中；右侧 √ 24pt
    CGFloat rightInset = self.checkView != nil ? 16.0 + 24.0 + 12.0 : 16.0;
    CGFloat nameH = 20.0, nativeH = 15.0, gap = 2.0;
    CGFloat top = (h - (nameH + gap + nativeH)) / 2.0;
    self.nameLabel.frame = CGRectMake(16.0, top, w - 16.0 - rightInset, nameH);
    self.nativeLabel.frame = CGRectMake(16.0, top + nameH + gap, w - 16.0 - rightInset, nativeH);
    self.checkView.frame = CGRectMake(w - 16.0 - 24.0, (h - 24.0) / 2.0, 24.0, 24.0);
    self.separator.frame = CGRectMake(0, h - 1.0, w, 1.0);
}

@end

@interface TSAIInterpreterLanguageSheetVC () <UITextFieldDelegate, UIGestureRecognizerDelegate>

#pragma mark - 视图
/// 返回
@property (nonatomic, strong) UIButton *backButton;
/// 标题
@property (nonatomic, strong) UILabel *titleLabel;
/// 搜索框容器
@property (nonatomic, strong) UIView *searchBox;
/// 搜索图标
@property (nonatomic, strong) UIImageView *searchIcon;
/// 搜索输入
@property (nonatomic, strong) UITextField *searchField;
/// 滚动容器
@property (nonatomic, strong) UIScrollView *scrollView;
/// 「最近使用」
@property (nonatomic, strong) UILabel *recentLabel;
/// 最近使用 chips 容器
@property (nonatomic, strong) UIView *chipsView;
/// 「全部语言 · N」
@property (nonatomic, strong) UILabel *allLabel;
/// 列表卡片
@property (nonatomic, strong) UIView *listView;
/// 无匹配提示
@property (nonatomic, strong) UILabel *emptyLabel;
/// 底栏
@property (nonatomic, strong) UIView *footerView;
/// 确定
@property (nonatomic, strong) UIButton *confirmButton;

#pragma mark - 状态
/// 标题文本
@property (nonatomic, copy) NSString *sheetTitleText;
/// 候选语言
@property (nonatomic, copy) NSArray<NSNumber *> *languages;
/// 初始语言
@property (nonatomic, assign) TSAILanguage initialLanguage;
/// 当前选中语言
@property (nonatomic, assign) TSAILanguage currentLanguage;
/// 选中回调
@property (nonatomic, copy) void (^onPickHandler)(TSAILanguage);
/// 最近使用（仅包含候选中存在的语言）
@property (nonatomic, copy) NSArray<NSNumber *> *recentLanguages;
/// 当前过滤后的列表
@property (nonatomic, copy) NSArray<NSNumber *> *filteredLanguages;

@end

@implementation TSAIInterpreterLanguageSheetVC

#pragma mark - 生命周期

- (instancetype)initWithTitle:(NSString *)title
                     languages:(NSArray<NSNumber *> *)languages
                       current:(TSAILanguage)current
                        onPick:(void (^)(TSAILanguage))onPick {
    self = [super init];
    if (self) {
        _sheetTitleText = [title copy];
        _languages = [languages copy];
        _initialLanguage = current;
        _currentLanguage = current;
        _onPickHandler = [onPick copy];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [TSAIInterpreterTheme paper];
    [self.view addSubview:self.backButton];
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.searchBox];
    [self.searchBox addSubview:self.searchIcon];
    [self.searchBox addSubview:self.searchField];
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.recentLabel];
    [self.scrollView addSubview:self.chipsView];
    [self.scrollView addSubview:self.allLabel];
    [self.scrollView addSubview:self.listView];
    [self.listView addSubview:self.emptyLabel];
    [self.view addSubview:self.footerView];
    [self.footerView addSubview:self.confirmButton];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onBackgroundTap)];
    tap.cancelsTouchesInView = NO;
    tap.delegate = self;
    [self.scrollView addGestureRecognizer:tap];

    [self loadRecent];
    [self rebuildList];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self layoutViews];
}

#pragma mark - 布局

- (void)layoutViews {
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat height = CGRectGetHeight(self.view.bounds);
    if (width <= 0 || height <= 0) return;
    CGFloat side = 20.0;
    CGFloat innerW = width - side * 2;

    // 顶栏
    CGFloat topY = self.view.safeAreaInsets.top + 10.0;
    self.backButton.frame = CGRectMake(side, topY, 44.0, 44.0);
    self.titleLabel.frame = CGRectMake(side + 54.0, topY, innerW - 108.0, 44.0);
    CGFloat y = topY + 44.0 + 8.0;

    // 搜索框：margin 8 20 4，高 48
    self.searchBox.frame = CGRectMake(side, y + 8.0, innerW, 48.0);
    self.searchIcon.frame = CGRectMake(16.0, 15.0, 18.0, 18.0);
    self.searchField.frame = CGRectMake(44.0, 0, innerW - 60.0, 48.0);
    y = CGRectGetMaxY(self.searchBox.frame) + 4.0;

    // 底栏：padding 12 20 34
    CGFloat bottomPad = MAX(self.view.safeAreaInsets.bottom, 16.0);
    CGFloat footerH = 12.0 + 56.0 + bottomPad;
    self.footerView.frame = CGRectMake(0, height - footerH, width, footerH);
    self.confirmButton.frame = CGRectMake(side, 12.0, innerW, 56.0);

    // 滚动区：padding 8 20 0，gap 18
    self.scrollView.frame = CGRectMake(0, y, width, CGRectGetMinY(self.footerView.frame) - y);
    CGFloat cy = 8.0;
    if (self.recentLanguages.count > 0) {
        self.recentLabel.hidden = NO;
        self.chipsView.hidden = NO;
        self.recentLabel.frame = CGRectMake(side, cy, innerW, 16.0);
        cy += 16.0 + 10.0;
        CGFloat chipsH = [self layoutChipsWithWidth:innerW];
        self.chipsView.frame = CGRectMake(side, cy, innerW, chipsH);
        cy += chipsH + 18.0;
    } else {
        self.recentLabel.hidden = YES;
        self.chipsView.hidden = YES;
    }
    self.allLabel.frame = CGRectMake(side, cy, innerW, 16.0);
    cy += 16.0 + 10.0;
    CGFloat listH = [self layoutListRowsWithWidth:innerW];
    self.listView.frame = CGRectMake(side, cy, innerW, listH);
    cy += listH + 20.0;
    self.scrollView.contentSize = CGSizeMake(width, cy);
}

/// chips 流式排布：高 40，gap 8，返回总高
- (CGFloat)layoutChipsWithWidth:(CGFloat)width {
    CGFloat x = 0, y = 0;
    CGFloat chipH = 40.0, gap = 8.0;
    for (UIView *chip in self.chipsView.subviews) {
        CGFloat w = CGRectGetWidth(chip.bounds);
        if (x > 0 && x + w > width) {
            x = 0;
            y += chipH + gap;
        }
        chip.frame = CGRectMake(x, y, w, chipH);
        x += w + gap;
    }
    return self.chipsView.subviews.count > 0 ? y + chipH : 0;
}

/// 列表行纵向排布：最小高 60，返回总高
- (CGFloat)layoutListRowsWithWidth:(CGFloat)width {
    if (self.filteredLanguages.count == 0) {
        self.emptyLabel.hidden = NO;
        self.emptyLabel.frame = CGRectMake(0, 0, width, 60.0);
        return 60.0;
    }
    self.emptyLabel.hidden = YES;
    CGFloat y = 0;
    for (UIView *row in self.listView.subviews) {
        if (row == self.emptyLabel) continue;
        row.frame = CGRectMake(0, y, width, 60.0);
        y += 60.0;
    }
    return y;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    // 只用来收起键盘，不拦截控件的点击
    return ![touch.view isKindOfClass:[UIControl class]];
}

#pragma mark - 私有方法 - 数据

/// 读取最近使用并过滤为候选中存在的语言
- (void)loadRecent {
    NSArray *stored = [[NSUserDefaults standardUserDefaults] arrayForKey:kTSAIInterpreterRecentLanguagesKey];
    NSMutableArray<NSNumber *> *recent = [NSMutableArray array];
    for (id item in stored) {
        if (![item isKindOfClass:[NSNumber class]]) continue;
        if ([self.languages containsObject:item] && ![recent containsObject:item]) {
            [recent addObject:item];
        }
        if (recent.count >= kTSAIInterpreterRecentLimit) break;
    }
    self.recentLanguages = recent;
}

/// 把一次选择写入最近使用（Auto 不记录）
- (void)rememberRecent:(TSAILanguage)language {
    if (language == TSAILanguageAuto) return;
    NSMutableArray<NSNumber *> *stored =
        [[[NSUserDefaults standardUserDefaults] arrayForKey:kTSAIInterpreterRecentLanguagesKey] mutableCopy]
        ?: [NSMutableArray array];
    [stored removeObject:@(language)];
    [stored insertObject:@(language) atIndex:0];
    while (stored.count > kTSAIInterpreterRecentLimit) [stored removeLastObject];
    [[NSUserDefaults standardUserDefaults] setObject:stored forKey:kTSAIInterpreterRecentLanguagesKey];
    [self loadRecent];
}

/// 语言的原生名（Auto 为「由后端判断语种」）
- (NSString *)nativeNameForLanguage:(TSAILanguage)language {
    if (language == TSAILanguageAuto) {
        return TSLocalizedString(@"ai_interpreter.lang_auto_native");
    }
    NSString *code = [TSAILanguageMapper bcp47CodeForLanguage:language];
    if (code.length == 0) return @"";
    NSLocale *locale = [NSLocale localeWithLocaleIdentifier:code];
    NSString *name = [locale localizedStringForLocaleIdentifier:code];
    if (name.length == 0) {
        name = [locale localizedStringForLanguageCode:[code componentsSeparatedByString:@"-"].firstObject ?: code];
    }
    return name.length > 0 ? name : code;
}

/// 按搜索词过滤
- (NSArray<NSNumber *> *)languagesMatchingQuery:(NSString *)query {
    NSString *q = [query stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].lowercaseString;
    if (q.length == 0) return self.languages;
    NSMutableArray<NSNumber *> *result = [NSMutableArray array];
    for (NSNumber *item in self.languages) {
        TSAILanguage language = (TSAILanguage)item.integerValue;
        NSString *name = [TSAIInterpreterFormatter displayNameForLanguage:language].lowercaseString;
        NSString *native = [self nativeNameForLanguage:language].lowercaseString;
        NSString *code = ([TSAILanguageMapper bcp47CodeForLanguage:language] ?: @"").lowercaseString;
        if ([name containsString:q] || [native containsString:q] || [code containsString:q]) {
            [result addObject:item];
        }
    }
    return result;
}

#pragma mark - 私有方法 - 构建

/// 重建 chips 与列表行
- (void)rebuildList {
    for (UIView *chip in self.chipsView.subviews.copy) [chip removeFromSuperview];
    for (NSNumber *item in self.recentLanguages) {
        [self.chipsView addSubview:[self chipForLanguage:(TSAILanguage)item.integerValue]];
    }
    for (UIView *row in self.listView.subviews.copy) {
        if (row != self.emptyLabel) [row removeFromSuperview];
    }
    self.filteredLanguages = [self languagesMatchingQuery:self.searchField.text ?: @""];
    [self.filteredLanguages enumerateObjectsUsingBlock:^(NSNumber *item, NSUInteger idx, BOOL *stop) {
        UIControl *row = [self rowForLanguage:(TSAILanguage)item.integerValue isLast:idx == self.filteredLanguages.count - 1];
        [self.listView insertSubview:row belowSubview:self.emptyLabel];
    }];
    self.allLabel.attributedText = [self sectionAttributedText:
        [NSString stringWithFormat:TSLocalizedString(@"ai_interpreter.lang_all_fmt"), (unsigned long)self.languages.count]];
    [self.view setNeedsLayout];
}

/// 「最近使用」chip：高 40，圆角 20，内边距 16，14px / 500；选中为 ink 底白字
- (UIButton *)chipForLanguage:(TSAILanguage)language {
    BOOL on = language == self.currentLanguage;
    UIColor *background = on ? [TSAIInterpreterTheme ink] : [TSAIInterpreterTheme panel];
    UIColor *tint = on ? [UIColor whiteColor] : [TSAIInterpreterTheme ink];
    UIButton *chip = [UIButton buttonWithType:UIButtonTypeCustom];
    chip.tag = language;
    UIButtonConfiguration *cfg = [UIButtonConfiguration plainButtonConfiguration];
    cfg.contentInsets = NSDirectionalEdgeInsetsMake(0, 16.0, 0, 16.0);
    UIBackgroundConfiguration *bg = cfg.background;
    bg.backgroundColor = background;
    bg.cornerRadius = 20.0;
    cfg.background = bg;
    cfg.baseForegroundColor = tint;
    cfg.attributedTitle = [[NSAttributedString alloc]
        initWithString:[TSAIInterpreterFormatter displayNameForLanguage:language]
            attributes:@{ NSFontAttributeName: [TSAIInterpreterTheme fontOfSize:14.0 cssWeight:500],
                          NSForegroundColorAttributeName: tint }];
    chip.configuration = cfg;
    chip.configurationUpdateHandler = ^(UIButton *b) {
        UIButtonConfiguration *updated = b.configuration;
        UIBackgroundConfiguration *updatedBg = updated.background;
        updatedBg.backgroundColor = background;
        updated.background = updatedBg;
        updated.baseForegroundColor = tint;
        b.configuration = updated;
    };
    CGSize size = [chip sizeThatFits:CGSizeMake(CGFLOAT_MAX, 40.0)];
    chip.frame = CGRectMake(0, 0, ceil(size.width), 40.0);
    [chip addTarget:self action:@selector(onChipTap:) forControlEvents:UIControlEventTouchUpInside];
    return chip;
}

/// 构建一行
- (UIControl *)rowForLanguage:(TSAILanguage)language isLast:(BOOL)isLast {
    TSAIInterpreterLanguageRow *row = [[TSAIInterpreterLanguageRow alloc] initWithFrame:CGRectZero];
    row.tag = language;
    row.nameLabel.text = [TSAIInterpreterFormatter displayNameForLanguage:language];
    row.nativeLabel.text = [self nativeNameForLanguage:language];
    row.separator.hidden = isLast;
    [row setChecked:language == self.currentLanguage];
    [row addTarget:self action:@selector(onRowTap:) forControlEvents:UIControlEventTouchUpInside];
    return row;
}

/// 分组标题样式（13px / 600 / muted / 0.5 字距）
- (NSAttributedString *)sectionAttributedText:(NSString *)text {
    return [[NSAttributedString alloc]
        initWithString:text
            attributes:@{ NSFontAttributeName: [TSAIInterpreterTheme fontOfSize:13.0 cssWeight:600],
                          NSForegroundColorAttributeName: [TSAIInterpreterTheme muted],
                          NSKernAttributeName: @0.5 }];
}

#pragma mark - 私有方法 - 事件

- (void)onBackgroundTap {
    [self.searchField resignFirstResponder];
}

- (void)onChipTap:(UIButton *)chip {
    [self selectLanguage:(TSAILanguage)chip.tag];
}

- (void)onRowTap:(UIControl *)row {
    [self selectLanguage:(TSAILanguage)row.tag];
}

/// 选中某语言：只移动选中态并记录最近使用，不关闭页面
- (void)selectLanguage:(TSAILanguage)language {
    self.currentLanguage = language;
    [self rememberRecent:language];
    [self rebuildList];
}

- (void)onSearchChanged {
    [self rebuildList];
}

/// 返回 / 确定：关闭页面并回传变化
- (void)onBackTap {
    [self finish];
}

- (void)onConfirmTap {
    [self finish];
}

- (void)finish {
    [self.searchField resignFirstResponder];
    TSAILanguage picked = self.currentLanguage;
    BOOL changed = picked != self.initialLanguage;
    void (^handler)(TSAILanguage) = self.onPickHandler;
    [self dismissViewControllerAnimated:YES completion:^{
        if (changed && handler != nil) handler(picked);
    }];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - 属性（懒加载）

- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [TSAIInterpreterTheme iconButtonWithSymbol:@"chevron.backward"
                                                      background:[TSAIInterpreterTheme panel]
                                                            tint:[TSAIInterpreterTheme ink]
                                                          target:self
                                                          action:@selector(onBackTap)];
    }
    return _backButton;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = self.sheetTitleText;
        _titleLabel.font = [TSAIInterpreterTheme fontOfSize:17.0 cssWeight:700];
        _titleLabel.textColor = [TSAIInterpreterTheme ink];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (UIView *)searchBox {
    if (!_searchBox) {
        _searchBox = [[UIView alloc] init];
        _searchBox.backgroundColor = [TSAIInterpreterTheme panel];
        _searchBox.layer.cornerRadius = 16.0;
    }
    return _searchBox;
}

- (UIImageView *)searchIcon {
    if (!_searchIcon) {
        _searchIcon = [TSAIInterpreterTheme symbolViewNamed:@"magnifyingglass" pointSize:16.0 tint:[TSAIInterpreterTheme muted]];
    }
    return _searchIcon;
}

- (UITextField *)searchField {
    if (!_searchField) {
        _searchField = [[UITextField alloc] init];
        _searchField.font = [TSAIInterpreterTheme fontOfSize:15.0 cssWeight:400];
        _searchField.textColor = [TSAIInterpreterTheme ink];
        _searchField.placeholder = TSLocalizedString(@"ai_interpreter.lang_search_placeholder");
        _searchField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _searchField.returnKeyType = UIReturnKeySearch;
        _searchField.autocorrectionType = UITextAutocorrectionTypeNo;
        _searchField.delegate = self;
        [_searchField addTarget:self action:@selector(onSearchChanged) forControlEvents:UIControlEventEditingChanged];
    }
    return _searchField;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.alwaysBounceVertical = YES;
        _scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        _scrollView.showsVerticalScrollIndicator = NO;
    }
    return _scrollView;
}

- (UILabel *)recentLabel {
    if (!_recentLabel) {
        _recentLabel = [[UILabel alloc] init];
        _recentLabel.attributedText = [self sectionAttributedText:TSLocalizedString(@"ai_interpreter.lang_recent")];
    }
    return _recentLabel;
}

- (UIView *)chipsView {
    if (!_chipsView) _chipsView = [[UIView alloc] init];
    return _chipsView;
}

- (UILabel *)allLabel {
    if (!_allLabel) _allLabel = [[UILabel alloc] init];
    return _allLabel;
}

- (UIView *)listView {
    if (!_listView) {
        _listView = [[UIView alloc] init];
        _listView.backgroundColor = [TSAIInterpreterTheme panel];
        _listView.layer.cornerRadius = 18.0;
        _listView.clipsToBounds = YES;
    }
    return _listView;
}

- (UILabel *)emptyLabel {
    if (!_emptyLabel) {
        _emptyLabel = [[UILabel alloc] init];
        _emptyLabel.text = TSLocalizedString(@"ai_interpreter.lang_no_match");
        _emptyLabel.font = [TSAIInterpreterTheme fontOfSize:13.0 cssWeight:400];
        _emptyLabel.textColor = [TSAIInterpreterTheme muted];
        _emptyLabel.textAlignment = NSTextAlignmentCenter;
        _emptyLabel.hidden = YES;
    }
    return _emptyLabel;
}

- (UIView *)footerView {
    if (!_footerView) {
        _footerView = [[UIView alloc] init];
        _footerView.backgroundColor = [TSAIInterpreterTheme paper];
    }
    return _footerView;
}

- (UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [TSAIInterpreterTheme ctaButtonWithTitle:TSLocalizedString(@"ai_interpreter.lang_confirm")
                                                           symbol:nil
                                                       background:[TSAIInterpreterTheme ink]
                                                             tint:[UIColor whiteColor]
                                                        cssWeight:700
                                                           target:self
                                                           action:@selector(onConfirmTap)];
    }
    return _confirmButton;
}

@end
