//
//  UIButton+XY.m
//  Footprint
//
//  Created by 李小亚 on 16/3/31.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import "UIButton+XY.h"

@implementation UIButton (XY)

/**
 *  初始化创建按钮
 *  @param target          目标对象
 *  @param selector        方法
 *  @param event           响应方式
 *  @param title           按钮标题
 *
 *  @return 按钮
 */
+ (instancetype)buttonWithTarget:(id)target selcetor:(SEL)selector controlEvent:(UIControlEvents)event title:(NSString *)title{
    
    
    UIButton *btn = [self buttonWithType:UIButtonTypeCustom];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

    btn.titleLabel.font = [UIFont systemFontOfSize:12];
    btn.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [btn addTarget:target action:selector forControlEvents:event];
    
    return btn;
    
}

/**
 *  初始化创建按钮
 *
 *  @param normalImage     正常状态下的图片
 *  @param hightlightImage 高亮图片
 *  @param target          目标对象
 *  @param selector        方法
 *  @param event           响应方式
 *  @param title           按钮标题
 *
 *  @return 按钮
 */
+ (instancetype)toolButtonWithNormalImage:(UIImage *)normalImage hightlightImage:(UIImage *)hightlightedImage target:(id)target selcetor:(SEL)selector controlEvent:(UIControlEvents)event title:(NSString *)title{
    
    
    UIButton *btn = [self buttonWithType:UIButtonTypeCustom];
    
//    btn.backgroundColor = [UIColor magentaColor];
    
    [btn setImage:hightlightedImage forState:UIControlStateHighlighted];
    [btn setImage:normalImage forState:UIControlStateNormal];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    btn.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    btn.width += 10;
    
    [btn addTarget:target action:selector forControlEvents:event];
//    [btn sizeToFit];
    
    return btn;
    
}

/**
 *  初始化创建按钮
 *  @param target          目标对象
 *  @param selector        方法
 *  @param event           响应方式
 *  @param normalImage     正常状态下的图片
 *  @param hightlightImage 高亮图片
 *  @return 按钮
 */
+ (instancetype)buttonWithTarget:(id)target selcetor:(SEL)selector controlEvent:(UIControlEvents)event normalImage:(UIImage *)normalImage highlightedImage:(UIImage *)highlightedImage{
    UIButton *btn = [self buttonWithType:UIButtonTypeCustom];
    
    [btn setImage:highlightedImage forState:UIControlStateHighlighted];
    [btn setImage:normalImage forState:UIControlStateNormal];
    [btn addTarget:target action:selector forControlEvents:event];
    return btn;
}

/**
 *  更改按钮图片
 *
 *  @param button      按钮
 *  @param normal      正常状态的按钮
 *  @param highlighted 高亮状态的按钮
 */
+ (void)changeButton:(UIButton *)button normalImage:(NSString *)normal highlighted:(NSString *)highlighted{
    [button setImage:[UIImage imageNamed:normal] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:highlighted] forState:UIControlStateHighlighted];
    
}
@end
