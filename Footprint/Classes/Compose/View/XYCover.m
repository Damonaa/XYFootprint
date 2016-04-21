//
//  Cover.m
//  Weibo
//
//  Created by 李小亚 on 16/3/2.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import "XYCover.h"

@implementation XYCover

//- (void)setDimBackground:(BOOL)dimBackground{
//    _dimBackground = dimBackground;
//    if (dimBackground) {
//        self.backgroundColor = [UIColor blackColor];
//        self.alpha = 0.5;
//    }else{
//        self.alpha = 1;
//        self.backgroundColor = [UIColor clearColor];
//    }
//}
/**
 *  显示蒙板
 */
+ (instancetype)show{
    XYCover *cover = [[XYCover alloc] initWithFrame:[UIScreen mainScreen].bounds];
    cover.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.315];
    
    [XYKeyWindow.rootViewController.view addSubview:cover];
    return cover;
}
//点击蒙板，移除
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self hiddenCover];
    
    if ([self.delegate respondsToSelector:@selector(coverDidClickCover:)]) {
        [self.delegate coverDidClickCover:self];
    }
}
//移除
- (void)hiddenCover{
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
      [self removeFromSuperview];
    }];
}
- (void)dealloc{
    XYLog(@"销毁");
}
@end
