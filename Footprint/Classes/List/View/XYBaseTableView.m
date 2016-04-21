//
//  XYBaseTableView.m
//  Footprint
//
//  Created by 李小亚 on 16/4/20.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import "XYBaseTableView.h"
#import "XYSingleTag.h"
#import "XYSimpleEventCell.h"
#import "XYEvent.h"
#import "XYSqliteTool.h"
#import "XYMainNavigationController.h"

@interface XYBaseTableView ()<UITableViewDelegate, UITableViewDataSource, XYSimpleEventCellDelegate>

@end

@implementation XYBaseTableView

- (NSMutableArray *)events{
    if (!_events) {
        _events = [NSMutableArray array];
    }
    return _events;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.dataSource = self;
        self.delegate = self;
    }
    return self;
}



#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _events.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    XYSimpleEventCell *cell = [XYSimpleEventCell simpleEventCellWithTableView:tableView];
    cell.event = self.events[indexPath.row];
    cell.delegate = self;
    return cell;
}
#pragma mark - UITableViewDelegate
//点击进去事件编辑修改界面， 如果事件event.completeEvent == YES, 修改
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    XYEvent *event = self.events[indexPath.row];
    if (_tagEvent) {
        _tagEvent(event);
//        _tagEvent = nil;
    }
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewRowAction *delAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"拜" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        //从数据库中移除此事件
        XYEvent *event = self.events[indexPath.row];
        //删除数据库中对应的一条数据
        NSString *sql = [NSString stringWithFormat:@"delete from  t_event where notiKey = %@", event.notiKey];
        //
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [XYSqliteTool executeUpdate:sql];
            //删除本地所保存的图片
            if (event.images.count > 0) {
                for (NSString *imageName in event.images) {
                    [[XYFileTool sharedFileTool] removeImageWithName:imageName];
                }
            }
            //删除本地所保存的音频
            if (event.audioDuration > 0) {
                [[XYFileTool sharedFileTool] removeAudioWithName:event.audioName];
            }
        });
        //先删除内存中的数据
        [self.events removeObjectAtIndex:indexPath.row];
        //刷新表格
        [self reloadData];
        
        //取消通知
        [[XYFileTool sharedFileTool] cancelLocalNotiWithKey:event.notiKey];
        
        //主界面需要刷新数据, TagView监听
        [[NSNotificationCenter defaultCenter] postNotificationName:@"deleteEventAtTag" object:self userInfo:@{@"newEventTag": event.tag}];
        
        
    }];
    delAction.backgroundColor = [UIColor orangeColor];
    
    
    return @[delAction];
}

#pragma mark - XYSimpleEventCellDelegate
- (void)simpleEventCell:(XYSimpleEventCell *)simpleEventCell didTapCompletedImageView:(UIImageView *)completedImageView{
    XYEvent *event = simpleEventCell.event;
    if (!event.completeEvent) {
        completedImageView.image = [UIImage imageNamed:@"completed"];
    }
    
    //更新数据库
    event.completeEvent = YES;
    //更新数据库, 修改此条数据的complete为1 完成
    NSString *sql = [NSString stringWithFormat:@"update t_event set complete = %d where notiKey = %@", event.completeEvent, event.notiKey];
    [XYSqliteTool executeUpdate:sql];
    //取消通知
    [[XYFileTool sharedFileTool] cancelLocalNotiWithKey:event.notiKey];
    
    //刷新主界面数据，
    [[NSNotificationCenter defaultCenter] postNotificationName:@"addCompletedEvent" object:self userInfo:nil];
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.superview endEditing:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"hidenKeyboard" object:self userInfo:nil];
    
}



- (void)dealloc{
    XYLog(@"base table view");
}
@end
