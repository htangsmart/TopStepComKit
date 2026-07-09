//
//  TSAIChatLogSheet.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/19.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIChatLogSheet.h"

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

#import "TSRootVC.h"

/// iOS 13+ 用系统等宽字体；iOS 12 回退到 Menlo
static inline UIFont *TSAIChatMonoFont(CGFloat size, UIFontWeight weight) {
    if (@available(iOS 13.0, *)) {
        return [UIFont monospacedSystemFontOfSize:size weight:weight];
    }
    return [UIFont fontWithName:@"Menlo" size:size] ?: [UIFont systemFontOfSize:size weight:weight];
}

@interface TSAIChatLogSheet ()

@property (nonatomic, strong) UISegmentedControl *tabSegment;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIStackView  *listStack;
@property (nonatomic, strong) UILabel      *emptyLabel;

// 已渲染的条目（按发生顺序）
@property (nonatomic, strong) NSMutableArray<UIView *> *contentRows;
@property (nonatomic, strong) NSMutableArray<UIView *> *eventRows;

@end

@implementation TSAIChatLogSheet

#pragma mark - 生命周期

- (instancetype)init {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _contentRows = [NSMutableArray array];
        _eventRows   = [NSMutableArray array];
        if (@available(iOS 13.0, *)) {
            self.modalPresentationStyle = UIModalPresentationPageSheet;
        } else {
            self.modalPresentationStyle = UIModalPresentationFormSheet;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = TSColor_Background;
    self.title = @"调试日志";

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭"
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(onCloseTapped)];
    self.navigationItem.leftBarButtonItem  = [[UIBarButtonItem alloc] initWithTitle:@"清空"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(onClearTapped)];

    [self.view addSubview:self.tabSegment];
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.listStack];
    [self.view addSubview:self.emptyLabel];

    [self setupConstraints];
    [self refreshVisibleList];
}

#pragma mark - 公开方法

- (void)appendContent:(TSAIChatContent *)content {
    if (!content) return;
    UIView *row = [self rowViewForContent:content];
    [self.contentRows addObject:row];
    [self updateTabTitles];
    if (self.tabSegment.selectedSegmentIndex == 0) {
        [self.listStack addArrangedSubview:row];
        [self updateEmptyLabel];
        [self scrollToBottomDeferred];
    }
}

- (void)appendEvent:(TSAIChatEvent *)event {
    if (!event) return;
    UIView *row = [self rowViewForEvent:event];
    [self.eventRows addObject:row];
    [self updateTabTitles];
    if (self.tabSegment.selectedSegmentIndex == 1) {
        [self.listStack addArrangedSubview:row];
        [self updateEmptyLabel];
        [self scrollToBottomDeferred];
    }
}

- (void)clearAll {
    [self.contentRows removeAllObjects];
    [self.eventRows removeAllObjects];
    [self updateTabTitles];
    [self refreshVisibleList];
}

#pragma mark - 私有方法

- (void)setupConstraints {
    self.tabSegment.translatesAutoresizingMaskIntoConstraints = NO;
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.listStack.translatesAutoresizingMaskIntoConstraints  = NO;
    self.emptyLabel.translatesAutoresizingMaskIntoConstraints = NO;

    UILayoutGuide *safeArea = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [self.tabSegment.topAnchor      constraintEqualToAnchor:safeArea.topAnchor      constant:TSSpacing_SM],
        [self.tabSegment.leadingAnchor  constraintEqualToAnchor:safeArea.leadingAnchor  constant:TSSpacing_MD],
        [self.tabSegment.trailingAnchor constraintEqualToAnchor:safeArea.trailingAnchor constant:-TSSpacing_MD],

        [self.scrollView.topAnchor      constraintEqualToAnchor:self.tabSegment.bottomAnchor constant:TSSpacing_SM],
        [self.scrollView.leadingAnchor  constraintEqualToAnchor:safeArea.leadingAnchor],
        [self.scrollView.trailingAnchor constraintEqualToAnchor:safeArea.trailingAnchor],
        [self.scrollView.bottomAnchor   constraintEqualToAnchor:safeArea.bottomAnchor],

        [self.listStack.topAnchor      constraintEqualToAnchor:self.scrollView.topAnchor      constant:TSSpacing_SM],
        [self.listStack.leadingAnchor  constraintEqualToAnchor:self.scrollView.leadingAnchor  constant:TSSpacing_MD],
        [self.listStack.trailingAnchor constraintEqualToAnchor:self.scrollView.trailingAnchor constant:-TSSpacing_MD],
        [self.listStack.bottomAnchor   constraintEqualToAnchor:self.scrollView.bottomAnchor   constant:-TSSpacing_MD],
        [self.listStack.widthAnchor    constraintEqualToAnchor:self.scrollView.widthAnchor    constant:-TSSpacing_MD * 2],

        [self.emptyLabel.centerXAnchor constraintEqualToAnchor:self.scrollView.centerXAnchor],
        [self.emptyLabel.centerYAnchor constraintEqualToAnchor:self.scrollView.centerYAnchor],
    ]];
}

/// 渲染一条 content 行
- (UIView *)rowViewForContent:(TSAIChatContent *)content {
    NSString *typeName = [self readableNameForContentType:content.contentType];
    UIColor  *typeColor = [self colorForContentType:content.contentType];
    NSString *body = [self bodyTextForContent:content];

    return [self makeLogRowWithType:typeName
                          typeColor:typeColor
                            tagText:[NSString stringWithFormat:@"round=%ld", (long)content.roundIndex]
                               body:body
                          timestamp:[self formatTimestamp:[NSDate date]]];
}

/// 渲染一条 event 行
- (UIView *)rowViewForEvent:(TSAIChatEvent *)event {
    NSString *typeName = [self readableNameForEventType:event.eventType];
    UIColor  *typeColor = TSColor_Warning;
    NSString *body = [NSString stringWithFormat:@"taskId: %@", [self abbreviateTaskId:event.taskId]];
    NSDate *ts = event.timestamp ?: [NSDate date];

    return [self makeLogRowWithType:typeName
                          typeColor:typeColor
                            tagText:nil
                               body:body
                          timestamp:[self formatTimestamp:ts]];
}

/// 构造一行 log 卡片
- (UIView *)makeLogRowWithType:(NSString *)typeName
                     typeColor:(UIColor *)typeColor
                       tagText:(nullable NSString *)tagText
                          body:(NSString *)body
                     timestamp:(NSString *)timestamp {
    UIView *card = [[UIView alloc] init];
    card.backgroundColor = TSColor_Card;
    card.layer.cornerRadius = TSRadius_SM;
    card.layer.borderWidth = 0.5f;
    card.layer.borderColor = TSColor_Separator.CGColor;

    UILabel *typeLabel = [[UILabel alloc] init];
    typeLabel.font = TSAIChatMonoFont(11.f, UIFontWeightSemibold);
    typeLabel.textColor = typeColor;
    typeLabel.text = tagText.length > 0
        ? [NSString stringWithFormat:@"[%@] %@", typeName, tagText]
        : [NSString stringWithFormat:@"[%@]", typeName];
    typeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [card addSubview:typeLabel];

    UILabel *timeLabel = [[UILabel alloc] init];
    timeLabel.font = TSAIChatMonoFont(10.f, UIFontWeightRegular);
    timeLabel.textColor = TSColor_TextSecondary;
    timeLabel.text = timestamp;
    timeLabel.textAlignment = NSTextAlignmentRight;
    timeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [card addSubview:timeLabel];

    UILabel *bodyLabel = [[UILabel alloc] init];
    bodyLabel.font = TSAIChatMonoFont(11.f, UIFontWeightRegular);
    bodyLabel.textColor = TSColor_TextPrimary;
    bodyLabel.text = body;
    bodyLabel.numberOfLines = 0;
    bodyLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [card addSubview:bodyLabel];

    [NSLayoutConstraint activateConstraints:@[
        [typeLabel.topAnchor      constraintEqualToAnchor:card.topAnchor     constant:6.f],
        [typeLabel.leadingAnchor  constraintEqualToAnchor:card.leadingAnchor constant:10.f],
        [typeLabel.trailingAnchor constraintLessThanOrEqualToAnchor:timeLabel.leadingAnchor constant:-6.f],

        [timeLabel.topAnchor      constraintEqualToAnchor:typeLabel.topAnchor],
        [timeLabel.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-10.f],

        [bodyLabel.topAnchor      constraintEqualToAnchor:typeLabel.bottomAnchor constant:2.f],
        [bodyLabel.leadingAnchor  constraintEqualToAnchor:card.leadingAnchor    constant:10.f],
        [bodyLabel.trailingAnchor constraintEqualToAnchor:card.trailingAnchor   constant:-10.f],
        [bodyLabel.bottomAnchor   constraintEqualToAnchor:card.bottomAnchor     constant:-6.f],
    ]];

    return card;
}

/// 切换 tab 时整体刷新可见列表
- (void)refreshVisibleList {
    for (UIView *v in [self.listStack.arrangedSubviews copy]) {
        [self.listStack removeArrangedSubview:v];
        [v removeFromSuperview];
    }
    NSArray<UIView *> *rows = (self.tabSegment.selectedSegmentIndex == 0) ? self.contentRows : self.eventRows;
    for (UIView *r in rows) {
        [self.listStack addArrangedSubview:r];
    }
    [self updateEmptyLabel];
    [self scrollToBottomDeferred];
}

- (void)updateTabTitles {
    [self.tabSegment setTitle:[NSString stringWithFormat:@"Content (%lu)", (unsigned long)self.contentRows.count]
            forSegmentAtIndex:0];
    [self.tabSegment setTitle:[NSString stringWithFormat:@"Event (%lu)", (unsigned long)self.eventRows.count]
            forSegmentAtIndex:1];
}

- (void)updateEmptyLabel {
    NSArray *rows = (self.tabSegment.selectedSegmentIndex == 0) ? self.contentRows : self.eventRows;
    self.emptyLabel.hidden = (rows.count > 0);
}

/// 渲染后下一 runloop 滚到底
- (void)scrollToBottomDeferred {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.scrollView layoutIfNeeded];
        CGFloat bottomY = self.scrollView.contentSize.height - self.scrollView.bounds.size.height;
        if (bottomY > 0) {
            [self.scrollView setContentOffset:CGPointMake(0, bottomY) animated:NO];
        }
    });
}

/// content body 文本
- (NSString *)bodyTextForContent:(TSAIChatContent *)content {
    switch (content.contentType) {
        case TSAIChatContentTypeQuestion:
        case TSAIChatContentTypeAnswer:
            return [NSString stringWithFormat:@"text: \"%@\"\nisFinal: %@",
                    content.text ?: @"", content.isTextFinal ? @"YES" : @"NO"];
        case TSAIChatContentTypeAudioChunk:
            return [NSString stringWithFormat:@"bytes: %lu  format: %ld\nisAudioFinal: %@",
                    (unsigned long)content.audioChunk.length,
                    (long)content.audioFormat,
                    content.isAudioFinal ? @"YES" : @"NO"];
        case TSAIChatContentTypeIntent:
            return [NSString stringWithFormat:@"type: %ld\nquery: \"%@\"\nvalue: %@\nintentId: %@",
                    (long)content.intent.type,
                    content.intent.query ?: @"",
                    content.intent.value ?: @"-",
                    content.intent.intentId ?: @"-"];
        default:
            return @"(unknown)";
    }
}

- (NSString *)readableNameForContentType:(TSAIChatContentType)type {
    switch (type) {
        case TSAIChatContentTypeQuestion:   return @"Question";
        case TSAIChatContentTypeAnswer:     return @"Answer";
        case TSAIChatContentTypeAudioChunk: return @"AudioChunk";
        case TSAIChatContentTypeIntent:     return @"Intent";
        default: return @"Unknown";
    }
}

- (UIColor *)colorForContentType:(TSAIChatContentType)type {
    switch (type) {
        case TSAIChatContentTypeQuestion:   return TSColor_Primary;
        case TSAIChatContentTypeAnswer:     return TSColor_Purple;
        case TSAIChatContentTypeAudioChunk: return TSColor_Success;
        case TSAIChatContentTypeIntent:     return TSColor_Warning;
        default: return TSColor_TextSecondary;
    }
}

- (NSString *)readableNameForEventType:(TSAIChatEventType)type {
    switch (type) {
        case TSAIChatEventTypeSessionStarted:        return @"SessionStarted";
        case TSAIChatEventTypeUserSpeechStarted:     return @"UserSpeechStarted";
        case TSAIChatEventTypeUserSpeechEnded:       return @"UserSpeechEnded";
        case TSAIChatEventTypeAIPlaybackStarted:     return @"AIPlaybackStarted";
        case TSAIChatEventTypeAIPlaybackEnded:       return @"AIPlaybackEnded";
        case TSAIChatEventTypeAIPlaybackInterrupted: return @"AIPlaybackInterrupted";
        case TSAIChatEventTypeNetworkError:          return @"NetworkError";
        case TSAIChatEventTypeBleDisconnected:       return @"BleDisconnected";
        case TSAIChatEventTypeAutoEnding:            return @"AutoEnding";
        default: return @"Unknown";
    }
}

- (NSString *)abbreviateTaskId:(NSString *)taskId {
    if (taskId.length <= 8) return taskId ?: @"";
    return [NSString stringWithFormat:@"%@...", [taskId substringToIndex:8]];
}

- (NSString *)formatTimestamp:(NSDate *)date {
    static NSDateFormatter *fmt;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fmt = [[NSDateFormatter alloc] init];
        fmt.dateFormat = @"HH:mm:ss.SSS";
    });
    return [fmt stringFromDate:date ?: [NSDate date]];
}

#pragma mark - 事件

- (void)onCloseTapped {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onClearTapped {
    [self clearAll];
}

- (void)onTabChanged {
    [self refreshVisibleList];
}

#pragma mark - 属性（懒加载）

- (UISegmentedControl *)tabSegment {
    if (!_tabSegment) {
        _tabSegment = [[UISegmentedControl alloc] initWithItems:@[@"Content (0)", @"Event (0)"]];
        _tabSegment.selectedSegmentIndex = 0;
        [_tabSegment addTarget:self
                        action:@selector(onTabChanged)
              forControlEvents:UIControlEventValueChanged];
    }
    return _tabSegment;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.alwaysBounceVertical = YES;
    }
    return _scrollView;
}

- (UIStackView *)listStack {
    if (!_listStack) {
        _listStack = [[UIStackView alloc] init];
        _listStack.axis = UILayoutConstraintAxisVertical;
        _listStack.alignment = UIStackViewAlignmentFill;
        _listStack.spacing = 6.f;
    }
    return _listStack;
}

- (UILabel *)emptyLabel {
    if (!_emptyLabel) {
        _emptyLabel = [[UILabel alloc] init];
        _emptyLabel.font = TSFont_Body;
        _emptyLabel.textColor = TSColor_TextSecondary;
        _emptyLabel.text = @"暂无回调";
        _emptyLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _emptyLabel;
}

@end
