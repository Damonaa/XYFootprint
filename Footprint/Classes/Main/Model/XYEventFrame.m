//
//  XYEventFrame.m
//  Footprint
//
//  Created by 李小亚 on 16/4/14.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import "XYEventFrame.h"
#import "XYEvent.h"
#import "XYRecord.h"


@implementation XYEventFrame

//计算每个控件的frame
- (void)setEvent:(XYEvent *)event{
    _event = event;
    //提醒的图标
    CGFloat margin = 3;
    CGFloat remindWH = 40;
    CGFloat remindX = 5;
    CGFloat remindY = 20;
    self.remindFrame = CGRectMake(remindX, 10, remindWH, remindWH);
    
    //标签按钮， 位于提醒时间的下面
    if (![_event.tag isEqualToString:@"(null)"]) {
        CGFloat tagY = CGRectGetMaxY(_remindFrame) + 5;
        self.tagFrame = CGRectMake(remindX, tagY, remindWH, 18);
    }
    
   
    //文本frame， 如果有文本信息
    
    //图片视图的Y轴
    CGFloat picturesY = remindY;
    //音频按钮的frame的Y
    CGFloat audioY = remindY;
    //下一次提醒frame的Y
    CGFloat nextRepeatY = remindY;
    //提醒地点frame的Y
    CGFloat remindLocY = remindY;
    //天气标签的Y
    CGFloat weatherY = remindY;
    
    if (![_event.text isEqualToString:@"(null)"]) {
        CGFloat textW = XYScreenWidth - remindWH - margin * 2;
        CGSize maxSize = CGSizeMake(textW, MAXFLOAT);
        CGSize textSize = [_event.text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:XYCellTextFont} context:nil].size;
        CGFloat textX = CGRectGetMaxX(_remindFrame) + margin;
        CGFloat textY = remindY;
        self.textFrame = (CGRect){{textX, textY}, textSize};
        
        //图片视图的Y轴
        picturesY = CGRectGetMaxY(_textFrame) + margin;
        //音频按钮的frame的Y
        audioY = picturesY;
        //下一次提醒frame的Y
        nextRepeatY = audioY;
        //提醒地点frame的Y
        remindLocY = nextRepeatY;
        //天气标签的Y
        weatherY = remindLocY;

        //1，如果有文本
        self.rowHeight = CGRectGetMaxY(_textFrame) + margin;
    }
    
    //图片frame
    if (_event.images.count > 0) {
        CGSize picturesSzie = [self photosSizeWithCount:_event.images.count];
        CGFloat picturesX = CGRectGetMaxX(_remindFrame) + margin;
        self.picturesFrame = (CGRect){{picturesX, picturesY}, picturesSzie};
        //音频按钮的frame的Y
        audioY = CGRectGetMaxY(_picturesFrame) + margin;
        //下一次提醒frame的Y
        nextRepeatY = audioY;
        //提醒地点frame的Y
        remindLocY = nextRepeatY;
        //天气标签的Y
        weatherY = remindLocY;
        
        //2，如果有图片
        self.rowHeight = CGRectGetMaxY(_picturesFrame) + margin;
        
    }
    
    //音频frame
    if (_event.audioDuration != 0) {
        CGFloat audioX = CGRectGetMaxX(_remindFrame) + margin;
        self.audioFrame = CGRectMake(audioX, audioY, 100, 40);
        //下一次提醒frame的Y
        nextRepeatY = CGRectGetMaxY(_audioFrame) + margin;
        //提醒地点frame的Y
        remindLocY = nextRepeatY;
        //天气标签的Y
        weatherY = remindLocY;
        
        //3，如果有音频
        self.rowHeight = CGRectGetMaxY(_audioFrame) + margin;
        
    }
    //下一次的重复提醒时间
    if (_event.frequency != 0) {
        CGFloat nextRepeatX = CGRectGetMaxX(_remindFrame) + margin;
        self.nextRepeatFrame = CGRectMake(nextRepeatX, nextRepeatY, XYScreenWidth - remindWH - 20, 40);
        //提醒地点frame的Y
        remindLocY = CGRectGetMaxY(_nextRepeatFrame) + margin;
        //天气标签的Y
        weatherY = remindLocY;
        //4，如果有重复
        self.rowHeight = CGRectGetMaxY(_nextRepeatFrame) + margin;
    }
    
    //提醒地点，并且有设置时间
    
    if (![_event.remindLoc isEqualToString:@"(null)"] && _event.remindDate.length > 6) {
        CGFloat remindLocX = CGRectGetMaxX(_remindFrame) + margin;
        self.addressFrame = CGRectMake(remindLocX, remindLocY, XYScreenWidth - remindWH - 20, 40);
        //天气标签的Y
        weatherY = CGRectGetMaxY(_addressFrame) + margin;
        //5，如果有提醒地址
        self.rowHeight = CGRectGetMaxY(_addressFrame) + margin;
    }
    
    //天气 在最底部
    if (_event.isHasWeather) {
        CGFloat weatherX = CGRectGetMaxX(_remindFrame) + margin;
        self.weatherFrame = CGRectMake(weatherX, weatherY, remindWH, 35);
        //6，如果有提醒地址
        self.rowHeight = CGRectGetMaxY(_weatherFrame);
    }
    
    //7，与左边的两个控件比较
    //左边控件最大Y值，有无tag按钮
    CGFloat maxYLeft = [_event.tag isEqualToString:@"(null)"] ? CGRectGetMaxY(_remindFrame) : CGRectGetMaxY(_tagFrame);
    
    //如果之前的赋值以后，高度依然没有左边的控件高，重新赋值
    if (self.rowHeight < maxYLeft) {
        self.rowHeight = maxYLeft + margin;
    }
}

/**
 *  计算图片占的size
 *
 *  @param count 图片个数
 */
- (CGSize)photosSizeWithCount:(NSInteger)count{
    NSInteger colume = count > 1 ? 2 : 1;
    NSInteger row = count > 2 ? 2 : 1;
    CGFloat photoWH = (XYScreenWidth - _remindFrame.size.width - 30) / 2;
    return CGSizeMake(colume * (photoWH + 10), row * (photoWH + 10));
}
@end
