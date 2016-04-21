//
//  XYMapViewController.h
//  Footprint
//
//  Created by 李小亚 on 16/4/12.
//  Copyright © 2016年 李小亚. All rights reserved.
// e737da7e930e0986fb06a4830ce9a07e

#import <UIKit/UIKit.h>


typedef void(^RegionBlock)(CLRegion *remindRegion, NSString *completnAddress);

@interface XYMapViewController : UIViewController


@property (nonatomic, copy) RegionBlock remindRegion;

/**
 *  接受上一个控制器传来的值
 */
@property (nonatomic, strong) CLRegion *completeRegion;

@end
