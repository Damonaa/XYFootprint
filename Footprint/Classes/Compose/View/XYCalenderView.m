//
//  XYCalenderView.m
//  Footprint
//
//  Created by 李小亚 on 16/4/1.
//  Copyright © 2016年 李小亚. All rights reserved.
//


#define XYRowHeight self.bounds.size.width / 9

#import "XYCalenderView.h"
//#import "NSDate+extend.h"
#import "XYCover.h"
#import "XYDateView.h"
#import "XYClockView.h"

@interface XYCalenderView ()
/**
 *  显示日期时间
 */
@property (nonatomic, weak) UILabel *titleLabel;
/**
 *  存放日期的背景View
 */
@property (nonatomic, weak) XYDateView *dateView;
/**
 *  选择时间的View
 */
@property (nonatomic, weak) XYClockView *clockView;

/**
 *  设置时间显示标签
 */
@property (nonatomic, weak) UILabel *timeLabel;

/**
 *  确定按钮
 */
@property (nonatomic, weak) UIButton *doneBtn;

/**
 *  选中的按钮, 默认今天选中
 */
@property (nonatomic, weak) UIButton *selectedBtn;
/**
 *  是否展示了选择时间界面， 默认为NO
 */
@property (nonatomic, assign, getter=isShowTimeView) BOOL showTimeView;


@property (nonatomic, assign) NSInteger year;
@property (nonatomic, assign) NSInteger month;
@property (nonatomic, assign) NSInteger day;
@property (nonatomic, assign) NSInteger hour;
@property (nonatomic, assign) NSInteger minute;
@property (nonatomic, copy) NSString *dateStr;


@property (nonatomic, strong) NSDate *today;//今天0点的时间


@end

@implementation XYCalenderView

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

+ (instancetype)showCalender{
    CGFloat calW = XYScreenWidth - 20;
    CGFloat calH = calW;
    CGFloat calX = 10;
    CGFloat calY = (XYScreenHeight - calH) / 2;
    XYCalenderView *calenderView = [[XYCalenderView alloc] initWithFrame:CGRectMake(calX, calY, calW, calH)];
    
    
    calenderView.layer.cornerRadius = 2.0;
    calenderView.layer.masksToBounds = YES;
    calenderView.backgroundColor = [UIColor whiteColor];
    calenderView.userInteractionEnabled = YES;
    //添加子控件
    [calenderView setupAllChildView];
    //设置日期数据
    [calenderView setupDate];
    [XYKeyWindow addSubview:calenderView];
    return calenderView;
}


#pragma mark - 添加子控件
- (void)setupAllChildView{
    
    //设置顶部导航栏， 左右两个图片，中间一个标签
    //左右两个图片
    UIImageView *leftIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrows_right"]];
    leftIV.transform = CGAffineTransformMakeRotation(M_PI);
    CGFloat marginImage = 30;
    CGFloat leftImageY = (XYRowHeight - marginImage) / 2 + 3;
    leftIV.frame = CGRectMake(marginImage, leftImageY, 12, 19.5);
    [self addSubview:leftIV];
    
    UIImageView *rightIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrows_right"]];
    CGFloat rightX = self.bounds.size.width - marginImage - 8;
    rightIV.frame = CGRectMake(rightX, leftImageY, 12, 19.5);
    [self addSubview:rightIV];
    
    //中间一个标签
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, XYRowHeight)];
    self.titleLabel = titleLabel;
    [self addSubview:titleLabel];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.userInteractionEnabled = YES;
    
    //为标题栏添加手势，同于切换月份，更改时间
    UITapGestureRecognizer *titleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchMonthTap:)];
    [titleLabel addGestureRecognizer:titleTap];
    
    //添加一个细线在标题栏底部
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(titleLabel.frame) - 0.5, CGRectGetWidth(self.frame), 0.5)];
    line.backgroundColor = [UIColor colorWithWhite:0.667 alpha:0.293];
    [self addSubview:line];
    
    //此UIView用于存放日历数据
    XYDateView *dateView = [[XYDateView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_titleLabel.frame), CGRectGetWidth(self.frame), XYRowHeight * 7)];
    self.dateView = dateView;
    dateView.backgroundColor = [UIColor colorWithRed:0.910 green:0.914 blue:0.910 alpha:1.000];
    [self addSubview:dateView];
    
    __weak typeof(self) weakSelf = self;
    
    dateView.complete = ^(NSString *dateStr){
        XYLog(@"%@", dateStr);
        weakSelf.dateStr = dateStr;
        NSString *titleStr = [NSString stringWithFormat:@"%@ %ld:%ld",weakSelf.dateStr, (long)weakSelf.hour, (long)weakSelf.minute];
        
        titleLabel.text = titleStr;
    };
    //添加选择时间的View， 默认隐藏
    
    XYClockView *clockView = [[XYClockView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_titleLabel.frame), CGRectGetWidth(self.frame), XYRowHeight * 7)];
    [self addSubview:clockView];
    self.clockView = clockView;
    clockView.alpha = 0;
    clockView.backgroundColor = [UIColor colorWithRed:0.910 green:0.914 blue:0.910 alpha:1.000];
    
    clockView.hourChange = ^(NSInteger hourInt){
        weakSelf.hour = hourInt;
        NSString *titleStr = [NSString stringWithFormat:@"%@ %ld:%ld",weakSelf.dateStr, (long)weakSelf.hour, (long)weakSelf.minute];
        
        titleLabel.text = titleStr; 
    };
    
    clockView.minuteChange = ^(NSInteger minuteInt){
        weakSelf.minute = minuteInt;
        NSString *titleStr = [NSString stringWithFormat:@"%@ %ld:%ld",weakSelf.dateStr, (long)weakSelf.hour, (long)weakSelf.minute];
        
        titleLabel.text = titleStr;
    };
    
    //底部画个细线
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_dateView.frame), CGRectGetWidth(self.frame), 0.5)];
    bottomLine.backgroundColor = [UIColor colorWithWhite:0.667 alpha:0.293];
    [self addSubview:bottomLine];

    //添加确定按钮，不同状态背景图不同
    UIButton *doneBtn = [UIButton toolButtonWithNormalImage:[UIImage imageNamed:@"ok_normal"] hightlightImage:nil target:self selcetor:@selector(doneBtnClick:) controlEvent:UIControlEventTouchUpInside title:nil];
    
    self.doneBtn = doneBtn;
    CGFloat doneY = CGRectGetMaxY(_dateView.frame) + (XYRowHeight - 30) / 2;
    [doneBtn setFrame:CGRectMake(CGRectGetWidth(self.frame)/5.0 * 3, doneY, 60, 30)];

    [self addSubview:doneBtn];
    //添加选择时间，或者日历的按钮
    UIButton *switchBtn = [UIButton toolButtonWithNormalImage:[UIImage imageNamed:@"alarm_clock_normal"] hightlightImage:nil target:self selcetor:@selector(switchToChooseTime:) controlEvent:UIControlEventTouchUpInside title:nil];
    [switchBtn setFrame:CGRectMake(CGRectGetWidth(self.frame)/5.0, doneY, 60, 30)];
    [self addSubview:switchBtn];
    
}

#pragma mark - 设置日期数据
- (void)setupDate{
    
    //当前年月
    NSDate *currentDate = [NSDate date];
    self.month = currentDate.month;
    self.year = currentDate.year;
    self.day = currentDate.day;
    self.hour = currentDate.hour;
    self.minute = currentDate.minute;

}

#pragma mark - 导航栏点击处理
- (void)switchMonthTap:(UITapGestureRecognizer *)tap{
    CGPoint loc = [tap locationInView:_titleLabel];
    CGFloat titleLabWidth = CGRectGetWidth(_titleLabel.frame);
    
    if (loc.x <= titleLabWidth / 3.0) {//点击左边
        [self leftSwitch];
    }else if (loc.x >= titleLabWidth / 3.0 * 2){//点击右边
        [self rightSwitch];
    }else{//点击中间
//        [self mindleClick:(UIButton *)tap.view];
    }

    //发布通知， date发生变化
    NSMutableDictionary *dateDic = [NSMutableDictionary dictionary];
    dateDic[@"year"] = @(self.year);
    dateDic[@"month"] = @(self.month);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"switchDate" object:self userInfo:dateDic];
}

- (void)leftSwitch{
    if (self.month > 1) {
        self.month -= 1;
    }else{
        self.month = 12;
        self.year -= 1;
    }
}
- (void)rightSwitch{
    if (self.month < 12) {
        self.month += 1;
    }else{
        self.month = 1;
        self.year += 1;
    }
}
//
//- (void)mindleClick:(UIButton *)button{
//    
//    //切换当前视图，日历或者是时间
////    [self switchToChooseTime:button];
//}
//
////设置时间标签内容，frame
//- (void)refrshTimeLabel:(UILabel *)timeLabel{
////    NSString *timeStr = [NSString stringWithFormat:@"%ld : %ld", self.hour, self.minute];
////    timeLabel.text = timeStr;
////    //设置frame
////    [timeLabel sizeToFit];
////    timeLabel.x = (self.dateView.width - timeLabel.width ) / 2;
////    timeLabel.y = (self.dateView.height - timeLabel.height ) / 2;
//}
#pragma mark - 设置时间
- (void)switchToChooseTime:(UIButton *)button{
    
    button.highlighted = NO;
    if (self.showTimeView) {
        //显示日历
        [self shwoCalenderView:button];
    }else{
        //显示时钟
        [self showTimeView:button];
    }
    //切换当前视图，日历或者是时间
    self.showTimeView = !self.showTimeView;
}
 //显示日历
- (void)shwoCalenderView:(UIButton *)button{
    
    [UIView animateWithDuration:0.25 animations:^{
        self.clockView.alpha = 0;
        self.dateView.alpha = 1;
    } completion:^(BOOL finished) {
        //更改按钮的图
        [UIButton changeButton:button normalImage:@"alarm_clock_normal" highlighted:nil];
    }];
    
}
//显示时钟
- (void)showTimeView:(UIButton *)button{
  
    [UIView animateWithDuration:0.25 animations:^{
        self.dateView.alpha = 0;
        self.clockView.alpha = 1;
    } completion:^(BOOL finished) {
        //更改按钮的图
        [UIButton changeButton:button normalImage:@"calender_normal" highlighted:@"calender_highlighted"];
    }];
}

#pragma mark - 确定按钮点击
- (void)doneBtnClick:(id)sender{
    if (_complete) {
        _complete(self.titleLabel.text);
    }
    
    [self hiddenCalender];
    //隐藏蒙板
    XYCover *cover = [[XYCover alloc] init];
    [cover hiddenCover];
}

- (void)hiddenCalender{
    //隐藏日历窗口
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    
    self.showTimeView = NO;
}

- (void)dealloc{
    XYLog(@"销毁");
}
@end
