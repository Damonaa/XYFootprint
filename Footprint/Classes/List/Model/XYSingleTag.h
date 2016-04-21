//
//  XYSingleTag.h
//  Footprint
//
//  Created by 李小亚 on 16/4/18.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XYSingleTag : NSObject

/**
 *  tag的名称
 */
@property (nonatomic, copy) NSString *tagName;
/**
 *  该组tag的事件 (XYEvent)
 */
@property (nonatomic, strong) NSMutableArray *tagEvents;

@end
