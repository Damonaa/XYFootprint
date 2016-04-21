//
//  UIButton+XY.h
//  Footprint
//
//  Created by 李小亚 on 16/3/31.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (XY)
/**
 *  初始化创建按钮
 *  @param target          目标对象
 *  @param selector        方法
 *  @param event           响应方式
 *  @param title           按钮标题
 *
 *  @return 按钮
 */
+ (instancetype)buttonWithTarget:(id)target selcetor:(SEL)selector controlEvent:(UIControlEvents)event title:(NSString *)title;

/**
 *  初始化创建按钮
 *  @param target          目标对象
 *  @param selector        方法
 *  @param event           响应方式
 *  @param normalImage     正常状态下的图片
 *  @param hightlightImage 高亮图片
 *  @return 按钮
 */
+ (instancetype)buttonWithTarget:(id)target selcetor:(SEL)selector controlEvent:(UIControlEvents)event normalImage:(UIImage *)normalImage highlightedImage:(UIImage *)highlightedImage;
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
+ (instancetype)toolButtonWithNormalImage:(UIImage *)normalImage hightlightImage:(UIImage *)hightlightedImage target:(id)target selcetor:(SEL)selector controlEvent:(UIControlEvents)event title:(NSString *)title;


/**
 *  更改按钮图片
 *
 *  @param button      按钮
 *  @param normal      正常状态的按钮
 *  @param highlighted 高亮状态的按钮
 */
+ (void)changeButton:(UIButton *)button normalImage:(NSString *)normal highlighted:(NSString *)highlighted;
@end
