//
//  XYCellPhotosView.m
//  Footprint
//
//  Created by 李小亚 on 16/4/14.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import "XYCellPhotosView.h"
#import "XYPhotoView.h"
#import "XYPhoto.h"
#import "XYPhotosBrowser.h"

@interface  XYCellPhotosView()
/**
 *  存放4个 XYPhotoImageView
 */
@property (nonatomic, strong) NSMutableArray *imageViews;
@end

@implementation XYCellPhotosView

- (NSMutableArray *)imageViews{
    if (!_imageViews) {
        _imageViews = [NSMutableArray array];
    }
    return _imageViews;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        for (int i = 0; i < 4; i ++) {
            XYPhotoView *imageView = [[XYPhotoView alloc] init];
            imageView.tag = i;
            [self addSubview:imageView];
            [self.imageViews addObject:imageView];
            imageView.userInteractionEnabled = YES;
            imageView.image = [UIImage imageNamed:@"clock_bg"];
            
            //添加点击手势，查看大图
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageView:)];
            [imageView addGestureRecognizer:tap];
        }
//        XYLog(@"%@", self.photosPath);
    }
    return self;
}
//查看大图
- (void)tapImageView:(UITapGestureRecognizer *)gesture{
    
    UIImageView *tapView = (UIImageView *)gesture.view;
    
    NSMutableArray *photoArray = [NSMutableArray array];
    int i = 0;
    for (NSString *photoName in self.photosPath) {
        XYPhoto *photo = [[XYPhoto alloc] init];
        photo.photoName = photoName;
        photo.index = i;
        [photoArray addObject:photo];
        i ++;
    }
    
    //        弹出图片浏览器
    XYPhotosBrowser *browser = [[XYPhotosBrowser alloc] init];
    browser.photos = photoArray;
    browser.currentPhotoIndex = tapView.tag;
    [browser show];

    
}
//设置图片的path
- (void)setPhotosPath:(NSArray *)photosPath{
    _photosPath = photosPath;
    for (int i = 0; i < photosPath.count; i ++) {
        XYPhotoView *iv = self.imageViews[i];
        iv.picName = self.photosPath[i];
        
    }
}
//布局imagview
- (void)layoutSubviews{
    [super layoutSubviews];
    NSInteger count = self.photosPath.count;
    
    NSInteger colume = count > 1 ? 2 : 1;
    
    CGFloat imageHW = (XYScreenWidth - 45 - 50) / 2;
    for (int i = 0 ; i < 4; i++) {
        UIImageView *iv = self.imageViews[i];
        
        if (i < count) {
            iv.hidden = NO;
            int row = i / colume;
            int currentColumn = i % colume;
            CGFloat imageX = (imageHW + 10) * currentColumn;
            CGFloat imageY = (imageHW + 10) * row;
            iv.frame = CGRectMake(imageX, imageY, imageHW, imageHW);
            
        }else{//隐藏
            iv.hidden = YES;
        }
    }
}

@end
