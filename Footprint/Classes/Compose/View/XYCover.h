//
//  Cover.h
//  Weibo
//
//  Created by 李小亚 on 16/3/2.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XYCover;
@protocol XYCoverDelegate <NSObject>

@optional

- (void)coverDidClickCover:(XYCover *)cover;

@end

@interface XYCover : UIView

@property (nonatomic, weak) id<XYCoverDelegate> delegate;

/**
 *  设置浅灰色的蒙板
 */
//@property (nonatomic, assign) BOOL dimBackground;

/**
 *  显示蒙板
 */
+ (instancetype)show;
//移除
- (void)hiddenCover;

@end
