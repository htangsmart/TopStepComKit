//
//  TSScrollBannerView.m
//  JieliJianKang
//
//  Created by 磐石 on 2024/3/11.
//

#import "TSScrollBannerView.h"
#import "TSScrollBannerItem.h"
#import "TSColor.h"

@interface TSScrollBannerView ()<UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate>

@property (nonatomic,strong) UICollectionView *bannerCollectionView;

@property (nonatomic,strong) UIPageControl *bannerControl;

@property (nonatomic,strong) NSString *itemName;

@property (nonatomic,strong) NSArray *bannerArray;

@property (nonatomic,strong) NSTimer *mTimer;

@end

@implementation TSScrollBannerView

- (instancetype)initWithRegisterItemName:(NSString *)itemName{
    self = [super init];
    if (self) {
        _itemName = itemName;
        [self initData];
        [self initViews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initData];
        [self initViews];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initData];
        [self initViews];
    }
    return self;
}

- (void)initData {
    [self.bannerCollectionView registerClass:[TSScrollBannerItem class] forCellWithReuseIdentifier:@"kTSScrollBannerItem"];
}

- (void)initViews {
    [self addSubview:self.bannerCollectionView];
    [self addSubview:self.bannerControl];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    NSInteger bWidth = _bannerArray.count * 40;
    NSInteger leftP = self.frame.size.width - bWidth - 32;
    self.bannerControl.frame = CGRectMake(leftP, CGRectGetHeight(self.frame) - 30 - 16, _bannerArray.count * 50, 30);
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.bannerCollectionView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
}

- (void)reloadWithArray:(NSArray *)bannerArray {
    self.bannerArray = bannerArray;
    self.bannerControl.numberOfPages = bannerArray.count;
    [self.bannerCollectionView performBatchUpdates:^{
        [self.bannerCollectionView reloadData];
    } completion:^(BOOL finished) {
        if (self.bannerArray.count > 1) {
            [self.bannerCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:50] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
        }
    }];
    [self start];
}

// MARK: UICollectionViewDelegate && UICollectionViewDataSource
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.dataSource bannerView:self bannerSizeForItemAtIndexPath:indexPath];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (self.bannerArray.count > 1) {
        return 100;
    } else {
        return 1;
    }
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.bannerArray.count;
}

-(__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TSScrollBannerItem * typeItem = [collectionView dequeueReusableCellWithReuseIdentifier:@"kTSScrollBannerItem" forIndexPath:indexPath];
    TSBannerModel *model = self.bannerArray[indexPath.item];
    [typeItem reloadBannerCellWithModel:model];
    return typeItem;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = indexPath.row%self.bannerArray.count;
    [self.delegate bannerView:self didSelectBannerAtIndex:index];
}

// MARK: UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger page = (NSInteger)(scrollView.contentOffset.x / scrollView.frame.size.width) % self.bannerArray.count;
    self.bannerControl.currentPage = page;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (_mTimer) {
        [_mTimer setFireDate:NSDate.distantFuture];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (_mTimer) {
        [_mTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:3]];
    }
}

- (void)timeLoopImg {
    [self next];
}

- (void)next {
    // 获取当前正在展示的位置
    NSIndexPath *currentIndexPath = [[self.bannerCollectionView indexPathsForVisibleItems] lastObject];
    // 反回中间的数据100是返回的分区个数
    NSIndexPath *currentIndexPathRest = [NSIndexPath indexPathForItem:currentIndexPath.item inSection:100 / 2];
    [self.bannerCollectionView scrollToItemAtIndexPath:currentIndexPathRest atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    // 计算出下一个需要展示的位置
    NSInteger nextItem = currentIndexPathRest.item + 1;
    NSInteger nextSection = currentIndexPathRest.section;
    if (nextItem == self.bannerArray.count) {
        nextItem = 0;
        nextSection++;
    }
    NSIndexPath *nextIndexPath = [NSIndexPath indexPathForItem:nextItem inSection:nextSection];
    // 通过动画滚到下一个位置
    [self.bannerCollectionView scrollToItemAtIndexPath:nextIndexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
    self.bannerControl.currentPage = nextItem;
}

- (void)stopTimer {
    if(_mTimer) {
        [_mTimer invalidate];
        _mTimer = nil;
    }
}

- (void)start {
    [self mTimer];
}

- (NSTimer *)mTimer {
    if(_mTimer == nil && self.bannerArray.count > 1) {
        _mTimer = [NSTimer scheduledTimerWithTimeInterval:3.0f
                                                          target:self
                                                        selector:@selector(wy_action:)
                                                        userInfo:nil
                                                         repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_mTimer forMode:NSRunLoopCommonModes];
    }
    return _mTimer;
}

- (void)wy_action:(NSTimer *)timer {
    if (self.bannerArray.count>1) {
        [self timeLoopImg];
    }
}

- (UICollectionView *)bannerCollectionView {
    if (!_bannerCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        
        _bannerCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))  collectionViewLayout:layout];
        _bannerCollectionView.backgroundColor = [UIColor clearColor];
        _bannerCollectionView.delegate = self;
        _bannerCollectionView.dataSource = self;
        _bannerCollectionView.alwaysBounceVertical = NO;
        _bannerCollectionView.alwaysBounceHorizontal = YES;
        _bannerCollectionView.showsVerticalScrollIndicator = NO;
        _bannerCollectionView.showsHorizontalScrollIndicator = NO;
        _bannerCollectionView.pagingEnabled = YES;
    }
    return _bannerCollectionView;
}

- (UIPageControl *)bannerControl {
    if(!_bannerControl){
        _bannerControl = [[UIPageControl alloc] init];
//        _bannerControl.pageIndicatorTintColor = [TSColor colorwithHexString:@"#ffffff" alpha:0.3];
//        _bannerControl.currentPageIndicatorTintColor = [TSColor colorwithHexString:@"#ffffff" alpha:1.0];
        _bannerControl.hidesForSinglePage = YES;
    }
    return _bannerControl;
}

- (void)dealloc {
    [self stopTimer];
}

@end
