//
//  UIBarButtonItem+XY.m
//  Footprint
//
//  Created by 李小亚 on 16/3/30.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import "UIBarButtonItem+XY.h"

@implementation UIBarButtonItem (XY)

+ (UIBarButtonItem *)barButtonItemWithNormalImage:(UIImage *)normalImage hightlightImage:(UIImage *)hightlightImage target:(id)target selcetor:(SEL)selector controlEvent:(UIControlEvents)event{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:normalImage forState:UIControlStateNormal];
    [btn setImage:hightlightImage forState:UIControlStateHighlighted];
    
    [btn addTarget:target action:selector forControlEvents:event];
    [btn sizeToFit];
    return [[UIBarButtonItem alloc] initWithCustomView:btn];
}


@end
