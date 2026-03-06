//
//  TSDialImageCropVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/3/4.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSDialImageCropVC.h"

// 底部操作栏高度
static const CGFloat kCropBarH     = 72.f;
// 裁剪框四周与屏幕边缘的间距
static const CGFloat kCropPadH     = 24.f;
static const CGFloat kCropPadV     = 24.f;
// 裁剪框白色边框宽度
static const CGFloat kCropBorderW  = 1.5f;

@interface TSDialImageCropVC () <UIScrollViewDelegate>

/** 原始图片 */
@property (nonatomic, strong) UIImage      *sourceImage;
/** 表盘高宽比（高/宽） */
@property (nonatomic, assign) CGFloat       aspectRatio;

/** 黑色背景底层 */
@property (nonatomic, strong) UIView       *bgView;
/** 可滑动/缩放的裁剪视口（frame = cropRect） */
@property (nonatomic, strong) UIScrollView *scrollView;
/** 图片视图，作为 scrollView 的 zoom 目标 */
@property (nonatomic, strong) UIImageView  *imageView;
/** 白色边框指示裁剪区 */
@property (nonatomic, strong) UIView       *cropBorderView;
/** 底部操作栏 */
@property (nonatomic, strong) UIView       *bottomBar;
/** 取消按钮 */
@property (nonatomic, strong) UIButton     *cancelBtn;
/** 使用按钮 */
@property (nonatomic, strong) UIButton     *useBtn;

@end

@implementation TSDialImageCropVC

#pragma mark - 初始化

- (instancetype)initWithImage:(UIImage *)image aspectRatio:(CGFloat)aspectRatio {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _sourceImage  = image;
        _aspectRatio  = (aspectRatio > 0) ? aspectRatio : 1.0f;
    }
    return self;
}

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.blackColor;
    [self setupViews];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self layoutViews];
}

/** 进入时隐藏导航栏，返回时恢复 */
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

#pragma mark - 视图构建

/** 添加子视图层级 */
- (void)setupViews {
    [self.view addSubview:self.bgView];
    [self.bgView addSubview:self.scrollView];
    [self.scrollView addSubview:self.imageView];
    [self.bgView addSubview:self.cropBorderView];
    [self.view addSubview:self.bottomBar];
    [self.bottomBar addSubview:self.cancelBtn];
    [self.bottomBar addSubview:self.useBtn];
}

/** Frame 布局 */
- (void)layoutViews {
    CGFloat w  = CGRectGetWidth(self.view.bounds);
    CGFloat h  = CGRectGetHeight(self.view.bounds);
    if (w <= 0) return;

    CGFloat safeTop    = self.view.safeAreaInsets.top;
    CGFloat safeBottom = self.view.safeAreaInsets.bottom;

    // 底部操作栏
    CGFloat barH = kCropBarH + safeBottom;
    self.bottomBar.frame = CGRectMake(0, h - barH, w, barH);

    // 取消 / 使用 按钮
    CGFloat btnW = 80.f;
    self.cancelBtn.frame = CGRectMake(20, 0, btnW, kCropBarH);
    self.useBtn.frame    = CGRectMake(w - btnW - 20, 0, btnW, kCropBarH);

    // 裁剪区域背景（从安全区顶部到操作栏顶部）
    CGFloat bgH = h - safeTop - barH;
    self.bgView.frame = CGRectMake(0, safeTop, w, bgH);

    // 计算裁剪框尺寸（保持 aspectRatio，两端留 padding）
    CGFloat maxCropW = w - kCropPadH * 2;
    CGFloat maxCropH = bgH - kCropPadV * 2;
    CGFloat cropW, cropH;
    if ((maxCropH / maxCropW) >= self.aspectRatio) {
        cropW = maxCropW;
        cropH = cropW * self.aspectRatio;
    } else {
        cropH = maxCropH;
        cropW = cropH / self.aspectRatio;
    }
    CGFloat cropX = (w - cropW) / 2.f;
    CGFloat cropY = (bgH - cropH) / 2.f;
    CGRect cropRect = CGRectMake(cropX, cropY, cropW, cropH);

    // scrollView 即为裁剪框
    self.scrollView.frame    = cropRect;
    self.cropBorderView.frame = cropRect;

    // 初始化 imageView 尺寸（与原图相同），设置 contentSize
    CGSize imgSize = self.sourceImage.size;
    self.imageView.frame       = CGRectMake(0, 0, imgSize.width, imgSize.height);
    self.scrollView.contentSize = imgSize;

    // 按最长边适配：图片最长边对齐裁剪框，另一边自动居中（aspect fill）
    CGFloat scaleX    = cropW / imgSize.width;
    CGFloat scaleY    = cropH / imgSize.height;
    CGFloat fillScale = MAX(scaleX, scaleY);   // 充满裁剪框
    CGFloat fitScale  = MIN(scaleX, scaleY);   // 完整图片（可缩小至此）

    // 最小缩放 = aspect fit（可看到完整图片），最大缩放 = fill 的 4 倍
    self.scrollView.minimumZoomScale = fitScale;
    self.scrollView.maximumZoomScale = fillScale * 4.f;

    // 只在首次布局时设置初始缩放
    if (self.scrollView.zoomScale <= 0.01f) {
        [self.scrollView setZoomScale:fillScale animated:NO];
    }

    // 将图片居中（初始 fill 状态时，较短边的多余部分居中）
    CGFloat scaledW = imgSize.width  * self.scrollView.zoomScale;
    CGFloat scaledH = imgSize.height * self.scrollView.zoomScale;
    CGFloat offsetX = MAX(0, (scaledW - cropW) / 2.f);
    CGFloat offsetY = MAX(0, (scaledH - cropH) / 2.f);
    self.scrollView.contentInset = UIEdgeInsetsZero;
    if (CGPointEqualToPoint(self.scrollView.contentOffset, CGPointZero)) {
        self.scrollView.contentOffset = CGPointMake(offsetX, offsetY);
    }
}

#pragma mark - 裁剪操作

/** 将 scrollView 当前可见区域渲染为裁剪图（含 contentInset 补偿） */
- (UIImage *)performCrop {
    CGSize  cropSize = self.scrollView.bounds.size;
    CGFloat scale    = self.scrollView.zoomScale;
    CGPoint offset   = self.scrollView.contentOffset;
    UIEdgeInsets insets = self.scrollView.contentInset;

    // contentOffset 是相对于 contentInset 之后的原点，需减去 inset 补偿
    CGFloat drawX = -(offset.x + insets.left);
    CGFloat drawY = -(offset.y + insets.top);
    CGFloat drawW = self.sourceImage.size.width  * scale;
    CGFloat drawH = self.sourceImage.size.height * scale;

    UIGraphicsImageRenderer *renderer =
        [[UIGraphicsImageRenderer alloc] initWithSize:cropSize];
    return [renderer imageWithActions:^(UIGraphicsImageRendererContext *ctx) {
        // 黑色背景（图片未覆盖区域）
        [[UIColor blackColor] setFill];
        UIRectFill(CGRectMake(0, 0, cropSize.width, cropSize.height));
        [self.sourceImage drawInRect:CGRectMake(drawX, drawY, drawW, drawH)];
    }];
}

#pragma mark - 按钮回调

/** 取消 → 返回上一页 */
- (void)onCancelTapped {
    [self.navigationController popViewControllerAnimated:YES];
}

/** 使用 → 裁剪并回调 */
- (void)onUseTapped {
    UIImage *cropped = [self performCrop];
    if (cropped && self.onCropComplete) {
        self.onCropComplete(cropped);
    }
}

#pragma mark - UIScrollViewDelegate

/** 指定 imageView 为缩放目标 */
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

/** 缩放至比裁剪框小时（aspect fit 区间），动态居中 */
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGSize cropSize = scrollView.bounds.size;
    CGFloat scaledW = self.imageView.frame.size.width;
    CGFloat scaledH = self.imageView.frame.size.height;
    UIEdgeInsets insets = UIEdgeInsetsZero;
    if (scaledW < cropSize.width)  insets.left = insets.right  = (cropSize.width  - scaledW) / 2.f;
    if (scaledH < cropSize.height) insets.top  = insets.bottom = (cropSize.height - scaledH) / 2.f;
    scrollView.contentInset = insets;
}


#pragma mark - 懒加载

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = UIColor.blackColor;
        _bgView.clipsToBounds   = YES;
    }
    return _bgView;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.clipsToBounds                = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator   = NO;
        _scrollView.bounces                      = NO;
        _scrollView.backgroundColor              = UIColor.blackColor;
        _scrollView.delegate                     = self;
    }
    return _scrollView;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithImage:self.sourceImage];
        _imageView.contentMode  = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}

- (UIView *)cropBorderView {
    if (!_cropBorderView) {
        _cropBorderView = [[UIView alloc] init];
        _cropBorderView.backgroundColor   = UIColor.clearColor;
        _cropBorderView.layer.borderColor  = [UIColor colorWithWhite:1 alpha:0.8f].CGColor;
        _cropBorderView.layer.borderWidth  = kCropBorderW;
        _cropBorderView.userInteractionEnabled = NO;
        // 四角小标记
        [self addCornerMarkersTo:_cropBorderView];
    }
    return _cropBorderView;
}

/** 在裁剪框四角添加白色 L 形标记增强视觉感 */
- (void)addCornerMarkersTo:(UIView *)view {
    CGFloat len = 16.f;
    CGFloat t   = 2.f;
    UIColor *c  = UIColor.whiteColor;
    // 位置枚举：左上/右上/左下/右下
    NSArray *origins = @[
        [NSValue valueWithCGPoint:CGPointMake(0, 0)],
        [NSValue valueWithCGPoint:CGPointMake(1, 0)],
        [NSValue valueWithCGPoint:CGPointMake(0, 1)],
        [NSValue valueWithCGPoint:CGPointMake(1, 1)],
    ];
    for (NSValue *val in origins) {
        CGPoint anchor = val.CGPointValue;
        // 水平线
        UIView *hLine = [[UIView alloc] init];
        hLine.tag = 100;
        hLine.backgroundColor = c;
        [view addSubview:hLine];
        // 垂直线
        UIView *vLine = [[UIView alloc] init];
        vLine.tag = 100;
        vLine.backgroundColor = c;
        [view addSubview:vLine];

        // frame 将在 layoutSubviews 阶段重新计算；这里先赋值以便 bounds 可用
        hLine.frame = CGRectMake(anchor.x == 0 ? 0 : 1 - len,
                                  anchor.y == 0 ? 0 : 1 - t,
                                  len, t);
        vLine.frame = CGRectMake(anchor.x == 0 ? 0 : 1 - t,
                                  anchor.y == 0 ? 0 : 1 - len,
                                  t, len);
    }
    (void)len; (void)t; // suppress unused warning
}

- (UIView *)bottomBar {
    if (!_bottomBar) {
        _bottomBar = [[UIView alloc] init];
        _bottomBar.backgroundColor = UIColor.blackColor;
    }
    return _bottomBar;
}

- (UIButton *)cancelBtn {
    if (!_cancelBtn) {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelBtn setTitleColor:[UIColor colorWithWhite:1 alpha:0.8f]
                         forState:UIControlStateNormal];
        _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [_cancelBtn addTarget:self
                       action:@selector(onCancelTapped)
             forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}

- (UIButton *)useBtn {
    if (!_useBtn) {
        _useBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_useBtn setTitle:@"使用" forState:UIControlStateNormal];
        [_useBtn setTitleColor:[UIColor colorWithRed:0/255.f
                                              green:122/255.f
                                               blue:255/255.f
                                              alpha:1.f]
                      forState:UIControlStateNormal];
        _useBtn.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
        [_useBtn addTarget:self
                    action:@selector(onUseTapped)
          forControlEvents:UIControlEventTouchUpInside];
    }
    return _useBtn;
}

@end
