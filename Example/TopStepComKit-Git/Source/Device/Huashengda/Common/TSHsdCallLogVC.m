//
//  TSHsdCallLogVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/22.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSHsdCallLogVC.h"

#pragma mark - 日志行（.lrow）

@interface TSHsdLogRowView : UIView
@property (nonatomic, strong) UIView *dot;
@property (nonatomic, strong) UILabel *methodLabel;
@property (nonatomic, strong) UILabel *argsLabel;
@property (nonatomic, strong) UILabel *resultLabel;
@property (nonatomic, strong) UILabel *msLabel;
@end

@implementation TSHsdLogRowView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) { return nil; }
    _dot = [[UIView alloc] init];
    _dot.layer.cornerRadius = 3.5f;
    [self addSubview:_dot];
    _methodLabel = [[UILabel alloc] init];
    _methodLabel.font = [TSHsdDisplay monoFontOfSize:12.5f];
    _methodLabel.textColor = [TSHsdDisplay ink];
    _methodLabel.numberOfLines = 2;
    [self addSubview:_methodLabel];
    _argsLabel = [[UILabel alloc] init];
    _argsLabel.font = [UIFont systemFontOfSize:11.5f];
    _argsLabel.textColor = [TSHsdDisplay textSecondary];
    _argsLabel.numberOfLines = 3;
    [self addSubview:_argsLabel];
    _resultLabel = [[UILabel alloc] init];
    _resultLabel.font = [UIFont systemFontOfSize:12.f weight:UIFontWeightSemibold];
    _resultLabel.textAlignment = NSTextAlignmentRight;
    _resultLabel.numberOfLines = 3;
    [self addSubview:_resultLabel];
    _msLabel = [[UILabel alloc] init];
    _msLabel.font = [TSHsdDisplay monoFontOfSize:10.5f];
    _msLabel.textColor = [TSHsdDisplay textTertiary];
    _msLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:_msLabel];
    return self;
}

- (void)configureWithEntry:(TSHsdCallLogEntry *)entry {
    self.methodLabel.text = entry.method;
    NSString *time = [TSHsdDisplay clockString:entry.startedAt];
    self.argsLabel.text = entry.params.length ? [NSString stringWithFormat:@"%@ · %@", time, entry.params] : time;
    if (!entry.finished) {
        self.dot.backgroundColor = [TSHsdDisplay statusWarn];
        self.resultLabel.text = @"…";
        self.resultLabel.textColor = [TSHsdDisplay textSecondary];
        self.msLabel.text = TSLocalizedString(@"hsd.log.pending");
    } else if (entry.success) {
        self.dot.backgroundColor = [TSHsdDisplay statusGood];
        self.resultLabel.text = entry.result.length ? entry.result : TSLocalizedString(@"hsd.log.ok");
        self.resultLabel.textColor = [TSHsdDisplay ink];
        self.msLabel.text = [NSString stringWithFormat:@"%.0f ms", entry.durationMs];
    } else {
        self.dot.backgroundColor = [TSHsdDisplay statusBad];
        self.resultLabel.text = [TSHsdErrorText summaryForError:entry.error];
        self.resultLabel.textColor = [TSHsdDisplay statusBad];
        self.msLabel.text = [NSString stringWithFormat:@"%.0f ms", entry.durationMs];
    }
    [self setNeedsLayout];
}

- (CGFloat)ts_leftWidth:(CGFloat)width { return (width - 16.f * 2 - 8.f - 11.f * 2) * 0.58f; }
- (CGFloat)ts_rightWidth:(CGFloat)width { return (width - 16.f * 2 - 8.f - 11.f * 2) * 0.42f; }

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat lw = [self ts_leftWidth:size.width], rw = [self ts_rightWidth:size.width];
    CGFloat left = ceil([self.methodLabel sizeThatFits:CGSizeMake(lw, CGFLOAT_MAX)].height) + 3.f + ceil([self.argsLabel sizeThatFits:CGSizeMake(lw, CGFLOAT_MAX)].height);
    CGFloat right = ceil([self.resultLabel sizeThatFits:CGSizeMake(rw, CGFLOAT_MAX)].height) + 3.f + 14.f;
    return CGSizeMake(size.width, MAX(left, right) + 24.f);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat w = self.bounds.size.width, lw = [self ts_leftWidth:w], rw = [self ts_rightWidth:w];
    self.dot.frame = CGRectMake(16.f, 17.f, 7.f, 7.f);
    CGFloat x = 16.f + 8.f + 11.f;
    CGFloat mh = ceil([self.methodLabel sizeThatFits:CGSizeMake(lw, CGFLOAT_MAX)].height);
    self.methodLabel.frame = CGRectMake(x, 12.f, lw, mh);
    CGFloat ah = ceil([self.argsLabel sizeThatFits:CGSizeMake(lw, CGFLOAT_MAX)].height);
    self.argsLabel.frame = CGRectMake(x, 12.f + mh + 3.f, lw, ah);
    CGFloat rx = w - 16.f - rw;
    CGFloat rh = ceil([self.resultLabel sizeThatFits:CGSizeMake(rw, CGFLOAT_MAX)].height);
    self.resultLabel.frame = CGRectMake(rx, 12.f, rw, rh);
    self.msLabel.frame = CGRectMake(rx, 12.f + rh + 3.f, rw, 14.f);
}

@end

#pragma mark - TSHsdCallLogVC

@implementation TSHsdCallLogVC

- (void)initData {
    [super initData];
    self.title = TSLocalizedString(@"hsd.log.title");
    self.hue = [TSHsdDisplay hueParental];
    self.showsReloadButton = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ts_entriesChanged) name:TSHsdCallLogDidChangeNotification object:nil];
}

- (void)setupViews {
    [super setupViews];
    // 本页右上角只有「清空」
    UIBarButtonItem *clear = [[UIBarButtonItem alloc] initWithTitle:TSLocalizedString(@"general.clear") style:UIBarButtonItemStylePlain target:self action:@selector(ts_clear)];
    self.navigationItem.rightBarButtonItems = @[clear];
}

- (void)ts_entriesChanged {
    [self render];
}

- (void)ts_clear {
    [[TSHsdCallLog shared] clear];
}

- (NSArray<UIView *> *)buildBlocks {
    NSArray<TSHsdCallLogEntry *> *entries = [TSHsdCallLog shared].entries;
    self.chips = @[@"TSHsdCallLog", [NSString stringWithFormat:TSLocalizedString(@"hsd.log.count_format"), (long)entries.count]];
    self.navigationItem.rightBarButtonItems.firstObject.enabled = entries.count > 0;
    if (!entries.count) {
        TSHsdEmptyView *empty = [self emptyWithSymbol:@"terminal" title:TSLocalizedString(@"hsd.log.empty") text:TSLocalizedString(@"hsd.log.empty_sub") code:nil];
        return @[[self card:@[empty]]];
    }
    NSMutableArray<UIView *> *rows = [NSMutableArray array];
    for (TSHsdCallLogEntry *entry in entries) {
        TSHsdLogRowView *row = [[TSHsdLogRowView alloc] init];
        [row configureWithEntry:entry];
        [rows addObject:row];
    }
    return @[[self card:rows]];
}

@end
