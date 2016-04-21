//
//  UIImage+Category.h
//  Weibo
//
//  Created by 李小亚 on 16/3/1.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Category)
/**
 *  显示原本的图片，不渲染
 */
+ (UIImage *)imageWithOringinal:(UIImage *)image;

/**
 *  拉伸图片
 */
+ (UIImage *)stretchableImage:(UIImage *)image;
@end
