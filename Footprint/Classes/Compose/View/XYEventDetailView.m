//
//  XYEventDetailView.m
//  Footprint
//
//  Created by 李小亚 on 16/4/7.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#define XYDetailMargin 10

#import "XYEventDetailView.h"
#import "XYRepeatFrequencyView.h"
#import "XYEvent.h"
#import "XYPhotosView.h"
#import "XYRecord.h"

@interface XYEventDetailView ()<XYPhotosViewDelegate>

/**
 *  存放按钮
 */
@property (nonatomic, strong) NSMutableArray *btns;

/**
 *  显示提醒时间的按钮， 默认为当前时间
 */
@property (nonatomic, weak) UIButton *remindDateBtn;
/**
 *  显示提醒地点的按钮
 */
@property (nonatomic, weak) UIButton *remindLocBtn;
/**
 *  重复频率视图
 */
@property (nonatomic, weak) XYRepeatFrequencyView *repeatFrequencyView;
/**
 *  图片
 */
@property (nonatomic, weak) UIButton *pictureBtn;
/**
 *  存放添加的图片
 */
@property (nonatomic, weak) XYPhotosView *photosView;
/**
 *  录音
 */
@property (nonatomic, weak) UIButton *recordBtn;
/**
 *  播放, 默认隐藏
 */
@property (nonatomic, weak) UIButton *playerBtn;
/**
 *  标签
 */
@property (nonatomic, weak) UIButton *tagBtn;
@end


@implementation XYEventDetailView


- (NSMutableArray *)btns{
    if (!_btns) {
        _btns = [NSMutableArray array];
    }
    return _btns;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupAllChildView];
//        self.backgroundColor = [UIColor brownColor];
    }
    return self;
}

#pragma mark - 添加子控件们
- (void)setupAllChildView{
    //1.提醒时间按钮
    UIButton *remindDateBtn = [UIButton toolButtonWithNormalImage:[UIImage imageNamed:@"alarm_clock_normal"] hightlightImage:nil target:self selcetor:@selector(detailBtnClick:) controlEvent:UIControlEventTouchUpInside title:@"何时提醒"];
    [self addSubview:remindDateBtn];
    self.remindDateBtn = remindDateBtn;
    remindDateBtn.tag = self.btns.count;
    [self.btns addObject:remindDateBtn];
    
    //提醒地点的按钮
    UIButton *remindLocBtn = [UIButton toolButtonWithNormalImage:[UIImage imageNamed:@"location_normal"] hightlightImage:nil target:self selcetor:@selector(detailBtnClick:) controlEvent:UIControlEventTouchUpInside title:@"何地提醒"];
    [self addSubview:remindLocBtn];
    self.remindLocBtn = remindLocBtn;
    remindLocBtn.tag = self.btns.count;
    [self.btns addObject:remindLocBtn];
    
    //2. 重复方法方式
    __weak typeof(self) weakSelf = self;
    XYRepeatFrequencyView *repeatFrequencyView = [[XYRepeatFrequencyView alloc] init];
    [self addSubview:repeatFrequencyView];
    self.repeatFrequencyView = repeatFrequencyView;
    _repeatFrequencyView.showOptionBlock = ^(BOOL showOption){
//        XYLog(@"%d", showOption);
        weakSelf.event.showOptions = showOption;
    };
    _repeatFrequencyView.frequencyTagBlock = ^(NSInteger tag){
        XYLog(@"%ld", (long)tag);
        switch (tag) {
            case 0:
                weakSelf.event.frequency = RepeatFrequenceNever;
                break;
                
            case 1:
                weakSelf.event.frequency = RepeatFrequenceDay;
                break;
            case 2:
                weakSelf.event.frequency = RepeatFrequenceMonToFir;
                break;
            case 3:
                weakSelf.event.frequency = RepeatFrequenceWeek;
                break;
            case 4:
                weakSelf.event.frequency = RepeatFrequenceMonth;
                break;
            case 5:
                weakSelf.event.frequency = RepeatFrequenceYear;
                break;
            default:
                weakSelf.event.frequency = RepeatFrequenceNever;
                break;
        }
    };

    
    //3. 图片按钮
    UIButton *pictureBtn = [UIButton toolButtonWithNormalImage:[UIImage imageNamed:@"picture_normal"] hightlightImage:nil target:self selcetor:@selector(detailBtnClick:) controlEvent:UIControlEventTouchUpInside title:@"选取图片"];
    [self addSubview:pictureBtn];
    self.pictureBtn = pictureBtn;
    pictureBtn.tag = self.btns.count;
    [self.btns addObject:pictureBtn];
    //存放图片的View
    XYPhotosView *photosView = [[XYPhotosView alloc] init];
//    photosView.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:photosView];
    self.photosView = photosView;
    photosView.delegate = self;
    
    
    //4. 录音按钮
    UIButton *recordBtn = [UIButton toolButtonWithNormalImage:[UIImage imageNamed:@"record_normal"] hightlightImage:[UIImage imageNamed:@"record_hightlighted"] target:self selcetor:@selector(detailBtnClick:) controlEvent:UIControlEventTouchUpInside title:@"录个音吧"];
    [self addSubview:recordBtn];
    self.recordBtn = recordBtn;
    recordBtn.tag = self.btns.count;
    [self.btns addObject:recordBtn];
     //添加一个播放按钮
    UIButton *playerBtn = [UIButton toolButtonWithNormalImage:[UIImage imageNamed:@"audio_play_normal"] hightlightImage:nil target:self selcetor:@selector(playerBtnClick) controlEvent:UIControlEventTouchUpInside title:@""];
    self.playerBtn = playerBtn;
    [self addSubview:playerBtn];
    playerBtn.hidden = YES;
    //添加手势，用于删除
    UISwipeGestureRecognizer *swipePlayer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipePlayerBtn:)];
    swipePlayer.direction = UISwipeGestureRecognizerDirectionRight;
    [playerBtn addGestureRecognizer:swipePlayer];
    
    //5. 标签按钮
    UIButton *tagBtn = [UIButton toolButtonWithNormalImage:[UIImage imageNamed:@"tag_normal"] hightlightImage:nil target:self selcetor:@selector(detailBtnClick:) controlEvent:UIControlEventTouchUpInside title:@"标签"];
    [self addSubview:tagBtn];
    self.tagBtn = tagBtn;
    tagBtn.tag = self.btns.count;
    [self.btns addObject:tagBtn];
//    //标签视图，默认隐藏
//    XYTagsView *tagsView = [[XYTagsView alloc] init];
//    self.tagsView = tagsView;
//    [self addSubview:tagsView];
}


#pragma mark - 监听event的变化
- (void)setEvent:(XYEvent *)event{
    _event = event;
    
    [self observeValueForKeyPath:nil ofObject:nil change:nil context:nil];
    [event addObserver:self forKeyPath:@"remindDate" options:NSKeyValueObservingOptionNew context:nil];
    [event addObserver:self forKeyPath:@"remindLoc" options:NSKeyValueObservingOptionNew context:nil];
    [event addObserver:self forKeyPath:@"showOptions" options:NSKeyValueObservingOptionNew context:nil];
    [event addObserver:self forKeyPath:@"frequency" options:NSKeyValueObservingOptionNew context:nil];
    [event addObserver:self forKeyPath:@"images" options:NSKeyValueObservingOptionNew context:nil];
    [event addObserver:self forKeyPath:@"audioDuration" options:NSKeyValueObservingOptionNew context:nil];
    [event addObserver:self forKeyPath:@"tag" options:NSKeyValueObservingOptionNew context:nil];
}

#pragma mark - 为控件赋值，设置frame
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    //设置remindDateBtn的属性
    [self setupRemindDateBtn];

    //设置remindLocBtn的属性
    [self setupRemindLocBtn];
    //设置重复频率视图
    [self setupFrequencyView];
    //添加图片
    [self setupPictureView];
    //设置录音按钮的frame
    [self setupRecordBtn];
    //添加标签，分组
    [self setupTag];
    
}
//设置remindDateBtn的属性
- (void)setupRemindDateBtn{
    if (_event.remindDate.length != 0 && ![_event.remindDate isEqualToString:@"(null)"]) {
        
        [_remindDateBtn setTitle:[self transformDateWithDateStr:_event.remindDate] forState:UIControlStateNormal];
    }else{
        [_remindDateBtn setTitle:@"何时提醒" forState:UIControlStateNormal];
    }
    _remindDateBtn.x = XYDetailMargin;
    _remindDateBtn.y = XYDetailMargin;
    [_remindDateBtn sizeToFit];
    _remindDateBtn.width += 10;
}

//转换时间样式
- (NSString *)transformDateWithDateStr:(NSString *)dateStr{
    
    NSDateFormatter *dateFormate = [[NSDateFormatter alloc] init];
    dateFormate.dateFormat = @"yyyy-MM-dd HH:mm";
    dateFormate.locale = [NSLocale localeWithLocaleIdentifier:@"zn_US"];
    
    NSDate *date = [dateFormate dateFromString:dateStr];
    
    //截取 时:分
    NSRange hourRange = [dateStr rangeOfString:@" "];
    NSString *hourStr = [dateStr substringFromIndex:hourRange.length + hourRange.location];
    NSString *finalStr;
    
    if ([date isToday]) {
        finalStr = [NSString stringWithFormat:@"今天 %@", hourStr];
    }else if ([date isTomorrow]){
        finalStr = [NSString stringWithFormat:@"明天 %@", hourStr];
    }else if ([date isTheDayAfterTomorrow]){
        finalStr = [NSString stringWithFormat:@"后天 %@", hourStr];
    }else{
        return dateStr;
    }
    
    return finalStr;

}
//设置remindLocBtn的属性
- (void)setupRemindLocBtn{
    if (_event.remindLoc.length != 0 && ![_event.remindLoc isEqualToString:@"(null)"]) {
        [self.remindLocBtn setTitle:_event.remindLoc forState:UIControlStateNormal];
    }else{
        [self.remindLocBtn setTitle:@"何地提醒" forState:UIControlStateNormal];
    }
    _remindLocBtn.x = XYDetailMargin;
    _remindLocBtn.y = CGRectGetMaxY(_remindDateBtn.frame) + XYDetailMargin;
    [_remindLocBtn sizeToFit];
    _remindLocBtn.width += 10;
}
//设置重复频率视图
- (void)setupFrequencyView{
    
    //修改的时候，设置按钮的状态
    if (_event.frequency != RepeatFrequenceNever) {
        UIButton *selectedBtn = _repeatFrequencyView.btns[_event.frequency];
        _repeatFrequencyView.selectedBtn = selectedBtn;
        [self.repeatFrequencyView.repeatBtn setTitle:selectedBtn.currentTitle forState:UIControlStateNormal];
    }
    
    if (_event.showOptions) {
        _repeatFrequencyView.frame = CGRectMake(0, CGRectGetMaxY(_remindLocBtn.frame) + 10, XYScreenWidth - 10, 70);
    }else{
        _repeatFrequencyView.frame = CGRectMake(0, CGRectGetMaxY(_remindLocBtn.frame) + 10, XYScreenWidth - 10, 35);
    }

}
//添加图片按钮，以及视图
- (void)setupPictureView{
    _pictureBtn.x = XYDetailMargin;
    _pictureBtn.y = CGRectGetMaxY(_repeatFrequencyView.frame) + XYDetailMargin;
    [_pictureBtn sizeToFit];
    _pictureBtn.width += 10;
    if (_event.images.count) {
//        XYLog(@"new image");
        _photosView.hidden = NO;
        _photosView.frame = CGRectMake(0, CGRectGetMaxY(_pictureBtn.frame), self.bounds.size.width, XYImageWidthHeight);
    }else{
        _photosView.height = 0;
        _photosView.hidden = YES;
    }
    
    //将图片路径存数组赋值给图片视图
    _photosView.photoNames = _event.images;
    [_photosView layoutSubviews];
    //最多添加4张照片
    self.pictureBtn.enabled = _event.images.count > 3 ? NO : YES;

}
//设置录音按钮的frame
- (void)setupRecordBtn{
    _recordBtn.x = XYDetailMargin;
    if (_event.images.count > 0) {//有图片
        _recordBtn.y = CGRectGetMaxY(_photosView.frame) + XYDetailMargin;
    }else{//无图片
        _recordBtn.y = CGRectGetMaxY(_pictureBtn.frame) + XYDetailMargin;
    }
    [_recordBtn sizeToFit];
    _recordBtn.width += 10;
    
   //显示播放按钮
    if (![_event.audioName isEqualToString:@"(null)"] && _event.audioName.length > 0 && _event.audioDuration != 0.0) {
        _playerBtn.hidden = NO;
        [_playerBtn setTitle:[NSString timeStringForTimeInterval:_event.audioDuration] forState:UIControlStateNormal];
        _playerBtn.y = _recordBtn.y;
        _playerBtn.x = CGRectGetMaxX(_recordBtn.frame) + XYDetailMargin;
        [_playerBtn sizeToFit];
        _playerBtn.width += 10;
        
    }else{
        _playerBtn.hidden = YES;
    }
}
//添加标签，分组
- (void)setupTag{
    
    //是否启用tagBtn
    self.tagBtn.enabled = !_event.disableChangeTag;
    
    if (_event.tag.length > 0 && ![_event.tag isEqualToString:@"(null)"]) {
        [_tagBtn setTitle:_event.tag forState:UIControlStateNormal];
    }else{
        [_tagBtn setTitle:@"标签" forState:UIControlStateNormal];
    }
    
    _tagBtn.x = XYDetailMargin;
    _tagBtn.y = CGRectGetMaxY(_recordBtn.frame) + XYDetailMargin;
    [_tagBtn sizeToFit];
    _tagBtn.width += 10;
}

#pragma mark - 点击播放按钮
- (void)playerBtnClick{
    if ([self.delegate respondsToSelector:@selector(eventDetailViewDidClickPlayerButton)]) {
        [self.delegate eventDetailViewDidClickPlayerButton];
    }
}
#pragma mark - 删除播放按钮
- (void)swipePlayerBtn:(UISwipeGestureRecognizer *)gesture{
    [UIView animateWithDuration:0.5 animations:^{
        _playerBtn.transform = CGAffineTransformMakeTranslation(XYScreenWidth, 0);
    } completion:^(BOOL finished) {
        _playerBtn.hidden = YES;
        
        if ([self.delegate respondsToSelector:@selector(eventDetailViewDidSwipePlayerButton)]) {
            [self.delegate eventDetailViewDidSwipePlayerButton];
        }
    }];
}
#pragma mark - XYPhotosViewDelegate
//删除图片
- (void)photosViewDeleteImageWithIndex:(NSInteger)index{
    [[_event mutableArrayValueForKey:@"images" ]  removeObjectAtIndex:index];

}
#pragma mark - 响应按钮的点击
- (void)detailBtnClick:(UIButton *)button{
    XYLog(@"%ld", (long)button.tag);
    //结束图片晃动的动画
    //发出通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"stopShake" object:nil];
    
    if ([self.delegate respondsToSelector:@selector(eventDetailViewDidClickButton:)]) {
        [self.delegate eventDetailViewDidClickButton:button];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    //结束图片晃动的动画
    //发出通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"stopShake" object:nil];
//    [self.nextResponder resignFirstResponder];
    XYLog(@"点击事件详情视图");
}
- (void)dealloc{
    [self.event removeObserver:self forKeyPath:@"remindDate"];
    [self.event removeObserver:self forKeyPath:@"remindLoc"];
    [self.event removeObserver:self forKeyPath:@"showOptions"];
    [self.event removeObserver:self forKeyPath:@"frequency"];
    [self.event removeObserver:self forKeyPath:@"images"];
    [self.event removeObserver:self forKeyPath:@"audioDuration"];
    [self.event removeObserver:self forKeyPath:@"tag"];
    XYLog(@"销毁");
}
@end
