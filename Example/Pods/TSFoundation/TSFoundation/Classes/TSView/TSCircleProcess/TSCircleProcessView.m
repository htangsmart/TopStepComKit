//
//  TSCircleProcessView.m
//  JieliJianKang
//
//  Created by 磐石 on 2024/2/6.
//

#import "TSCircleProcessView.h"

@implementation TSCircleProcessConfiger

@end

@interface TSCircleProcessView ()<CAAnimationDelegate>

@property (nonatomic,strong) TSCircleProcessConfiger * configer;

@property (nonatomic,strong) NSTimer * processTimer;

@property (nonatomic,assign) NSInteger processDuring;

@property (nonatomic,strong) CAShapeLayer * bottomCircleLayer;

@property (nonatomic,strong) CAShapeLayer * topCircleLayer;

@end

@implementation TSCircleProcessView

- (instancetype)initWithConfiger:(TSCircleProcessConfiger *)configer{
    self = [super init];
    if (self) {
        _configer = configer;
        [self initData];
        [self initViews];
        [self layoutViews];
    }
    return self;
}


- (void)initData{
    [self initProcessDuring];
}

- (void)initViews{
    
    [self.layer addSublayer:self.bottomCircleLayer];
    [self.layer addSublayer:self.topCircleLayer];
}

- (void)layoutViews{
    
    self.bottomCircleLayer.frame = self.bounds;
    UIBezierPath *bottomCirclePath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2) radius:self.frame.size.height/2 startAngle:-M_PI_2 endAngle:M_PI*3/2 clockwise:1];
    self.bottomCircleLayer.path = bottomCirclePath.CGPath;
    
    self.topCircleLayer.frame = self.bounds;
    UIBezierPath *topCirclePath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2) radius:self.frame.size.height/2 startAngle:-M_PI_2 endAngle:M_PI*3/2 clockwise:1];
    self.topCircleLayer.path = topCirclePath.CGPath;
}

- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    [self layoutViews];
}

- (void)timerEvent:(NSTimer *)timer{
    self.processDuring--;
    if (self.processDuring>=0 && self.configer.callBackBlock) {
        self.configer.callBackBlock(self.processDuring);
    }
}

-(void)start{
    [self initProcessDuring];
    [self startAnimation];
    [self srartTimer];
}

- (void)initProcessDuring{
    self.processDuring = _configer.processDuring;
}

- (void)srartTimer{
    if (_configer.needCallback && _configer.timeInterval>0) {
        __weak typeof(self)weakSelf = self;
        _processTimer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
            [weakSelf timerEvent:timer];
        }];
        [_processTimer fire];
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if (self.configer.finishedBlock) {
        self.configer.finishedBlock();
    }
    [self stop];
}

-(void)startAnimation{
    CABasicAnimation *pathAnima = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
    pathAnima.duration = _configer.processDuring;
    pathAnima.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    pathAnima.fromValue = [NSNumber numberWithFloat:0.0f];
    pathAnima.toValue = [NSNumber numberWithFloat:1.0f];
    pathAnima.fillMode = kCAFillModeBackwards;
    pathAnima.removedOnCompletion = YES;
    pathAnima.delegate = self;
    [_topCircleLayer addAnimation:pathAnima forKey:@"strokeCircleAnimation"];
}

-(void)reSrart{
    [self start];
}

- (void)stop{
    [self stopAnimation];
    [self stopTimer];
}
- (void)stopTimer{
    if (_processTimer) {
        [_processTimer invalidate];
        _processTimer = nil;
    }
}

- (void)stopAnimation{
    [_topCircleLayer removeAnimationForKey:@"strokeCircleAnimation"];
}


- (CAShapeLayer *)bottomCircleLayer{
    if (!_bottomCircleLayer) {
        _bottomCircleLayer = [CAShapeLayer layer];//进度条的背景圆环.
    }
    _bottomCircleLayer.fillColor = [UIColor clearColor].CGColor;
    _bottomCircleLayer.lineWidth = _configer.lineWidth;
    //kDF_RGBA(240, 241, 241, 1.0)
    _bottomCircleLayer.strokeColor = _configer.circleBackgroundColor.CGColor;

    return _bottomCircleLayer;
}

- (CAShapeLayer *)topCircleLayer{
    if (!_topCircleLayer) {
        _topCircleLayer = [CAShapeLayer layer];
    }
    _topCircleLayer.fillColor = [UIColor clearColor].CGColor;
    _topCircleLayer.lineCap = kCALineCapRound;
    _topCircleLayer.lineWidth = _configer.lineWidth;
    _topCircleLayer.strokeColor = _configer.circleColor.CGColor;

    return _topCircleLayer;
}






@end
