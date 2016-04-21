//
//  XYPhotoView.m
//  Weibo
//
//  Created by 李小亚 on 16/3/8.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import "XYPhotoView.h"


@interface XYPhotoView ()
@end

@implementation XYPhotoView

//设置imageView的属性，并添加一个GIF图片
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.clipsToBounds = YES;
        self.userInteractionEnabled = YES;
        
    }
    return self;
}
//设置imageView的图片
- (void)setPicName:(NSString *)picName{
    _picName = picName;
    NSString *picPath = [[XYFileTool sharedFileTool].imagesPath stringByAppendingPathComponent:picName];
    self.image = [UIImage imageWithContentsOfFile:picPath];
}



@end
