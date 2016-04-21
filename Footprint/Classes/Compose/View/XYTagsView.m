//
//  XYTagsView.m
//  Footprint
//
//  Created by 李小亚 on 16/4/11.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import "XYTagsView.h"
#import "XYTagsTool.h"
#import "XYEvent.h"

@interface XYTagsView ()

/**
 *  存放全部的标签按钮
 */
@property (nonatomic, strong) NSMutableArray *tagsBtn;
/**
 *  删除按钮
 */
@property (nonatomic, weak) UIButton *delBtn;
/**
 *  选中的按钮
 */
@property (nonatomic, weak) UIButton *selectedBtn;

/**
 *  是否是删除状态， 默认NO
 */
@property (nonatomic, assign, getter=isDeleteTag) BOOL deleteTag;

@end

@implementation XYTagsView

- (NSMutableArray *)tagsBtn{
    if (!_tagsBtn) {
        _tagsBtn = [NSMutableArray array];

    }
    return _tagsBtn;
}

+ (instancetype)show{
    XYTagsView *tagsView = [[self alloc] init];
    [tagsView setupAllChildView];
    [XYKeyWindow.rootViewController.view addSubview:tagsView];
    
    return tagsView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //检测通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTagsView) name:@"insertNewTag" object:nil];
    }
    return self;
}

#pragma mark - 添加子控件
- (void)setupAllChildView{
    //返回按钮
    UIButton *backBtn = [UIButton buttonWithTarget:self selcetor:@selector(backBtnClick) controlEvent:UIControlEventTouchUpInside normalImage:[UIImage imageNamed:@"arrow_left_normal"] highlightedImage:nil];
    [self addSubview:backBtn];
    self.backBtn = backBtn;
    //删除按钮
    UIButton *delBtn = [UIButton buttonWithTarget:self selcetor:@selector(delBtnClick:) controlEvent:UIControlEventTouchUpInside normalImage:[UIImage imageNamed:@"trash_normal"] highlightedImage:nil];
    [self addSubview:delBtn];
    self.delBtn = delBtn;
    
    //标签按钮
    NSInteger tagCount = [XYTagsTool sharedTagsTool].tags.count;
    NSArray *tagsTemp = [XYTagsTool sharedTagsTool].tags;
    for (NSInteger i = 0; i < tagCount + 1; i ++) {
        if (i != tagCount) {//标签按钮
            UIButton *tagBtn = [UIButton buttonWithTarget:self selcetor:@selector(tagBtnClick:) controlEvent:UIControlEventTouchUpInside title:tagsTemp[i]];
            [tagBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            tagBtn.tag = i;
            [self addSubview:tagBtn];
            [self.tagsBtn addObject:tagBtn];
        }else{//添加标签按钮
            UIButton *addBtn = [UIButton buttonWithTarget:self selcetor:@selector(tagBtnClick:) controlEvent:UIControlEventTouchUpInside normalImage:[UIImage imageNamed:@"add_tag_normal"] highlightedImage:nil];
            addBtn.tag = i;
            [self addSubview:addBtn];
            [self.tagsBtn addObject:addBtn];
        }
        
    }
}

#pragma mark -布局按钮
- (void)layoutSubviews{
    XYLog(@"tag layout subviews");
    [super layoutSubviews];
    
    //设置标签按钮的frame
    CGFloat margin = 10;
    
    //上一个按钮
    UIButton *lastBtn = nil;
    for (NSInteger i = 0; i < _tagsBtn.count; i ++) {
        UIButton *btn = _tagsBtn[i];
        [btn sizeToFit];
        btn.layer.cornerRadius = 8;
        btn.layer.masksToBounds = YES;
        btn.layer.borderWidth = 1;
        btn.layer.borderColor = [UIColor blackColor].CGColor;
        

        btn.x = CGRectGetMaxX(lastBtn.frame) + margin;
        if ((btn.x + btn.width) > self.width) {//如果按钮的frame超出父视图的frame，换行
            btn.x = 10;
            btn.y = CGRectGetMaxY(lastBtn.frame)+ margin;
        }else{//y轴坐标与上一个按钮一直
            btn.y = lastBtn.y;
        }

        lastBtn = btn;
        
        //如果已经设置了tag
        if (_event.tag != nil) {
            if ([btn.currentTitle isEqualToString:_event.tag]) {
                btn.selected = YES;
                btn.backgroundColor = [UIColor blackColor];
                self.selectedBtn = btn;
            }
        }
    }
    
    //设置返回按钮的frame
    [_backBtn sizeToFit];
    _backBtn.x = margin;
    _backBtn.y = CGRectGetMaxY(lastBtn.frame) + margin;
    //设置删除按钮的frame
    [_delBtn sizeToFit];
    _delBtn.x = self.width - _delBtn.width - margin;
    _delBtn.y = _backBtn.y;
    
    self.height = CGRectGetMaxY(_delBtn.frame) + margin;
    self.y = XYScreenHeight - self.height;
    self.x = 0;
    self.width = XYScreenWidth;
}



#pragma mark -返回，隐藏标签
- (void)backBtnClick{
    [self hiddenTagsView];
    
}

#pragma mark - 隐藏标签视图
- (void)hiddenTagsView{
    [UIView animateWithDuration:0.5 animations:^{
        self.transform = CGAffineTransformMakeTranslation(-XYScreenWidth, 0);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        if ([self.delegate respondsToSelector:@selector(tagsViewDidChooseTag)]) {
            [self.delegate tagsViewDidChooseTag];
        }
    }];
}

#pragma mark - 删除标签
- (void)delBtnClick:(UIButton *)button{
    self.deleteTag = !self.deleteTag;
    if (self.deleteTag) {//NO
        [self startShake:button];
    }else{
        [self stopShake:button];
    }
}

//开始摇晃
- (void)startShake:(UIButton *)button{
    //更改按钮图片
    [button setImage:[UIImage imageNamed:@"tag_cancel_normal"] forState:UIControlStateNormal];
    for (int i = 0; i < _tagsBtn.count; i++) {
        UIButton *btn = _tagsBtn[i];
        if (i < _tagsBtn.count - 1) {
            CAKeyframeAnimation *shakeAnimation = [CAKeyframeAnimation animation];
            shakeAnimation.keyPath = @"transform.rotation";
            CGFloat angle = M_PI_4 * 0.2;
            shakeAnimation.values = @[@(-angle), @(angle), @(-angle)];
            shakeAnimation.duration = 1;
            shakeAnimation.repeatCount = MAXFLOAT;
            [btn.layer addAnimation:shakeAnimation forKey:@"shake"];
            
        }else{//添加按钮隐藏
            btn.hidden = YES;
        }
    }
}

//停止摇晃
- (void)stopShake:(UIButton *)button{
    //更改按钮图片
    [button setImage:[UIImage imageNamed:@"trash_normal"] forState:UIControlStateNormal];
    for (int i = 0; i < _tagsBtn.count; i++) {
        UIButton *btn = _tagsBtn[i];
        if (i < _tagsBtn.count - 1) {
           
            [btn.layer removeAnimationForKey:@"shake"];
            
        }else{//添加按钮隐藏
            btn.hidden = NO;
        }
    }
}
#pragma mark - 点击标签
- (void)tagBtnClick:(UIButton *)button{
    
    if (self.isDeleteTag) {//删除
        [self deleteTagButton:button];
    }else{//选中
        [self selectedTagButton:button];
    }
}

//删除
- (void)deleteTagButton:(UIButton *)button{
    
    if ([button.currentTitle isEqualToString:_event.tag]) {
        _event.tag = nil;
    }
    
    //将tag按钮从View中移除
    [button removeFromSuperview];
    
    //将tag从数组中移除
    [[XYTagsTool sharedTagsTool].tags removeObjectAtIndex:button.tag];
    
    //将tag从plist中删除
    NSString *tagsPath = [XYTagsTool sharedTagsTool].tagDir;
    [[XYTagsTool sharedTagsTool].tags writeToFile:tagsPath atomically:YES];
    
    //数组中的按钮移除,
    [_tagsBtn removeObjectAtIndex:button.tag];
    //修改剩下的标签按钮的tag
    for (UIButton *btn in _tagsBtn) {
        if (btn.tag > button.tag) {//如果数组中按钮的tag大于移除的，则将其tag - 1
            btn.tag -= 1;
        }
    }
    //重新布局
    [self layoutSubviews];
}
//选中
- (void)selectedTagButton:(UIButton *)button{
    if (button.tag != [XYTagsTool sharedTagsTool].tags.count) {//选中标签按钮
        self.selectedBtn.backgroundColor = [UIColor clearColor];
        self.selectedBtn.selected = NO;
        button.selected = YES;
        button.backgroundColor = [UIColor blackColor];
        self.selectedBtn.selected = YES;
        if (_tagStr) {
            _tagStr(button.currentTitle);
            _tagStr = nil;
        }
        //隐藏标签视图
        [self hiddenTagsView];
    }else{//添加标签按钮
        //添加标签
        if ([self.delegate respondsToSelector:@selector(tagsViewAddNewTag)]) {
            [self.delegate tagsViewAddNewTag];
        }
    }
}

#pragma mark - 刷新视图
- (void)refreshTagsView{
    //移除子视图
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    //清空数组
    [self.tagsBtn removeAllObjects];
    
    //重新添加子控件
    [self setupAllChildView];
    //布局
    [self layoutSubviews];
}

- (void)dealloc{
    XYLog(@"标签视图销毁");
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
