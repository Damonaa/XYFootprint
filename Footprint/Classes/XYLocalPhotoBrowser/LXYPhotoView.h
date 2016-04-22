//
//  XYPhotosView.h
//  XYLocalPhotoBrowser
//
//  Created by 李小亚 on 16/4/23.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XYPhoto, LXYPhotoView;

@protocol XYPhotosViewDelegate <NSObject>
@optional
- (void)photoViewImageFinishLoad:(LXYPhotoView *)photoView;
- (void)photoViewSingleTap:(LXYPhotoView *)photoView;


- (void)photoViewDidEndZoom:(LXYPhotoView *)photoView;
@end


@interface LXYPhotoView : UIScrollView

@property (nonatomic, strong) XYPhoto *photo;

// 代理
@property (nonatomic, weak) id<XYPhotosViewDelegate> photoViewDelegate;
@end
