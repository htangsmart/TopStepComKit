//
//  TSRealtimeDanMuLogView.m
//  TopStepComKit_Example
//

#import "TSRealtimeDanMuLogView.h"

#import <TopStepToolKit/TopStepToolKit.h>

#import "TSDialEditorAppearance.h"
#import "TSRootVC.h"

/** 保留的记录条数 */
static const NSUInteger kTSRealtimeDanMuLogCapacity = 20;
/** 记录区固定高度 */
static const CGFloat kTSRealtimeDanMuLogBodyHeight = 132.f;

@interface TSRealtimeDanMuLogView ()

@property (nonatomic, strong) UIView *headingView;
@property (nonatomic, strong) UIButton *clearButton;
@property (nonatomic, strong) UITextView *bodyView;
@property (nonatomic, strong) NSMutableArray<NSString *> *records;
@property (nonatomic, strong) NSDateFormatter *timeFormatter;

@end

@implementation TSRealtimeDanMuLogView

#pragma mark - 生命周期

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _records = [NSMutableArray array];
        _timeFormatter = [[NSDateFormatter alloc] init];
        _timeFormatter.dateFormat = @"HH:mm:ss";
        [self buildSubviews];
        [self refreshBody];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = CGRectGetWidth(self.bounds);
    UIView *separator = [self viewWithTag:1];
    separator.frame = CGRectMake(0, 0, width, 1);
    self.headingView.frame = CGRectMake(0, 17, width - 60, 20);
    self.clearButton.frame = CGRectMake(width - 60, 12, 60, 30);
    self.bodyView.frame = CGRectMake(0, 49, width, kTSRealtimeDanMuLogBodyHeight);
}

#pragma mark - 公开方法

- (CGFloat)preferredHeight {
    return 49 + kTSRealtimeDanMuLogBodyHeight + 8;
}

/** 屏幕记录与 TSLog 同步输出，联调时两边能对上 */
- (void)appendSuccess:(BOOL)success action:(NSString *)action detail:(NSString *)detail {
    NSString *line = [NSString stringWithFormat:@"%@  %@  %@  %@",
                      [self.timeFormatter stringFromDate:NSDate.date],
                      success ? @"✓" : @"✗",
                      action ?: @"",
                      detail ?: @""];
    [self.records insertObject:line atIndex:0];
    while (self.records.count > kTSRealtimeDanMuLogCapacity) {
        [self.records removeLastObject];
    }
    TSLog(@"[TSRealtimeDanMuVC] %@", line);
    [self refreshBody];
}

- (void)clearRecords {
    [self.records removeAllObjects];
    [self refreshBody];
}

#pragma mark - 私有方法

- (void)buildSubviews {
    UIView *separator = [[UIView alloc] init];
    separator.tag = 1;
    separator.backgroundColor = [TSDialEditorAppearance color:0xE9EAE4];
    [self addSubview:separator];

    self.headingView = [TSDialEditorAppearance heading:7 title:TSLocalizedString(@"realtime_danmu.section.log")];
    [self addSubview:self.headingView];

    self.clearButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.clearButton setTitle:TSLocalizedString(@"realtime_danmu.log.clear") forState:UIControlStateNormal];
    self.clearButton.titleLabel.font = [UIFont systemFontOfSize:11];
    self.clearButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    self.clearButton.tintColor = [TSDialEditorAppearance color:0xA96D4C];
    [self.clearButton addTarget:self action:@selector(clearRecords) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.clearButton];

    self.bodyView = [[UITextView alloc] init];
    self.bodyView.editable = NO;
    self.bodyView.backgroundColor = [TSDialEditorAppearance color:0xFAFAF8];
    self.bodyView.layer.cornerRadius = 11;
    self.bodyView.layer.borderWidth = 1;
    self.bodyView.layer.borderColor = [TSDialEditorAppearance color:0xE9EAE4].CGColor;
    self.bodyView.font = [UIFont monospacedDigitSystemFontOfSize:10.5 weight:UIFontWeightRegular];
    self.bodyView.textColor = [TSDialEditorAppearance color:0x252823];
    self.bodyView.textContainerInset = UIEdgeInsetsMake(10, 8, 10, 8);
    [self addSubview:self.bodyView];
}

- (void)refreshBody {
    if (self.records.count == 0) {
        self.bodyView.text = TSLocalizedString(@"realtime_danmu.log.empty");
        self.bodyView.textColor = [TSDialEditorAppearance color:0x93958E];
        return;
    }
    self.bodyView.text = [self.records componentsJoinedByString:@"\n"];
    self.bodyView.textColor = [TSDialEditorAppearance color:0x252823];
    [self.bodyView setContentOffset:CGPointZero animated:NO];
}

@end
