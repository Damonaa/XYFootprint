//
//  XYCalenderView.h
//  Footprint
//
//  Created by 李小亚 on 16/4/1.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CalenderBlock)(NSString *selectedTime);

@interface XYCalenderView : UIView


/**
 *  选中时间日期传值出去
 */
@property (nonatomic, copy) CalenderBlock complete;
+ (instancetype)showCalender;

- (void)hiddenCalender;

@end
