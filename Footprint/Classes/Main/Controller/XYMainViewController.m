
//  XYMainViewController.m
//  Footprint
//
//  Created by 李小亚 on 16/3/30.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import "XYMainViewController.h"
#import "XYComposeController.h"
#import "XYTagsTool.h"
#import "XYEventCell.h"
#import "XYSqliteTool.h"
#import "XYEvent.h"
#import "XYEventFrame.h"
#import "XYMoveButton.h"
#import "XYWeatherTool.h"
#import <AVFoundation/AVFoundation.h>
#import "MJRefresh.h"
#import "XYListViewController.h"


#define XYAddBtnX @"addBtnX"
#define XYAddBtnY @"addBtnY"

@interface XYMainViewController ()<UITableViewDataSource, UITableViewDelegate, XYEventCellDelegate>
/**
 *  添加新事件按钮
 */
@property (nonatomic, weak) XYMoveButton *addBtn;
/**
 *  事件列表
 */
@property (nonatomic, weak) UITableView *eventsTableView;
/**
 *  存放添加的事件
 */
@property (nonatomic, strong) NSMutableArray *eventFramesArray;
/**
 *  播放
 */
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
/**
 *  上一次点击的cell的index
 */
@property (nonatomic, assign) NSInteger lastClickIndex;

@end

@implementation XYMainViewController



- (NSMutableArray *)eventFramesArray{
    if (!_eventFramesArray) {
        _eventFramesArray = [NSMutableArray array];
    }
    return _eventFramesArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"脚印";
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.925 alpha:1.000];

    UIButton *listBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [listBtn setImage:[UIImage imageNamed:@"tag_normal"] forState:UIControlStateNormal];
    [listBtn sizeToFit];
    [listBtn addTarget:self action:@selector(jumpToListVC) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:listBtn];
    
    //添加tableView 展示提示事项
    [self setupEventsTabelView];
    
   //添加add按钮
    [self setupAddBtn];
    
    //加载数据
    [self loadData];
    
    //监听天气通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshWeatherInfo:) name:@"getWeatherInfo" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshgWeatherFailure:) name:@"getWeatherFailure" object:nil];
    
    //监听是否有新数据添加进来, 事件总数变化
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadData) name:@"createdEventAtTag" object:nil];
    //监听EventViewCOntroller上点击图片，完成事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadData) name:@"addCompletedEvent" object:nil];
    //监听EventViewCOntroller上删除事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadData) name:@"deleteEventAtTag" object:nil];
    //监听删除组事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadData) name:@"deleteTagGroup" object:nil];
    
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//    [self.eventsTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    [self.eventsTableView reloadData];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSUserDefaults standardUserDefaults] setFloat:_addBtn.x forKey:XYAddBtnX];
    [[NSUserDefaults standardUserDefaults] setFloat:_addBtn.y forKey:XYAddBtnY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - 加载数据
- (void)loadData{
    [self.eventFramesArray removeAllObjects];
    //从数据库中查询所有未完成的数据
    NSArray *evetns = [XYSqliteTool executeQuaryWithUncompletedEvent];
    for (XYEvent *event in evetns) {
        XYEventFrame *eventFrame = [[XYEventFrame alloc] init];
        //判断是否该显示天气
//        2， 有时间
//        2.1 时间是 明天 后天 大后天，显示
//        计算某日期距离今天的差
        NSDate *date = [NSDate dateTransformFromStr:event.remindDate format:@"yyyy-MM-dd HH:mm"];
        NSInteger delta = [date daysDifferentsToToday];
        if (delta < 4 && delta > 0) {
            event.hasWeather = YES;
        }
        //为模型视图赋值
        eventFrame.event = event;
        //添加到数组中
        [self.eventFramesArray addObject:eventFrame];
    }
    [self.eventsTableView reloadData];

}

- (void)jumpToListVC{
    XYListViewController *listVC = [[XYListViewController alloc] init];
    [self.navigationController pushViewController:listVC animated:YES];
}

#pragma mark - 添加tableView 展示提示事项
- (void)setupEventsTabelView{
    UITableView *eventsTableView = [[UITableView alloc] init];
    [self.view addSubview:eventsTableView];
    
    self.eventsTableView = eventsTableView;
    
    self.eventsTableView.dataSource = self;
    self.eventsTableView.delegate = self;
    
    self.eventsTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.eventsTableView addHeaderWithTarget:self action:@selector(loadWeatherInfo)];
    self.eventsTableView.frame = self.view.bounds;
}

//下拉加载天气信息
- (void)loadWeatherInfo{
    
    for (XYEventFrame *eventFrame in self.eventFramesArray) {
        XYEvent *event = eventFrame.event;
        if (event.isHasWeather) {
            //发起请求
            [[XYWeatherTool sharedXYWeatherTool] requestLoaclForecastsWeather];

        }else{
            //停止刷新
            [self.eventsTableView headerEndRefreshing];
        }
    }
}
//获取天气成功
- (void)refreshWeatherInfo:(NSNotification *)noti{
    NSDictionary *weathersInfo = noti.userInfo;
    NSArray *weathers = weathersInfo[@"info"];
    
    for (AMapLocalDayWeatherForecast *forcast in weathers) {
        //逐一遍历获得的天气， 取得日期
        NSDate *resultDate = [NSDate dateTransformFromStr:forcast.date format:@"yyyy-MM-dd"];
        //与需要天气的成员日期对比
        int i = 0;
        for (XYEventFrame *eventFrame in _eventFramesArray) {
            XYEvent *event = eventFrame.event;
            if (event.isHasWeather) {
                NSDate *requestDate = [NSDate dateTransformFromStr:event.remindDate format:@"yyyy-MM-dd HH:mm"];
                //判断提醒的时间与获取的时间是否是同一天
                if ([NSDate isSameDayWithDate:resultDate andDate:requestDate]) {
                    
                    NSString *resualtWeather = [NSString stringWithFormat:@"天气:%@, 温度%@-%@",forcast.dayWeather,forcast.dayTemp, forcast.nightTemp];
                    //为模型的天气赋值
                    event.weather = resualtWeather;
                    
                    //刷新表格
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                    
                    [self.eventsTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
                    //子线程中更新数据，天气写入数据库
                    NSString *sql = [NSString stringWithFormat:@"update t_event set weather = '%@' where notiKey = '%@'",resualtWeather, event.notiKey];
                    BOOL flag = [XYSqliteTool executeUpdate:sql];
                    if (!flag) {
                        //停止刷新
                        [self.eventsTableView headerEndRefreshing];
                    }
                }
                
            }
            i ++;
        }
    }
    //停止刷新
    [self.eventsTableView headerEndRefreshing];
//    XYLog(@"%@", weathers);
}
//获取天气失败
- (void)refreshgWeatherFailure:(NSNotification *)nito{
    //停止刷新
    [self.eventsTableView headerEndRefreshing];
}
#pragma mark - 设置添加新事件的按钮
- (void)setupAddBtn{
    XYMoveButton *addBtn = [XYMoveButton moveButton];
    [self.view addSubview:addBtn];
    self.addBtn = addBtn;
    float x = [[NSUserDefaults standardUserDefaults] floatForKey:XYAddBtnX];
    if (x > 0 ) {
        addBtn.x = [[NSUserDefaults standardUserDefaults] floatForKey:XYAddBtnX];
        addBtn.y = [[NSUserDefaults standardUserDefaults] floatForKey:XYAddBtnY];
    }else{
        addBtn.x = (XYScreenWidth - addBtn.width) / 2;
        addBtn.y = XYScreenHeight - addBtn.height;

    }
    
    [addBtn addTarget:self action:@selector(jumpToComposeVC) forControlEvents:UIControlEventTouchUpInside];
    UIPanGestureRecognizer *move = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
    [self.addBtn addGestureRecognizer:move];
    
    
}

- (void)move:(UIPanGestureRecognizer *)gesture{
    //获取当前位置
    CGPoint tans = [gesture translationInView:gesture.view];
    CGPoint curCenter = self.addBtn.center;
    curCenter.x += tans.x;
    curCenter.y += tans.y;
    self.addBtn.center = curCenter;
    
    [gesture setTranslation:CGPointZero inView:self.view];
    
    if (gesture.state == UIGestureRecognizerStateEnded) {
        CGRect btnRect = self.addBtn.frame;
        CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
        CGFloat screenH = [UIScreen mainScreen].bounds.size.height;
        
        if (btnRect.origin.y < 60) {//Y距离顶部小于60，
            btnRect.origin = CGPointMake(btnRect.origin.x, 64);
        }else if (btnRect.origin.y + btnRect.size.height > screenH - 60){//距离底部小于60
            btnRect.origin.y = screenH - btnRect.size.height;
        }else if (btnRect.origin.x + 0.5 * btnRect.size.width < screenW * 0.5){//在屏幕的左半边
            btnRect.origin.x = 0;
        }else{//在屏幕的右半边
            btnRect.origin.x = screenW - btnRect.size.width;
        }
        
        if (btnRect.origin.x < 0) {//在左边窗口外部
            btnRect.origin.x = 0;
        }else if (btnRect.origin.x > screenW - btnRect.size.width){//在右边窗口外部
            btnRect.origin.x = screenW - btnRect.size.width;
        }
        self.addBtn.frame = btnRect;
        
        [[NSUserDefaults standardUserDefaults] setFloat:self.addBtn.x forKey:XYAddBtnX];
        [[NSUserDefaults standardUserDefaults] setFloat:self.addBtn.y forKey:XYAddBtnY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

}


#pragma mark - 跳转控制器
- (void)jumpToComposeVC{
    XYComposeController *composeVC = [[XYComposeController alloc] init];
    [self.navigationController pushViewController:composeVC animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.eventFramesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    XYEventCell *cell = [XYEventCell eventCellWithTableView:tableView];
    cell.cellDelegate = self;
    cell.eventFrame = self.eventFramesArray[indexPath.row];
    cell.tag = indexPath.row;
    
    return cell;
}
#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    XYEventFrame *frame = self.eventFramesArray[indexPath.row];
//    XYLog(@"%f", frame.rowHeight);
    
    return frame.rowHeight;
}

//点击Cell跳转到下一个控制器
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    XYComposeController *composeVc = [[XYComposeController alloc] init];
    XYEvent *event = [self.eventFramesArray[indexPath.row] event];
    composeVc.event = event;
    composeVc.modifyEvent = YES;
    [self.navigationController pushViewController:composeVc animated:YES];
}

#pragma mark - XYEventCellDelegate
- (void)eventCell:(XYEventCell *)eventCell didClickPlayButtonAtIndex:(NSInteger)index{
    
    XYEvent *event = [self.eventFramesArray[index] event];
    NSString *audioPath = [[XYFileTool sharedFileTool].audiosPath stringByAppendingPathComponent:event.audioName];
    if (!self.audioPlayer || _lastClickIndex != index) {
        
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:audioPath] error:NULL];
#warning AVAudioSession
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
    
    if (_audioPlayer.isPlaying) {
        [_audioPlayer stop];
    }else{
        [_audioPlayer prepareToPlay];
        [_audioPlayer play];
    }
    
    self.lastClickIndex = index;
}


- (void)eventCell:(XYEventCell *)eventCell slideToRightDoneWithIndex:(NSInteger)index{
    XYLog(@"%ld 完成", index);
    //取出事件
    XYEvent *event = [self.eventFramesArray[index] event];
    event.completeEvent = YES;
    //更新数据库, 修改此条数据的complete为1 完成
    NSString *sql = [NSString stringWithFormat:@"update t_event set complete = %d where notiKey = %@", event.completeEvent, event.notiKey];
    [XYSqliteTool executeUpdate:sql];
    
    //删除内存中的数据
    [self.eventFramesArray removeObjectAtIndex:index];
    //刷新表格
    [self.eventsTableView reloadData];
    //更新数据库 子线程
    

    //取消通知
    [[XYFileTool sharedFileTool] cancelLocalNotiWithKey:event.notiKey];
    
}

- (void)eventCell:(XYEventCell *)eventCell slideToLeftDeleteWithIndex:(NSInteger)index{
    XYLog(@"%ld 删除", index);

    //更新数据库 子线程
    XYEvent *event = [self.eventFramesArray[index] event];
    //删除数据库中对应的一条数据
    NSString *sql = [NSString stringWithFormat:@"delete from  t_event where notiKey = %@", event.notiKey];
    //
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [XYSqliteTool executeUpdate:sql];
        //删除本地所保存的图片
        if (event.images.count > 0) {
            for (NSString *imageName in event.images) {
                [[XYFileTool sharedFileTool] removeImageWithName:imageName];
            }
        }
        //删除本地所保存的音频
        if (event.audioDuration > 0) {
            [[XYFileTool sharedFileTool] removeAudioWithName:event.audioName];
        }
    });
    //先删除内存中的数据
    [self.eventFramesArray removeObjectAtIndex:index];
    //刷新表格
    [self.eventsTableView reloadData];
    
    //取消通知
    [[XYFileTool sharedFileTool] cancelLocalNotiWithKey:event.notiKey];
}

- (void)dealloc{
    [self.audioPlayer stop];
    self.audioPlayer = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[AVAudioSession sharedInstance] setActive:NO error:NULL];
     XYLog(@"销毁");
}
@end
