//
//  XYComposeController.m
//  Footprint
//
//  Created by 李小亚 on 16/3/30.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import "XYComposeController.h"
#import "XYEventTextView.h"
#import "UIBarButtonItem+XY.h"
#import "XYSqliteTool.h"
#import "XYCalenderView.h"
#import "XYCover.h"
#import "XYEvent.h"
#import "XYRecord.h"
#import "XYEventDetailView.h"
#import "TZImagePickerController.h"
#import "XYRecordView.h"
#import "XYWaveView.h"
#import <AVFoundation/AVFoundation.h>
#import "XYTagsTool.h"
#import "XYTagsView.h"
#import "XYMapViewController.h"

@interface XYComposeController ()<UITextViewDelegate, XYCoverDelegate, XYEventDetailViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, TZImagePickerControllerDelegate, XYRecordViewDelegate, AVAudioRecorderDelegate, XYTagsViewDelegate>

/**
 *  输入文本View
 */
@property (nonatomic, weak) XYEventTextView *eventTextView;

/**
 *  事件详情视图
 */
@property (nonatomic, weak) XYEventDetailView *eventDetailView;
/**
 *  日历
 */
@property (nonatomic, weak) XYCalenderView *calenderView;
/**
 *  蒙板
 */
@property (nonatomic, weak) XYCover *cover;
/**
 *  录音视图
 */
@property (nonatomic, weak) XYRecordView *recordView;

/**
 *  标签视图
 */
@property (nonatomic, weak) XYTagsView *tagsView;

/**
 *  录音
 */
@property (nonatomic, strong) AVAudioRecorder *audioRecord;
/**
 *  播放
 */
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
/**
 *  录音的名称
 */
@property (nonatomic, copy) NSString *audioName;
/**
*  录音存放的路径
*/
@property (nonatomic, copy) NSString *audioDir;

/**
 *  定时器
 */
@property (nonatomic, strong) CADisplayLink *displayLink;
/**
 *  左边一条细线，装饰用
 */
@property (nonatomic, strong) CALayer *thinLine;
/**
 *  左上角一个圆
 */
@property (nonatomic, strong) CALayer *dotView;

/**
 *  需要修改的通知的key
 */
@property (nonatomic, copy) NSString *originalNotiKey;
/**
 *  需要修改的通知的原始音频的名字
 */
@property (nonatomic, copy) NSString *originalAudioName;

@end

@implementation XYComposeController

#pragma mark - 懒觉载
- (AVAudioRecorder *)audioRecord{
    if (!_audioRecord) {
        //保存路径
        self.audioName = [[NSDate currentDateStr] stringByAppendingString:@".m4a"];
        self.audioDir = [[XYFileTool sharedFileTool].audiosPath stringByAppendingPathComponent:_audioName];
        
        //录音属性
        NSMutableDictionary *recordSetting = [NSMutableDictionary dictionary];
        //录音格式
//         CoreAudioTypes
        recordSetting[AVFormatIDKey] = @(kAudioFormatMPEG4AAC);
        //采样率
        recordSetting[AVSampleRateKey] = @44100.0;
        //通道
        recordSetting[AVNumberOfChannelsKey] = @2;
        _audioRecord = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:_audioDir] settings:recordSetting error:NULL];
        _audioRecord.delegate = self;
        
    }
    return _audioRecord;
}


- (XYEvent *)event{
    if (!_event) {
        _event = [[XYEvent alloc] init];
    }
    return _event;
}

#pragma mark - 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    self.title = self.isModifyEvent ? @"修改事件" : @"新计划";
    
    if (self.isModifyEvent) {
        self.originalNotiKey = _event.notiKey;
        //禁用标签按钮的点击
//        _event.disableChangeTag = YES;
    }
    
    //添加子控件
    [self setupChildView];
    
    //添加左右BarButtonItem
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem barButtonItemWithNormalImage:[UIImage imageNamed:@"arrow_left_normal"] hightlightImage:nil target:self selcetor:@selector(leftBtnClick) controlEvent:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem barButtonItemWithNormalImage:[UIImage imageNamed:@"done"] hightlightImage:nil target:self selcetor:@selector(rightBtnClick) controlEvent:UIControlEventTouchUpInside];
}

#pragma mark - 点击取消，返回上一控制器
- (void)leftBtnClick{
    [self.navigationController popViewControllerAnimated:YES];

    if (self.isModifyEvent) {//如果是修改，则点击取消不做任何处理
        return;
    }
    //删除存入沙盒的图片，音频
    if (_event.images.count) {
        for (NSString *imageName in _event.images) {
            [[XYFileTool sharedFileTool] removeImageWithName:imageName];
        }
    }
    //删除录音
    if (_event.audioDuration > 0) {
        [[XYFileTool sharedFileTool] removeAudioWithName:_event.audioName];
    }
    
}

#pragma mark - 保存事件到数据库
- (void)rightBtnClick{
    //创建本地通知

    [self setupLocalNotification];
    
    if (self.isModifyEvent) {//修改原事件
        [self modifyOriginalLocalNoti];
    }else{//创建新事件
        [self creatNewLocalNoti];
    }
    
    //发出通知，新事件创建，通知XYEventsViewController,XYListViewController
    if (self.event.tag == nil) {
        self.event.tag = @"(null)";
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"createdEventAtTag" object:self userInfo:@{@"newEventTag":self.event.tag}];
    
    [self.navigationController popViewControllerAnimated:YES];
}
//创建新的本地通知
- (void)creatNewLocalNoti{
    
    //保存到数据库
    //转换event数据
    [self transformEventText];
    NSString *strImages;
    if (_event.images.count > 0) {
        NSData *jsonImages = [NSJSONSerialization dataWithJSONObject:_event.images options:NSJSONWritingPrettyPrinted error:NULL];
        strImages = [[NSString alloc] initWithData:jsonImages encoding:NSUTF8StringEncoding];
    }
    NSData *regionD = [NSKeyedArchiver archivedDataWithRootObject:_event.region];
    
    
    NSString *sqlStr = [NSString stringWithFormat:@"insert into t_event (text, remindDate, remindLoc, region, frequency, images, audioName, audioDuration, notiKey, tag, complete) values ('%@', '%@', '%@', '%@', %u, '%@', '%@', %f, '%@', '%@', %d)", _event.text, _event.remindDate, _event.remindLoc, regionD, _event.frequency, strImages, _event.audioName, _event.audioDuration, _event.notiKey, _event.tag, _event.completeEvent];
    BOOL flag =  [XYSqliteTool executeUpdate:sqlStr];
    if (flag) {
        XYLog(@"新事件保存到数据库成功");
    }
}

- (void)showAttentionAlertWithText:(NSString *)text{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"注意了" message:text preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"知道了哟" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}
//转换event数据，便于数据可以被数据库存储利用
- (void)transformEventText{
    if (self.eventTextView.text.length > 0 && self.event.remindDate.length > 0) {
        self.event.text = [self.eventTextView.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    }
}
//修改原有的本地通知
- (void)modifyOriginalLocalNoti{
    
    //转换event数据
    [self transformEventText];
    NSString *strImages;
    if (_event.images.count > 0) {
        NSData *jsonImages = [NSJSONSerialization dataWithJSONObject:_event.images options:NSJSONWritingPrettyPrinted error:NULL];
        strImages = [[NSString alloc] initWithData:jsonImages encoding:NSUTF8StringEncoding];
    }
    NSData *regionD = [NSKeyedArchiver archivedDataWithRootObject:_event.region];
    //更新数据库
    NSString *sql = [NSString stringWithFormat:@"update t_event set text = '%@', remindDate = '%@', remindLoc = '%@', region = '%@', frequency = %u, images = '%@', audioName = '%@', audioDuration = %f, notiKey = '%@', tag = '%@', complete = %d where notiKey = '%@'",  _event.text, _event.remindDate, _event.remindLoc, regionD, _event.frequency, strImages, _event.audioName, _event.audioDuration, _event.notiKey, _event.tag, _event.completeEvent, _originalNotiKey];
    XYLog(@"%@", sql);
    BOOL flag = [XYSqliteTool executeUpdate:sql];
    if (flag) {
        XYLog(@"修改事件保存到数据库成功");
    }

}
#pragma mark - 创建本地通知
- (void)setupLocalNotification{//77.63
    
    //时间和地点至少设置一个
    if (_event.remindDate == nil && _event.remindLoc == nil) {
        [self showAttentionAlertWithText:@"你要告诉我个时间或者地址,不然我提醒个鬼啊！！"];
        return;
    }
    //文字，声音，图片三者必须有起义
    BOOL hasText;
    if (_event.text != nil && ![_event.text isEqualToString:@"(null)"]) {
        hasText = YES;
    }else{
        hasText = NO;
    }
    
    if (!hasText && _event.images.count == 0 && _event.audioDuration == 0.0) {
        
        [self showAttentionAlertWithText:@"什么都不写，你要提醒的是什么事啊！"];
        return;
    }

    
    //先取消通知
    if (self.isModifyEvent && !self.event.completeEvent) {//修改事件，并且是没有完成的事件
        //取消通知
        [[XYFileTool sharedFileTool] cancelLocalNotiWithKey:_event.notiKey];
    }
    //将完成的事件改为未完成
    if (self.event.completeEvent) {
        self.event.completeEvent = NO;
    }
    //创建本地通知
    UILocalNotification *localNoti = [[UILocalNotification alloc] init];
    //触发事件
    NSDateFormatter *dateForm = [[NSDateFormatter alloc] init];
    dateForm.dateFormat = @"yyyy-MM-dd HH:mm";
    NSDate *fireDate = [dateForm dateFromString:self.event.remindDate];
    localNoti.fireDate = fireDate;
    
    if (_event.text != nil && ![_event.text isEqualToString:@"(null)"]) {
        localNoti.alertBody = self.event.text;
    }else if (_event.images.count > 0){
        localNoti.alertBody = [NSString stringWithFormat:@"有%ld张图片", _event.images.count];
    }else if (_event.audioDuration > 0.0){
        localNoti.alertBody = @"有录音";
    }
    
    
    localNoti.alertAction = @"快点划开";
    if (_event.region) {
        localNoti.region = _event.region;
    }
    //设置重复频率
    switch (self.event.frequency) {
        case RepeatFrequenceNever:
            localNoti.repeatInterval = 0;
            break;
        case RepeatFrequenceDay:
            localNoti.repeatInterval = kCFCalendarUnitDay;
            break;
        case RepeatFrequenceMonToFir:
            localNoti.repeatInterval = kCFCalendarUnitWeekday;
            break;
        case RepeatFrequenceWeek:
            localNoti.repeatInterval = NSCalendarUnitWeekOfMonth;
            break;
        case RepeatFrequenceMonth:
            localNoti.repeatInterval = kCFCalendarUnitMonth;
            break;
        case RepeatFrequenceYear:
            localNoti.repeatInterval = kCFCalendarUnitYear;
            break;
            
        default:
            localNoti.repeatInterval = 0;
            break;
    }
    
    localNoti.alertLaunchImage = @"launchImage";
    localNoti.soundName = UILocalNotificationDefaultSoundName;
    //以提醒时间作为Key，用于取消推送通知
    //以创建的时间作为通知的key
    self.event.notiKey = [NSDate currentDateStr];
    localNoti.userInfo = @{@"key": self.event.notiKey};
    [[UIApplication sharedApplication] scheduleLocalNotification:localNoti];
}

#pragma mark - 添加子控件
- (void)setupChildView{
    //导航栏底部添加一条细线
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, XYScreenWidth, 1.3)];
    [self.view addSubview:lineView];
    lineView.backgroundColor = [UIColor lightGrayColor];
    
    //输入文本
    XYEventTextView *eventTextView = [[XYEventTextView alloc] init];
//    eventTextView.backgroundColor = [UIColor redColor];
    eventTextView.delegate = self;
    [self.view addSubview:eventTextView];
    self.eventTextView = eventTextView;
    eventTextView.placeholder = @"你想干点啥捏......";
    if (self.isModifyEvent && ![_event.text isEqualToString:@"(null)"]) {
        self.eventTextView.text = _event.text;
        self.eventTextView.hidenPlaceHolder = YES;
    }

    

    CGFloat margin = 20;
    eventTextView.frame = CGRectMake(margin, 64 + margin / 2 , XYScreenWidth - margin * 2, 50);
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewTextDidChange) name:UITextViewTextDidChangeNotification object:nil];

    //左上角添加一个圆
    CALayer *dotView = [CALayer layer];
    self.dotView = dotView;
    [self.view.layer addSublayer:dotView];
    dotView.frame = CGRectMake(margin / 4, CGRectGetMinY(eventTextView.frame), margin / 2, margin / 2);
    dotView.cornerRadius = dotView.bounds.size.width / 2;
    dotView.masksToBounds = YES;
    dotView.backgroundColor = [UIColor orangeColor].CGColor;
    
    //左边添加一条细线
    CALayer *thinLine = [CALayer layer];
    self.thinLine = thinLine;
    [self.view.layer addSublayer:thinLine];
    thinLine.backgroundColor = [UIColor orangeColor].CGColor;
    //线宽
    CGFloat thinLineW = 1;
    thinLine.frame = CGRectMake(margin / 2 - thinLineW / 2, CGRectGetMaxY(dotView.frame), thinLineW, CGRectGetHeight(eventTextView.frame));
    //显示事件详细内容
    XYEventDetailView *eventDetailView = [[XYEventDetailView alloc] init];
    [self.view addSubview:eventDetailView];
    self.eventDetailView = eventDetailView;
    eventDetailView.frame = CGRectMake(5, CGRectGetMaxY(eventTextView.frame) + 20, XYScreenWidth - 10, XYScreenHeight);
    eventDetailView.event = self.event;
    eventDetailView.delegate = self;
}

#pragma mark UITextViewDelegate XYEventTextView文本内容变化通知
- (void)textViewTextDidChange{
    //隐藏占位符
    if (self.eventTextView.text.length > 0) {
        self.eventTextView.hidenPlaceHolder = YES;
    }else{
        self.eventTextView.hidenPlaceHolder = NO;
    }
//    
    CGSize maxSize = CGSizeMake(XYScreenWidth - 20, MAXFLOAT);
    CGSize size = [self.eventTextView.text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:XYTextViewFont} context:nil].size;
    //当文本输入size大于初始预设的高度的时候，重新设置高度
    if (size.height > 35) {
       self.eventTextView.height = size.height + 30;
    }else if(size.height > XYScreenHeight / 4){//最大不超过屏幕的三分之一高
        self.eventTextView.height = XYScreenHeight / 4;
    }else{//最小60
        self.eventTextView.height = 50;
    }
    
    //细线的高度与输入文本框一致
    self.thinLine.frame = CGRectMake(20 / 2 - 1 / 2, CGRectGetMaxY(_dotView.frame), 1, CGRectGetHeight(_eventTextView.frame));
    
//    根据输入文本的frame的变化，改变工具视图的Y
    [UIView animateWithDuration:0.25 animations:^{
        self.eventDetailView.y = CGRectGetMaxY(self.eventTextView.frame) + 20;
    }];
    
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
      
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}
//结束编辑，为事件的文本赋值
- (void)textViewDidEndEditing:(UITextView *)textView{
    self.event.text = _eventTextView.text;
}
#pragma mark - XYEventDetailViewDelegate
- (void)eventDetailViewDidClickButton:(UIButton *)button{
    //退出键盘
    [self.view endEditing:YES];
    switch (button.tag) {
        case 0:
            //显示日历，设置时间
            [self chooseTime];
            break;
        case 1:
            //设置提醒地点, 跳转到地图视图控制器
            [self jumpToMapView];
            
            break;
        case 2:
            //添加图片
            [self addPictures];
            break;
        case 3:
            //录音
            [self recordAudio];
            break;
        case 4:
            //添加标签
            [self setupTag];
            break;

    }
}
// 跳转到地图视图控制器
- (void)jumpToMapView{
    XYMapViewController *mapVC = [[XYMapViewController alloc] init];
    
    if (_event.region) {
        mapVC.completeRegion = _event.region;    
    }
    
    mapVC.remindRegion = ^(CLRegion *region, NSString *address){
        _event.region = region;
        _event.remindLoc = address;
        XYLog(@"region: %@, -- %@", region, address);
    };
    
    [self.navigationController pushViewController:mapVC animated:YES];
}

#pragma mark - 播放录音
- (void)eventDetailViewDidClickPlayerButton{
    if (_audioPlayer.isPlaying) {
        [_audioPlayer stop];
    }else{
        [_audioPlayer prepareToPlay];
        [_audioPlayer play];
    }
}
#pragma mark - 删除录音
- (void)eventDetailViewDidSwipePlayerButton{
    //删除录音
    [[XYFileTool sharedFileTool] removeAudioWithName:_event.audioName];
    
    if (self.isModifyEvent) {//是从主界面跳转过来的，修改事件
        //更新数据库
        NSString *sql = [NSString stringWithFormat:@"update t_event set audioName = '%@', audioDuration = 0 where notiKey = '%@'",nil, _originalNotiKey];
        [XYSqliteTool executeUpdate:sql];
        self.event.audioName = nil;
        self.event.audioDuration = 0;
    }
    
}
#pragma mark - 设定提醒时间
- (void)chooseTime{
    //显示蒙版
    self.cover =[XYCover show];
    self.cover.delegate = self;
    //显示日历
    self.calenderView = [XYCalenderView showCalender];
    __weak typeof(self) weakSelf = self;
    self.calenderView.complete = ^(NSString *selectedTime){
        if (selectedTime) {
            XYLog(@"%@", selectedTime);
            weakSelf.event.remindDate = selectedTime;
            
            [self.cover hiddenCover];
        }
    };
    
}
#pragma mark - 添加图片
- (void)addPictures{
    //设置选取方式
    UIAlertController *alertCtr = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    //进入相机
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // Snapshotting a view that has not been rendered results in an empty snapshot. Ensure your view has been rendered at least once before snapshotting or snapshot after screen updates
            UIImagePickerController *pickerCtr = [[UIImagePickerController alloc] init];
            pickerCtr.delegate = self;
            pickerCtr.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:pickerCtr animated:YES completion:nil];   
    }];
    [alertCtr addAction:cameraAction];
    
    //进入相册
    UIAlertAction *albumAction = [UIAlertAction actionWithTitle:@"从相册中选取" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        TZImagePickerController *imagePicker = [[TZImagePickerController alloc] initWithMaxImagesCount:4 delegate:self];

        [self presentViewController:imagePicker animated:YES completion:nil];
    }];
    [alertCtr addAction:albumAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertCtr addAction:cancelAction];
    [self presentViewController:alertCtr animated:YES completion:nil];
    
}
#pragma mark - 录音
- (void)recordAudio{
    [_displayLink invalidate];
    self.event.audioDuration = 0.0;
    //删除之前的录音
    if (self.isModifyEvent) {//修改的，先删除之前的录音
        if (_originalAudioName != nil) {
            [[XYFileTool sharedFileTool] removeAudioWithName:_originalAudioName];
        }
    }
    //开始录音
    if (self.audioRecord != nil && self.audioRecord.isRecording) {//正在录音
        [self recordViewDidFinishRecord];
        return;
    }
    //添加录音视图到导航栏
    
    XYRecordView *recordView = [[XYRecordView alloc] init];
    self.recordView = recordView;
    [self.navigationController.navigationBar addSubview:recordView];
    
    CGRect navBounds = self.navigationController.navigationBar.bounds;
    recordView.frame = navBounds;
    recordView.y = -recordView.height - 20;
    recordView.delegate = self;
    
    [UIView animateWithDuration:0.2 animations:^{
        recordView.transform = CGAffineTransformMakeTranslation(0, 64);
    } completion:^(BOOL finished) {
#warning AVAudioSession
        //添加会话，才能录音
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:nil];
        self.audioRecord.meteringEnabled = YES;
        [self.audioRecord prepareToRecord];
        [self.audioRecord record];
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateMeters)];
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        
    }];
    
}
//更新当前录音
- (void)updateMeters{
    [_audioRecord updateMeters];
    CGFloat normalizedValue = pow(15, 1 / (-[_audioRecord peakPowerForChannel:0]));
//    XYLog(@"%lf, ---- %lf",[_audioRecord averagePowerForChannel:0], normalizedValue);
    
    [_recordView.waveView updateWithLevel:normalizedValue];
    //更新当前时间
    _recordView.durationLabel.text = [NSString timeStringForTimeInterval:_audioRecord.currentTime];
//    XYLog(@"%f", _audioRecord.currentTime);
}

#pragma mark - 添加标签
- (void)setupTag{
    //添加蒙版
    _cover = [XYCover show];
    _cover.delegate = self;
    
    //添加标签视图
    XYTagsView *tagsView = [XYTagsView show];
    self.tagsView = tagsView;
    tagsView.event = _event;
    tagsView.delegate = self;
    
    //重画，设置frame
    [tagsView layoutSubviews];
    tagsView.tagStr = ^(NSString *tag){
        _event.tag = tag;
    };
    
}

#pragma mark - XYTagsViewDelegate
- (void)tagsViewDidChooseTag{
    [_cover hiddenCover];
}
- (void)tagsViewAddNewTag{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"添加新标签" message:@"新标签的名称不能与现有的重复" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert addAction:cancelAction];
    
    UIAlertAction *doneAction = [UIAlertAction actionWithTitle:@"完成" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSString *inputTag = [alert.textFields.firstObject text];
        if (inputTag.length > 0) {
            //
            NSArray *tags = (NSMutableArray *)[XYTagsTool sharedTagsTool].tags;
            for (NSString *tag in tags) {
                if ([inputTag isEqualToString:tag]) {
                    return;
                }
            }
            //为模型赋值
            _event.tag = inputTag;
            //将新写入的标签加入内存
           [[XYTagsTool sharedTagsTool].tags addObject:inputTag];
            //写入plist中
            BOOL flag = [[XYTagsTool sharedTagsTool] writeTagToFileWithTag:inputTag];
            if (flag) {
                XYLog(@"plist success");
                //重新刷新，发出通知
                [[NSNotificationCenter defaultCenter] postNotificationName:@"insertNewTag" object:nil userInfo:@{@"newTag": inputTag}];
            }
        }
    }];
    [alert addAction:doneAction];
    //添加文本输入窗口
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
    }];
    [self presentViewController:alert animated:YES completion:nil];
}



#pragma mark - XYRecordViewDelegate
//点击完成按钮，保存到沙盒
- (void)recordViewDidFinishRecord{
#warning AVAudioSession
//    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:nil];
    [_audioRecord stop];
    _audioRecord.meteringEnabled = NO;
    [_displayLink invalidate];//移除定时器
    //移除录音视图
    [UIView animateWithDuration:0.2 animations:^{
        _recordView.transform = CGAffineTransformMakeTranslation(0, -64);
    } completion:^(BOOL finished) {
        [_recordView removeFromSuperview];
    }];
    
#warning AVAudioSession
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    //创建播放器
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:_audioDir] error:NULL];
    
    self.event.audioName = _audioName;
    self.event.audioDuration = _audioPlayer.duration;
    
//    XYLog(@"%@", _audioPath);
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    XYLog(@"%@", info);
    
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    [self saveImageToSandboxWithImage:image name:nil];

    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - TZImagePickerControllerDelegate
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets{
    if (photos.count > 0) {
        int i = 0;
        for (UIImage *image in photos) {
            //拼接图片名称，同时添加多个，在时间后面加上index
            NSString *indexName = [NSString stringWithFormat:@"%d.jpg", i];
            NSString *name = [[NSDate currentDateStr] stringByAppendingString:indexName];
            
            [self saveImageToSandboxWithImage:image name:name];
            i ++;
//            XYLog(@"%@", image);
        }
    }
}
//保存图片到沙盒
- (void)saveImageToSandboxWithImage:(UIImage *)image name:(NSString *)name{
    NSData *imageData = UIImagePNGRepresentation(image);
    //生成图片的名称，以创建的时间作为图片名
    if (!name) {
        name = [[NSDate currentDateStr] stringByAppendingString:@".jpg"];
    }
   
    NSString *imagePath = [[XYFileTool sharedFileTool].imagesPath stringByAppendingPathComponent:name];
    //图片写入沙盒
    BOOL write = [imageData writeToFile:imagePath atomically:YES];
    if (write) {
        XYLog(@"write success");
        //为模型对象添加 图片名
        [[_event mutableArrayValueForKey:@"images"] addObject:name];
        
    }else{
        XYLog(@"write failure");
    }
}

#pragma mark - UIScrollView delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
}

#pragma mark - XYCoverDelegate 点击蒙板
- (void)coverDidClickCover:(XYCover *)cover{
    [self.calenderView hiddenCalender];
    [self.tagsView hiddenTagsView];
}
/**
 *  移除通知
 */
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.audioRecord stop];
    self.audioRecord = nil;
    [self.audioPlayer stop];
    self.audioPlayer = nil;

    XYLog(@"销毁");
}

@end
