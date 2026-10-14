//
//  TSHsdTimelineView.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/22.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSHsdTimelineView.h"
#import "TSHsdDisplay.h"
#import "TSRootVC.h"

@interface TSHsdTimelineView ()
@property (nonatomic, strong) UILabel *captionLabel;
@property (nonatomic, strong) UILabel *spanLabel;
@property (nonatomic, strong) UIView *track;
@property (nonatomic, strong) UIView *segmentA;
@property (nonatomic, strong) UIView *segmentB;
@property (nonatomic, strong) NSArray<UILabel *> *tickLabels;
@end

@implementation TSHsdTimelineView

+ (CGFloat)viewHeight {
    // padding 16 / sum 24 + 12 / track 12 / ticks 6 + 14 / padding 6
    return 16.f + 24.f + 12.f + 12.f + 6.f + 14.f + 6.f;
}

+ (NSInteger)spanMinutesFrom:(NSInteger)start to:(NSInteger)end {
    NSInteger span = ((end - start) % 1440 + 1440) % 1440;
    return span == 0 ? 1440 : span;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) { return nil; }
    _hue = [TSHsdDisplay hueParental];

    self.captionLabel = [[UILabel alloc] init];
    self.captionLabel.font = [UIFont systemFontOfSize:13.f];
    self.captionLabel.textColor = [TSHsdDisplay textSecondary];
    [self addSubview:self.captionLabel];

    self.spanLabel = [[UILabel alloc] init];
    self.spanLabel.font = [TSHsdDisplay roundedFontOfSize:20.f weight:UIFontWeightBold];
    self.spanLabel.textColor = [TSHsdDisplay ink];
    self.spanLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:self.spanLabel];

    self.track = [[UIView alloc] init];
    self.track.backgroundColor = [TSHsdDisplay fill];
    self.track.layer.cornerRadius = 6.f;
    self.track.clipsToBounds = YES;
    [self addSubview:self.track];

    self.segmentA = [[UIView alloc] init];
    self.segmentA.layer.cornerRadius = 6.f;
    self.segmentB = [[UIView alloc] init];
    self.segmentB.layer.cornerRadius = 6.f;
    [self.track addSubview:self.segmentA];
    [self.track addSubview:self.segmentB];

    NSMutableArray<UILabel *> *ticks = [NSMutableArray array];
    for (NSString *text in @[@"0", @"6", @"12", @"18", @"24"]) {
        UILabel *label = [[UILabel alloc] init];
        label.font = [TSHsdDisplay roundedFontOfSize:10.5f weight:UIFontWeightRegular];
        label.textColor = [TSHsdDisplay textTertiary];
        label.text = text;
        [self addSubview:label];
        [ticks addObject:label];
    }
    self.tickLabels = [ticks copy];
    [self ts_apply];
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(size.width, [[self class] viewHeight]);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat w = self.bounds.size.width - 32.f;
    CGFloat x = 16.f;
    self.captionLabel.frame = CGRectMake(x, 16.f, w / 2.f, 24.f);
    self.spanLabel.frame = CGRectMake(x + w / 2.f, 16.f, w / 2.f, 24.f);
    CGFloat trackY = 16.f + 24.f + 12.f;
    self.track.frame = CGRectMake(x, trackY, w, 12.f);

    CGFloat total = 1440.f;
    NSInteger start = MAX(0, MIN(self.startMinute, 1439));
    NSInteger end = MAX(0, MIN(self.endMinute, 1439));
    if (end > start) {
        self.segmentA.frame = CGRectMake(w * start / total, 0, w * (end - start) / total, 12.f);
        self.segmentB.frame = CGRectZero;
    } else {
        // 跨天（或相等 = 全天）：start→24:00 与 00:00→end
        self.segmentA.frame = CGRectMake(w * start / total, 0, w * (total - start) / total, 12.f);
        self.segmentB.frame = CGRectMake(0, 0, w * end / total, 12.f);
    }
    CGFloat tickY = trackY + 12.f + 6.f;
    for (NSInteger i = 0; i < 5; i++) {
        UILabel *label = self.tickLabels[i];
        [label sizeToFit];
        CGFloat lx = x + w * i / 4.f - (i == 4 ? label.bounds.size.width : (i == 0 ? 0 : label.bounds.size.width / 2.f));
        label.frame = CGRectMake(lx, tickY, label.bounds.size.width, 14.f);
    }
}

#pragma mark - 属性

- (void)setStartMinute:(NSInteger)startMinute { _startMinute = startMinute; [self ts_apply]; }
- (void)setEndMinute:(NSInteger)endMinute { _endMinute = endMinute; [self ts_apply]; }
- (void)setHue:(UIColor *)hue { _hue = hue; [self ts_apply]; }
- (void)setCaption:(nullable NSString *)caption { _caption = [caption copy]; [self ts_apply]; }
- (void)setDimmed:(BOOL)dimmed { _dimmed = dimmed; [self ts_apply]; }

- (void)ts_apply {
    UIColor *color = self.dimmed ? [TSHsdDisplay textTertiary] : self.hue;
    self.segmentA.backgroundColor = color;
    self.segmentB.backgroundColor = color;
    self.captionLabel.text = self.caption;
    NSInteger span = [[self class] spanMinutesFrom:self.startMinute to:self.endMinute];
    self.spanLabel.text = [TSHsdDisplay durationStringForMinutes:span];
    [self setNeedsLayout];
}

@end
