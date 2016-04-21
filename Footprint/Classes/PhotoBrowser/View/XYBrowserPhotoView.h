//
//  XYBrowserPhotoView.h
//  Footprint
//
//  Created by 李小亚 on 16/4/9.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XYPhotosBrowser, XYPhoto, XYBrowserPhotoView;

@protocol XYBrowserPhotoViewDelegate <NSObject>
- (void)photoViewImageFinishLoad:(XYBrowserPhotoView *)photoView;
- (void)photoViewSingleTap:(XYBrowserPhotoView *)photoView;
- (void)photoViewDidEndZoom:(XYBrowserPhotoView *)photoView;
@end


@interface XYBrowserPhotoView : UIScrollView <UIScrollViewDelegate>
// 图片
@property (nonatomic, strong) XYPhoto *photo;
// 代理
@property (nonatomic, weak) id<XYBrowserPhotoViewDelegate> photoViewDelegate;


@end
