//
//  TSPhotoPreviewVC.m
//  JieliJianKang
//
//  Created by luigi on 2024/4/24.
//

#import "TSPhotoPreviewVC.h"
#import "TSPhotoPreviewCell.h"
#import <Photos/Photos.h>
#import<SDWebImage/UIImageView+WebCache.h>
#import "ReactiveObjC.h"
#import "TSChecker.h"
#import "Masonry.h"
#import "UIView+TSView.h"
#import "TSAlert.h"
#import "JLPhoneUISetting.h"
#import "TSToast.h"
#import "UIImage+Bundle.h"
#import "NSBundle+TSFoundation.h"

@interface TSPhotoPreviewVC ()<UICollectionViewDataSource,UICollectionViewDelegate,UIScrollViewDelegate>
{
    UICollectionView *_collectionView;
    UICollectionViewFlowLayout *_layout;
    
    UIView *_naviBar;
    UIButton *_backButton;
    
    UIView *_toolBar;
    UIButton *_downloadButton;
    UIButton *_deleteButton;

    BOOL _didSetIsSelectOriginalPhoto;
}
@property (nonatomic, assign) BOOL isHideNaviBar;
@property (nonatomic, strong) UIImageView *cacheImageView;

@end

@implementation TSPhotoPreviewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.cacheImageView = [UIImageView new];
    [self createUI];
    [self layoutUI];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (_currentIndex > 0) {
        CGFloat offsetX = _currentIndex * _layout.itemSize.width;
        [_collectionView setContentOffset:CGPointMake(offsetX, 0) animated:NO];
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    
    _layout.itemSize = CGSizeMake(size.width + 20, size.height);
    _layout.minimumInteritemSpacing = 0;
    _layout.minimumLineSpacing = 0;
    [_collectionView setCollectionViewLayout:_layout];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:true animated:true];
    if (_currentIndex) {
        [_collectionView setContentOffset:CGPointMake((self.view.width + 20) * self.currentIndex, 0) animated:NO];
    }
    [self refreshNaviBarAndBottomBarState];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:false animated:YES];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)setPhotos:(NSArray *)photos {
    _photos = photos;
    if (_currentIndex >= photos.count) { _currentIndex = photos.count - 1; }
    [_collectionView reloadData];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    // NSLog(@"%@ dealloc",NSStringFromClass(self.class));
}

#pragma mark - setupUI
- (void)createUI {
    
    [self configCollectionView];
    [self createCustomNaviBar];
    [self configBottomToolBar];
}

- (void)createCustomNaviBar {
    _naviBar = [[UIView alloc] initWithFrame:CGRectZero];
    _naviBar.backgroundColor = [UIColor colorWithRed:(34/255.0) green:(34/255.0)  blue:(34/255.0) alpha:0.7];
    
    _backButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [_backButton setImage:[[UIImage imageNamed:@"icon_return_nol_black" inBundle:[NSBundle foundationBundle]] imageWithRenderingMode:(UIImageRenderingModeAlwaysTemplate)] forState:UIControlStateNormal];
    [_backButton.imageView setTintColor:UIColor.whiteColor];
    [_backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    [_naviBar addSubview:_backButton];
    [self.view addSubview:_naviBar];
}

- (void)configBottomToolBar {
    
    _toolBar = [[UIView alloc] initWithFrame:CGRectZero];
    static CGFloat rgb = 34 / 255.0;
    _toolBar.backgroundColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:0.7];
    
    _downloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _downloadButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [_downloadButton addTarget:self action:@selector(downloadButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_downloadButton setImage:[[UIImage imageNamed:@"ic_file_download_36pt" inBundle:[NSBundle foundationBundle]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    _downloadButton.tintColor = UIColor.whiteColor;

    _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _deleteButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [_deleteButton addTarget:self action:@selector(deleteButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_deleteButton setImage:[[UIImage imageNamed:@"icon_delete_nol" inBundle:[NSBundle foundationBundle]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    _deleteButton.tintColor = UIColor.whiteColor;
    
    
    _toolBar.hidden = self.isHideNaviBar || (!self.canSaveToPhotoAlbum && !self.showDeleteBtn);

    [_toolBar addSubview:_downloadButton];
    [_toolBar addSubview:_deleteButton];
    [self.view addSubview:_toolBar];
}

- (void)configCollectionView {
    _layout = [[UICollectionViewFlowLayout alloc] init];
    _layout.itemSize = CGSizeMake(self.view.width + 20, self.view.height);
    _layout.minimumInteritemSpacing = 0;
    _layout.minimumLineSpacing = 0;
    _layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_layout];
    _collectionView.backgroundColor = [UIColor blackColor];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.pagingEnabled = YES;
    _collectionView.scrollsToTop = NO;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.contentOffset = CGPointMake(0, 0);
    _collectionView.contentSize = CGSizeMake(self.photos.count * (self.view.frame.size.width + 20), 0);
    [self.view addSubview:_collectionView];
    [_collectionView registerClass:[TSPhotoPreviewCell class] forCellWithReuseIdentifier:@"TSPhotoPreviewCell"];
}

- (void)layoutUI {
    
    [_naviBar mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.top.left.right.offset(0);
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(44);
        } else {
            make.bottom.equalTo(self.mas_topLayoutGuide).offset(44);
        }
    }];
    
    [_backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(10);
        make.bottom.offset(0);
        make.size.sizeOffset(CGSizeMake(44, 44));
    }];
        
    [_toolBar mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.right.bottom.offset(0);
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-44);
        } else {
            make.top.equalTo(self.mas_bottomLayoutGuide).offset(-44);
        }
    }];
    
    _downloadButton.hidden = !self.canSaveToPhotoAlbum;
    [_downloadButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_toolBar.mas_right).offset(-12);
        make.top.offset(0);
        make.size.sizeOffset(CGSizeMake(44, 44));
    }];
    
    _deleteButton.hidden = !self.showDeleteBtn;
    [_deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.canSaveToPhotoAlbum ? _downloadButton.mas_left : _toolBar.mas_right).offset(-12);
        make.top.offset(0);
        make.size.sizeOffset(CGSizeMake(44, 44));
    }];
    
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.offset(0);
        make.left.equalTo(self.view.mas_left).offset(-10);
        make.right.equalTo(self.view.mas_right).offset(10);
    }];
    
}


#pragma mark - action
- (void)backButtonClick {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)deleteButtonClick {
    
    @weakify(self)
    if (self.deleteBtnClickBlock) { self.deleteBtnClickBlock(self, ^(BOOL deleteResult) {
        
        @strongify(self)
        if (!deleteResult) { return; }
        NSMutableArray *photos = [self.photos mutableCopy];
        [photos removeObjectAtIndex:self.currentIndex];
        self.photos = [photos copy];
    });}
}

- (void)downloadButtonClick {
 
    if (TSARRAY_ISEMPTY(self.photos)) { return; }
    if (self.photos.count <= self.currentIndex) { return; }
    id photo = self.photos[self.currentIndex];
        
    if ([photo isKindOfClass:[UIImage class]]) {
    
        [self savePhotoToPhotoAlbum:photo];
    } else if ([photo isKindOfClass:[NSString class]]) {
        
        if ([photo hasPrefix:@"http"]) {
            
            @weakify(self)
            [self.cacheImageView sd_setImageWithURL:[NSURL URLWithString:photo] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                
                @strongify(self)
                [self savePhotoToPhotoAlbum:image];
            }];
        } else {
            
            [self savePhotoToPhotoAlbum:[UIImage imageWithContentsOfFile:photo]];
        }
    }
}

- (void)savePhotoToPhotoAlbum:(UIImage *)photo {
    
    if (![photo isKindOfClass:[UIImage class]]) { [TSToast showText:kJL_TXT("图片保存失败") onView:self.view dismissAfterDelay:2.f]; }
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [[PHAssetCreationRequest creationRequestForAsset] addResourceWithType:PHAssetResourceTypePhoto data:UIImagePNGRepresentation(photo) options:nil];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        
        if (success) {
            
            [TSToast showText:kJL_TXT("已将图片保存至相册") onView:self.view dismissAfterDelay:2.f];
        } else {
            
            [TSToast showText:error.localizedDescription onView:self.view dismissAfterDelay:2.f];
        }
    }];
}

- (void)didTapPreviewCell {
    self.isHideNaviBar = !self.isHideNaviBar;
    _naviBar.hidden = self.isHideNaviBar;
    _toolBar.hidden = self.isHideNaviBar || (!self.canSaveToPhotoAlbum && !self.showDeleteBtn);
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offSetWidth = scrollView.contentOffset.x;
    offSetWidth = offSetWidth +  ((self.view.width + 20) * 0.5);
    
    NSInteger currentIndex = offSetWidth / (self.view.width + 20);
    if (currentIndex < _photos.count && _currentIndex != currentIndex) {
        _currentIndex = currentIndex;
        [self refreshNaviBarAndBottomBarState];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"photoPreviewCollectionViewDidScroll" object:nil];
}

- (void)refreshNaviBarAndBottomBarState {

}

#pragma mark - UICollectionViewDataSource && Delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _photos.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TSPhotoPreviewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TSPhotoPreviewCell" forIndexPath:indexPath];
    __weak typeof(self) weakSelf = self;
    cell.photo = self.photos[indexPath.item];
    [cell setSingleTapGestureBlock:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf didTapPreviewCell];
    }];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {

    [(TSPhotoPreviewCell *)cell recoverSubviews];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {

    [(TSPhotoPreviewCell *)cell recoverSubviews];
}

@end
