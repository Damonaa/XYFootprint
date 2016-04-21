//
//  XYBrowserPhotoView.m
//  Footprint
//
//  Created by 李小亚 on 16/4/9.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import "XYBrowserPhotoView.h"
#import "XYPhoto.h"

@interface XYBrowserPhotoView ()
@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, assign) BOOL doubleTap;

@end

@implementation XYBrowserPhotoView

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        self.clipsToBounds = YES;
        // 图片
        UIImageView *imageView = [[UIImageView alloc] init];
        self.imageView = imageView;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_imageView];
        self.backgroundColor = [UIColor whiteColor];
        
        // 属性
        self.backgroundColor = [UIColor clearColor];
        self.delegate = self;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        // 监听点击
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        singleTap.delaysTouchesBegan = YES;
        singleTap.numberOfTapsRequired = 1;
        [self addGestureRecognizer:singleTap];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTap];
    }
    return self;
}

#pragma mark - photoSetter显示图片
- (void)setPhoto:(XYPhoto *)photo {
    _photo = photo;
    NSString *name = [[XYFileTool sharedFileTool].imagesPath  stringByAppendingPathComponent:photo.photoName];
    
    self.imageView.image = [UIImage imageWithContentsOfFile:name];

    self.scrollEnabled = YES;
    [self adjustFrame];

}
#pragma mark 调整frame
- (void)adjustFrame
{
    if (_imageView.image == nil) return;
    
    // 基本尺寸参数
    CGSize boundsSize = self.bounds.size;
    CGFloat boundsWidth = boundsSize.width;
    CGFloat boundsHeight = boundsSize.height;
    
    CGSize imageSize = _imageView.image.size;
    CGFloat imageWidth = imageSize.width;
    CGFloat imageHeight = imageSize.height;
    
    // 设置伸缩比例
    self.maximumZoomScale = 2;
    self.minimumZoomScale = 0.5;
    self.zoomScale = 1;
    
    CGRect imageFrame = CGRectMake(0, 0, boundsWidth, imageHeight * boundsWidth / imageWidth);
    // 内容尺寸

    self.contentSize = CGSizeMake(boundsWidth, imageFrame.size.height);
    
    // y值
    if (imageFrame.size.height < boundsHeight) {//小于屏幕 居中
        imageFrame.origin.y = floorf((boundsHeight - imageFrame.size.height) / 2.0);
    } else {//大于屏幕高，左上角开始
        imageFrame.origin.y = 0;
    }
     _imageView.frame = imageFrame;

}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {

    return _imageView;
}
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    
    if (_imageView.width > self.width) {
        _imageView.x = 0;
    }else{
        _imageView.x = (self.width - _imageView.width) / 2;
//        _imageView.center = self.center;
    }
        
        
    if (_imageView.height > self.height) {
        _imageView.y = 0;
    }else{
        _imageView.y = (self.height - _imageView.height) / 2;
    }
}
#pragma mark - 手势处理
- (void)handleSingleTap:(UITapGestureRecognizer *)tap {
    _doubleTap = NO;
    [self performSelector:@selector(hide) withObject:nil afterDelay:0.2];
}
- (void)hide
{
    if (_doubleTap) return;

    
    [UIView animateWithDuration:0.3 animations:^{
        self.contentOffset = CGPointZero;
        // gif图片仅显示第0张
        if (_imageView.image.images) {
            _imageView.image = _imageView.image.images[0];
        }
        
//        _imageView.alpha = 0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            // 通知代理
            if ([self.photoViewDelegate respondsToSelector:@selector(photoViewSingleTap:)]) {
                [self.photoViewDelegate photoViewSingleTap:self];
            }
        } completion:^(BOOL finished) {
            // 通知代理
            if ([self.photoViewDelegate respondsToSelector:@selector(photoViewDidEndZoom:)]) {
                [self.photoViewDelegate photoViewDidEndZoom:self];
            }
        }];
        
        
    }];
}

- (void)reset
{
    _imageView.contentMode = UIViewContentModeScaleToFill;
}
//双击缩放
- (void)handleDoubleTap:(UITapGestureRecognizer *)tap {
    _doubleTap = YES;
    
    if (self.zoomScale != 1) {
        [self setZoomScale:1.0 animated:YES];
    } else {
        [self setZoomScale:self.maximumZoomScale animated:YES];
    }
}

- (void)dealloc
{
    XYLog(@"销毁咯哟");
}
@end
