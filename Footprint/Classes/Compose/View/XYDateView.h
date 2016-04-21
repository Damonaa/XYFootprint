//
//  XYDateView.h
//  Footprint
//
//  Created by 李小亚 on 16/4/5.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^DateChooseBlock)(NSString *dateStr);

@interface XYDateView : UIView


@property (nonatomic, copy) DateChooseBlock complete;




@end
