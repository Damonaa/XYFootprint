//
//  XYDateView.m
//  Footprint
//
//  Created by 李小亚 on 16/4/5.
//  Copyright © 2016年 李小亚. All rights reserved.
//
#define XYUnitWidth self.bounds.size.width / 7
#define XYUnitHeight self.bounds.size.height / 7

#import "XYDateView.h"
//#import "NSDate+extend.h"

@interface XYDateView ()

@property (nonatomic, assign) NSInteger year;
@property (nonatomic, assign) NSInteger month;
@property (nonatomic, assign) NSInteger day;
//@property (nonatomic, assign) NSInteger hour;
//@property (nonatomic, assign) NSInteger minute;

@property (nonatomic, strong) NSDate *today;//今天0点的时间

/**
 *  月初第一天的index
 */
@property (nonatomic, assign) NSInteger startDayIndex;

/**
 *  当前月份的1号
 */
@property (nonatomic, strong) NSDate *firstDay;
/**
 *  选中的按钮, 默认今天选中
 */
@property (nonatomic, weak) UIButton *selectedBtn;

@end

@implementation XYDateView


- (NSDate *)today{
    if (!_today) {
        NSDate *currentDate = [NSDate date];
        
        NSInteger tYear = currentDate.year;
        NSInteger tMonth = currentDate.month;
        NSInteger tDay = currentDate.day;
        
        //
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        //自定义自己需要的时间格式
        [dateFormat setDateFormat:@"yyyy-MM-dd"];
        _today = [dateFormat dateFromString:[NSString stringWithFormat:@"%@-%@-%@",@(tYear),@(tMonth),@(tDay)]];
    }
    return _today;
}


- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        //初始化年月日
        [self setupDate];
        //监测通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(switchDate:) name:@"switchDate" object:nil];
    }
    return self;
}

//响应通知发来的消息
- (void)switchDate:(NSNotification *)noti{
//    XYLog(@"%@", noti.userInfo);
    self.year = [noti.userInfo[@"year"] integerValue];
    self.month = [noti.userInfo[@"month"] integerValue];
    //重画
    [self layoutSubviews];
}

//布局添加子控件
- (void)layoutSubviews{
    [super layoutSubviews];
    [self setupChildView];
}
#pragma mark - 设置日期数据
- (void)setupDate{
    
    //当前年月
    NSDate *currentDate = [NSDate date];
    self.month = currentDate.month;
    self.year = currentDate.year;
    self.day = currentDate.day;
//    self.hour = currentDate.hour;
//    self.minute = currentDate.minute;
}

#pragma mark - 添加子控件
- (void)setupChildView{
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    //添加日期数据
    //第一行，周1234567
    NSArray *weekArray = @[@"周一",@"周二",@"周三",@"周四",@"周五",@"周六",@"周日"];
    CGFloat unitX = 0;
    CGFloat unitY = 0;
    for (int i = 0; i < 7; i++) {
        unitX = XYUnitWidth * i;
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(unitX, unitY,XYUnitWidth, XYUnitHeight)];
        lab.text = weekArray[i];
        lab.textColor = [UIColor colorWithRed:1.000 green:0.232 blue:0.343 alpha:1.000];
        lab.textAlignment = NSTextAlignmentCenter;
        lab.font = [UIFont systemFontOfSize:10];
        lab.backgroundColor = [UIColor clearColor];
        [self addSubview:lab];
    }
    
    //日期
    NSDateFormatter *dateForm = [[NSDateFormatter alloc] init];
    dateForm.dateFormat = @"yyyy-MM-dd";
    _firstDay = [dateForm dateFromString:[NSString stringWithFormat:@"%@-%@-%@", @(self.year), @(self.month), @(1)]];
    //判断每月第一天的index
    _startDayIndex = [NSDate acquireWeekDayFromDate:_firstDay];
    
    //index 0 ---- 6
    if (_startDayIndex == 1) {//如果是1， 代表周末，index移到最后
        _startDayIndex = 6;
    }else{
        _startDayIndex -= 2;
    }
    
    //    self.startDayIndex = startDayIndex;
    //每一张日历上显示7 * 6个日子 42
    //绘制日期
    for (NSInteger i = _startDayIndex; i < 42; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:btn];
        
        btn.tag = i;
        btn.backgroundColor = [UIColor clearColor];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:10]];
        
        //为btn添加注册事件
        [btn addTarget:self action:@selector(chooesDay:) forControlEvents:UIControlEventTouchUpInside];
        
        //计算frame
        CGFloat dayX = XYUnitWidth * (i % 7);
        CGFloat dayY = XYUnitHeight * (i / 7) + XYUnitHeight;
        btn.frame = CGRectMake(dayX, dayY, XYUnitWidth, XYUnitHeight);
        
        //计算日期
        NSDate *date = [_firstDay dateByAddingTimeInterval:(i - _startDayIndex) * 24 * 60 * 60];
        NSString *dayStr = [@(date.day) stringValue];
        
        if ([date isToday]) {
            dayStr = @"今天";
            btn.layer.borderColor = [UIColor redColor].CGColor;
            btn.layer.borderWidth = 1;
        }else if (date.day == 1){//月初显示下标月份
            UILabel *monthLab = [[UILabel alloc] initWithFrame:CGRectMake(0, btn.bounds.size.height - 7, btn.bounds.size.width, 7)];
            monthLab.backgroundColor = [UIColor clearColor];
            monthLab.textAlignment = NSTextAlignmentCenter;
            monthLab.font = [UIFont systemFontOfSize:7];
            monthLab.textColor = [UIColor lightGrayColor];
            monthLab.text = [NSString stringWithFormat:@"%@月", @(date.month)];
            [btn addSubview:monthLab];
        }
        
        //设置按钮title
        [btn setTitle:dayStr forState:UIControlStateNormal];
        
        //如果日期小于今天的就禁用
        if ([self.today compare:date] > 0) {
            btn.enabled = NO;
            [btn setTitleColor:[UIColor colorWithRed:0.831 green:0.875 blue:0.859 alpha:1.000] forState:UIControlStateDisabled];
        }else{
            btn.enabled = YES;
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
        //设置今天为默认选中的
        if ([self.today compare:date] == 0) {
            [self chooesDay:btn];
        }
        
    }

}

//点击选中日期
- (void)chooesDay:(UIButton *)button{
    //设置选中按钮状态
    [self.selectedBtn setBackgroundColor:[UIColor clearColor]];
    self.selectedBtn.selected = NO;
    
    button.selected = YES;
    self.selectedBtn = button;
    [button setBackgroundColor:[UIColor magentaColor]];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    
    //计算日期
    NSDate *chooseDate = [NSDate dateWithTimeInterval:(button.tag - self.startDayIndex) * 24 * 60 * 60 sinceDate:_firstDay];
    NSDateFormatter *dateForm = [[NSDateFormatter alloc] init];
    dateForm.dateFormat = @"yyyy-MM-dd";
    NSString *choosedateStr = [dateForm stringFromDate:chooseDate];
    //将取得的值传出去
    
    if (_complete) {
        _complete(choosedateStr);
    }
}

//移除通知
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    - (void)dealloc{
        XYLog(@"销毁");
//    }
}


@end
