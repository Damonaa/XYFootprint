//
//  XYMainNavigationController.m
//  Footprint
//
//  Created by 李小亚 on 16/3/30.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import "XYMainNavigationController.h"
#import "XYMapViewController.h"

@interface XYMainNavigationController ()<UINavigationControllerDelegate>
@property (nonatomic, strong) id popDelegate;
@end

@implementation XYMainNavigationController


+ (void)initialize{
    UINavigationBar *navBar = [UINavigationBar appearanceWhenContainedIn:self, nil];
    //设置导航条颜色
    navBar.barTintColor = [UIColor colorWithRed:0.963 green:0.933 blue:0.896 alpha:1.000];
    //设置导航条字体属性
    NSMutableDictionary *titleAttr = [NSMutableDictionary dictionary];
    titleAttr[NSFontAttributeName] = [UIFont systemFontOfSize:18];
    titleAttr[NSForegroundColorAttributeName] = [UIColor colorWithRed:0.925 green:0.459 blue:0.510 alpha:1.000];
    
    navBar.titleTextAttributes = titleAttr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.delegate = self;
    
    self.popDelegate = self.interactivePopGestureRecognizer.delegate;
    self.interactivePopGestureRecognizer.delegate = nil;
    
//    if([[[UIDevice
//          currentDevice] systemVersion] floatValue]>=8.0) {
//        
//        self.modalPresentationStyle=UIModalPresentationOverFullScreen;
//        
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//判断是否是跟控制器，还原手势代理
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    
//    XYLog(@"%ld", self.viewControllers.count);
    
    if (viewController == self.viewControllers[0]) {
        //根控制器
        self.interactivePopGestureRecognizer.delegate = self.popDelegate;

    }else{
        self.interactivePopGestureRecognizer.delegate = nil;
    }
}

//隐藏指定控制器的导航栏
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    for (UIViewController *vc in self.viewControllers) {
        if ([vc isKindOfClass:[XYMapViewController class]]) {
            self.navigationBarHidden = YES;
        }else{
            self.navigationBarHidden = NO;
        }
    }
}

@end
