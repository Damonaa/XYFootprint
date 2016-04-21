//
//  XYRecordView.m
//  Footprint
//
//  Created by 李小亚 on 16/4/10.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import "XYRecordView.h"
#import "XYWaveView.h"

@interface XYRecordView ()



/**
 *  完成按钮
 */
@property (nonatomic, weak) UIButton *doneBtn;

@end

@implementation XYRecordView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        //添加子控件
        [self setupChildView];
    }
    return self;
}
//添加子控件
- (void)setupChildView{
    //添加波浪线
    XYWaveView *waveView = [[XYWaveView alloc] init];
    [self addSubview:waveView];
    self.waveView = waveView;
    
    //显示录音时长的label
    UILabel *durationLabel = [[UILabel alloc] init];
    [self addSubview:durationLabel];
    self.durationLabel = durationLabel;
    durationLabel.font = [UIFont systemFontOfSize:12];
    durationLabel.textAlignment = NSTextAlignmentCenter;
    durationLabel.textColor = [UIColor blackColor];
    durationLabel.text = @"00:00";
    //完成按钮
    UIButton *doneBtn = [UIButton buttonWithTarget:self selcetor:@selector(doneBtnClick) controlEvent:UIControlEventTouchUpInside title:@"完成"];
    [self addSubview:doneBtn];
    self.doneBtn = doneBtn;
}

//完成按钮点击事件
- (void)doneBtnClick{
    if ([self.delegate respondsToSelector:@selector(recordViewDidFinishRecord)]) {
        [self.delegate recordViewDidFinishRecord];
    }
}

//布局控件
- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.waveView.frame = self.bounds;
    
    [self.durationLabel sizeToFit];
    self.durationLabel.x = 15;
    self.durationLabel.y = (self.height - self.durationLabel.height ) /2;
    
    [self.doneBtn sizeToFit];
    self.doneBtn.y = (self.height - self.doneBtn.height ) /2;
    self.doneBtn.x = self.width - 15 - self.doneBtn.width;
}
@end
