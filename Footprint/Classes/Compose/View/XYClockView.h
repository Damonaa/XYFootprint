//
//  ClockView.h
//  Thread&NetTest
//
//  Created by 李小亚 on 2/13/16.
//  Copyright © 2016 李小亚. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^HourBlock)(NSInteger hourInt);

typedef void(^MinuteBlock)(NSInteger minuteInt);

@interface XYClockView : UIView


@property (nonatomic, copy) HourBlock hourChange;

@property (nonatomic, copy) MinuteBlock minuteChange;
@end
