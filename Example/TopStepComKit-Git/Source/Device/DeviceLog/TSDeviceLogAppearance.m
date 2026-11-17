#import "TSDeviceLogAppearance.h"

#import "TSBaseVC.h"
#import "TSDeviceCoordinator.h"

static const NSUInteger kLogBackground = 0xf6f8f6;
static const NSUInteger kLogInk = 0x13261e;
static const NSUInteger kLogMuted = 0x546760;
static const NSUInteger kLogAccent = 0x096650;

UIColor *TSDeviceLogColor(NSUInteger rgb) {
    return [UIColor colorWithRed:((rgb >> 16) & 255) / 255.0 green:((rgb >> 8) & 255) / 255.0
                            blue:(rgb & 255) / 255.0 alpha:1];
}

UILabel *TSDeviceLogLabel(CGFloat size, UIFontWeight weight, UIColor *color) {
    UILabel *label = [[UILabel alloc] init];
    label.font = [[UIFontMetrics defaultMetrics] scaledFontForFont:[UIFont systemFontOfSize:size weight:weight]];
    label.adjustsFontForContentSizeCategory = YES;
    label.textColor = color;
    label.numberOfLines = 0;
    return label;
}

UIStackView *TSDeviceLogStack(NSArray<UIView *> *views, UILayoutConstraintAxis axis, CGFloat spacing) {
    UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:views];
    stack.axis = axis;
    stack.spacing = spacing;
    if (axis == UILayoutConstraintAxisHorizontal) {
        stack.alignment = UIStackViewAlignmentCenter;
    }
    return stack;
}

void TSDeviceLogInset(UIStackView *stack, UIEdgeInsets insets) {
    stack.layoutMarginsRelativeArrangement = YES;
    stack.directionalLayoutMargins = NSDirectionalEdgeInsetsMake(insets.top, insets.left, insets.bottom, insets.right);
}

void TSDeviceLogCard(UIView *view, CGFloat radius) {
    view.backgroundColor = UIColor.whiteColor;
    view.layer.cornerRadius = radius;
    view.layer.borderColor = TSDeviceLogColor(0xdce4de).CGColor;
    view.layer.borderWidth = 1;
    view.clipsToBounds = YES;
}

// 将表单、标题和底部操作放在同一个可滚动区域。
UIScrollView *TSDeviceLogInstall(UIStackView *content, UIView *host) {
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    host.backgroundColor = TSDeviceLogColor(kLogBackground);
    [host addSubview:scrollView];
    [scrollView addSubview:content];
    content.translatesAutoresizingMaskIntoConstraints = NO;
    TSDeviceLogInset(content, UIEdgeInsetsMake(6, 15, 12, 15));
    UILayoutGuide *safe = host.safeAreaLayoutGuide;
    UILayoutGuide *area = scrollView.contentLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [scrollView.topAnchor constraintEqualToAnchor:safe.topAnchor],
        [scrollView.leadingAnchor constraintEqualToAnchor:safe.leadingAnchor],
        [scrollView.trailingAnchor constraintEqualToAnchor:safe.trailingAnchor],
        [scrollView.bottomAnchor constraintEqualToAnchor:safe.bottomAnchor],
        [content.topAnchor constraintEqualToAnchor:area.topAnchor],
        [content.bottomAnchor constraintEqualToAnchor:area.bottomAnchor],
        [content.leadingAnchor constraintEqualToAnchor:area.leadingAnchor],
        [content.trailingAnchor constraintEqualToAnchor:area.trailingAnchor],
        [content.widthAnchor constraintEqualToAnchor:scrollView.frameLayoutGuide.widthAnchor],
    ]];
    return scrollView;
}

// 保留系统返回手势和按钮，只为设备日志两页调整背景与颜色。
void TSDeviceLogNavigation(UINavigationItem *item) {
    UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
    [appearance configureWithOpaqueBackground];
    appearance.backgroundColor = TSDeviceLogColor(kLogBackground);
    appearance.shadowColor = UIColor.clearColor;
    UIColor *tint = TSDeviceLogColor(kLogAccent);
    UIImage *image = [TSDeviceLogPageIcon(@"chevron.left", 17) imageWithTintColor:tint
                                                                  renderingMode:UIImageRenderingModeAlwaysOriginal];
    [appearance setBackIndicatorImage:image transitionMaskImage:image];
    UIFont *font = [[UIFontMetrics defaultMetrics] scaledFontForFont:
                    [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold]];
    appearance.backButtonAppearance.normal.titleTextAttributes =
        @{NSForegroundColorAttributeName: tint, NSFontAttributeName: font};
    item.standardAppearance = appearance;
    item.scrollEdgeAppearance = appearance;
    item.compactAppearance = appearance;
    item.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
}

// 原型使用 24 点坐标，缩放画布时保留图形与留白的比例。
UIImage *TSDeviceLogPageIcon(NSString *symbol, CGFloat size) {
    UIBezierPath *path = [UIBezierPath bezierPath];
    BOOL filled = NO;
    if ([symbol isEqualToString:@"applewatch"]) {
        [path appendPath:[UIBezierPath bezierPathWithRoundedRect:CGRectMake(5.5, 6, 13, 12) cornerRadius:3.5]];
        [path moveToPoint:CGPointMake(9, 6)];
        [path addLineToPoint:CGPointMake(9.7, 2)];
        [path addLineToPoint:CGPointMake(14.3, 2)];
        [path addLineToPoint:CGPointMake(15, 6)];
        [path moveToPoint:CGPointMake(9, 18)];
        [path addLineToPoint:CGPointMake(9.7, 22)];
        [path addLineToPoint:CGPointMake(14.3, 22)];
        [path addLineToPoint:CGPointMake(15, 18)];
        [path moveToPoint:CGPointMake(18.5, 11)];
        [path addLineToPoint:CGPointMake(20, 11)];
    } else if ([symbol isEqualToString:@"slider.horizontal.3"]) {
        CGFloat positions[] = {17, 9, 16};
        for (NSUInteger index = 0; index < sizeof(positions) / sizeof(positions[0]); index++) {
            CGFloat height = 6 + index * 6;
            CGFloat center = positions[index];
            [path moveToPoint:CGPointMake(4, height)];
            [path addLineToPoint:CGPointMake(center - 2, height)];
            [path moveToPoint:CGPointMake(center + 2, height)];
            [path addLineToPoint:CGPointMake(20, height)];
            [path appendPath:[UIBezierPath bezierPathWithOvalInRect:CGRectMake(center - 2, height - 2, 4, 4)]];
        }
    } else if ([symbol isEqualToString:@"play.fill"]) {
        filled = YES;
        [path moveToPoint:CGPointMake(8, 5)];
        [path addLineToPoint:CGPointMake(19, 12)];
        [path addLineToPoint:CGPointMake(8, 19)];
        [path closePath];
    } else if ([symbol isEqualToString:@"stop.fill"]) {
        filled = YES;
        path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(6, 6, 12, 12) cornerRadius:2];
    } else if ([symbol isEqualToString:@"arrow.clockwise"]) {
        path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(13.1, 12) radius:8
                                        startAngle:-M_PI / 6.0 endAngle:M_PI / 6.0 clockwise:NO];
        [path moveToPoint:CGPointMake(20, 3)];
        [path addLineToPoint:CGPointMake(20, 9)];
        [path addLineToPoint:CGPointMake(14, 9)];
    } else if ([symbol isEqualToString:@"chevron.left"] || [symbol isEqualToString:@"chevron.right"]) {
        BOOL left = [symbol isEqualToString:@"chevron.left"];
        [path moveToPoint:CGPointMake(left ? 14 : 9, 6)];
        [path addLineToPoint:CGPointMake(left ? 8 : 15, 12)];
        [path addLineToPoint:CGPointMake(left ? 14 : 9, 18)];
    } else {
        return [UIImage systemImageNamed:symbol withConfiguration:
                [UIImageSymbolConfiguration configurationWithPointSize:size]];
    }
    path.lineWidth = 1.7;
    path.lineCapStyle = kCGLineCapRound;
    path.lineJoinStyle = kCGLineJoinRound;
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(size, size)];
    UIImage *image = [renderer imageWithActions:^(UIGraphicsImageRendererContext *context) {
        CGContextScaleCTM(context.CGContext, size / 24, size / 24);
        [UIColor.blackColor set];
        if (filled) {
            [path fill];
        } else {
            [path stroke];
        }
    }];
    return [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

// 共用设备、类型和文件图标的容器。
static UIView *TSDeviceLogIcon(NSString *symbol, CGFloat size, UIColor *foreground, UIColor *background) {
    UIView *tile = [[UIView alloc] init];
    tile.backgroundColor = background;
    tile.layer.cornerRadius = size == 36 ? 10 : 9;
    UIImageView *icon = [[UIImageView alloc] initWithImage:TSDeviceLogPageIcon(symbol, size == 36 ? 21 : 18)];
    icon.tintColor = foreground;
    icon.translatesAutoresizingMaskIntoConstraints = NO;
    [tile addSubview:icon];
    [NSLayoutConstraint activateConstraints:@[
        [tile.widthAnchor constraintEqualToConstant:size], [tile.heightAnchor constraintEqualToConstant:size],
        [icon.centerXAnchor constraintEqualToAnchor:tile.centerXAnchor],
        [icon.centerYAnchor constraintEqualToAnchor:tile.centerYAnchor],
    ]];
    return tile;
}

UIStackView *TSDeviceLogDeviceCard(TSDeviceConnectionSnapshot *snapshot, NSString *badge, TSDeviceLogTone tone) {
    UIColor *accent = TSDeviceLogColor(kLogAccent);
    UIView *icon = TSDeviceLogIcon(@"applewatch", 36, accent, TSDeviceLogColor(0xdceee5));
    UILabel *name = TSDeviceLogLabel(14, UIFontWeightBold, TSDeviceLogColor(kLogInk));
    name.text = snapshot.peripheral.systemInfo.bleName.length ? snapshot.peripheral.systemInfo.bleName
                                                             : TSLocalizedString(@"device_log.design.device");
    UILabel *connection = TSDeviceLogLabel(12, UIFontWeightRegular, TSDeviceLogColor(kLogMuted));
    connection.text = TSLocalizedString(snapshot.isReady ? @"device_log.design.connected" : @"device_log.design.disconnected");
    UIStackView *text = TSDeviceLogStack(@[name, connection], UILayoutConstraintAxisVertical, 3);
    UIColor *badgeText = tone == TSDeviceLogToneLimited ? TSDeviceLogColor(0x83521c)
        : (tone == TSDeviceLogToneInactive ? TSDeviceLogColor(kLogMuted) : accent);
    UILabel *badgeLabel = TSDeviceLogLabel(11, UIFontWeightBold, badgeText);
    badgeLabel.text = badge;
    badgeLabel.textAlignment = NSTextAlignmentCenter;
    [badgeLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    UIStackView *pill = TSDeviceLogStack(@[badgeLabel], UILayoutConstraintAxisHorizontal, 0);
    TSDeviceLogInset(pill, UIEdgeInsetsMake(5, 8, 5, 8));
    [badgeLabel.heightAnchor constraintGreaterThanOrEqualToConstant:16].active = YES;
    pill.layer.cornerRadius = 13;
    pill.backgroundColor = TSDeviceLogColor(tone == TSDeviceLogToneLimited ? 0xf9eedc
        : (tone == TSDeviceLogToneInactive ? 0xedf1ee : 0xdceee5));
    UIStackView *card = TSDeviceLogStack(@[icon, text, pill], UILayoutConstraintAxisHorizontal, 11);
    TSDeviceLogInset(card, UIEdgeInsetsMake(10, 11, 10, 11));
    TSDeviceLogCard(card, 16);
    [card.heightAnchor constraintGreaterThanOrEqualToConstant:62].active = YES;
    return card;
}

UIButton *TSDeviceLogRow(NSString *symbol, NSString *title, NSString *subtitle, NSString *action,
                          BOOL chevron, BOOL enabled) {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.enabled = enabled;
    button.accessibilityLabel = title;
    button.accessibilityValue = subtitle;
    button.accessibilityHint = action;
    UIColor *accent = TSDeviceLogColor(kLogAccent);
    BOOL file = [symbol isEqualToString:@"doc.text"];
    UIView *icon = TSDeviceLogIcon(symbol, 33, TSDeviceLogColor(enabled ? (file ? 0x396452 : kLogAccent) : 0x687971),
                                  TSDeviceLogColor(enabled ? (file ? 0xe8f1eb : 0xdceee5) : 0xedf1ee));
    UILabel *heading = TSDeviceLogLabel(14, UIFontWeightBold, TSDeviceLogColor(enabled ? kLogInk : kLogMuted));
    heading.text = title;
    UILabel *detail = TSDeviceLogLabel(12, UIFontWeightRegular, TSDeviceLogColor(kLogMuted));
    detail.text = subtitle;
    UIStackView *text = TSDeviceLogStack(@[heading, detail], UILayoutConstraintAxisVertical, 3);
    UIStackView *row = TSDeviceLogStack(@[icon, text], UILayoutConstraintAxisHorizontal, 10);
    if (enabled && chevron) {
        UIImageView *image = [[UIImageView alloc] initWithImage:TSDeviceLogPageIcon(@"chevron.right", 16)];
        image.tintColor = accent;
        [image setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [row addArrangedSubview:image];
    } else if (enabled && action.length) {
        UILabel *label = TSDeviceLogLabel(12, UIFontWeightSemibold, accent);
        label.text = action;
        [label setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [row addArrangedSubview:label];
    }
    row.userInteractionEnabled = NO;
    row.accessibilityElementsHidden = YES;
    row.translatesAutoresizingMaskIntoConstraints = NO;
    [button addSubview:row];
    TSDeviceLogInset(row, UIEdgeInsetsMake(9, 11, 9, 11));
    [NSLayoutConstraint activateConstraints:@[
        [row.topAnchor constraintEqualToAnchor:button.topAnchor],
        [row.leadingAnchor constraintEqualToAnchor:button.leadingAnchor],
        [row.trailingAnchor constraintEqualToAnchor:button.trailingAnchor],
        [row.bottomAnchor constraintEqualToAnchor:button.bottomAnchor],
        [button.heightAnchor constraintGreaterThanOrEqualToConstant:58],
    ]];
    return button;
}

// 文件区随着内容增高，达到原型上限后在卡片内滚动。
UIView *TSDeviceLogFileList(NSArray<UIButton *> *rows, NSString *empty, CGFloat maximumHeight) {
    if (!rows.count) {
        UILabel *label = TSDeviceLogLabel(12, UIFontWeightRegular, TSDeviceLogColor(kLogMuted));
        label.textAlignment = NSTextAlignmentCenter;
        label.text = empty;
        [label.heightAnchor constraintGreaterThanOrEqualToConstant:17].active = YES;
        UIStackView *card = TSDeviceLogStack(@[label], UILayoutConstraintAxisVertical, 0);
        TSDeviceLogInset(card, UIEdgeInsetsMake(18, 13, 18, 13));
        TSDeviceLogCard(card, 14);
        return card;
    }

    UIStackView *files = TSDeviceLogStack(@[], UILayoutConstraintAxisVertical, 0);
    for (UIButton *row in rows) {
        if (files.arrangedSubviews.count) {
            UIView *divider = [[UIView alloc] init];
            divider.backgroundColor = TSDeviceLogColor(0xdce4de);
            [divider.heightAnchor constraintEqualToConstant:1].active = YES;
            [files addArrangedSubview:divider];
        }
        [files addArrangedSubview:row];
    }
    UIScrollView *scroll = [[UIScrollView alloc] init];
    scroll.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    TSDeviceLogCard(scroll, 14);
    files.translatesAutoresizingMaskIntoConstraints = NO;
    [scroll addSubview:files];
    UILayoutGuide *area = scroll.contentLayoutGuide;
    NSLayoutConstraint *fit = [scroll.heightAnchor constraintEqualToAnchor:files.heightAnchor];
    fit.priority = UILayoutPriorityDefaultLow;
    [NSLayoutConstraint activateConstraints:@[
        [files.topAnchor constraintEqualToAnchor:area.topAnchor],
        [files.bottomAnchor constraintEqualToAnchor:area.bottomAnchor],
        [files.leadingAnchor constraintEqualToAnchor:area.leadingAnchor],
        [files.trailingAnchor constraintEqualToAnchor:area.trailingAnchor],
        [files.widthAnchor constraintEqualToAnchor:scroll.frameLayoutGuide.widthAnchor],
        [scroll.heightAnchor constraintLessThanOrEqualToConstant:maximumHeight], fit,
    ]];
    return scroll;
}

void TSDeviceLogPrimary(UIButton *button, NSString *title, NSString *symbol, BOOL destructive, BOOL enabled) {
    UIButtonConfiguration *configuration = [UIButtonConfiguration plainButtonConfiguration];
    configuration.title = title;
    BOOL captureIcon = [symbol isEqualToString:@"play.fill"] || [symbol isEqualToString:@"stop.fill"];
    configuration.image = TSDeviceLogPageIcon(symbol, captureIcon ? 18 : 15);
    configuration.imagePadding = 8;
    configuration.contentInsets = NSDirectionalEdgeInsetsMake(9, 14, 9, 14);
    configuration.titleAlignment = UIButtonConfigurationTitleAlignmentCenter;
    configuration.baseForegroundColor = enabled ? UIColor.whiteColor : TSDeviceLogColor(0x52655b);
    UIBackgroundConfiguration *background = [UIBackgroundConfiguration clearConfiguration];
    background.cornerRadius = 14;
    background.backgroundColor = TSDeviceLogColor(enabled ? (destructive ? 0xa72e33 : kLogAccent) : 0xe0e7e1);
    configuration.background = background;
    configuration.titleTextAttributesTransformer = ^NSDictionary *(NSDictionary *attributes) {
        NSMutableDictionary *styled = [attributes mutableCopy];
        styled[NSFontAttributeName] = [[UIFontMetrics defaultMetrics] scaledFontForFont:
                                      [UIFont systemFontOfSize:15 weight:UIFontWeightBold]];
        styled[NSForegroundColorAttributeName] = enabled ? UIColor.whiteColor : TSDeviceLogColor(0x52655b);
        return styled;
    };
    button.enabled = enabled;
    button.configuration = configuration;
}

NSString *TSDeviceLogBytes(uint64_t count) {
    if (count < 1024) {
        return [NSString stringWithFormat:@"%llu B", (unsigned long long)count];
    }
    if (count < 1024 * 1024) {
        return [NSString stringWithFormat:@"%.1f KiB", count / 1024.0];
    }
    return [NSString stringWithFormat:@"%.2f MiB", count / (1024.0 * 1024)];
}

@interface TSDeviceLogDialogVC : TSBaseVC
@property (nonatomic, copy) NSArray<UIView *> *dialogViews;
@property (nonatomic, assign) BOOL closable;
@end

@implementation TSDeviceLogDialogVC

#pragma mark - 生命周期

// 页面内弹窗使用原型的圆角卡片与半透明遮罩。
- (void)setupViews {
    self.view.backgroundColor = [TSDeviceLogColor(0x0b221b) colorWithAlphaComponent:0.41];
    self.view.accessibilityViewIsModal = YES;
    UILabel *title = TSDeviceLogLabel(22, UIFontWeightBold, TSDeviceLogColor(kLogInk));
    title.text = self.title;
    title.accessibilityTraits |= UIAccessibilityTraitHeader;
    UIStackView *header = TSDeviceLogStack(@[title], UILayoutConstraintAxisHorizontal, 10);
    if (self.closable) {
        UIButton *close = [UIButton buttonWithType:UIButtonTypeSystem];
        [close setImage:[UIImage systemImageNamed:@"xmark"] forState:UIControlStateNormal];
        close.tintColor = TSDeviceLogColor(kLogMuted);
        close.accessibilityLabel = TSLocalizedString(@"device_log.design.close");
        [close addTarget:self action:@selector(closeDialog) forControlEvents:UIControlEventTouchUpInside];
        [header addArrangedSubview:close];
        [NSLayoutConstraint activateConstraints:@[
            [close.widthAnchor constraintEqualToConstant:44], [close.heightAnchor constraintEqualToConstant:44],
        ]];
    }

    UIStackView *content = TSDeviceLogStack([@[header] arrayByAddingObjectsFromArray:self.dialogViews],
                                            UILayoutConstraintAxisVertical, 10);
    TSDeviceLogInset(content, UIEdgeInsetsMake(17, 18, 18, 18));
    UIScrollView *card = [[UIScrollView alloc] init];
    TSDeviceLogCard(card, 23);
    card.backgroundColor = TSDeviceLogColor(0xfbfdfb);
    card.translatesAutoresizingMaskIntoConstraints = NO;
    content.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:card];
    [card addSubview:content];
    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;
    UILayoutGuide *area = card.contentLayoutGuide;
    NSLayoutConstraint *width = [card.widthAnchor constraintEqualToAnchor:safe.widthAnchor constant:-24];
    width.priority = UILayoutPriorityDefaultHigh;
    NSLayoutConstraint *height = [card.heightAnchor constraintEqualToAnchor:content.heightAnchor];
    height.priority = UILayoutPriorityDefaultHigh;
    NSLayoutConstraint *verticalPosition = self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact
        ? [card.bottomAnchor constraintEqualToAnchor:safe.bottomAnchor constant:-6]
        : [card.centerYAnchor constraintEqualToAnchor:safe.centerYAnchor];
    [NSLayoutConstraint activateConstraints:@[
        [card.centerXAnchor constraintEqualToAnchor:safe.centerXAnchor],
        verticalPosition,
        [card.widthAnchor constraintLessThanOrEqualToAnchor:safe.widthAnchor constant:-24],
        [card.widthAnchor constraintLessThanOrEqualToConstant:416], width,
        [card.heightAnchor constraintLessThanOrEqualToAnchor:safe.heightAnchor constant:-24], height,
        [content.topAnchor constraintEqualToAnchor:area.topAnchor],
        [content.bottomAnchor constraintEqualToAnchor:area.bottomAnchor],
        [content.leadingAnchor constraintEqualToAnchor:area.leadingAnchor],
        [content.trailingAnchor constraintEqualToAnchor:area.trailingAnchor],
        [content.widthAnchor constraintEqualToAnchor:card.frameLayoutGuide.widthAnchor],
    ]];
}

// 弹窗由安全区约束定位。
- (void)layoutViews {
}

#pragma mark - 私有方法

// 关闭详情或结果卡片。
- (void)closeDialog {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

void TSDeviceLogPresentDialog(UIViewController *presenter, NSString *title, NSArray<UIView *> *views, BOOL closable) {
    if (presenter.presentedViewController) {
        return;
    }
    TSDeviceLogDialogVC *dialog = [[TSDeviceLogDialogVC alloc] init];
    dialog.title = title;
    dialog.dialogViews = views;
    dialog.closable = closable;
    dialog.modalPresentationStyle = UIModalPresentationOverFullScreen;
    dialog.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [presenter presentViewController:dialog animated:YES completion:nil];
}
