//
//  XYEventTextView.m
//  Footprint
//
//  Created by 李小亚 on 16/3/30.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import "XYEventTextView.h"

@interface XYEventTextView ()

/**
 *  占位符标签
 */
@property (nonatomic, weak) UILabel *placeHolderLabel;

@end

@implementation XYEventTextView

- (void)setPlaceHolderLabel:(UILabel *)placeHolderLabel{
    _placeHolderLabel = placeHolderLabel;
    placeHolderLabel.x = 5;
    placeHolderLabel.y = 6;
}

//初始化
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        //添加占位符
        UILabel *phl = [[UILabel alloc] init];
        [self addSubview:phl];
        self.placeHolderLabel = phl;

        //默认字体
        self.font = XYTextViewFont;
        self.alwaysBounceVertical = YES;
        self.returnKeyType = UIReturnKeyDone;
        
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.placeHolderLabel.text = self.placeholder;
    [self.placeHolderLabel sizeToFit];
}

//设置占位符标签与TextVIew的字体一致
- (void)setFont:(UIFont *)font{
    [super setFont:font];
    self.placeHolderLabel.font = font;
}

//隐藏占位符 
- (void)setHidenPlaceHolder:(BOOL)hidenPlaceHolder{
    _hidenPlaceHolder = hidenPlaceHolder;
    
    self.placeHolderLabel.hidden = hidenPlaceHolder;
}
@end
