//
//  XYComposeController.h
//  Footprint
//
//  Created by 李小亚 on 16/3/30.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XYEvent;

@interface XYComposeController : UIViewController

/**
 *  创建的事件模型
 */
@property (nonatomic, strong) XYEvent *event;
/**
 *  修改事件，默认是NO，若是从MainVC跳转进去的则修改 YES
 */
@property (nonatomic, assign, getter=isModifyEvent) BOOL modifyEvent;


@end
