//
//  XYPhotosView.h
//  Weibo
//
//  Created by 李小亚 on 16/3/8.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XYPhotosViewDelegate <NSObject>

- (void)photosViewDeleteImageWithIndex:(NSInteger)index;

@end
@interface XYPhotosView : UIView

@property (nonatomic, weak) id<XYPhotosViewDelegate> delegate;

/**
 *  存放event模型中images中的图片路径
 */
@property (nonatomic, strong) NSArray *photoNames;


@end
