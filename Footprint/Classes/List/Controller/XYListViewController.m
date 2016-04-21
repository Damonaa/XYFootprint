//
//  XYListViewController.m
//  Footprint
//
//  Created by 李小亚 on 16/4/18.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import "XYListViewController.h"
#import "UIBarButtonItem+XY.h"
#import "XYSearchField.h"
#import "XYCircleTagsView.h"
#import "XYSingleTag.h"
#import "XYTagView.h"
#import "XYEventsViewController.h"
#import "XYSqliteTool.h"
#import "XYBaseTableView.h"
#import "XYComposeController.h"
#import "XYTagsTool.h"
#import "XYEvent.h"

@interface XYListViewController ()<XYCircleTagsViewDelegate,UITextFieldDelegate>
/**
 *  标签视图容器
 */
@property (nonatomic, weak) XYCircleTagsView *circleTagsView;
/**
 *  搜索栏
 */
@property (nonatomic, weak) XYSearchField *searchField;
/**
 *  取消搜索按钮
 */
@property (nonatomic, weak) UIButton *cancleBtn;
/**
 *  展示全部数据
 */
@property (nonatomic, weak) XYBaseTableView *tableView;

@property (nonatomic, strong) UIBarButtonItem *addItem;

@end

@implementation XYListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"标签";
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem barButtonItemWithNormalImage:[UIImage imageNamed:@"arrow_left_normal"] hightlightImage:nil target:self selcetor:@selector(leftBtnClick) controlEvent:UIControlEventTouchUpInside];
    
    UIBarButtonItem *addItem = [UIBarButtonItem barButtonItemWithNormalImage:[UIImage imageNamed:@"add_tag_normal"] hightlightImage:nil target:self selcetor:@selector(rightBtnClick) controlEvent:UIControlEventTouchUpInside];
    self.addItem = addItem;
    UIBarButtonItem *searchItem = [UIBarButtonItem barButtonItemWithNormalImage:[UIImage imageNamed:@"search"] hightlightImage:nil target:self selcetor:@selector(searchBtnClick) controlEvent:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItems = @[addItem, searchItem];;
    //添加子控件
    [self setupAllChildView];
    
    //监听搜索框的变化
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
    //监听tableView滚动，发出隐藏键盘的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hidenKeyboard) name:@"hidenKeyboard" object:nil];
}
//隐藏键盘
- (void)hidenKeyboard{
    [self.navigationController.navigationBar endEditing:YES];
}

#pragma mark - 添加子控件
- (void)setupAllChildView{
    
    XYCircleTagsView *circleTagsView = [[XYCircleTagsView alloc] init];
    circleTagsView.x = - XYScreenWidth;
    circleTagsView.y = 70;
#warning 如何居中
//    circleTagsView.y = (XYScreenHeight - circleTagsView.height) / 2 - 64;
//    circleTagsView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:circleTagsView];
    self.circleTagsView = circleTagsView;
    circleTagsView.alpha = 0;
    circleTagsView.delegate = self;
    
    
    XYSearchField *searchField = [XYSearchField searchField];
    self.searchField = searchField;
    searchField.placeholder = @"搜索";
    [self.navigationController.navigationBar addSubview:searchField];
    searchField.delegate = self;
    CGFloat searchW = XYScreenWidth - 5 - 10 - 35;
    
    searchField.frame = CGRectMake(-searchW, 4.5, searchW, 35);


    //添加取消按钮
    UIButton *cancleBtn = [UIButton buttonWithTarget:self selcetor:@selector(cancelSearch) controlEvent:UIControlEventTouchUpInside title:@"取消"];
    self.cancleBtn = cancleBtn;
    [self.navigationController.navigationBar addSubview:cancleBtn];
    cancleBtn.frame = CGRectMake(XYScreenWidth, 4.5, 35, 35);//searchW + 10
    cancleBtn.backgroundColor = [UIColor whiteColor];
    cancleBtn.layer.cornerRadius = 3;
    cancleBtn.layer.masksToBounds = YES;
    //添加展示数据用的tableView
    XYBaseTableView *tableView = [[XYBaseTableView alloc] init];
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    __weak typeof(self) weakSelf = self;
    tableView.tagEvent = ^(XYEvent *event){
        [weakSelf cancelSearch];
        
        XYComposeController *composeVC = [[XYComposeController alloc] init];
        composeVC.event = event;
        composeVC.modifyEvent = YES;
        [weakSelf.navigationController pushViewController:composeVC animated:YES];
    };
    
    tableView.frame = CGRectMake(0, XYScreenHeight, XYScreenWidth, XYScreenHeight - 64);
    //展示全部数据
    tableView.events = (NSMutableArray *)[XYSqliteTool executeQuaryAllEvent];
    [tableView reloadData];
}


#pragma mark - UITextFieldDelegate
//搜索
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
//响应textfield的变化，开始搜索
- (void)textFieldTextDidChange:(NSNotification *)noti{
    
    NSArray *searchResult = [XYSqliteTool executeQuarySqecifyRequire:self.searchField.text];
//    XYLog(@"%@", searchResult);
    self.tableView.events = (NSMutableArray *)searchResult;
    [self.tableView reloadData];
}

#pragma mark - 展示标签
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.circleTagsView.alpha = 1;
    [UIView animateWithDuration:0.5 delay:0.05 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.circleTagsView.transform = CGAffineTransformMakeTranslation(XYScreenWidth, 0);
    } completion:nil];
}

#pragma mark - XYCircleTagsViewDelegate
//点击进入下一个控制器
- (void)circleTagsView:(XYCircleTagsView *)circleTagsView didTapTagView:(XYTagView *)tagView{
    
    XYEventsViewController *eventsVC = [[XYEventsViewController alloc] init];
    eventsVC.singleTag = tagView.singleTag;
    
    [self.navigationController pushViewController:eventsVC animated:YES];
}
//长按选择是否删除
- (void)circleTagsView:(XYCircleTagsView *)circleTagsView didLongPressTagView:(XYTagView *)tagView{
    //显示提示信息
    UIAlertController *alertCtr = [UIAlertController alertControllerWithTitle:@"注意" message:@"将会删除本标签下的所有事件" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertCtr addAction:cancelAction];
    
    UIAlertAction *doneAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        ////取消未完成的通知
        NSArray *tagEvents = tagView.singleTag.tagEvents;
        for (XYEvent *event in tagEvents) {
            if (!event.completeEvent) {//未完成的事件
                //取消通知
                [[XYFileTool sharedFileTool] cancelLocalNotiWithKey:event.notiKey];
            }
        }
        //删除数据库中的相关数据
        NSString *tag = tagView.singleTag.tagName;//delete from  t_event where
        NSString *sql = [NSString stringWithFormat:@"delete from t_event where tag = '%@'",tag];
        BOOL flag = [XYSqliteTool executeUpdate:sql];
        if (flag) {
//            XYLog(@"delete success");
            //删除标签plist中tag
            NSMutableArray *allTags = [XYTagsTool sharedTagsTool].tags;
            [allTags removeObject:tag];
            
            
            NSString *path = [XYTagsTool sharedTagsTool].tagDir;
            
            BOOL plistFlag = [allTags writeToFile:path atomically:YES];
            //移除tagView
            if (plistFlag) {
                //移除标签数组中的的模型
                [self.circleTagsView.allTagsEvents removeObject:tagView.singleTag];
                //移除一个tagView视图
                [self.circleTagsView.tagViews removeLastObject];
                
                [tagView removeFromSuperview];
                [self.circleTagsView layoutSubviews];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"deleteTagGroup" object:self userInfo:nil];
                
            }
        }
    }];
    [alertCtr addAction:doneAction];
    
    [self presentViewController:alertCtr animated:YES completion:nil];
}

#pragma mark - 点击添加新标签，或者新事件
- (void)rightBtnClick{
    //设置选取方式
    UIAlertController *alertCtr = [UIAlertController alertControllerWithTitle:nil message:@"创建新的..." preferredStyle:UIAlertControllerStyleActionSheet];
    //标签
    UIAlertAction *tagAction = [UIAlertAction actionWithTitle:@"新标签" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //添加新标签
        [self tagsViewAddNewTag];
    }];
    [alertCtr addAction:tagAction];
    
    //进入新事件界面
    UIAlertAction *eventAction = [UIAlertAction actionWithTitle:@"新事件" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        XYComposeController *composeVC = [[XYComposeController alloc] init];
        [self.navigationController pushViewController:composeVC animated:YES];
    }];
    [alertCtr addAction:eventAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertCtr addAction:cancelAction];
    [self presentViewController:alertCtr animated:YES completion:nil];
}

#pragma mark - 添加新标签
- (void)tagsViewAddNewTag{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"添加新标签" message:@"新标签的名称不能与现有的重复" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert addAction:cancelAction];
    
    UIAlertAction *doneAction = [UIAlertAction actionWithTitle:@"完成" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSString *inputTag = [alert.textFields.firstObject text];
        if (inputTag.length > 0) {
            //不可与现有的标签重复
            NSArray *tags = (NSMutableArray *)[XYTagsTool sharedTagsTool].tags;
            for (NSString *tag in tags) {
                if ([inputTag isEqualToString:tag]) {
                    return;
                }
            }
            //为模型赋值
//            _event.tag = inputTag;
            //将新写入的标签加入内存
            [[XYTagsTool sharedTagsTool].tags addObject:inputTag];
            //写入plist中
            BOOL flag = [[XYTagsTool sharedTagsTool] writeTagToFileWithTag:inputTag];
            if (flag) {
                XYLog(@"plist success");
                //重新刷新，发出通知
                [[NSNotificationCenter defaultCenter] postNotificationName:@"insertNewTagInListVC" object:nil userInfo:@{@"newTag": inputTag}];
            }
        }
    }];
    [alert addAction:doneAction];
    //添加文本输入窗口
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
    }];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - 点击取消，返回上一控制器
- (void)leftBtnClick{
    [self.navigationController popViewControllerAnimated:YES];
}

//点击搜索按钮
- (void)searchBtnClick{
    //禁用添加按钮
    self.addItem.enabled = NO;
    //搜索框
    
    //从左边滑入
    [UIView animateWithDuration:0.25 animations:^{
        self.searchField.transform = CGAffineTransformMakeTranslation(_searchField.width + 5, 0);
    }];
    
    //取消按钮
    [UIView animateWithDuration:0.25 animations:^{
        self.cancleBtn.transform = CGAffineTransformMakeTranslation(-40, 0);
    }];
    
    //展示数据用的tableView
    //展示全部数据
    self.tableView.events = (NSMutableArray *)[XYSqliteTool executeQuaryAllEvent];
    [self.tableView reloadData];
    
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.tableView.transform =CGAffineTransformMakeTranslation(0, -XYScreenHeight + 64);
    } completion:^(BOOL finished) {
        
    }];
    
}

//移除，隐藏
- (void)cancelSearch{
    //启用添加按钮
    self.addItem.enabled = YES;
    
    [self.navigationController.navigationBar endEditing:YES];
    [UIView animateWithDuration:0.25 animations:^{
        self.searchField.transform = CGAffineTransformIdentity;
        self.cancleBtn.transform = CGAffineTransformIdentity;
        self.tableView.transform = CGAffineTransformIdentity;
        
    }completion:^(BOOL finished) {
        
    }];
}


- (void)dealloc{
    XYLog(@"list vc销毁");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
