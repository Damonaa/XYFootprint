//
//  XYWaveView.m
//  Footprint
//
//  Created by 李小亚 on 16/4/10.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import "XYWaveView.h"

@interface XYWaveView ()
/**
 *  波浪线的数目，默认5条
 */
@property (nonatomic, assign) NSUInteger numberOfWaves;
/**
 *  波浪线的颜色，默认白色
 */
@property (nonatomic, weak) UIColor *waveColor;
/**
 *  初始化首要的波浪线宽， 默认3.0
 */
@property (nonatomic, assign) CGFloat primaryWaveLineWidth;
/**
 *  其他次要的波浪线宽， 默认1.0
 */
@property (nonatomic, assign) CGFloat secondaryWaveLineWidth;
/**
 *  初始的时候，闲置状态的振幅， 默认0.01
 */
@property (nonatomic, assign) CGFloat idleAmplitude;
/**
 *  频率，默认1.5
 */
@property (nonatomic, assign) CGFloat frequency;
/**
 *  波浪线被逐级加入View，默认稠密度 5
 */
@property (nonatomic, assign) CGFloat density;
/**
 *  改变动画的速度以及方向 默认-0.15
 */
@property (nonatomic, assign) CGFloat phaseShift;

/**
 *  相位
 */
@property (nonatomic, assign) CGFloat phase;
/**
 *  振幅
 */
@property (nonatomic, assign) CGFloat amplitude;




@end

@implementation XYWaveView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor lightGrayColor];
        //初始化默认值
        self.numberOfWaves = 5;
        self.waveColor = [UIColor whiteColor];
        self.primaryWaveLineWidth = 3.0;
        self.secondaryWaveLineWidth = 1.0;
        self.idleAmplitude = 0.01;
        self.frequency = 1.5;
        self.density = 5;
        self.phaseShift = -0.15;
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect{
    //画背景颜色
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, self.bounds);
    [self.backgroundColor set];
    CGContextFillRect(context, rect);
    
    //画线
    for (int i = 0; i < _numberOfWaves; i ++) {
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        //线宽
        CGContextSetLineWidth(ctx, (i == 0 ? _primaryWaveLineWidth : _secondaryWaveLineWidth));
        
        CGFloat halfHeight = CGRectGetHeight(self.bounds) / 2.0;
        CGFloat width = CGRectGetWidth(self.bounds);
        CGFloat mid = width / 2.0;
        
        const CGFloat maxAmplitude = halfHeight - 4.0;
        //progress在1.0 到 0 之间
        CGFloat progress = 1.0 - (CGFloat)i / _numberOfWaves;
        CGFloat normalAmplitude = (1.5 * progress - 0.5) * _amplitude;
        
        CGFloat multiplier = MIN(1.0, ((progress / 3 * 2.0) + 1.0/3.0));
        //线的颜色
        [[_waveColor colorWithAlphaComponent:multiplier * CGColorGetAlpha(_waveColor.CGColor)] set];
        //画线，X上累加
        for (CGFloat x = 0; x < width +_density; x += _density) {
            
            //计算此条线在Y轴上的值
            CGFloat scaling = -pow(1/mid * (x - mid), 2) + 1;
            CGFloat y = scaling * maxAmplitude * normalAmplitude * sinf(2 * M_PI * (x / width) * _frequency + _phase) + halfHeight;
            
            if (x == 0) {
                CGContextMoveToPoint(ctx, x, y);
            }else{
                CGContextAddLineToPoint(ctx, x, y);
            }
            
        }
        CGContextStrokePath(ctx);
    }
}

/**
 *  根据lavel,重画波浪线
 *
 *  @param level 音量
 */
- (void)updateWithLevel:(CGFloat)level{
    self.phase += self.phaseShift;
    self.amplitude = fmax(level, self.idleAmplitude);
    [self setNeedsDisplay];
}
@end
