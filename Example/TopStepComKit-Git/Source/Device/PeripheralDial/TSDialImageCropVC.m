//
//  TSDialImageCropVC.m
//  TopStepComKit_Example
//

#import "TSDialImageCropVC.h"
#import <TopStepComKit/TopStepComKit.h>
#import "TSDialEditorAppearance.h"

@interface TSDialImageCropVC () <UIScrollViewDelegate>
// 整批临时素材，确认前不修改宿主草稿。
@property (nonatomic, copy) NSArray<NSDictionary *> *records;
@property (nonatomic, strong) NSMutableArray<NSDictionary *> *results;
@property (nonatomic, strong) TSPeripheralScreen *screen;
@property (nonatomic, assign) NSUInteger step;
// 裁切视口与图层。
@property (nonatomic, strong) UIScrollView *imageScroll;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *cropBorder;
@property (nonatomic, strong) CAShapeLayer *gridLayer;
@property (nonatomic, strong) UIImage *sourceImage;
// 顶部及底部操作。
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *resetButton;
@property (nonatomic, strong) UIButton *previousButton;
@property (nonatomic, strong) UIButton *applyButton;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *stepLabel;
@property (nonatomic, strong) UILabel *helpLabel;
@property (nonatomic, strong) UILabel *zoomLabel;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UISlider *zoomSlider;
// 布局与导航恢复。
@property (nonatomic, assign) BOOL needsImageLayout;
@property (nonatomic, assign) BOOL previousNavigationHidden;
@property (nonatomic, assign) CGFloat fillScale;
@property (nonatomic, assign) CGSize previousViewport;
@end

@implementation TSDialImageCropVC

#pragma mark - 生命周期

// 保留旧单图调用方式。
- (instancetype)initWithImage:(UIImage *)image aspectRatio:(CGFloat)aspectRatio {
    TSPeripheralScreen *screen = [[TSPeripheralScreen alloc] init];
    screen.screenSize = CGSizeMake(720, 720 * MAX(0.1, aspectRatio));
    screen.shape = eTSPeriphShapeVerticalRectangle;
    return [self initWithRecords:@[@{@"name":@"照片", @"source":image, @"image":image}]
                         screen:screen];
}

// 临时记录与调用方数组完全分离。
- (instancetype)initWithRecords:(NSArray<NSDictionary *> *)records screen:(TSPeripheralScreen *)screen {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _records = [records copy];
        _results = [records mutableCopy];
        _screen = screen;
        _needsImageLayout = YES;
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

// 全屏深色页面使用自己的顶部操作栏。
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.previousNavigationHidden = self.navigationController.navigationBarHidden;
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

// 恢复上一页面原有导航栏状态。
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:self.previousNavigationHidden animated:animated];
}

// 安全区变化后重排。
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self layoutViews];
}

// 深色背景使用浅色状态栏文字。
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - 公开方法

// 搭建原型的裁切页面。
- (void)setupViews {
    self.view.backgroundColor = [TSDialEditorAppearance color:0x10130F];
    [self.view addSubview:self.imageScroll];
    [self.imageScroll addSubview:self.imageView];
    [self.view addSubview:self.cropBorder];
    for (UIView *view in @[self.cancelButton, self.resetButton, self.previousButton, self.applyButton,
                          self.titleLabel, self.stepLabel, self.helpLabel, self.zoomSlider, self.zoomLabel, self.nameLabel]) {
        [self.view addSubview:view];
    }
    [self loadStep];
}

// 裁切框始终与目标屏幕比例相同，圆屏使用正方形画布加圆形遮罩。
- (void)layoutViews {
    CGFloat width = CGRectGetWidth(self.view.bounds), height = CGRectGetHeight(self.view.bounds);
    CGFloat top = self.view.safeAreaInsets.top, bottom = self.view.safeAreaInsets.bottom;
    self.cancelButton.frame = CGRectMake(20, top, 60, 48);
    self.resetButton.frame = CGRectMake(width - 80, top, 60, 48);
    self.titleLabel.frame = CGRectMake(85, top, width - 170, 48);
    self.stepLabel.frame = CGRectMake(20, top + 50, width - 40, 26);
    self.previousButton.frame = CGRectMake(22, height - bottom - 66, 80, 46);
    self.applyButton.frame = CGRectMake(width - 167, height - bottom - 66, 145, 46);
    self.nameLabel.frame = CGRectMake(30, height - bottom - 93, width - 60, 18);
    self.zoomSlider.frame = CGRectMake(30, height - bottom - 143, width - 110, 36);
    self.zoomLabel.frame = CGRectMake(width - 75, height - bottom - 143, 55, 36);
    self.helpLabel.frame = CGRectMake(20, height - bottom - 178, width - 40, 28);
    CGFloat availableHeight = MAX(40, height - bottom - 190 - top - 88);
    CGFloat ratio = self.screen.screenSize.height / MAX(1, self.screen.screenSize.width);
    CGFloat cropWidth = MIN(width - 46, availableHeight / ratio);
    CGSize viewport = CGSizeMake(cropWidth, cropWidth * ratio);
    BOOL viewportChanged = !CGSizeEqualToSize(self.previousViewport, viewport);
    if (viewportChanged && !self.needsImageLayout && self.previousViewport.width > 0) {
        [self storeCurrentCrop];
    }
    self.imageScroll.frame = CGRectMake((width - cropWidth) / 2,
                                       top + 88 + (availableHeight - viewport.height) / 2,
                                       viewport.width, viewport.height);
    self.cropBorder.frame = self.imageScroll.frame;
    CGFloat radius = self.screen.shape == eTSPeriphShapeCircle ? cropWidth / 2 : 0;
    self.imageScroll.layer.cornerRadius = radius;
    self.cropBorder.layer.cornerRadius = radius;
    [self layoutGrid];
    if (self.needsImageLayout || viewportChanged) {
        self.previousViewport = viewport;
        [self restoreCrop];
    }
}

#pragma mark - 私有方法

// 加载当前步骤，保留前后步骤的裁切参数。
- (void)loadStep {
    if (self.step >= self.records.count) {
        self.applyButton.enabled = NO;
        return;
    }
    self.sourceImage = self.records[self.step][@"source"];
    self.imageView.image = self.sourceImage;
    self.needsImageLayout = YES;
    self.previousButton.hidden = self.step == 0;
    self.nameLabel.text = self.records[self.step][@"name"];
    self.stepLabel.text = self.records.count > 1 ?
        [NSString stringWithFormat:@"第 %lu / %lu 张 · 全部裁切后统一添加", self.step + 1, self.records.count] :
        self.screen.shape == eTSPeriphShapeCircle ? @"圆形表盘裁切 · 圆内为最终可见区域" : @"按表盘比例裁切 · 画面内为最终显示区域";
    NSString *action = self.step + 1 < self.records.count ? @"下一张" :
        self.records.count > 1 ? @"使用全部照片" : @"使用照片";
    [self.applyButton setTitle:action forState:UIControlStateNormal];
    self.applyButton.enabled = self.sourceImage != nil;
    [self.view setNeedsLayout];
}

// 缩放范围从完全填满开始，不允许露出空白。
- (void)restoreCrop {
    CGSize sourceSize = self.sourceImage.size, viewport = self.imageScroll.bounds.size;
    if (sourceSize.width <= 0 || sourceSize.height <= 0 || viewport.width <= 0 || viewport.height <= 0) {
        return;
    }
    self.needsImageLayout = NO;
    self.imageScroll.minimumZoomScale = 0.001;
    self.imageScroll.maximumZoomScale = 100;
    self.imageScroll.zoomScale = 1;
    self.imageView.frame = (CGRect){CGPointZero, sourceSize};
    self.imageScroll.contentSize = sourceSize;
    self.fillScale = MAX(viewport.width / sourceSize.width, viewport.height / sourceSize.height);
    self.imageScroll.minimumZoomScale = self.fillScale;
    self.imageScroll.maximumZoomScale = self.fillScale * 4;
    CGRect crop = CGRectFromString(self.results[self.step][@"crop"] ?: NSStringFromCGRect(CGRectZero));
    CGFloat zoom = crop.size.width > 0 ? viewport.width / (sourceSize.width * crop.size.width) : self.fillScale;
    self.imageScroll.zoomScale = MAX(self.fillScale, MIN(self.fillScale * 4, zoom));
    CGSize content = self.imageScroll.contentSize;
    CGPoint offset = crop.size.width > 0 ? CGPointMake(crop.origin.x * content.width, crop.origin.y * content.height) :
        CGPointMake((content.width - viewport.width) / 2, (content.height - viewport.height) / 2);
    offset.x = MAX(0, MIN(content.width - viewport.width, offset.x));
    offset.y = MAX(0, MIN(content.height - viewport.height, offset.y));
    self.imageScroll.contentOffset = offset;
    self.zoomSlider.value = self.imageScroll.zoomScale / self.fillScale;
    self.zoomLabel.text = [NSString stringWithFormat:@"%.1f×", self.zoomSlider.value];
}

// 三分线随圆形遮罩裁切。
- (void)layoutGrid {
    self.gridLayer.frame = self.cropBorder.bounds;
    CGFloat width = CGRectGetWidth(self.cropBorder.bounds), height = CGRectGetHeight(self.cropBorder.bounds);
    UIBezierPath *grid = [UIBezierPath bezierPath];
    for (NSUInteger index = 1; index <= 2; index++) {
        [grid moveToPoint:CGPointMake(width * index / 3, 0)];
        [grid addLineToPoint:CGPointMake(width * index / 3, height)];
        [grid moveToPoint:CGPointMake(0, height * index / 3)];
        [grid addLineToPoint:CGPointMake(width, height * index / 3)];
    }
    self.gridLayer.path = grid.CGPath;
}

// 保存当前构图并按设备像素生成成品，原图保留用于再次裁切。
- (void)storeCurrentCrop {
    CGSize viewport = self.imageScroll.bounds.size, content = self.imageScroll.contentSize;
    if (content.width <= 0 || content.height <= 0) {
        return;
    }
    CGRect crop = CGRectMake(MAX(0, self.imageScroll.contentOffset.x) / content.width,
                             MAX(0, self.imageScroll.contentOffset.y) / content.height,
                             viewport.width / content.width, viewport.height / content.height);
    CGSize output = self.screen.screenSize;
    UIGraphicsImageRendererFormat *format = [UIGraphicsImageRendererFormat defaultFormat];
    format.scale = 1;
    format.opaque = YES;
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:output format:format];
    UIImage *image = [renderer imageWithActions:^(UIGraphicsImageRendererContext *context) {
        CGFloat width = output.width / crop.size.width, height = output.height / crop.size.height;
        [self.sourceImage drawInRect:CGRectMake(-crop.origin.x * width, -crop.origin.y * height, width, height)];
    }];
    NSMutableDictionary *record = [self.records[self.step] mutableCopy];
    record[@"image"] = image;
    record[@"crop"] = NSStringFromCGRect(crop);
    self.results[self.step] = record;
}

// 只重置本张图片。
- (void)resetCrop {
    if (self.step >= self.results.count) {
        return;
    }
    NSMutableDictionary *record = [self.results[self.step] mutableCopy];
    record[@"crop"] = NSStringFromCGRect(CGRectZero);
    self.results[self.step] = record;
    [self restoreCrop];
}

// 滑杆与双指缩放共用同一缩放值。
- (void)changeZoom:(UISlider *)sender {
    self.imageScroll.zoomScale = self.fillScale * sender.value;
}

// 返回上一张并保留当前临时构图。
- (void)previousStep {
    if (self.step == 0) {
        return;
    }
    [self storeCurrentCrop];
    self.step--;
    [self loadStep];
}

// 最后一张完成后才提交整批结果。
- (void)applyCrop {
    if (!self.sourceImage || self.imageScroll.bounds.size.width <= 0) {
        return;
    }
    [self storeCurrentCrop];
    if (self.step + 1 < self.records.count) {
        self.step++;
        [self loadStep];
    } else if (self.onCropBatchComplete) {
        self.onCropBatchComplete([self.results copy]);
    } else if (self.onCropComplete) {
        self.onCropComplete(self.results.firstObject[@"image"]);
    }
}

// 取消丢弃临时结果。
- (void)cancelCrop {
    if (self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - UIScrollViewDelegate

// 指定缩放素材。
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

// 同步双指操作的倍率。
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    if (self.fillScale > 0) {
        self.zoomSlider.value = scrollView.zoomScale / self.fillScale;
        self.zoomLabel.text = [NSString stringWithFormat:@"%.1f×", self.zoomSlider.value];
    }
}

#pragma mark - 属性懒加载

// 不允许弹性滚动露底。
- (UIScrollView *)imageScroll {
    if (!_imageScroll) {
        _imageScroll = [[UIScrollView alloc] init];
        _imageScroll.delegate = self;
        _imageScroll.bounces = NO;
        _imageScroll.bouncesZoom = NO;
        _imageScroll.showsHorizontalScrollIndicator = NO;
        _imageScroll.showsVerticalScrollIndicator = NO;
        _imageScroll.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _imageScroll.clipsToBounds = YES;
    }
    return _imageScroll;
}

// 原始图片。
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
    }
    return _imageView;
}

// 裁切边界和网格。
- (UIView *)cropBorder {
    if (!_cropBorder) {
        _cropBorder = [[UIView alloc] init];
        _cropBorder.userInteractionEnabled = NO;
        _cropBorder.layer.borderWidth = 1;
        _cropBorder.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.6].CGColor;
        _cropBorder.clipsToBounds = YES;
        _gridLayer = [CAShapeLayer layer];
        _gridLayer.strokeColor = [UIColor colorWithWhite:1 alpha:0.25].CGColor;
        _gridLayer.lineWidth = 0.5;
        [_cropBorder.layer addSublayer:_gridLayer];
    }
    return _cropBorder;
}

// 顶部取消。
- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        _cancelButton.tintColor = [TSDialEditorAppearance color:0xD7DFCC];
        [_cancelButton addTarget:self action:@selector(cancelCrop) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

// 顶部重置。
- (UIButton *)resetButton {
    if (!_resetButton) {
        _resetButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_resetButton setTitle:@"重置" forState:UIControlStateNormal];
        _resetButton.tintColor = [TSDialEditorAppearance color:0xD7DFCC];
        [_resetButton addTarget:self action:@selector(resetCrop) forControlEvents:UIControlEventTouchUpInside];
    }
    return _resetButton;
}

// 批量处理上一步。
- (UIButton *)previousButton {
    if (!_previousButton) {
        _previousButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_previousButton setTitle:@"上一步" forState:UIControlStateNormal];
        _previousButton.tintColor = [TSDialEditorAppearance color:0xD7DFCC];
        [_previousButton addTarget:self action:@selector(previousStep) forControlEvents:UIControlEventTouchUpInside];
    }
    return _previousButton;
}

// 原型橙色确认按钮。
- (UIButton *)applyButton {
    if (!_applyButton) {
        _applyButton = [TSDialEditorAppearance button:@"使用照片" primary:YES];
        [_applyButton addTarget:self action:@selector(applyCrop) forControlEvents:UIControlEventTouchUpInside];
    }
    return _applyButton;
}

// 页面标题。
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [TSDialEditorAppearance label:@"裁切图片" size:17 color:0xF4F6EE];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];
    }
    return _titleLabel;
}

// 步骤和可见区域说明。
- (UILabel *)stepLabel {
    if (!_stepLabel) {
        _stepLabel = [TSDialEditorAppearance label:@"" size:11 color:0xA9B19F];
        _stepLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _stepLabel;
}

// 手势帮助。
- (UILabel *)helpLabel {
    if (!_helpLabel) {
        _helpLabel = [TSDialEditorAppearance label:@"拖动调整位置 · 双指或滑杆缩放" size:11 color:0xA9B19F];
        _helpLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _helpLabel;
}

// 实时倍率。
- (UILabel *)zoomLabel {
    if (!_zoomLabel) {
        _zoomLabel = [TSDialEditorAppearance label:@"1.0×" size:11 color:0xB8C3AB];
        _zoomLabel.textAlignment = NSTextAlignmentRight;
    }
    return _zoomLabel;
}

// 素材文件名。
- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [TSDialEditorAppearance label:@"" size:10 color:0x7D8872];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _nameLabel;
}

// 1～4 倍完全填充缩放。
- (UISlider *)zoomSlider {
    if (!_zoomSlider) {
        _zoomSlider = [[UISlider alloc] init];
        _zoomSlider.minimumValue = 1;
        _zoomSlider.maximumValue = 4;
        _zoomSlider.value = 1;
        _zoomSlider.tintColor = [TSDialEditorAppearance color:0xE8ECDE];
        [_zoomSlider addTarget:self action:@selector(changeZoom:) forControlEvents:UIControlEventValueChanged];
    }
    return _zoomSlider;
}

@end
