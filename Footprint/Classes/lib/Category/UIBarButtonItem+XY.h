//
//  UIBarButtonItem+XY.h
//  Footprint
//
//  Created by 李小亚 on 16/3/30.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (XY)
/**
 *  创建内部为UIbutton的UIBarButtonItem
 *
 *  @param normalImage     正常状态下的图片
 *  @param hightlightImage 高亮状态下的图片
 *  @param selector        响应方法
 *  @param event           响应方式
 *
 *  @return 内部为UIbutton的UIBarButtonItem
 */
+ (UIBarButtonItem *)barButtonItemWithNormalImage:(UIImage *)normalImage hightlightImage:(UIImage *)hightlightImage target:(id)target selcetor:(SEL)selector controlEvent:(UIControlEvents)event;
@end
