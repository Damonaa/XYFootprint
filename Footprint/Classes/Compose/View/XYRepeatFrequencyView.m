//
//  XYRepeatFrequencyView.m
//  Footprint
//
//  Created by 李小亚 on 16/4/7.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import "XYRepeatFrequencyView.h"
#import "XYEvent.h"

@interface XYRepeatFrequencyView ()




/**
 *  存放分割线
 */
@property (nonatomic, strong) NSMutableArray *lines;



/**
 *  存放按钮的容器
 */
@property (nonatomic, weak) UIImageView *btnsView;
@end

@implementation XYRepeatFrequencyView


- (NSMutableArray *)btns{
    if (!_btns) {
        _btns = [NSMutableArray array];
    }
    return _btns;
}
- (NSMutableArray *)lines{
    if (!_lines) {
        _lines = [NSMutableArray array];
    }
    return _lines;
}
- (UIImageView *)btnsView{
    if (!_btnsView) {
        UIImageView *btnsView = [[UIImageView alloc] init];
        _btnsView = btnsView;
        btnsView.userInteractionEnabled = YES;
        [self addSubview:btnsView];
    }
    return _btnsView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        self.image = [UIImage stretchableImage:[UIImage imageNamed:@"timeline_card_bottom_background"]];
        //设置子控件， 三个按钮
        [self setupAllChildView];
        self.userInteractionEnabled = YES;
        self.btnsView.hidden = YES;
    }
    return self;
}

//设置子控件， 三个按钮
- (void)setupAllChildView{
    
    //2. 重复方法是按钮
    UIButton *repeatBtn = [UIButton toolButtonWithNormalImage:[UIImage imageNamed:@"repeat_normal"] hightlightImage:nil target:self selcetor:@selector(repeatBtnClick) controlEvent:UIControlEventTouchUpInside title:@"永不重复"];
    [self addSubview:repeatBtn];
    self.repeatBtn = repeatBtn;
   
    
    NSArray *frequency = @[@"永不",@"每天",@"周一到周五",@"每周",@"每月",@"每年"];
    //添加按钮
    for (NSInteger i = 0; i < frequency.count; i ++) {
        UIButton *btn = [UIButton buttonWithTarget:self selcetor:@selector(frequencyBtnClick:) controlEvent:UIControlEventTouchUpInside title:frequency[i]];
        btn.tag = i;
        [self.btnsView addSubview:btn];
        [self.btns addObject:btn];

        //默认选中第一个
//        if (i == 0) {
//            [self frequencyBtnClick:btn];
//        }
//
    }
    
    //添加分割线
    for (int i = 0; i < frequency.count - 1; i ++) {
        UIImageView *line = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"timeline_card_bottom_line"]];
        
        [self.lines addObject:line];
        [self.btnsView addSubview:line];
        
    }
}


//布局按钮的位置
- (void)layoutSubviews{
    [super layoutSubviews];
    //按钮的frame
    self.repeatBtn.x = 10;
    [self.repeatBtn sizeToFit];
    self.repeatBtn.width += 10;
    
    //按钮容器的frame
    self.btnsView.frame = CGRectMake(0, CGRectGetMaxY(_repeatBtn.frame), self.bounds.size.width, 35);
    
    NSInteger count = self.btns.count;
    CGFloat margin = 5;
    
    CGFloat btnW = (self.bounds.size.width - (margin * (count - 1))) / count - 5;
    CGFloat btnH = self.btnsView.bounds.size.height;
    CGFloat btnX = 0;
    CGFloat btnY = 0;
    //布局按钮的位置
    int i = 0;
    for (UIButton *btn in self.btns) {
        btnX = (btnW + margin) * i;
        btn.frame = CGRectMake(btnX, btnY, btnW, btnH);
        if (i == 2) {//第三个按钮宽度加30
            btn.width = btnW + 30;
        }
        
        if (i > 2) {//第4个以及后面的按钮 X轴+ 30
            btn.x = btnX + 30;
        }
        i ++;
    }
    //布局分割线的位置
    int j = 1;
    for (UIImageView *imageView in self.lines) {
        UIButton *btn = self.btns[j];
        imageView.x = btn.x - margin / 2;
        j ++;
    }

}

//处理按钮的点击
- (void)frequencyBtnClick:(UIButton *)button{
    //设置选中按钮的背景颜色
    self.selectedBtn.backgroundColor = [UIColor clearColor];
    button.backgroundColor = [UIColor orangeColor];
    self.selectedBtn = button;
    
    [self.repeatBtn setTitle:button.currentTitle forState:UIControlStateNormal];
    //隐藏选项视图
    if (_showOptionBlock) {
        _showOptionBlock(NO);
    }
    self.btnsView.hidden = YES;
    
    //设置频率
    if (_frequencyTagBlock) {
        _frequencyTagBlock(button.tag);

    }
}

//选择重复方式按钮的点击，隐藏或者显示重复方式
- (void)repeatBtnClick{
    //设置选中已经的按钮
    if (_selectedBtn) {
        [self frequencyBtnClick:_selectedBtn];
    }else{
        [self frequencyBtnClick:self.btns[0]];
    }
    
    if (_showOptionBlock) {
        _showOptionBlock(self.btnsView.hidden);
        
    }
    self.btnsView.hidden = !self.btnsView.hidden;
    
    //结束图片晃动的动画
    //发出通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"stopShake" object:nil];
}

@end
