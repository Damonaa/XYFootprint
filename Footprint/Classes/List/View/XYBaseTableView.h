//
//  XYBaseTableView.h
//  Footprint
//
//  Created by 李小亚 on 16/4/20.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XYSingleTag, XYEvent;

//@protocol XYBaseTableViewDelegate <NSObject>
//
//
//
//@end

typedef void(^TagEventBlock)(XYEvent *event);

@interface XYBaseTableView : UITableView

//@property (nonatomic, strong) XYSingleTag *singleTag;

@property (nonatomic, strong) NSMutableArray *events;

@property (nonatomic, copy) TagEventBlock tagEvent;

@end
