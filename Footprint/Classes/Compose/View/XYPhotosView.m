//
//  XYPhotosView.m
//  Weibo
//
//  Created by 李小亚 on 16/3/8.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import "XYPhotosView.h"
#import "XYPhotoView.h"
#import "XYLocalPhotoBrowserController.h"
#import "XYPhoto.h"
#import "XYFileTool.h"

@interface XYPhotosView ()

/**
 *  存放全部的 imageview
 */
@property (nonatomic, strong) NSMutableArray *photoViews;
/**
 *  存放全部删除按钮
 */
@property (nonatomic, strong) NSMutableArray *delBtns;

@end

@implementation XYPhotosView

- (NSMutableArray *)delBtns{
    if (!_delBtns) {
        _delBtns = [NSMutableArray array];
    }
    return _delBtns;
}
- (NSMutableArray *)photoViews{
    if (!_photoViews) {
        _photoViews = [NSMutableArray array];
    }
    return _photoViews;
}
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {

        [self setupAllChildView];
        //注册通知, 停止动画
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopShake) name:@"stopShake" object:nil];
        
    }
    return self;
}

#pragma mark - 添加image View
- (void)setupAllChildView{
    
    for (int i = 0; i < 4; i ++) {
        XYPhotoView *imageView = [[XYPhotoView alloc] init];
        imageView.tag = i;
        imageView.userInteractionEnabled = YES;
        

        // 添加手势，跳转到图片浏览器
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTap:)];
        [imageView addGestureRecognizer:tap];
        imageView.layer.cornerRadius = 3;
        imageView.layer.masksToBounds = YES;

        //长按 删除图片
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(imageLongPress:)];
        [imageView addGestureRecognizer:longPress];
        
        [self addSubview:imageView];
        [self.photoViews addObject:imageView];
        
        
        //右上角添加一个按钮，删除图片,默认隐藏
        UIButton *delBtn = [UIButton buttonWithTarget:self selcetor:@selector(deleteImage:) controlEvent:UIControlEventTouchUpInside normalImage:[UIImage imageNamed:@"delete"] highlightedImage:nil];
        delBtn.hidden = YES;
        
        delBtn.tag = imageView.tag;
        delBtn.layer.cornerRadius = 7.5;
        delBtn.layer.masksToBounds = YES;
        [imageView addSubview:delBtn];
        [self.delBtns addObject:delBtn];
        
    }
    
}
#pragma mark - 点击图片，跳转到图片浏览器
- (void)imageTap:(UITapGestureRecognizer *)gesture{
    
    UIImageView *tapView = (UIImageView *)gesture.view;
    
    NSMutableArray *photoArray = [NSMutableArray array];
    int i = 0;
    for (NSString *photoName in self.photoNames) {
        XYPhoto *photo = [[XYPhoto alloc] init];
        
        NSString *imagePath = [[XYFileTool sharedFileTool].imagesPath stringByAppendingPathComponent:photoName];
        photo.image = [UIImage imageWithContentsOfFile:imagePath];
//        photo.photoName = photoName;
        photo.index = i;
        photo.srcImageView = tapView;
        [photoArray addObject:photo];
        i ++;
    }
    
    //        弹出图片浏览器
    //        弹出图片浏览器
    XYLocalPhotoBrowserController *localBC = [[XYLocalPhotoBrowserController alloc] init];
    localBC.photos = photoArray;
    localBC.currentPhotoIndex = tapView.tag;
    [localBC show];
}
#pragma mark - 长按 删除图片
- (void)imageLongPress:(UILongPressGestureRecognizer *)gesture{
    //添加动画，图片摇晃
    for (int i = 0; i < self.photoNames.count; i ++) {
        CAKeyframeAnimation *shakeAnimation = [CAKeyframeAnimation animation];
        shakeAnimation.keyPath = @"transform.rotation";
        CGFloat angle = M_PI_4 * 0.07;
        shakeAnimation.values = @[@(-angle), @(angle), @(-angle)];
        shakeAnimation.duration = 1;
        shakeAnimation.repeatCount = MAXFLOAT;
        
        UIImageView *imageView = self.photoViews[i];
        [imageView.layer addAnimation:shakeAnimation forKey:@"shake"];
        
        UIButton *delBtn = self.delBtns[i];
        delBtn.hidden = NO;
        //删除按钮
        delBtn.width = 15;
        delBtn.height = 15;
        delBtn.x = CGRectGetWidth(imageView.frame) - delBtn.width;
        delBtn.y = 0;

    }
}
#pragma mark - 删除图片
- (void)deleteImage:(UIButton *)btn{
//    XYLog(@"%ld", btn.tag);
    //删除存入沙盒的图片，音频
//    BOOL remove = [[NSFileManager defaultManager] removeItemAtPath:_photoNames[btn.tag] error:NULL];
//    if (remove) {
//        XYLog(@"remove success");
//    }
//    
    [[XYFileTool sharedFileTool] removeImageWithName:_photoNames[btn.tag]];
    
    if ([self.delegate respondsToSelector:@selector(photosViewDeleteImageWithIndex:)]) {
        [self.delegate photosViewDeleteImageWithIndex:btn.tag];
    }
    //移除动画
    
}
#pragma mark - 移除动画
- (void)stopShake{
    for (UIImageView *imageView in _photoViews) {
        [imageView.layer removeAnimationForKey:@"shake"];
    }
    //隐藏删除按钮
    for (UIButton *btn in _delBtns) {
        btn.hidden = YES;
    }
}
#pragma mark - 布局imageView,共一行，三张图片
- (void)layoutSubviews{
    [super layoutSubviews];

    NSInteger count = self.photoNames.count;

    CGFloat pictureMargin = 10;
    
    CGFloat imageWH = XYImageWidthHeight;
//布局图片和删除按钮的位置
    for (int i = 0 ; i < 4; i ++) {
        UIImageView *imageView = self.photoViews[i];
        if (i < count) {
            //图片
            imageView.hidden = NO;
            CGFloat imageX = (imageWH + pictureMargin) * i;
            CGFloat imageY = 0;
            imageView.frame = CGRectMake(imageX, imageY, imageWH, imageWH);     
        }else{
            imageView.hidden = YES;
        }
    }

}

//传递图片路径
- (void)setPhotoNames:(NSArray *)photoNames{
    _photoNames = photoNames;
    
    for (NSInteger i = 0; i < photoNames.count; i++) {
        XYPhotoView *photo = self.photoViews[i];
//        photo.picPath = photosPath[i];
        photo.picName = photoNames[i];
    }
    
}

- (void)dealloc{
    XYLog(@"图片视图销毁");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
