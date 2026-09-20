//
//  TSRealtimeDanMuDraft.m
//  TopStepComKit_Example
//

#import "TSRealtimeDanMuDraft.h"

const NSUInteger kTSRealtimeDanMuMaxDraftCount = 5;
const NSUInteger kTSRealtimeDanMuMaxTextBytes = 128;
const NSInteger kTSRealtimeDanMuMinFontSize = 12;
const NSInteger kTSRealtimeDanMuMaxFontSize = 64;
const NSInteger kTSRealtimeDanMuMinSpeed = 10;
const NSInteger kTSRealtimeDanMuMaxSpeed = 200;

@implementation TSRealtimeDanMuDraft

#pragma mark - 生命周期

/** 默认值与 TSDanMuItem 的指定初始化保持一致 */
- (instancetype)init {
    self = [super init];
    if (self) {
        _text = @"";
        _type = TSDanMuTypeMine;
        _color = UIColor.whiteColor;
        _fontSize = 32;
        _speed = 60;
        _animation = TSDanMuAnimationNone;
        _yCoordinate = TSDanMuRandomYCoordinate;
    }
    return self;
}

#pragma mark - 公开方法

+ (instancetype)defaultDraft {
    return [[self alloc] init];
}

/** 按 UTF-8 字节计，与 TSDanMuItem 的 128 字节限制同口径 */
- (NSUInteger)textByteLength {
    return [self.text lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
}

- (BOOL)isRandomPosition {
    return self.yCoordinate == TSDanMuRandomYCoordinate;
}

- (void)useRandomPosition {
    self.yCoordinate = TSDanMuRandomYCoordinate;
}

- (TSDanMuItem *)danMuItem {
    TSDanMuItem *item = [TSDanMuItem itemWithText:self.text];
    item.type = self.type;
    item.color = self.color;
    item.fontSize = self.fontSize;
    item.speed = self.speed;
    item.animation = self.animation;
    item.yCoordinate = self.yCoordinate;
    return item;
}

/** 不重复实现校验，直接问模型 */
- (NSError *)validate {
    return [[self danMuItem] doesModelHasError];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    TSRealtimeDanMuDraft *draft = [[[self class] allocWithZone:zone] init];
    draft.text = self.text;
    draft.type = self.type;
    draft.color = self.color;
    draft.fontSize = self.fontSize;
    draft.speed = self.speed;
    draft.animation = self.animation;
    draft.yCoordinate = self.yCoordinate;
    return draft;
}

@end
