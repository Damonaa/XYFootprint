//
//  XYEventsViewController.m
//  Footprint
//
//  Created by 李小亚 on 16/4/19.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import "XYEventsViewController.h"
#import "XYSingleTag.h"
#import "XYSearchField.h"
#import "XYEvent.h"
#import "XYSimpleEventCell.h"
#import "XYComposeController.h"
#import "UIBarButtonItem+XY.h"
#import "XYSqliteTool.h"
#import "XYBaseTableView.h"

@interface XYEventsViewController ()<UITextFieldDelegate>

@property (nonatomic, weak) XYBaseTableView *tableView;
/**
 *  搜索框
 */
@property (nonatomic, weak) XYSearchField *searchField;

@end

@implementation XYEventsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    if ([_singleTag.tagName isEqualToString:@"(null)"]) {
        self.title = @"其他";
    }else{
        self.title = _singleTag.tagName;
    }
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem barButtonItemWithNormalImage:[UIImage imageNamed:@"arrow_left_normal"] hightlightImage:nil target:self selcetor:@selector(leftBtnClick) controlEvent:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem barButtonItemWithNormalImage:[UIImage imageNamed:@"add_tag_normal"] hightlightImage:nil target:self selcetor:@selector(rightBtnClick) controlEvent:UIControlEventTouchUpInside];
    
    [self setupChildView];
    
    //监听是否有新数据添加进来
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createdEventAtTag:) name:@"createdEventAtTag" object:nil];
    //监听搜索框的变化
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)setupChildView{
    //搜索框
    XYSearchField *searchField = [XYSearchField searchField];
    searchField.placeholder = @"搜索";
    [self.view addSubview:searchField];
    self.searchField = searchField;
    searchField.delegate = self;
    searchField.frame = CGRectMake(5, 64, XYScreenWidth - 10, 35);

    //展示数据的tableView
    XYBaseTableView *tableView = [[XYBaseTableView alloc] init];
    [self.view addSubview:tableView];
    self.tableView = tableView;
    CGFloat tableY = CGRectGetMaxY(searchField.frame);
    tableView.frame = CGRectMake(0, tableY, XYScreenWidth, XYScreenHeight - tableY);
    tableView.events = _singleTag.tagEvents;
    
    __weak typeof(self) weakSelf = self;
    tableView.tagEvent = ^(XYEvent *event){
        XYComposeController *composeVC = [[XYComposeController alloc] init];
        composeVC.event = event;
        composeVC.modifyEvent = YES;
        [weakSelf.navigationController pushViewController:composeVC animated:YES];
    };
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
#warning 从composeVC创建新的事件，返回来，刷新数据
    //重新从数据库获取数据，每次呈现的时候
    [self createdEventAtTag:nil];
    [self.tableView reloadData];
}

#pragma mark - 新事件插入数据库
- (void)createdEventAtTag:(NSNotification *)noti{
    //为self.singleTag.tagEvents 重新赋值
    //从数据库中获取数据
    self.singleTag.tagEvents = (NSMutableArray *)[XYSqliteTool executeTagQuaryWithName:self.singleTag.tagName];
    self.tableView.events = self.singleTag.tagEvents;
}

#pragma mark - 点击添加新事件
- (void)rightBtnClick{
    XYComposeController *composeVC = [[XYComposeController alloc] init];
    composeVC.event.tag = self.singleTag.tagName;
    composeVC.event.disableChangeTag = YES;
    
    [self.navigationController pushViewController:composeVC animated:YES];
}

#pragma mark - 点击取消，返回上一控制器
- (void)leftBtnClick{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
//响应textfield的变化，开始搜索
- (void)textFieldTextDidChange:(NSNotification *)noti{
    
    NSArray *searchResult = [XYSqliteTool executeQuarySqecifyTag:_singleTag.tagName require:_searchField.text];
    XYLog(@"%@", searchResult);
    self.tableView.events = (NSMutableArray *)searchResult;
    [self.tableView reloadData];
}


- (void)dealloc{
    XYLog(@"销毁标签事件列表");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
