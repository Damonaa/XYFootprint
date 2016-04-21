//
//  XYEventTextView.h
//  Footprint
//
//  Created by 李小亚 on 16/3/30.
//  Copyright © 2016年 李小亚. All rights reserved.
// 输入文本的UITextView

#import <UIKit/UIKit.h>

@interface XYEventTextView : UITextView
/**
 *  占位符
 */
@property (nonatomic, copy) NSString *placeholder;

/**
 *  是否隐藏占位符标签
 */
@property (nonatomic, assign) BOOL hidenPlaceHolder;

@end
