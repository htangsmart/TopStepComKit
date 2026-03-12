//
//  TSPeripheralDialVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/2/19.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSPeripheralDialVC.h"
#import "TSDialDetailVC.h"
#import "TSPushCloudDialVC.h"
#import "TSDialImageCropVC.h"
#import "TSDialVideoRecordVC.h"
#import "TSDialVideoEditVC.h"
#import "TSDialEditorVC.h"
#import <TopStepComKit/TopStepComKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>

// ─── 布局常量 ──────────────────────────────────────────────────────────────────
static const CGFloat kMainPadH       = 16.f;  // 水平外边距
static const CGFloat kMainPadV       = 12.f;  // 垂直间距
static const CGFloat kMainBtnH       = 48.f;  // 按钮高度
static const CGFloat kMainBtnCorner  = 12.f;  // 按钮圆角
static const CGFloat kMainCardCorner = 12.f;  // 分类卡片圆角
static const CGFloat kMainTitleH     = 44.f;  // Section 标题行高
static const CGFloat kCellW          = 80.f;  // 表盘 Cell 宽
static const CGFloat kCellH          = 112.f; // 表盘 Cell 高（~5:7 竖向比例）
static const CGFloat kCellCorner     = 10.f;  // Cell 圆角
static const CGFloat kCellBorderW    = 3.f;   // 当前表盘高亮边框宽度
static const CGFloat kCVH            = 140.f; // CollectionView 高度（含内边距）

// ─── Tag 常量：区分三个 CollectionView ─────────────────────────────────────────
static const NSInteger kTagBuiltIn = 0;
static const NSInteger kTagCloud   = 1;
static const NSInteger kTagCustom  = 2;

/** 返回自定义表盘预览图的本地路径（与 TSDialEditorVC 保存路径一致） */
static NSString *TSCustomDialPreviewPath(NSString *dialId) {
    if (dialId.length == 0) return nil;
    NSString *dir = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
                     stringByAppendingPathComponent:@"dialPreviews"];
    return [dir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", dialId]];
}

// ─────────────────────────────────────────────────────────────────────────────
#pragma mark - TSDialCell
// ─────────────────────────────────────────────────────────────────────────────

/**
 * 表盘列表格子 Cell
 * - 有图：显示 imageView（填充）
 * - 无图：按类型显示彩色占位背景 + 名称文字
 * - 当前表盘：主色边框 + 右下角「✓」角标
 */
@interface TSDialCell : UICollectionViewCell

- (void)configureWithDial:(TSDialModel *)dial isCurrent:(BOOL)isCurrent;

@end

@implementation TSDialCell {
    UIImageView *_imageView;
    UILabel     *_placeholderLabel;
    UILabel     *_checkBadge;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) return nil;

    self.contentView.layer.cornerRadius = kCellCorner;
    self.contentView.clipsToBounds      = YES;
    self.layer.cornerRadius = kCellCorner;

    _imageView = [[UIImageView alloc] init];
    _imageView.contentMode  = UIViewContentModeScaleAspectFill;
    _imageView.clipsToBounds = YES;
    [self.contentView addSubview:_imageView];

    _placeholderLabel = [[UILabel alloc] init];
    _placeholderLabel.font          = [UIFont systemFontOfSize:11 weight:UIFontWeightMedium];
    _placeholderLabel.textColor     = [UIColor colorWithWhite:1 alpha:0.9f];
    _placeholderLabel.textAlignment = NSTextAlignmentCenter;
    _placeholderLabel.numberOfLines = 3;
    [self.contentView addSubview:_placeholderLabel];

    // 右下角当前表盘勾选角标
    _checkBadge = [[UILabel alloc] init];
    _checkBadge.text            = @"✓";
    _checkBadge.font            = [UIFont systemFontOfSize:10 weight:UIFontWeightBold];
    _checkBadge.textColor       = UIColor.whiteColor;
    _checkBadge.textAlignment   = NSTextAlignmentCenter;
    _checkBadge.backgroundColor = TSColor_Primary;
    _checkBadge.layer.cornerRadius = 9;
    _checkBadge.clipsToBounds   = YES;
    _checkBadge.hidden          = YES;
    [self addSubview:_checkBadge];

    return self;
}

- (void)configureWithDial:(TSDialModel *)dial isCurrent:(BOOL)isCurrent {
    UIImage *img = nil;
    if (dial.filePath.length > 0) {
        img = [UIImage imageWithContentsOfFile:dial.filePath];
    }
    // 自定义表盘无 filePath 时，加载本地保存的预览图
    if (!img && dial.dialType == eTSDialTypeCustomer) {
        NSString *previewPath = TSCustomDialPreviewPath(dial.dialId);
        if (previewPath) {
            img = [UIImage imageWithContentsOfFile:previewPath];
        }
    }

    if (img) {
        _imageView.image           = img;
        _imageView.hidden          = NO;
        _placeholderLabel.hidden   = YES;
        self.contentView.backgroundColor = UIColor.blackColor;
    } else {
        _imageView.hidden          = YES;
        _placeholderLabel.hidden   = NO;
        _placeholderLabel.text     = dial.dialName.length ? dial.dialName : @"表盘";
        self.contentView.backgroundColor = [self ts_colorForDialType:dial.dialType];
    }

    // 高亮边框
    self.layer.borderWidth = isCurrent ? kCellBorderW : 0;
    self.layer.borderColor = isCurrent ? TSColor_Primary.CGColor : UIColor.clearColor.CGColor;
    _checkBadge.hidden     = !isCurrent;
}

- (UIColor *)ts_colorForDialType:(TSDialType)type {
    switch (type) {
        case eTSDialTypeBuiltIn:  return TSColor_Indigo;
        case eTSDialTypeCloud:    return TSColor_Primary;
        case eTSDialTypeCustomer: return TSColor_Teal;
        default:                  return TSColor_Gray;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _imageView.frame        = self.contentView.bounds;
    _placeholderLabel.frame = CGRectInset(self.contentView.bounds, 6, 6);
    _checkBadge.frame       = CGRectMake(CGRectGetWidth(self.bounds) - 20,
                                          CGRectGetHeight(self.bounds) - 20, 18, 18);
}

@end

// ─────────────────────────────────────────────────────────────────────────────
#pragma mark - TSPeripheralDialVC
// ─────────────────────────────────────────────────────────────────────────────

@interface TSPeripheralDialVC () <UICollectionViewDataSource,
                                  UICollectionViewDelegate,
                                  UIImagePickerControllerDelegate,
                                  UINavigationControllerDelegate>

// ── 数据 ──────────────────────────────────────────────────────────────────────
@property (nonatomic, strong) NSArray<TSDialModel *> *builtInDials;
@property (nonatomic, strong) NSArray<TSDialModel *> *cloudDials;
@property (nonatomic, strong) NSArray<TSDialModel *> *customDials;
@property (nonatomic, copy)   NSString               *currentDialId;

// ── 外层容器 ──────────────────────────────────────────────────────────────────
@property (nonatomic, strong) UIScrollView *scrollView;

// ── 顶部操作按钮区 ─────────────────────────────────────────────────────────────
@property (nonatomic, strong) UIButton *pushCloudBtn;
@property (nonatomic, strong) UIButton *makeCustomBtn;

// ── 三个分类卡片 ───────────────────────────────────────────────────────────────
@property (nonatomic, strong) UIView           *builtInCard;
@property (nonatomic, strong) UILabel          *builtInTitleLabel;
@property (nonatomic, strong) UICollectionView *builtInCV;

@property (nonatomic, strong) UIView           *cloudCard;
@property (nonatomic, strong) UILabel          *cloudTitleLabel;
@property (nonatomic, strong) UICollectionView *cloudCV;

@property (nonatomic, strong) UIView           *customCard;
@property (nonatomic, strong) UILabel          *customTitleLabel;
@property (nonatomic, strong) UICollectionView *customCV;

// ── Loading（无遮罩） ─────────────────────────────────────────────────────────
@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;

// ── 自定义表盘制作流程（协调器数据） ────────────────────────────────────────────
@property (nonatomic, assign) CGSize    customDialSize;
@property (nonatomic, assign) CGFloat   customDialAspectRatio;
@property (nonatomic, assign) BOOL      supportsVideoDial;
@property (nonatomic, assign) NSInteger maxVideoDialDuration;

@end

@implementation TSPeripheralDialVC

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerDialChangedCallback];
    [self fetchDials];
}

#pragma mark - Override Base Setup

/** 初始化标题与空数据 */
- (void)initData {
    [super initData];
    self.title      = @"表盘管理";
    _builtInDials   = @[];
    _cloudDials     = @[];
    _customDials    = @[];
}

/** 构建视图层级 */
- (void)setupViews {
    self.view.backgroundColor = TSColor_Background;

    [self.view addSubview:self.scrollView];

    // 顶部按钮
    [self.scrollView addSubview:self.pushCloudBtn];
    [self.scrollView addSubview:self.makeCustomBtn];

    // 分类卡片
    [self.scrollView addSubview:self.builtInCard];
    [self.builtInCard addSubview:self.builtInTitleLabel];
    [self.builtInCard addSubview:self.builtInCV];

    [self.scrollView addSubview:self.cloudCard];
    [self.cloudCard addSubview:self.cloudTitleLabel];
    [self.cloudCard addSubview:self.cloudCV];
    self.cloudCard.hidden = YES;   // 有数据后才显示

    [self.scrollView addSubview:self.customCard];
    [self.customCard addSubview:self.customTitleLabel];
    [self.customCard addSubview:self.customCV];
    self.customCard.hidden = YES;  // 有数据后才显示

    [self.view addSubview:self.loadingIndicator];

    // 导航栏刷新按钮
    UIImage *refreshImg = nil;
    if (@available(iOS 13.0, *)) {
        refreshImg = [UIImage systemImageNamed:@"arrow.clockwise"];
    }
    UIBarButtonItem *refreshItem = [[UIBarButtonItem alloc]
        initWithImage:refreshImg style:UIBarButtonItemStylePlain
               target:self action:@selector(fetchDials)];
    self.navigationItem.rightBarButtonItem = refreshItem;
}

/** Frame 布局 */
- (void)layoutViews {
    CGFloat w = CGRectGetWidth(self.view.bounds);
    CGFloat h = CGRectGetHeight(self.view.bounds);
    if (w <= 0) return;

    CGFloat top = self.ts_navigationBarTotalHeight;
    if (top <= 0) top = self.view.safeAreaInsets.top;
    self.scrollView.frame = CGRectMake(0, top, w, h - top);

    CGFloat cardW = w - kMainPadH * 2;
    CGFloat y     = kMainPadV;

    // ── 顶部两个按钮（并排）──────────────────────────────────────────────────
    CGFloat btnW = (cardW - kMainPadH) / 2.f;
    self.pushCloudBtn.frame  = CGRectMake(kMainPadH, y, btnW, kMainBtnH);
    self.makeCustomBtn.frame = CGRectMake(kMainPadH + btnW + kMainPadH, y, btnW, kMainBtnH);
    y += kMainBtnH + kMainPadV;

    // ── 三个分类卡片（云端/自定义无数据时跳过） ───────────────────────────────
    CGFloat sectionCardH = kMainTitleH + kCVH;

    // 内置表盘（始终展示）
    self.builtInCard.frame       = CGRectMake(kMainPadH, y, cardW, sectionCardH);
    self.builtInTitleLabel.frame = CGRectMake(kMainPadH, 0, cardW - kMainPadH * 2, kMainTitleH);
    self.builtInCV.frame         = CGRectMake(0, kMainTitleH, cardW, kCVH);
    y += sectionCardH + kMainPadV;

    // 云端表盘（有数据才布局并计入高度）
    if (!self.cloudCard.hidden) {
        self.cloudCard.frame       = CGRectMake(kMainPadH, y, cardW, sectionCardH);
        self.cloudTitleLabel.frame = CGRectMake(kMainPadH, 0, cardW - kMainPadH * 2, kMainTitleH);
        self.cloudCV.frame         = CGRectMake(0, kMainTitleH, cardW, kCVH);
        y += sectionCardH + kMainPadV;
    }

    // 自定义表盘（有数据才布局并计入高度）
    if (!self.customCard.hidden) {
        self.customCard.frame       = CGRectMake(kMainPadH, y, cardW, sectionCardH);
        self.customTitleLabel.frame = CGRectMake(kMainPadH, 0, cardW - kMainPadH * 2, kMainTitleH);
        self.customCV.frame         = CGRectMake(0, kMainTitleH, cardW, kCVH);
        y += sectionCardH + kMainPadV;
    }

    y += self.view.safeAreaInsets.bottom;

    self.scrollView.contentSize = CGSizeMake(w, y);
    self.loadingIndicator.center = CGPointMake(w / 2.f, (h - top) / 2.f + top);
}

#pragma mark - Data Loading

/** 注册设备表盘变化回调，自动刷新列表 */
- (void)registerDialChangedCallback {
    __weak typeof(self) wself = self;
    [[[TopStepComKit sharedInstance] dial] registerDialDidChangedBlock:^(NSArray<TSDialModel *> * _Nullable allDials) {
        if (!allDials) return;
        dispatch_async(dispatch_get_main_queue(), ^{
            [wself classifyDials:allDials];
            [wself reloadAllCollectionViews];
        });
    }];
}

/** 进入页面 / 刷新：获取全部表盘 + 当前表盘 */
- (void)fetchDials {
    [self.loadingIndicator startAnimating];
    self.scrollView.userInteractionEnabled = NO;

    __weak typeof(self) wself = self;
    [[[TopStepComKit sharedInstance] dial] fetchAllDials:^(NSArray<TSDialModel *> * _Nullable dials, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (dials.count > 0) {
                [wself classifyDials:dials];
            }
            // 接着获取当前表盘
            [[[TopStepComKit sharedInstance] dial] fetchCurrentDial:^(TSDialModel * _Nullable dial, NSError * _Nullable error2) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (dial.dialId.length > 0) {
                        wself.currentDialId = dial.dialId;
                    }
                    [wself.loadingIndicator stopAnimating];
                    wself.scrollView.userInteractionEnabled = YES;
                    [wself reloadAllCollectionViews];
                });
            }];
        });
    }];
}

/** 将表盘按类型分类到三个数组，并同步 currentDialId */
- (void)classifyDials:(NSArray<TSDialModel *> *)allDials {
    NSMutableArray *builtIn = [NSMutableArray array];
    NSMutableArray *cloud   = [NSMutableArray array];
    NSMutableArray *custom  = [NSMutableArray array];

    for (TSDialModel *d in allDials) {
        if (d.isCurrent && d.dialId.length > 0) {
            self.currentDialId = d.dialId;
        }
        switch (d.dialType) {
            case eTSDialTypeBuiltIn:  [builtIn addObject:d]; break;
            case eTSDialTypeCloud:    [cloud   addObject:d]; break;
            case eTSDialTypeCustomer: [custom  addObject:d]; break;
            default: break;
        }
    }

    self.builtInDials = builtIn;
    self.cloudDials   = cloud;
    self.customDials  = custom;
}

/** 刷新三个 CollectionView，并根据数据量显示/隐藏云端与自定义模块 */
- (void)reloadAllCollectionViews {
    [self.builtInCV reloadData];
    [self.cloudCV   reloadData];
    [self.customCV  reloadData];

    // 云端/自定义无数据时隐藏整个卡片
    self.cloudCard.hidden  = (self.cloudDials.count  == 0);
    self.customCard.hidden = (self.customDials.count == 0);

    // 重新布局，收起隐藏卡片后重算 y 坐标与 contentSize
    [self layoutViews];
}

#pragma mark - Actions

/** 跳转推送云端表盘页，推送成功后刷新列表 */
- (void)onPushCloudDialTapped {
    TSPushCloudDialVC *vc = [[TSPushCloudDialVC alloc] init];
    __weak typeof(self) wself = self;
    vc.onPushSuccess = ^{ [wself fetchDials]; };
    [self.navigationController pushViewController:vc animated:YES];
}

/** 直接弹出来源选择 ActionSheet，保持背景可见；来源确定后 push 至裁剪/编辑页 */
- (void)onMakeCustomDialTapped {
    [self loadCustomDialDeviceCapabilities];

    UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:@"选择表盘素材"
                                            message:nil
                                     preferredStyle:UIAlertControllerStyleActionSheet];

    // 拍摄视频（置顶）
    if (self.supportsVideoDial) {
        [alert addAction:[UIAlertAction
            actionWithTitle:@"📹 拍摄视频"
                      style:UIAlertActionStyleDefault
                    handler:^(UIAlertAction *a) { [self recordVideoForCustomDial]; }]];
    }

    // 拍摄照片
    [alert addAction:[UIAlertAction
        actionWithTitle:@"📷 拍摄照片"
                  style:UIAlertActionStyleDefault
                handler:^(UIAlertAction *a) { [self pickFromCameraForCustomDial]; }]];

    // 从相册选择照片
    [alert addAction:[UIAlertAction
        actionWithTitle:@"🖼️ 从相册选择照片"
                  style:UIAlertActionStyleDefault
                handler:^(UIAlertAction *a) { [self pickFromLibraryForCustomDial]; }]];

    // 从相册选择视频
    if (self.supportsVideoDial) {
        [alert addAction:[UIAlertAction
            actionWithTitle:@"🎬 从相册选择视频"
                      style:UIAlertActionStyleDefault
                    handler:^(UIAlertAction *a) { [self pickVideoForCustomDial]; }]];
    }

    [alert addAction:[UIAlertAction
        actionWithTitle:@"取消"
                  style:UIAlertActionStyleCancel
                handler:nil]];

    [self presentViewController:alert animated:YES completion:nil];
}

/** 从 SDK 读取设备表盘尺寸与视频表盘能力 */
- (void)loadCustomDialDeviceCapabilities {
    TSPeripheral *peri = [[TopStepComKit sharedInstance] connectedPeripheral];
    CGSize s = peri.screenInfo.screenSize;
    if (CGSizeEqualToSize(s, CGSizeZero)) s = peri.screenInfo.screenSize;
    if (CGSizeEqualToSize(s, CGSizeZero)) s = CGSizeMake(240, 280);
    self.customDialSize        = s;
    self.customDialAspectRatio = s.height / s.width;

    id<TSPeripheralDialInterface> dialIF = [[TopStepComKit sharedInstance] dial];
    self.supportsVideoDial    = [dialIF isSupportVideoDial];
    self.maxVideoDialDuration = [dialIF maxVideoDialDuration];
    if (self.maxVideoDialDuration <= 0) self.maxVideoDialDuration = 10;
}

/** 录制视频 */
- (void)recordVideoForCustomDial {
    AVAuthorizationStatus status =
        [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusDenied ||
        status == AVAuthorizationStatusRestricted) {
        [self showAlertWithMsg:@"请在「设置」中允许访问相机"];
        return;
    }

    TSDialVideoRecordVC *recordVC =
        [[TSDialVideoRecordVC alloc] initWithMaxDuration:self.maxVideoDialDuration];
    __weak typeof(self) wself = self;
    recordVC.onRecordComplete = ^(NSURL *videoURL) {
        [wself pushVideoEditVCWithURL:videoURL];
    };
    [self.navigationController pushViewController:recordVC animated:YES];
}

/** 打开相机拍照 */
- (void)pickFromCameraForCustomDial {
    AVAuthorizationStatus status =
        [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusDenied ||
        status == AVAuthorizationStatusRestricted) {
        [self showAlertWithMsg:@"请在「设置」中允许访问相机"];
        return;
    }
    if (![UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeCamera]) {
        [self showAlertWithMsg:@"当前设备不支持相机"];
        return;
    }
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.mediaTypes = @[(NSString *)kUTTypeImage];
    picker.delegate   = self;
    [self presentViewController:picker animated:YES completion:nil];
}

/** 从相册选取图片 */
- (void)pickFromLibraryForCustomDial {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.mediaTypes = @[(NSString *)kUTTypeImage];
    picker.delegate   = self;
    [self presentViewController:picker animated:YES completion:nil];
}

/** 从相册选取视频 */
- (void)pickVideoForCustomDial {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType           = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.mediaTypes           = @[(NSString *)kUTTypeMovie];
    picker.videoMaximumDuration = (NSTimeInterval)self.maxVideoDialDuration;
    picker.videoQuality         = UIImagePickerControllerQualityTypeHigh;
    picker.delegate             = self;
    [self presentViewController:picker animated:YES completion:nil];
}

/** UIImagePickerController 选取完成回调 */
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info {
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    [picker dismissViewControllerAnimated:YES completion:^{
        if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
            UIImage *image = info[UIImagePickerControllerOriginalImage];
            if (image) [self pushImageCropVCWithImage:image];
        } else {
            NSURL *url = info[UIImagePickerControllerMediaURL];
            if (url)   [self pushVideoEditVCWithURL:url];
        }
    }];
}

/** 用户取消选取 */
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

/** Push 图片裁剪页到当前导航栈 */
- (void)pushImageCropVCWithImage:(UIImage *)image {
    TSDialImageCropVC *vc =
        [[TSDialImageCropVC alloc] initWithImage:image
                                     aspectRatio:self.customDialAspectRatio];
    __weak typeof(self) wself = self;
    vc.onCropComplete = ^(UIImage *cropped) {
        TSDialEditorVC *editor =
            [[TSDialEditorVC alloc] initWithImage:cropped
                                        dialSize:wself.customDialSize];
        editor.onPushSuccess = ^{ [wself fetchDials]; };
        [wself.navigationController pushViewController:editor animated:YES];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

/** Push 视频编辑页到当前导航栈 */
- (void)pushVideoEditVCWithURL:(NSURL *)url {
    TSDialVideoEditVC *vc =
        [[TSDialVideoEditVC alloc] initWithVideoURL:url
                                           dialSize:self.customDialSize
                                        maxDuration:self.maxVideoDialDuration];
    __weak typeof(self) wself = self;
    vc.onEditComplete = ^(NSURL *processedURL) {
        TSDialEditorVC *editor =
            [[TSDialEditorVC alloc] initWithVideoURL:processedURL
                                           dialSize:wself.customDialSize];
        editor.onPushSuccess = ^{ [wself fetchDials]; };
        [wself.navigationController pushViewController:editor animated:YES];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)cv numberOfItemsInSection:(NSInteger)section {
    return (NSInteger)[self dialsForCV:cv].count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TSDialCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"TSDialCell" forIndexPath:indexPath];
    TSDialModel *dial = [self dialsForCV:cv][indexPath.item];
    BOOL isCurrent = [dial.dialId isEqualToString:self.currentDialId];
    [cell configureWithDial:dial isCurrent:isCurrent];
    return cell;
}

#pragma mark - UICollectionViewDelegate

/** 点击表盘 → 进入详情页 */
- (void)collectionView:(UICollectionView *)cv didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    TSDialModel *dial = [self dialsForCV:cv][indexPath.item];
    BOOL isCurrent = [dial.dialId isEqualToString:self.currentDialId];

    TSDialDetailVC *detailVC = [[TSDialDetailVC alloc] initWithDial:dial isCurrent:isCurrent];
    __weak typeof(self) wself = self;
    detailVC.onDialSwitched = ^(NSString *newDialId) {
        wself.currentDialId = newDialId;
        [wself reloadAllCollectionViews];
    };
    [self.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark - Long Press（删除云端/自定义表盘）

/** 长按删除非内置表盘 */
- (void)onLongPressCell:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state != UIGestureRecognizerStateBegan) return;

    UICollectionView *cv = (UICollectionView *)gesture.view;
    NSIndexPath *indexPath = [cv indexPathForItemAtPoint:[gesture locationInView:cv]];
    if (!indexPath) return;

    TSDialModel *dial = [self dialsForCV:cv][indexPath.item];
    if (dial.dialType == eTSDialTypeBuiltIn) return; // 内置表盘不可删除

    NSString *name = dial.dialName.length ? dial.dialName : @"该表盘";
    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:@"删除表盘"
                         message:[NSString stringWithFormat:@"确定要删除「%@」吗？删除后不可恢复。", name]
                  preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];

    __weak typeof(self) wself = self;
    [alert addAction:[UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive
                                            handler:^(UIAlertAction *a) {
        [wself performDeleteDial:dial];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

/** 调用 SDK 执行删除 */
- (void)performDeleteDial:(TSDialModel *)dial {
    [self.loadingIndicator startAnimating];
    self.scrollView.userInteractionEnabled = NO;

    __weak typeof(self) wself = self;
    [[[TopStepComKit sharedInstance] dial] deleteDial:dial
                                          completion:^(BOOL isSuccess, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [wself.loadingIndicator stopAnimating];
            wself.scrollView.userInteractionEnabled = YES;
            if (isSuccess) {
                [wself removeDialFromCache:dial];
                [wself reloadAllCollectionViews];
            } else {
                [wself showAlertWithMsg:error.localizedDescription ?: @"删除失败，请重试"];
            }
        });
    }];
}

/** 从本地缓存数组中移除已删除的表盘 */
- (void)removeDialFromCache:(TSDialModel *)dial {
    if (dial.dialType == eTSDialTypeCloud) {
        NSMutableArray *arr = [self.cloudDials mutableCopy];
        [arr removeObject:dial];
        self.cloudDials = arr;
    } else if (dial.dialType == eTSDialTypeCustomer) {
        NSMutableArray *arr = [self.customDials mutableCopy];
        [arr removeObject:dial];
        self.customDials = arr;
    }
}

#pragma mark - Helpers

/** 根据 CollectionView 的 tag 返回对应数据数组 */
- (NSArray<TSDialModel *> *)dialsForCV:(UICollectionView *)cv {
    switch (cv.tag) {
        case kTagBuiltIn: return self.builtInDials;
        case kTagCloud:   return self.cloudDials;
        case kTagCustom:  return self.customDials;
        default:          return @[];
    }
}

/** 创建带长按手势的横向 CollectionView */
- (UICollectionView *)makeCollectionViewWithTag:(NSInteger)tag {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection         = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize                = CGSizeMake(kCellW, kCellH);
    layout.minimumInteritemSpacing = kMainPadH;
    layout.minimumLineSpacing      = kMainPadH;
    layout.sectionInset            = UIEdgeInsetsMake(kMainPadV, kMainPadH, kMainPadV, kMainPadH);

    UICollectionView *cv = [[UICollectionView alloc] initWithFrame:CGRectZero
                                              collectionViewLayout:layout];
    cv.tag          = tag;
    cv.backgroundColor = UIColor.clearColor;
    cv.dataSource   = self;
    cv.delegate     = self;
    cv.showsHorizontalScrollIndicator = NO;
    [cv registerClass:[TSDialCell class] forCellWithReuseIdentifier:@"TSDialCell"];

    UILongPressGestureRecognizer *lp = [[UILongPressGestureRecognizer alloc]
        initWithTarget:self action:@selector(onLongPressCell:)];
    lp.minimumPressDuration = 0.6;
    [cv addGestureRecognizer:lp];

    return cv;
}

/** 创建带阴影的白色圆角分类卡片 */
- (UIView *)makeSectionCard {
    UIView *card = [[UIView alloc] init];
    card.backgroundColor    = TSColor_Card;
    card.layer.cornerRadius = kMainCardCorner;
    card.layer.shadowColor  = UIColor.blackColor.CGColor;
    card.layer.shadowOpacity = 0.06f;
    card.layer.shadowOffset  = CGSizeMake(0, 2);
    card.layer.shadowRadius  = 6.f;
    return card;
}

/** 创建分类 Section 标题 Label */
- (UILabel *)makeSectionTitleLabel:(NSString *)text {
    UILabel *l = [[UILabel alloc] init];
    l.text      = text;
    l.font      = TSFont_H2;
    l.textColor = TSColor_TextPrimary;
    return l;
}

#pragma mark - Lazy

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.backgroundColor = TSColor_Background;
        _scrollView.alwaysBounceVertical = YES;
    }
    return _scrollView;
}

- (UIButton *)pushCloudBtn {
    if (!_pushCloudBtn) {
        _pushCloudBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _pushCloudBtn.backgroundColor    = TSColor_Primary;
        _pushCloudBtn.layer.cornerRadius = kMainBtnCorner;
        [_pushCloudBtn setTitle:@"推送云端表盘" forState:UIControlStateNormal];
        [_pushCloudBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        _pushCloudBtn.titleLabel.font                = [UIFont systemFontOfSize:13 weight:UIFontWeightSemibold];
        _pushCloudBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
        _pushCloudBtn.titleLabel.minimumScaleFactor  = 0.7f;
        [_pushCloudBtn addTarget:self action:@selector(onPushCloudDialTapped)
                forControlEvents:UIControlEventTouchUpInside];
    }
    return _pushCloudBtn;
}

- (UIButton *)makeCustomBtn {
    if (!_makeCustomBtn) {
        _makeCustomBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _makeCustomBtn.backgroundColor    = TSColor_Teal;
        _makeCustomBtn.layer.cornerRadius = kMainBtnCorner;
        [_makeCustomBtn setTitle:@"制作自定义表盘" forState:UIControlStateNormal];
        [_makeCustomBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        _makeCustomBtn.titleLabel.font                = [UIFont systemFontOfSize:13 weight:UIFontWeightSemibold];
        _makeCustomBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
        _makeCustomBtn.titleLabel.minimumScaleFactor  = 0.7f;
        [_makeCustomBtn addTarget:self action:@selector(onMakeCustomDialTapped)
                 forControlEvents:UIControlEventTouchUpInside];
    }
    return _makeCustomBtn;
}

- (UIView *)builtInCard {
    if (!_builtInCard) _builtInCard = [self makeSectionCard];
    return _builtInCard;
}

- (UILabel *)builtInTitleLabel {
    if (!_builtInTitleLabel) _builtInTitleLabel = [self makeSectionTitleLabel:@"内置表盘"];
    return _builtInTitleLabel;
}

- (UICollectionView *)builtInCV {
    if (!_builtInCV) _builtInCV = [self makeCollectionViewWithTag:kTagBuiltIn];
    return _builtInCV;
}

- (UIView *)cloudCard {
    if (!_cloudCard) _cloudCard = [self makeSectionCard];
    return _cloudCard;
}

- (UILabel *)cloudTitleLabel {
    if (!_cloudTitleLabel) _cloudTitleLabel = [self makeSectionTitleLabel:@"云端表盘"];
    return _cloudTitleLabel;
}

- (UICollectionView *)cloudCV {
    if (!_cloudCV) _cloudCV = [self makeCollectionViewWithTag:kTagCloud];
    return _cloudCV;
}

- (UIView *)customCard {
    if (!_customCard) _customCard = [self makeSectionCard];
    return _customCard;
}

- (UILabel *)customTitleLabel {
    if (!_customTitleLabel) _customTitleLabel = [self makeSectionTitleLabel:@"自定义表盘"];
    return _customTitleLabel;
}

- (UICollectionView *)customCV {
    if (!_customCV) _customCV = [self makeCollectionViewWithTag:kTagCustom];
    return _customCV;
}

- (UIActivityIndicatorView *)loadingIndicator {
    if (!_loadingIndicator) {
        if (@available(iOS 13.0, *)) {
            _loadingIndicator = [[UIActivityIndicatorView alloc]
                initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
        } else {
            _loadingIndicator = [[UIActivityIndicatorView alloc]
                initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        }
        _loadingIndicator.hidesWhenStopped = YES;
    }
    return _loadingIndicator;
}

@end
