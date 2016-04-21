//
//  XYMoveButton.m
//  Footprint
//
//  Created by 李小亚 on 16/4/15.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import "XYMoveButton.h"

@implementation XYMoveButton
+ (instancetype)moveButton{
    XYMoveButton *addBtn = [XYMoveButton buttonWithType:UIButtonTypeCustom ];
    
    [addBtn setImage:[UIImage imageNamed:@"write_normal"] forState:UIControlStateNormal];
    [addBtn sizeToFit];
//    addBtn.x = (XYScreenWidth - addBtn.width) / 2;
//    addBtn.y = XYScreenHeight - addBtn.height;
    
    addBtn.layer.cornerRadius = 10;
    addBtn.layer.masksToBounds = YES;
    addBtn.layer.anchorPoint = CGPointMake(0.5, 0.5);
    addBtn.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.296];
    
    return addBtn;
}
@end
