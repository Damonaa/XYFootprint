//
//  XYTagView.m
//  Footprint
//
//  Created by 李小亚 on 16/4/18.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import "XYTagView.h"
#import "XYSingleTag.h"
#import "XYSqliteTool.h"

@interface XYTagView ()
/**
 *  tag的名称
 */
@property (nonatomic, weak) UILabel *tagTitle;
/**
 *  tag中包含的事件个数
 */
@property (nonatomic, weak) UILabel *eventsCount;

@end

@implementation XYTagView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setupAllChildView];
        
        //监听是否有新数据添加进来, 事件总数变化deleteEventAtTag insertNewTagInListVC
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createdEventAtTag:) name:@"createdEventAtTag" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createdEventAtTag:) name:@"deleteEventAtTag" object:nil];
       
        
    }
    return self;
}

- (void)setupAllChildView{
    //tag title
    UILabel *tagTitle = [[UILabel alloc] init];
    [self addSubview:tagTitle];
    self.tagTitle = tagTitle;
    tagTitle.numberOfLines = 0;
    tagTitle.font = [UIFont systemFontOfSize:15];
    tagTitle.textAlignment = NSTextAlignmentCenter;
    
    //tag  event count
    UILabel *eventsCount = [[UILabel alloc] init];
    [self addSubview:eventsCount];
    self.eventsCount = eventsCount;
    eventsCount.font = [UIFont systemFontOfSize:11];
    eventsCount.textAlignment = NSTextAlignmentCenter;
}


- (void)setSingleTag:(XYSingleTag *)singleTag{
    _singleTag = singleTag;
    
    //为tagTitle赋值
    if ([_singleTag.tagName isEqualToString:@"(null)"]) {
        self.tagTitle.text = @"其他";
    }else{
        self.tagTitle.text = _singleTag.tagName;
    }
    [self.tagTitle sizeToFit];
    //计算自身的size
    if (self.tagTitle.width > 55) {
        self.width = self.tagTitle.width + 5;
        self.height = self.tagTitle.width + 5;
    }else{
        self.width = 60;
        self.height = 60;
    }
    
     self.tagTitle.x = (self.width - self.tagTitle.width) / 2;
    
    if (_singleTag.tagEvents.count > 0) {//如果有事件，上下分别展示名称，个数
        self.eventsCount.hidden = NO;
        self.eventsCount.text = [NSString stringWithFormat:@"%ld", _singleTag.tagEvents.count];
        [self.eventsCount sizeToFit];
        
        self.tagTitle.y = self.height / 2 - self.tagTitle.height / 2 - 5;

        self.eventsCount.x = (self.width - self.eventsCount.width) / 2;
        self.eventsCount.y = CGRectGetMaxY(_tagTitle.frame) + 2;
    }else{//没有事件 为0，不显示个数，title居中
        self.eventsCount.hidden = YES;
        self.tagTitle.y = (self.height - self.tagTitle.height) / 2;
    }
}

#pragma mark - 新事件插入数据库
- (void)createdEventAtTag:(NSNotification *)noti{
    //为self.singleTag.tagEvents 重新赋值
    NSString *tagName = noti.userInfo[@"newEventTag"];
    if ([_singleTag.tagName isEqualToString:tagName]) {
        XYSingleTag *newTag = [[XYSingleTag alloc] init];
        newTag.tagName = _singleTag.tagName;
        //从数据库中获取数据
        newTag.tagEvents = (NSMutableArray *)[XYSqliteTool executeTagQuaryWithName:tagName];
        self.singleTag = newTag;
    }
    
}


- (void)dealloc{
    XYLog(@"销毁TagView");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
