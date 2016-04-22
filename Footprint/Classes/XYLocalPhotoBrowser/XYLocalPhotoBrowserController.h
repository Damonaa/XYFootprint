//
//  XYLocalPhotoBrowserController.h
//  XYLocalPhotoBrowser
//
//  Created by 李小亚 on 16/4/23.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XYLocalPhotoBrowserController : UIViewController

/**
 *  所有的图片对象(MJPhoto)
 */
@property (nonatomic, strong) NSArray *photos;
//
/**
 *  当前展示的图片索引
 */
@property (nonatomic, assign) NSUInteger currentPhotoIndex;


/**
 *  显示
 */
- (void)show;


@end
