//
//  XYWaveView.h
//  Footprint
//
//  Created by 李小亚 on 16/4/10.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XYWaveView : UIView
/**
 *  根据lavel,重画波浪线
 *
 *  @param level 音量
 */
- (void)updateWithLevel:(CGFloat)level;

@end
