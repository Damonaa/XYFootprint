//
//  XYPhoto.h
//  XYLocalPhotoBrowser
//
//  Created by 李小亚 on 16/4/23.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XYPhoto : NSObject
/**
 *  图片的tag
 */
@property (nonatomic, assign) NSInteger index;
/**
 *  图片
 */
@property (nonatomic, strong) UIImage *image;

/**
 *  点击的图片
 */
@property (nonatomic, strong) UIImageView *srcImageView;


@end
