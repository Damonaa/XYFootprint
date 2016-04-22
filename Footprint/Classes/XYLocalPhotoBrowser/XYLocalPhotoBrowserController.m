//
//  XYLocalPhotoBrowserController.m
//  XYLocalPhotoBrowser
//
//  Created by 李小亚 on 16/4/23.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import "XYLocalPhotoBrowserController.h"
#import "XYPhotosToolBar.h"
#import "LXYPhotoView.h"

#define kPadding 10
#define kPhotoViewTagOffset 1000
#define kPhotoViewIndex(photoView) ([photoView tag] - kPhotoViewTagOffset)

@interface XYLocalPhotoBrowserController ()<UIScrollViewDelegate, XYPhotosViewDelegate>
/**
 *  工具条，显示index
 */
@property (nonatomic, weak) XYPhotosToolBar *toolbar;
/**
 * 存放展示全部的图片
 */
@property (nonatomic, weak) UIScrollView *photoScrollView;
/**
 *  当前可见的图片
 */
@property (nonatomic, strong) NSMutableSet *visiblePhotoViews;
/**
 *  重用的图片
 */
@property (nonatomic, strong) NSMutableSet *reusablePhotoViews;
@end

@implementation XYLocalPhotoBrowserController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
 
    //初始化控制器背景为黑色
    self.view = [[UIView alloc] init];
    self.view.frame = [UIScreen mainScreen].bounds;
    self.view.backgroundColor = [UIColor blackColor];
    // 1.创建UIScrollView
    [self createScrollView];
    
    // 2.创建工具条
    [self createToolbar];
}
// 隐藏状态栏
- (BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)show
{
    //将控制器添加到keyWindow上
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self.view];
    [window.rootViewController addChildViewController:self];
    
    
//    [self showPhotoViewAtIndex:_currentPhotoIndex];
    if (_currentPhotoIndex == 0) {
        [self showPhotos];
    }
}


#pragma mark 创建UIScrollView
- (void)createScrollView{
    CGRect frame = self.view.bounds;
    frame.origin.x -= kPadding;
    frame.size.width += (2 * kPadding);
    //frame比当前的View大kPadding * 2，并且向左偏移kPadding
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


#pragma mark 创建工具条
- (void)createToolbar{
    CGFloat barHeight = 44;
    CGFloat barY = self.view.frame.size.height - barHeight;
    XYPhotosToolBar *toolbar = [[XYPhotosToolBar alloc] init];
    self.toolbar = toolbar;
    toolbar.frame = CGRectMake(0, barY, self.view.frame.size.width, barHeight);
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    toolbar.photos = _photos;//初始化显示index的标签
    [self.view addSubview:_toolbar];
    //刷新index的变化
    [self updateTollbarState];
}

#pragma mark 更新toolbar状态
- (void)updateTollbarState{
    _currentPhotoIndex = _photoScrollView.contentOffset.x / _photoScrollView.frame.size.width;
    _toolbar.currentPhotoIndex = _currentPhotoIndex;
}

#pragma mark - setter方法
- (void)setPhotos:(NSArray *)photos{
    _photos = photos;
    
    //如果图片数量大于1，则重用图片
    if (photos.count > 1) {
        _visiblePhotoViews = [NSMutableSet set];
        _reusablePhotoViews = [NSMutableSet set];
    }

}
//根据index设置scrollView的offset
- (void)setCurrentPhotoIndex:(NSUInteger)currentPhotoIndex{
    _currentPhotoIndex = currentPhotoIndex;
    //根据当前的点击的图片的index，决定偏移量
    if ([self isViewLoaded]) {
        _photoScrollView.contentOffset = CGPointMake(_currentPhotoIndex * _photoScrollView.frame.size.width, 0);
        
        // 显示所有的相片
        [self showPhotos];
    }
    
}
#pragma mark 显示照片
- (void)showPhotos
{
    // 只有一张图片
    if (_photos.count == 1) {
        [self showPhotoViewAtIndex:0];
        return;
    }
    
    CGRect visibleBounds = _photoScrollView.bounds;
    NSInteger firstIndex = (NSInteger)floorf((CGRectGetMinX(visibleBounds)+ kPadding * 2) / CGRectGetWidth(visibleBounds));
    NSInteger lastIndex  = (NSInteger)floorf((CGRectGetMaxX(visibleBounds)- kPadding * 2 - 1) / CGRectGetWidth(visibleBounds));
    //计算切换index
    if (firstIndex < 0) firstIndex = 0;
    if (firstIndex >= _photos.count) firstIndex = _photos.count - 1;
    if (lastIndex < 0) lastIndex = 0;
    if (lastIndex >= _photos.count) lastIndex = _photos.count - 1;
    

  
    // 回收不再显示的ImageView
    NSInteger photoViewIndex;
    for (LXYPhotoView *photoView in _visiblePhotoViews) {
        
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

#pragma mark 显示一个图片view
- (void)showPhotoViewAtIndex:(NSInteger)index
{
    LXYPhotoView *photoView = [self dequeueReusablePhotoView];
    if (!photoView) { // 添加新的图片view
        photoView = [[LXYPhotoView alloc] init];
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

#pragma mark index这页是否正在显示
- (BOOL)isShowingPhotoViewAtIndex:(NSUInteger)index {
    for (LXYPhotoView *photoView in _visiblePhotoViews) {
        if (kPhotoViewIndex(photoView) == index) {
            return YES;
        }
    }
    return  NO;
}

#pragma mark 循环利用某个view
- (LXYPhotoView *)dequeueReusablePhotoView
{
    LXYPhotoView *photoView = [_reusablePhotoViews anyObject];
    if (photoView) {
        [_reusablePhotoViews removeObject:photoView];
    }
    return photoView;
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self showPhotos];
    [self updateTollbarState];
}

#pragma mark - MJPhotoView代理
- (void)photoViewSingleTap:(LXYPhotoView *)photoView{
    
//    [UIApplication sharedApplication].statusBarHidden = _statusBarHiddenInited;
    self.view.backgroundColor = [UIColor clearColor];
    
    // 移除工具条
    [_toolbar removeFromSuperview];
}

- (void)photoViewDidEndZoom:(LXYPhotoView *)photoView
{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

//- (void)photoViewImageFinishLoad:(XYPhotosView *)photoView
//{
//    _toolbar.currentPhotoIndex = _currentPhotoIndex;
//}

@end
