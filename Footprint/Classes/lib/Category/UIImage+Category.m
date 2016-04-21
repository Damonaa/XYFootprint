//
//  UIImage+Category.m
//  Weibo
//
//  Created by 李小亚 on 16/3/1.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import "UIImage+Category.h"

@implementation UIImage (Category)

+ (UIImage *)imageWithOringinal:(UIImage *)image{
    return [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}


+ (UIImage *)stretchableImage:(UIImage *)image{
    return [image stretchableImageWithLeftCapWidth:image.size.width * 0.5 topCapHeight:image.size.height * 0.5];
}
@end
