//
//  XYPhotosBrowser.m
//  Footprint
//
//  Created by 李小亚 on 16/4/9.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#define kPadding 10
#define kPhotoViewTagOffset 1000
#define kPhotoViewIndex(photoView) ([photoView tag] - kPhotoViewTagOffset)

#import "XYPhotosBrowser.h"
#import "XYPhotosToolBar.h"
#import "XYPhoto.h"
#import "XYBrowserPhotoView.h"

@interface XYPhotosBrowser ()<XYBrowserPhotoViewDelegate>

/**
 *  一开始的状态栏
 */
@property (nonatomic, assign) BOOL statusBarHiddenInited;
/**
 *  滚动的view
 */
@property (nonatomic, weak) UIScrollView *photoScrollView;
/**
 *   工具条
 */
@property (nonatomic, weak) XYPhotosToolBar *toolbar;
/**
 *  所有的图片view
 */
@property (nonatomic, strong) NSMutableSet *visiblePhotoViews;
@property (nonatomic, strong) NSMutableSet *reusablePhotoViews;
@end

@implementation XYPhotosBrowser

#pragma mark - Lifecycle
- (void)loadView
{
    _statusBarHiddenInited = [UIApplication sharedApplication].isStatusBarHidden;
    // 隐藏状态栏
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    self.view = [[UIView alloc] init];
    self.view.frame = [UIScreen mainScreen].bounds;
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 1.创建UIScrollView
    [self createScrollView];
    
    // 2.创建工具条
    [self createToolbar];
}

- (void)show
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self.view];
    [window.rootViewController addChildViewController:self];
    
    if (_currentPhotoIndex == 0) {
        [self showPhotos];
    }
}

#pragma mark - 私有方法
#pragma mark 创建工具条
- (void)createToolbar
{
    CGFloat barHeight = 44;
    CGFloat barY = self.view.frame.size.height - barHeight;
     XYPhotosToolBar *toolbar = [[XYPhotosToolBar alloc] init];
    self.toolbar = toolbar;
    toolbar.frame = CGRectMake(0, barY, self.view.frame.size.width, barHeight);
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    toolbar.photos = _photos;
    [self.view addSubview:_toolbar];
    
    [self updateTollbarState];
}

#pragma mark 创建UIScrollView
- (void)createScrollView
{
    CGRect frame = self.view.bounds;
    frame.origin.x -= kPadding;
    frame.size.width += (2 * kPadding);
    UIScrollView *photoScrollView = [[UIScrollView alloc] initWithFrame:frame];
    self.photoScrollView = photoScrollView;
    photoScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    photoScrollView.pagingEnabled = YES;
    photoScrollView.delegate = self;
    photoScrollView.showsHorizontalScrollIndicator = NO;
    photoScrollView.showsVerticalScrollIndicator = NO;
    photoScrollView.backgroundColor = [UIColor clearColor];
    photoScrollView.contentSize = CGSizeMake(frame.size.width * _photos.count, 0);
    [self.view addSubview:photoScrollView];
    photoScrollView.contentOffset = CGPointMake(_currentPhotoIndex * frame.size.width, 0);
}

- (void)setPhotos:(NSArray *)photos{
    _photos = photos;
    
    if (photos.count > 1) {
        _visiblePhotoViews = [NSMutableSet set];
        _reusablePhotoViews = [NSMutableSet set];
    }
#warning 有何用
    int i = 0;
    for (XYPhoto *photo in photos) {
        photo.index = i;
        i++;
    }
    
}
#pragma mark - 设置选中的图片
- (void)setCurrentPhotoIndex:(NSUInteger)currentPhotoIndex{
    _currentPhotoIndex = currentPhotoIndex;
    
    if ([self isViewLoaded]) {
        _photoScrollView.contentOffset = CGPointMake(_currentPhotoIndex * _photoScrollView.frame.size.width, 0);
        //显示所有的图片
        [self showPhotos];
    }
}
#pragma mark - 显示所有的图片
- (void)showPhotos{
    //只有一张图片
    if (_photos.count == 1) {
        [self showPhotoViewAtIndex:0];
        return;
    }
    
    CGRect visibleBounds = _photoScrollView.bounds;
    NSInteger firstIndex = (NSInteger)floorf((CGRectGetMinX(visibleBounds)+kPadding*2) / CGRectGetWidth(visibleBounds));
    NSInteger lastIndex  = (NSInteger)floorf((CGRectGetMaxX(visibleBounds)-kPadding*2-1) / CGRectGetWidth(visibleBounds));
    if (firstIndex < 0) firstIndex = 0;
    if (firstIndex >= _photos.count) firstIndex = _photos.count - 1;
    if (lastIndex < 0) lastIndex = 0;
    if (lastIndex >= _photos.count) lastIndex = _photos.count - 1;
    
    // 回收不再显示的ImageView
    NSInteger photoViewIndex;
    for (XYBrowserPhotoView *photoView in _visiblePhotoViews) {
        photoViewIndex = kPhotoViewIndex(photoView);
        if (photoViewIndex < firstIndex || photoViewIndex > lastIndex) {
            [_reusablePhotoViews addObject:photoView];
            [photoView removeFromSuperview];
        }
    }
    
    [_visiblePhotoViews minusSet:_reusablePhotoViews];
    while (_reusablePhotoViews.count > 2) {
        [_reusablePhotoViews removeObject:[_reusablePhotoViews anyObject]];
    }
    
    for (NSUInteger index = firstIndex; index <= lastIndex; index++) {
        if (![self isShowingPhotoViewAtIndex:index]) {
            [self showPhotoViewAtIndex:index];
        }
    }
}
#pragma mark index这页是否正在显示
- (BOOL)isShowingPhotoViewAtIndex:(NSUInteger)index {
    for (XYBrowserPhotoView *photoView in _visiblePhotoViews) {
        if (kPhotoViewIndex(photoView) == index) {
            return YES;
        }
    }
    return  NO;
}

#pragma mark - 显示一张图片
- (void)showPhotoViewAtIndex:(NSUInteger)index{
    XYBrowserPhotoView *photoView = [self dequeueReusablePhotoView];
    if (!photoView) {//添加新的图片View
        photoView = [[XYBrowserPhotoView alloc] init];
        photoView.photoViewDelegate = self;
    }
    
    // 调整当期页的frame
    CGRect bounds = _photoScrollView.bounds;
    CGRect photoViewFrame = bounds;
    photoViewFrame.size.width -= (2 * kPadding);
    photoViewFrame.origin.x = (bounds.size.width * index) + kPadding;
    photoView.tag = kPhotoViewTagOffset + index;
    if (_photos.count) {
        
        XYPhoto *photo = _photos[index];
        photoView.frame = photoViewFrame;
        photoView.photo = photo;
        
        [_visiblePhotoViews addObject:photoView];
        [_photoScrollView addSubview:photoView];
        
    }
}

#pragma mark 循环利用某个view
- (XYBrowserPhotoView *)dequeueReusablePhotoView
{
    XYBrowserPhotoView *photoView = [_reusablePhotoViews anyObject];
    if (photoView) {
        [_reusablePhotoViews removeObject:photoView];
    }
    return photoView;
}

#pragma mark 更新toolbar状态
- (void)updateTollbarState
{
    _currentPhotoIndex = _photoScrollView.contentOffset.x / _photoScrollView.frame.size.width;
    _toolbar.currentPhotoIndex = _currentPhotoIndex;
}


#pragma mark - XYBrowserPhotoView代理
- (void)photoViewSingleTap:(XYBrowserPhotoView *)photoView
{
    [UIApplication sharedApplication].statusBarHidden = _statusBarHiddenInited;
    self.view.backgroundColor = [UIColor clearColor];
    
    // 移除工具条
    [_toolbar removeFromSuperview];
}

- (void)photoViewDidEndZoom:(XYBrowserPhotoView *)photoView
{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

- (void)photoViewImageFinishLoad:(XYBrowserPhotoView *)photoView
{
//    _toolbar.currentPhotoIndex = _currentPhotoIndex;
}
#pragma mark - UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self showPhotos];
    [self updateTollbarState];
}
@end
