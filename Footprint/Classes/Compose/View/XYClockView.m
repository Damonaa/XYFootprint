//
//  ClockView.m
//  Thread&NetTest
//
//  Created by 李小亚 on 2/13/16.
//  Copyright © 2016 李小亚. All rights reserved.
//

#define VIEW_WIDTH self.frame.size.width
#define VIEW_HEIGHT self.frame.size.height

#import "XYClockView.h"

/**
 *  绘制钟表中间的点
 */
@interface CenterView : UIView

@end

@implementation CenterView

- (void)drawRect:(CGRect)rect{
//1, 开启图层上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
//
    
    CGFloat w = rect.size.width;
    CGFloat h = rect.size.height;
    
    CGFloat centerX = w * 0.5;
    CGFloat centerY = h * 0.5;
//    CGFloat radius = h * 0.45;
    //小圆，填充
    CGContextAddArc(ctx, centerX, centerY, 5, 0, M_PI * 2, 0);
    [[UIColor whiteColor] set];
    CGContextFillPath(ctx);
    
    //包围圆的线
//    CGContextAddArc(ctx, centerX, centerY, 3, 0, M_PI * 2, 0);
//    [[UIColor magentaColor] set];
//    CGContextSetLineWidth(ctx, 1.5);
//    CGContextStrokePath(ctx);
  
}

@end


@interface XYClockView ()

/**
 *  分针
 */
@property (nonatomic, strong) UIImageView *minuteView;
/**
 *  时针
 */
@property (nonatomic, strong) UIImageView *hourView;

/**
 *  背景图片
 */
@property (nonatomic, weak) UIImageView  *bgImageView;

/**
 *  累加记录时针的走动
 */
@property (nonatomic, assign) float hourPercent;
/**
 *  累加记录分针的走动
 */
@property (nonatomic, assign) float minutePercent;
/**
 *  当前分钟
 */
@property (nonatomic, assign) NSInteger currentMinute;

/**
 *  当前小时
 */
@property (nonatomic, assign) NSInteger currentHour;

@end

@implementation XYClockView



- (UIImageView *)minuteView{
    if (!_minuteView) {
        _minuteView = [[UIImageView alloc] init];
//        _minuteView.backgroundColor = [UIColor blackColor];
        _minuteView.image = [UIImage imageNamed:@"minute_hand"];
        CGFloat minuteH = XYScreenWidth * 0.3;
        
        _minuteView.bounds = CGRectMake(0, 0, 10, minuteH);
        _minuteView.layer.anchorPoint = CGPointMake(0.5, 0.77);
        _minuteView.layer.position = CGPointMake(VIEW_WIDTH * 0.5, VIEW_HEIGHT * 0.5);
        _minuteView.layer.cornerRadius = 0.5;
        _minuteView.layer.masksToBounds = YES;
        
        _minuteView.userInteractionEnabled = YES;
        UIPanGestureRecognizer *minutePan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(minutePan:)];
        [_minuteView addGestureRecognizer:minutePan];
    }
    return _minuteView;
}

- (UIImageView *)hourView{
    if (!_hourView) {
        _hourView = [[UIImageView alloc] init];
//        _hourView.backgroundColor = [UIColor blackColor];
        _hourView.image = [UIImage imageNamed:@"hour_hand"];
        
        CGFloat hourH = XYScreenWidth * 0.25;
        _hourView.bounds = CGRectMake(0, 0, 15, hourH);
        _hourView.layer.anchorPoint = CGPointMake(0.5, 0.77);
        _hourView.layer.position = CGPointMake(VIEW_WIDTH * 0.5, VIEW_HEIGHT * 0.5);
        _hourView.layer.cornerRadius = 0.5;
        _hourView.layer.masksToBounds = YES;
        
        _hourView.userInteractionEnabled = YES;
        UIPanGestureRecognizer *hourPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(hourPan:)];
        [_hourView addGestureRecognizer:hourPan];
        
    }
    return _hourView;
}
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        
        [self setupAllChileView];

//获取当前时间
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"hh:mm:ss";
//        dateFormatter.timeZone = [NSTimeZone localTimeZone];
        
//        NSString *dateStr = [dateFormatter stringFromDate:[NSDate date]];
//        设置当前分针的位置
        [self updateTimeLocWithDateFormate:@"mm" pointerView:self.minuteView];
        
        
        
//        设置当前时针的位置
        dateFormatter.dateFormat = @"mm";
        NSString *minuteStr = [dateFormatter stringFromDate:[NSDate date]];
        
        dateFormatter.dateFormat = @"HH";
        NSString *str = [dateFormatter stringFromDate:[NSDate date]];
//        XYLog(@"hour: %d", [str intValue]);
        self.currentHour = [str integerValue];
        float angle = (float)[str intValue] * 5 + (float)[minuteStr intValue] / 60 * 5;
        self.hourView.transform = CGAffineTransformRotate(self.hourView.transform, M_PI * 2 / 60 * angle);

    }
    return self;
}

//添加子控件
- (void)setupAllChileView{
    
    //添加背景图片
    UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"clock_bg"]];
    bgImageView.userInteractionEnabled = YES;
    [self addSubview:bgImageView];
    self.bgImageView = bgImageView;
    
    //添加时针，分针
    [self addSubview:self.minuteView];
    [self addSubview:self.hourView];
    
    //添加中心点
    CenterView *cv = [[CenterView alloc] init];
    cv.backgroundColor = [UIColor clearColor];
    CGFloat cvW = 15;
    CGFloat cvX = (self.frame.size.width - cvW) / 2;
    CGFloat cvY = (self.frame.size.height - cvW) / 2;
    cv.frame = CGRectMake(cvX, cvY, cvW, cvW);
    
    [self addSubview:cv];
}

-  (void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat ivWH = VIEW_HEIGHT;
    CGFloat ivX = (VIEW_WIDTH - VIEW_HEIGHT ) /2;
    self.bgImageView.frame = CGRectMake(ivX, 0, ivWH, ivWH);
}
//初始化的时候，更新指针位置
- (void)updateTimeLocWithDateFormate:(NSString *)dateFo pointerView:(UIView *)pointerView{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

    dateFormatter.dateFormat = dateFo;
    NSString *str = [dateFormatter stringFromDate:[NSDate date]];
    self.currentMinute = [str integerValue];
//    XYLog(@"second: %d", [str intValue]);
    pointerView.transform = CGAffineTransformRotate(pointerView.transform, M_PI * 2 / 60 * [str intValue]);
}



//拖动时针旋转
- (void)hourPan:(UIPanGestureRecognizer *)gesture{

    CGPoint translation = [gesture translationInView:gesture.view];

    float hourProgress = translation.x / gesture.view.bounds.size.height * 0.3;
    
    //累计时针的百分比
    self.hourPercent += hourProgress;
    if (self.hourPercent >= 2) {//重置
        self.hourPercent -= 2;
    }else if (self.hourPercent <= -2){
        self.hourPercent += 2;
    }
    
    self.hourView.transform = CGAffineTransformRotate(self.hourView.transform, M_PI * 2 * hourProgress);
    [gesture setTranslation:CGPointZero inView:gesture.view];
    
    
    //计算旋转后的小时
    float hour = 12 * self.hourPercent + self.currentHour;
//    XYLog(@"self.hourPercent: %f;  hour: %f", self.hourPercent, hour);
//将浮点小时数转换为整数，四舍五入
    NSInteger intHour = ((NSInteger)(hour + 0.5)) % 24;
    if (intHour < 0) {
        intHour += 24;
    }
    //block传值出去
    if (_hourChange) {
        _hourChange(intHour);
    }
    
//    XYLog(@"%ld", intHour);
}

//拖动分针旋转
- (void)minutePan:(UIPanGestureRecognizer *)gesture{
    CGPoint translation = [gesture translationInView:gesture.view];

    float minuteProgress = translation.x / gesture.view.bounds.size.height * 0.3;
    
    //累计时针的百分比
    self.minutePercent += minuteProgress;
    if (self.minutePercent >= 1) {//重置
        self.minutePercent -= 1;
    }else if (self.minutePercent <= -1){
        self.minutePercent += 1;
    }
    
    self.minuteView.transform = CGAffineTransformRotate(self.minuteView.transform, M_PI * 2 * minuteProgress);

    [gesture setTranslation:CGPointZero inView:gesture.view];
    
    //计算旋转后的小时
    float minute = 60 * self.minutePercent + self.currentMinute;
//将浮点分钟数转换为整数
    NSInteger intMinute = ((NSInteger)(minute + 0.5)) % 60;
    if (intMinute < 0) {
        intMinute += 60;
    }
    
    //block传值
    if (_minuteChange) {
        _minuteChange(intMinute);
    }
    
//    XYLog(@"%ld", intMinute);
}

- (void)dealloc{
    XYLog(@"销毁");
}
@end
