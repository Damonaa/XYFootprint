//
//  XYEventCell.m
//  Footprint
//
//  Created by 李小亚 on 16/3/30.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import "XYEventCell.h"
#import "XYCellPhotosView.h"
#import "XYEventFrame.h"
#import "XYEvent.h"
#import "XYRecord.h"
#import "XYWeatherTool.h"

@interface XYEventCell ()<UIGestureRecognizerDelegate>
/**
 *  提醒标签，优先显示时间，其次地址
 */
@property (nonatomic, weak) UILabel *remindLabel;
/**
 *  标签tag
 */
@property (nonatomic, weak) UILabel *tagLabel;
/**
 *  文本标签
 */
@property (nonatomic, weak) UILabel *textInfoLabel;
/**
 *  展示图片的视图
 */
@property (nonatomic, weak) XYCellPhotosView *photosView;
/**
 *  音频播放按钮
 */
@property (nonatomic, weak) UIButton *audioBtn;
/**
 *  下次重复提醒的标签
 */
@property (nonatomic, weak) UILabel *nextRepeatLable;
/**
 *  显示地址的标签
 */
@property (nonatomic, weak) UILabel *addressLabel;
/**
 *  天气预报
 */
@property (nonatomic, weak) UILabel *weatherLabel;
/**
 *  拖动手势
 */
@property (nonatomic, strong) UIPanGestureRecognizer *pan;
/**
 *  完成图标
 */
@property (nonatomic, weak) UIImageView *doneIV;
/**
 *  删除图标
 */
@property (nonatomic, weak) UIImageView *deleteIV;
@end

@implementation XYEventCell

+ (instancetype)eventCellWithTableView:(UITableView *)tableView{
    static NSString *reusedCell = @"eventCell";
    XYEventCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedCell];
    
    if (!cell) {
        cell = [[XYEventCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusedCell];
    }
    return cell;
}


//自定义布局cell的控件
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        //设置子控件
        [self setupAllChildView];
        //添加手势
        self.pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panSlideCell:)];
        [self addGestureRecognizer:_pan];
        self.pan.delegate = self;
    }
    return self;
}

#pragma mark - 滑动手势
- (void)panSlideCell:(UIPanGestureRecognizer *)gesture{
    if (gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint point = [gesture translationInView:gesture.view];
        //偏移量
        CGFloat offset = point.x;
        //移动self.contentView
        self.contentView.center = CGPointMake(self.contentView.center.x + offset, self.contentView.center.y);
        self.doneIV.center = CGPointMake(self.doneIV.center.x + offset, self.doneIV.center.y);
        self.deleteIV.center = CGPointMake(self.deleteIV.center.x + offset, self.deleteIV.center.y);
        
        //移动清零
        [gesture setTranslation:CGPointZero inView:gesture.view];
        
        if (self.contentView.x > self.width / 2) {//向右移动到二分之一
            //全部移除
            [UIView animateWithDuration:0.25 animations:^{
               self.contentView.x = self.width;
                self.doneIV.x = self.width;
            } completion:^(BOOL finished) {
               
            }];
        }else if (CGRectGetMaxX(self.contentView.frame) < self.width / 2){//向左移动到三分之一
            //全部移除
            [UIView animateWithDuration:0.25 animations:^{
                self.contentView.x = - self.width;
                self.deleteIV.x = - self.width;
            } completion:^(BOOL finished) {
                
            }];
        }
        
    }else if (gesture.state == UIGestureRecognizerStateEnded){
        if (self.contentView.x > -self.width && self.contentView.x < self.width) {//复位
            [UIView animateWithDuration:0.25 animations:^{
                self.contentView.center = CGPointMake(self.width / 2, self.contentView.center.y);
                self.doneIV.x = - self.doneIV.width;
                self.deleteIV.x = self.width;
            }];
        }else if (self.contentView.x < -self.width / 2){//判断是否响应代理  //删除
            if ([self.cellDelegate respondsToSelector:@selector(eventCell:slideToLeftDeleteWithIndex:)]) {
                [self.cellDelegate eventCell:self slideToLeftDeleteWithIndex:gesture.view.tag];
            }
        }else if (self.contentView.x > self.width / 2){
            if ([self.cellDelegate respondsToSelector:@selector(eventCell:slideToRightDoneWithIndex:)]) {//完成
                [self.cellDelegate eventCell:self slideToRightDoneWithIndex:gesture.view.tag];
            }
        }
    }
}

#pragma mark - 手势代理
//允许多个手势操作
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}
//依据XY轴方向移动的幅度，判断是否执行手势
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if (self.pan == gestureRecognizer) {
        CGPoint point = [self.pan translationInView:self];
        
        return fabs(point.x) > fabs(point.y);
    }else{
        return NO;
    }
}
#pragma mark - 设置子控件
- (void)setupAllChildView{
    //提醒
    UILabel *remindLabel = [[UILabel alloc] init];
    remindLabel.backgroundColor = [UIColor colorWithRed:1.000 green:0.500 blue:0.000 alpha:0.644];
    self.remindLabel = remindLabel;
    [self.contentView addSubview:remindLabel];
    remindLabel.textAlignment = NSTextAlignmentCenter;
    remindLabel.numberOfLines = 0;
    remindLabel.font = XYCellRemindFont;
    remindLabel.userInteractionEnabled = YES;
    
    //标签tag
    UILabel *tagLabel = [[UILabel alloc] init];
    [self.contentView addSubview:tagLabel];
    self.tagLabel = tagLabel;
    self.tagLabel.font = [UIFont systemFontOfSize:10];
    self.tagLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    self.tagLabel.textAlignment = NSTextAlignmentCenter;
//    tagLabel.backgroundColor = [UIColor lightGrayColor];
    
    //文本
    UILabel *textInfoLabel = [[UILabel alloc] init];
//    textInfoLabel.backgroundColor = [UIColor redColor];
    [self.contentView addSubview:textInfoLabel];
    self.textInfoLabel = textInfoLabel;
    textInfoLabel.numberOfLines = 0;
    textInfoLabel.textAlignment = NSTextAlignmentLeft;
    textInfoLabel.font = XYCellTextFont;
    
    //图片视图
    XYCellPhotosView *photosView = [[XYCellPhotosView alloc] init];
//    photosView.backgroundColor = [UIColor brownColor];
    [self.contentView addSubview:photosView];
    self.photosView = photosView;
    
    //音频按钮
    UIButton *audioBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    audioBtn.backgroundColor = [UIColor blueColor];
    [self.contentView addSubview:audioBtn];
    self.audioBtn = audioBtn;
    self.audioBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    
    //下一次重复提醒 label
    UILabel *nextRepeatLable = [[UILabel alloc] init];
//    nextRepeatLable.backgroundColor = [UIColor orangeColor];
    [self.contentView addSubview:nextRepeatLable];
    self.nextRepeatLable = nextRepeatLable;
    nextRepeatLable.font = [UIFont systemFontOfSize:14];
    
    
    //地址label
    UILabel *addressLabel = [[UILabel alloc] init];
//    addressLabel.backgroundColor = [UIColor yellowColor];
    [self.contentView addSubview:addressLabel];
    self.addressLabel = addressLabel;
    addressLabel.font = [UIFont systemFontOfSize:14];
    
    UILabel *weatherLabel = [[UILabel alloc] init];
    [self.contentView addSubview:weatherLabel];
//    weatherLabel.backgroundColor = [UIColor blueColor];
    self.weatherLabel = weatherLabel;
    weatherLabel.font = [UIFont systemFontOfSize:12];
    
    //在cell的左右各放两个imageView，左边完成，右边删除
    UIImageView *doneIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ok_normal"]];
    self.doneIV = doneIV;
    [self addSubview:doneIV];
    
    UIImageView *deleteIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"trash_normal"]];
    self.deleteIV = deleteIV;
    [self addSubview:deleteIV];
}

//响应按钮的点击，播放音频
- (void)playAudio:(UIButton *)button{
    if ([self.cellDelegate respondsToSelector:@selector(eventCell:didClickPlayButtonAtIndex:)]) {
        [self.cellDelegate eventCell:self didClickPlayButtonAtIndex:button.superview.superview.tag];
    }
}

#pragma mark - 为控件赋值
- (void)setEventFrame:(XYEventFrame *)eventFrame{
    _eventFrame = eventFrame;
//    //KVO监听天气的变化
//    [self observeValueForKeyPath:nil ofObject:nil change:nil context:nil];
//    [eventFrame addObserver:self forKeyPath:@"event.weather" options:NSKeyValueObservingOptionNew context:nil];
    
    //frame
    self.remindLabel.frame = eventFrame.remindFrame;
    self.tagLabel.frame = eventFrame.tagFrame;
    self.textInfoLabel.frame = eventFrame.textFrame;
    self.photosView.frame = eventFrame.picturesFrame;
    self.audioBtn.frame = eventFrame.audioFrame;
    self.nextRepeatLable.frame = eventFrame.nextRepeatFrame;
    self.addressLabel.frame = eventFrame.addressFrame;
    self.weatherLabel.frame = eventFrame.weatherFrame;
    
    CGFloat he = eventFrame.rowHeight;
    self.doneIV.x = - self.doneIV.width;
    self.doneIV.y = (he - self.doneIV.height) / 2;
    
    self.deleteIV.x = XYScreenWidth;
    self.deleteIV.y = (he - self.deleteIV.height) / 2;
    //赋值
    XYEvent *event = eventFrame.event;
    [self setupUIDataWithEvent:event];

    
}
//KVO监听天气的变化
//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
//    _weatherLabel.text = self.eventFrame.event.weather;
//}
//为控件赋值
- (void)setupUIDataWithEvent:(XYEvent *)event{
    //设置reminderLabel提醒框文字
    if (![event.remindDate isEqualToString:@"(null)"]) {
        self.remindLabel.text = [self transformRemindDateWithDateStr:event.remindDate];
    }else{
        self.remindLabel.text = event.remindLoc;
    }
    _remindLabel.layer.cornerRadius = _remindLabel.width / 2;
    _remindLabel.layer.masksToBounds = YES;
    
    //设置标签
    if (![event.tag isEqualToString:@"(null)"]) {
        self.tagLabel.text = event.tag;
//        [self.tagLabel sizeToFit];
        
        self.tagLabel.center = CGPointMake(self.remindLabel.center.x, self.tagLabel.center.y);;
    }

    
    //设置文本text内容
    if (![event.text isEqualToString:@"(null)"]) {
        self.textInfoLabel.text = event.text;
    }
    //设置图片们
    self.photosView.photosPath = event.images;
    
    //设置音频播放按钮
    if (event.audioDuration != 0) {
        [self.audioBtn setImage:[UIImage imageNamed:@"audio_play_normal"] forState:UIControlStateNormal];
        [self.audioBtn addTarget:self action:@selector(playAudio:) forControlEvents:UIControlEventTouchUpInside];
        [self.audioBtn setTitle:[NSString timeStringForTimeInterval:event.audioDuration] forState:UIControlStateNormal];
        [self.audioBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        self.audioBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        self.audioBtn.width += 10;
    }
    
    //设置重复提醒
    NSDate *fireDate = [NSDate dateTransformFromStr:event.remindDate format:@"yyyy-MM-dd HH:mm"];
    
    //有设置提醒的时间，并且重复提醒，才计算
    if (event.remindDate && event.frequency != RepeatFrequenceNever) {
        switch (event.frequency) {
            case RepeatFrequenceDay:
                self.nextRepeatLable.text = [self nextRepeatDaySinceDate:fireDate];
                break;
            case RepeatFrequenceMonToFir:
                self.nextRepeatLable.text = [self nextRepeatMonToFirSinceDate:fireDate];
                break;
            case RepeatFrequenceWeek:
                self.nextRepeatLable.text = [self nextRepeatWeekSinceDate:fireDate];
                break;
            case RepeatFrequenceMonth:
                self.nextRepeatLable.text = [self nextRepeatMonthSinceDate:fireDate];
                break;
            case RepeatFrequenceYear:
                self.nextRepeatLable.text = [self nextRepeatYearSinceDate:fireDate];
                break;
            default:
                break;
        }
        [self.nextRepeatLable sizeToFit];
    }
    
    
    if (![event.remindLoc isEqualToString:@"(null)"] && event.remindDate.length > 6) {
        self.addressLabel.text = event.remindLoc;
        [self.addressLabel sizeToFit];
    }
    

    if (event.isHasWeather) {
        self.weatherLabel.text = event.weather;
//        self.weatherLabel.backgroundColor = [UIColor lightGrayColor];
        [self.weatherLabel sizeToFit];
    }
    
    
}

#pragma mark - 计算转换时间样式
//计算每年的提醒
- (NSString *)nextRepeatYearSinceDate:(NSDate *)fireDate{
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSRange range = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitYear forDate:fireDate];
    NSString *nextDateStr = [NSDate nextRepeatDaySinceDate:fireDate interval:24 * 60 * 60 * range.length];
    
    return [NSString stringWithFormat:@"下次将与 %@ 提醒", nextDateStr];
}
//计算每月的提醒
- (NSString *)nextRepeatMonthSinceDate:(NSDate *)fireDate{
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSRange range = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:fireDate];
    NSString *nextDateStr = [NSDate nextRepeatDaySinceDate:fireDate interval:24 * 60 * 60 * range.length];
    
    return [NSString stringWithFormat:@"下次将与 %@ 提醒", nextDateStr];
}
//计算每周的提醒
- (NSString *)nextRepeatWeekSinceDate:(NSDate *)fireDate{
    NSString *nextDateStr = [NSDate nextRepeatDaySinceDate:fireDate interval:24 * 60 * 60 * 7];
    return [NSString stringWithFormat:@"下次将与 %@ 提醒", nextDateStr];
}

//计算周一到周五的提醒
- (NSString *)nextRepeatMonToFirSinceDate:(NSDate *)fireDate{
    NSString *nextDateStr = [NSDate nextRepeatMonToFirSinceDate:fireDate];
    return [NSString stringWithFormat:@"下次将与 %@ 提醒", nextDateStr];
}

//计算下一天的提醒
- (NSString *)nextRepeatDaySinceDate:(NSDate *)fireDate{
    NSString *nextDateStr = [NSDate nextRepeatDaySinceDate:fireDate interval:24 * 60 * 60];
    return [NSString stringWithFormat:@"下次将与 %@ 提醒", nextDateStr];
}

//转换时间日期样式
- (NSString *)transformRemindDateWithDateStr:(NSString *)remindDate{
    NSDate *date = [NSDate dateTransformFromStr:remindDate format:@"yyyy-MM-dd HH:mm"];

    //截取 时:分
    NSRange hourRange = [remindDate rangeOfString:@" "];
    NSString *hourStr = [remindDate substringFromIndex:hourRange.length + hourRange.location];
    NSString *dateStr;
    
    if ([date isToday]) {
        dateStr = [NSString stringWithFormat:@"今天 \n%@", hourStr];
    }else if ([date isTomorrow]){
        dateStr = [NSString stringWithFormat:@"明天 \n%@", hourStr];
    }else if ([date isTheDayAfterTomorrow]){
        dateStr = [NSString stringWithFormat:@"后天 \n%@", hourStr];
    }else{
        //截取字符
        NSRange range = [remindDate rangeOfString:@"-"];
        NSString *dateStr = [remindDate substringFromIndex:range.location + range.length];
        
        dateStr = [dateStr stringByReplacingOccurrencesOfString:@" " withString:@"\n"];
        return dateStr;
    }
    return dateStr;
}
@end
