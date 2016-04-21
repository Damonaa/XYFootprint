//
//  XYPhotosBrowser.h
//  Footprint
//
//  Created by 李小亚 on 16/4/9.
//  Copyright © 2016年 李小亚. All rights reserved.
//对MJPhotoBrowser框架的改造，仅仅用于本地图片的浏览，不能从网上获取图片

#import <UIKit/UIKit.h>

@interface XYPhotosBrowser : UIViewController<UIScrollViewDelegate>
// 所有的图片对象(XYPhoto)
@property (nonatomic, strong) NSArray *photos;
// 当前展示的图片索引
@property (nonatomic, assign) NSUInteger currentPhotoIndex;

// 显示
- (void)show;

@end
