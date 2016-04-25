//
//  XYNewFeatureCell.m
//  XYWeiBoThird
//
//  Created by 李小亚 on 16/4/25.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import "XYNewFeatureCell.h"
#import "XYMainViewController.h"
#import "XYMainNavigationController.h"

@interface XYNewFeatureCell ()
/**
 *  开始按钮
 */
@property (nonatomic, weak) UIButton *startBtn;

/**
 *  展示图片
 */
@property (nonatomic, weak) UIImageView *imageView;
@end

@implementation XYNewFeatureCell

#pragma mark - 懒加载

- (UIButton *)startBtn{
    if (!_startBtn) {
        UIButton *startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.startBtn = startBtn;
        [self.contentView addSubview:startBtn];
        [startBtn setBackgroundImage:[UIImage imageNamed:@"new_feature_finish_button"] forState:UIControlStateNormal];
        [startBtn setBackgroundImage:[UIImage imageNamed:@"new_feature_finish_button_highlighted"] forState:UIControlStateHighlighted];
        [startBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [startBtn setTitle:@"开启计划的生活" forState:UIControlStateNormal];
        [startBtn addTarget:self action:@selector(startBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [startBtn sizeToFit];
    }
    return _startBtn;
}

- (UIImageView *)imageView{
    if (!_imageView) {
        UIImageView *imageView = [[UIImageView alloc] init];
        self.imageView = imageView;
        [self.contentView addSubview:imageView];
    }
    return _imageView;
}

- (void)setImage:(UIImage *)image{
    _image = image;
    self.imageView.image = image;
}
//布局按钮的位置
- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.imageView.frame = self.bounds;
    self.startBtn.center = CGPointMake(XYScreenWidth / 2, XYScreenHeight * 0.87);
}

- (void)setIndexPath:(NSIndexPath *)indexPath count:(NSInteger)count{
    if (indexPath.row == count - 1) {
        self.startBtn.hidden = NO;
    }else{
        self.startBtn.hidden = YES;
    }
}

- (void)shareBtnClick:(UIButton *)btn{
    btn.selected = !btn.selected;
}

//切换根控制器
- (void)startBtnClick{
    XYMainViewController *mainVc = [[XYMainViewController alloc] init];
    XYMainNavigationController *mainNav = [[XYMainNavigationController alloc] initWithRootViewController:mainVc];
    XYKeyWindow.rootViewController = mainNav;
}
@end
