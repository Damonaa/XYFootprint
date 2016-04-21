//
//  XYRepeatFrequencyView.h
//  Footprint
//
//  Created by 李小亚 on 16/4/7.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void(^RepeatBlock)(BOOL showOption);
typedef void(^FrequencyBlock)(NSInteger tag);


@interface XYRepeatFrequencyView : UIImageView

/**
 *  显示或者隐藏频率选项视图block
 */
@property (nonatomic, copy) RepeatBlock showOptionBlock;

/**
 *  设置频率Block
 */
@property (nonatomic, copy) FrequencyBlock frequencyTagBlock;
/**
 *  存放按钮
 */
@property (nonatomic, strong) NSMutableArray *btns;
/**
 *  显示重复方式， 默认为永不提醒
 */
@property (nonatomic, weak) UIButton *repeatBtn;
/**
 * 被选中的按钮
 */
@property (nonatomic, weak) UIButton *selectedBtn;

@end
