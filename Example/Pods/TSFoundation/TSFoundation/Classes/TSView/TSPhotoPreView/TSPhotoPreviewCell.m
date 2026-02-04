//
//  TSPhotoPreviewCell.m
//  JieliJianKang
//
//  Created by luigi on 2024/4/24.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import "Masonry.h"
#import "ReactiveObjC.h"
#import "TSChecker.h"
#import "TSPhotoPreviewCell.h"
#import "UIView+TSView.h"

@implementation TSPhotoPreviewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blackColor];
        [self createUI];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoPreviewCollectionViewDidScroll) name:@"photoPreviewCollectionViewDidScroll" object:nil];
    }

    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.previewView.frame = self.bounds;
}

- (void)setPhoto:(id)photo {
    _photo = photo;
    self.previewView.photo = photo;
}

- (void)recoverSubviews {
    [_previewView recoverSubviews];
}

#pragma mark - Notification

- (void)photoPreviewCollectionViewDidScroll {
}

#pragma mark - setupUI
- (void)createUI {
    self.previewView = [[TSPhotoPreviewView alloc] initWithFrame:CGRectZero];
    __weak typeof(self) weakSelf = self;
    [self.previewView setSingleTapGestureBlock:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;

        if (strongSelf.singleTapGestureBlock) {
            strongSelf.singleTapGestureBlock();
        }
    }];
    [self.contentView addSubview:self.previewView];
}

@end


@interface TSPhotoPreviewView ()<UIScrollViewDelegate>

@end

@implementation TSPhotoPreviewView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    if (self) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.bouncesZoom = YES;
        _scrollView.maximumZoomScale = 2.5;
        _scrollView.minimumZoomScale = 0.1;
        _scrollView.multipleTouchEnabled = YES;
        _scrollView.delegate = self;
        _scrollView.scrollsToTop = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = YES;
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scrollView.delaysContentTouches = NO;
        _scrollView.canCancelContentTouches = YES;
        _scrollView.alwaysBounceVertical = NO;

        if (@available(iOS 11, *)) {
            _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }

        [self addSubview:_scrollView];

        _imageContainerView = [[UIView alloc] init];
        _imageContainerView.clipsToBounds = YES;
        _imageContainerView.contentMode = UIViewContentModeScaleAspectFill;
        [_scrollView addSubview:_imageContainerView];

        _imageView = [[UIImageView alloc] init];
        _imageView.backgroundColor = [UIColor colorWithWhite:1.000 alpha:0.500];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        [_imageContainerView addSubview:_imageView];

        UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        [self addGestureRecognizer:tap1];
        UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
        tap2.numberOfTapsRequired = 2;
        [tap1 requireGestureRecognizerToFail:tap2];
        [self addGestureRecognizer:tap2];
    }

    return self;
}

- (void)setPhoto:(id)photo {
    _photo = photo;
    [_scrollView setZoomScale:1.0 animated:NO];

    if ([photo isKindOfClass:[UIImage class]]) {
        self.imageView.image = photo;
    } else if ([photo isKindOfClass:[NSString class]]) {
        if ([photo hasPrefix:@"http"]) {
            @weakify(self)
            [self.imageView sd_setImageWithURL:[NSURL URLWithString:photo] completed:^(UIImage *_Nullable image, NSError *_Nullable error, SDImageCacheType cacheType, NSURL *_Nullable imageURL) {
                @strongify(self)
                [self resizeSubviews];
            }];
        } else {
            self.imageView.image = [UIImage imageWithContentsOfFile:photo];
            [self resizeSubviews];
        }
    }
}

- (void)recoverSubviews {
    [_scrollView setZoomScale:1 animated:NO];
    [self resizeSubviews];
}

- (void)resizeSubviews {
    CGRect frame = _imageContainerView.frame;

    frame.origin = CGPointZero;
    frame.size.width = self.scrollView.width;
    _imageContainerView.frame = frame;

    UIImage *image = _imageView.image;

    if (image.size.height / image.size.width > self.height / self.scrollView.width) {
        CGRect frame = _imageContainerView.frame;
        frame.size.height = floor(image.size.height / (image.size.width / self.scrollView.width));
        _imageContainerView.frame = frame;
    } else {
        CGFloat height = image.size.height / image.size.width * self.scrollView.width;

        if (height < 1 || isnan(height)) {
            height = self.height;
        }

        height = floor(height);
        CGRect frame = _imageContainerView.frame;
        frame.size.height = height;
        _imageContainerView.frame = frame;
        _imageContainerView.center = CGPointMake(_imageContainerView.center.x, self.height / 2);
    }

    if (_imageContainerView.height > self.height && _imageContainerView.height - self.height <= 1) {
        CGRect frame = _imageContainerView.frame;
        frame.size.height = self.height;
        _imageContainerView.frame = frame;
    }

    CGFloat contentSizeH = MAX(_imageContainerView.height, self.height);
    _scrollView.contentSize = CGSizeMake(self.scrollView.width, contentSizeH);
    [_scrollView scrollRectToVisible:self.bounds animated:NO];
    _scrollView.alwaysBounceVertical = _imageContainerView.height <= self.height ? NO : YES;
    _imageView.frame = _imageContainerView.bounds;
}

- (void)configMaximumZoomScale {
    _scrollView.maximumZoomScale = 10;
    _scrollView.minimumZoomScale = 0.1;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _scrollView.frame = CGRectMake(10, 0, self.width - 20, self.height);
    [self recoverSubviews];
}

#pragma mark - UITapGestureRecognizer Event

- (void)doubleTap:(UITapGestureRecognizer *)tap {
    if (_scrollView.zoomScale > _scrollView.minimumZoomScale) {
        _scrollView.contentInset = UIEdgeInsetsZero;
        [_scrollView setZoomScale:_scrollView.minimumZoomScale animated:YES];
    } else {
        CGPoint touchPoint = [tap locationInView:self.imageView];
        CGFloat newZoomScale = _scrollView.maximumZoomScale;
        CGFloat xsize = self.frame.size.width / newZoomScale;
        CGFloat ysize = self.frame.size.height / newZoomScale;
        [_scrollView zoomToRect:CGRectMake(touchPoint.x - xsize / 2, touchPoint.y - ysize / 2, xsize, ysize) animated:YES];
    }
}

- (void)singleTap:(UITapGestureRecognizer *)tap {
    if (self.singleTapGestureBlock) {
        self.singleTapGestureBlock();
    }
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageContainerView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    scrollView.contentInset = UIEdgeInsetsZero;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self refreshImageContainerViewCenter];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
}

#pragma mark - Private

- (void)refreshImageContainerViewCenter {
    CGFloat offsetX = (_scrollView.width > _scrollView.contentSize.width) ? ((_scrollView.width - _scrollView.contentSize.width) * 0.5) : 0.0;
    CGFloat offsetY = (_scrollView.height > _scrollView.contentSize.height) ? ((_scrollView.height - _scrollView.contentSize.height) * 0.5) : 0.0;

    self.imageContainerView.center = CGPointMake(_scrollView.contentSize.width * 0.5 + offsetX, _scrollView.contentSize.height * 0.5 + offsetY);
}

@end
