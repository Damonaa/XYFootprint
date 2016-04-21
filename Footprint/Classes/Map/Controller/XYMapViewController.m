//
//  XYMapViewController.m
//  Footprint
//
//  Created by 李小亚 on 16/4/12.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import "XYMapViewController.h"
#import "UIImage+Category.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import "XYAnnotationView.h"
#import "XYSearchField.h"
#import "VOSegmentedControl.h"

@interface XYMapViewController ()<MAMapViewDelegate, UITextFieldDelegate, AMapLocationManagerDelegate, AMapSearchDelegate, UIGestureRecognizerDelegate>
/**
 *  搜索框
 */
@property (nonatomic, weak) UITextField *searchField;
/**
 *  地图
 */
@property (nonatomic, strong) MAMapView *mapView;
/**
 *  位置管理
 */
@property (nonatomic, strong) AMapLocationManager *locationManager;
/**
 *  检索
 */
@property (nonatomic, strong) AMapSearchAPI *search;
/**
 *  正向地理编码解析
 */
@property (nonatomic, strong) AMapGeocodeSearchRequest *geo;
/**
 *  逆向地理编码解析
 */
@property (nonatomic, strong) AMapReGeocodeSearchRequest *regeo;
/**
 *  是否是第一次加载， 默认是YES
 */
@property (nonatomic, assign, getter=isFirstAppear) BOOL firstAppear;
/**
 *  遮盖层的半径, 最小为100m
 */
@property (nonatomic, assign) NSInteger overlayRadius;
/**
 *  缩小半径按钮
 */
@property (nonatomic, weak) UIButton *zoomInBtn;
/**
 *  放大半径按钮
 */
@property (nonatomic, weak) UIButton *zoomOutBtn;
/**
 *  覆盖层, 默认且最小半径为100m
 */
@property (nonatomic, strong) MACircle *circle;
/**
 *  解析到的location
 */
@property (nonatomic, strong) CLLocation *getLocation;
/**
 *设定的提醒区域的地址
 */
@property (nonatomic, copy) NSString *completnAddress;

/**
 *  离开时提醒, 默认为NO
 */
@property (nonatomic, assign, getter=isLeftRemind) BOOL leftRemind;


@end

@implementation XYMapViewController

#pragma mark - 懒加载
//- (AMapSearchAPI *)search{
//    if (!_search) {
//         //构造AMapReGeocodeSearchRequest对象
//        _regeo = [[AMapReGeocodeSearchRequest alloc] init];
//        _regeo.radius = 10000;
//        _regeo.requireExtension = YES;
//    }
//    return _search;
//}

- (AMapLocationManager *)locationManager{
    if (!_locationManager) {
        _locationManager = [[AMapLocationManager alloc] init];
//        _locationManager.delegate = self;
        // 带逆地理信息的一次定位（返回坐标和地址信息）
        [_locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
        //   定位超时时间，可修改，最小2s
        _locationManager.locationTimeout = 3;
        //   逆地理请求超时时间，可修改，最小2s
        _locationManager.reGeocodeTimeout = 3;
    }
    return _locationManager;
}


- (void)clearMapView
{
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView removeOverlays:self.mapView.overlays];
    self.getLocation = nil;
}

- (void)clearSearch
{
    self.search.delegate = nil;
}


- (void)viewDidLoad{
    [super viewDidLoad];
    self.firstAppear = YES;
    self.overlayRadius = 200;
    //设置地图
    [self setupMapView];
    //添加子控件
    [self setupChildView];
    //返回到用户当前位置
    [self goBackToUserLoc];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //上一个控制器是否传来的CLRegion
    if (_completeRegion) {
        //获取坐标，在进行逆向解析
        CLLocationCoordinate2D coordinate = _completeRegion.center;
        _regeo.location = [AMapGeoPoint locationWithLatitude:coordinate.latitude  longitude:coordinate.longitude];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            //发起逆地理编码
            [_search AMapReGoecodeSearch: _regeo];
        });
    }
}
#pragma mark - 设置地图
- (void)setupMapView{
    self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];
    self.mapView.showsUserLocation = YES;
    
    //
    if (self.isFirstAppear) {
        MACoordinateRegion region = MACoordinateRegionMakeWithDistance(_mapView.userLocation.location.coordinate, 1000, 1000);
        self.mapView.visibleMapRect = MAMapRectForCoordinateRegion(region);
        self.firstAppear = NO;
    }
    //为地图添加手势
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressToAddAnnotation:)];
    longPress.minimumPressDuration = 1.0;
    longPress.delegate = self;
    [self.mapView addGestureRecognizer:longPress];
    
    
    //初始化检索对象
    self.search = [[AMapSearchAPI alloc] init];
    self.search.delegate = self;
    _geo = [[AMapGeocodeSearchRequest alloc] init];
    _regeo = [[AMapReGeocodeSearchRequest alloc] init];
    _regeo.radius = 10000;
    _regeo.requireExtension = YES;
}
#pragma mark - 添加子控件
- (void)setupChildView{
    //左下角添加按钮，返回到用户当前位置
    UIButton *currentLocBtn = [UIButton buttonWithTarget:self selcetor:@selector(goBackToUserLoc) controlEvent:UIControlEventTouchUpInside normalImage:[UIImage imageNamed:@"btn_map_locate"] highlightedImage:nil];
    [self.view addSubview:currentLocBtn];
    [currentLocBtn sizeToFit];
    currentLocBtn.x = 10;
    currentLocBtn.y = XYScreenHeight - currentLocBtn.height - 10;
    
    //左上角，返回上一视图控制器按钮
    UIButton *backBtn = [UIButton buttonWithTarget:self selcetor:@selector(goBackToCompose) controlEvent:UIControlEventTouchUpInside normalImage:[UIImage imageNamed:@"back"] highlightedImage:nil];
    [self.view addSubview:backBtn];
    [backBtn sizeToFit];
    backBtn.x = 10;
    backBtn.y = 20;
    
    //添加搜索输入文本框
    XYSearchField *searchField = [XYSearchField searchField];
    self.searchField = searchField;
    searchField.placeholder = @"你想去哪儿...";
    searchField.delegate = self;
    CGFloat searchX = CGRectGetMaxX(backBtn.frame) + 10;
    CGFloat searchW = XYScreenWidth - searchX - 10;
    searchField.frame = CGRectMake(searchX, backBtn.y, searchW, 40);
    [self.view addSubview:searchField];
    
//    //右下角添加两个按钮，用于缩放半径,，默认隐藏
    //缩小 -
    UIButton *zoomOut = [UIButton buttonWithTarget:self selcetor:@selector(zoomOutRadius) controlEvent:UIControlEventTouchUpInside normalImage:[UIImage imageNamed:@"zoom_out_normal"] highlightedImage:nil];
    self.zoomOutBtn = zoomOut;
//    zoomOut.hidden = YES;
    [self.view addSubview:zoomOut];
    [zoomOut sizeToFit];
    zoomOut.x = XYScreenWidth - zoomOut.width - 20;
    zoomOut.y = XYScreenHeight - zoomOut.height - 20;
   
    
    //放大 +
    UIButton *zoomIn = [UIButton buttonWithTarget:self selcetor:@selector(zoomInRadius) controlEvent:UIControlEventTouchUpInside normalImage:[UIImage imageNamed:@"zoom_in_normal"] highlightedImage:nil];
//    zoomIn.hidden = YES;
    self.zoomInBtn = zoomIn;
    [self.view addSubview:zoomIn];
    [zoomIn sizeToFit];
    zoomIn.x = zoomOut.x;
    zoomIn.y = CGRectGetMinY(zoomOut.frame) - zoomIn.height - 30;;
    
    
    
    
    VOSegmentedControl *segctrl1 = [[VOSegmentedControl alloc] initWithSegments:@[@{VOSegmentText: @"到达时提醒"},
                                                                                  @{VOSegmentText: @"离开时提醒"},
                                                                                  ]];
    segctrl1.contentStyle = VOContentStyleTextAlone;
    segctrl1.indicatorStyle = VOSegCtrlIndicatorStyleBottomLine;
    segctrl1.backgroundColor = [UIColor clearColor];
    segctrl1.selectedBackgroundColor = segctrl1.backgroundColor;
    segctrl1.allowNoSelection = NO;
    
    CGFloat segctrlW = 180;
    CGFloat segctrlH = 40;
    CGFloat segctrlX = (XYScreenWidth - segctrlW) / 2;
    CGFloat segctrlY = XYScreenHeight - segctrlH - 20;
    segctrl1.frame = CGRectMake(segctrlX, segctrlY, segctrlW, segctrlH);
    segctrl1.indicatorThickness = 4;
    [self.view addSubview:segctrl1];
    
//    __weak typeof(self) weakSelf = self;
    //设置提醒方式
    [segctrl1 setIndexChangeBlock:^(NSInteger index) {
//        weakSelf.leftRemind = index == 0 ? NO : YES;
        NSLog(@"1: block --> %@", @(index));
        
        if (index == 0) {
            _leftRemind = NO;
        }else{
            _leftRemind = YES;
        }
        
    }];
    
 
}
//放大半径
- (void)zoomInRadius{
//    self.zoomInBtn.hidden = NO;
    self.overlayRadius += 100;
    [self addOverlayToMapInLocation:_getLocation];
}
//缩小半径
- (void)zoomOutRadius{
    if (_overlayRadius <= 100) {
//        self.zoomInBtn.hidden = YES;
        return;
    }
    self.overlayRadius -= 100;
    [self addOverlayToMapInLocation:_getLocation];
}
#pragma mark - 返回到用户当前位置
- (void)goBackToUserLoc{
    // 带逆地理（返回坐标和地址信息）
    [self.locationManager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
        [self moveToSpecialLoc:location];
    }];
}
#pragma mark - 移动到指定位置
- (void)moveToSpecialLoc:(CLLocation *)location{
    MACoordinateSpan span = MACoordinateSpanMake(0.035, 0.035);
    MACoordinateRegion region = MACoordinateRegionMake(location.coordinate, span);
    [self.mapView setRegion:region animated:YES];
}

#pragma mark - 长按解析地址
- (void)longPressToAddAnnotation:(UILongPressGestureRecognizer *)gesture{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        //获取当前点击位置的经纬度
        CGPoint positon = [gesture locationInView:gesture.view];
        CLLocationCoordinate2D coordinate = [self.mapView convertPoint:positon toCoordinateFromView:gesture.view];
        _regeo.location = [AMapGeoPoint locationWithLatitude:coordinate.latitude  longitude:coordinate.longitude];
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            //发起逆地理编码
            [_search AMapReGoecodeSearch: _regeo];
        });
    }

}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}
#pragma mark - 实现逆地理编码的回调函数
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    if(response.regeocode != nil)
    {
        [self clearMapView];
        //通过AMapReGeocodeSearchResponse对象处理搜索结果
        
        self.getLocation = [[CLLocation alloc] initWithLatitude:request.location.latitude longitude:request.location.longitude] ;
        //添加大头针和覆盖层
        MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
        pointAnnotation.coordinate = _getLocation.coordinate;
        
        //设置城市名，区别直辖市
        NSString *city = response.regeocode.addressComponent.city != nil ? response.regeocode.addressComponent.city : response.regeocode.addressComponent.province;
        
     
        //设置大头针标题， 街道以及门牌号
        self.completnAddress = [NSString stringWithFormat:@"%@%@",response.regeocode.addressComponent.streetNumber.street, response.regeocode.addressComponent.streetNumber.number];
        pointAnnotation.title = _completnAddress;
        
        
        //设置大头针子标题 城市名+区名
        NSString *annoSubtitle = [NSString stringWithFormat:@"%@%@",city, response.regeocode.addressComponent.district];
        pointAnnotation.subtitle = annoSubtitle;
        [self.mapView addAnnotation:pointAnnotation];
        //添加覆盖层
        [self addOverlayToMapInLocation:_getLocation];
        
        //移动
//        [self moveToSpecialLoc:_getLocation];

    }
}
#pragma mark - 覆盖层
- (void)addOverlayToMapInLocation:(CLLocation *)location{
    //移除之前添加的
    [self.mapView removeOverlays:self.mapView.overlays];
    
    MACircle *circle = [MACircle circleWithCenterCoordinate:location.coordinate radius:_overlayRadius];
    
    //在地图上添加圆
    [_mapView addOverlay:circle];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    //地理编码，将地理位置转为经纬度
    NSString *address = textField.text;
    if (address.length == 0) {
        return YES;
    }
    //address为必选项，city为可选项
    _geo.address = address;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //发起正向地理编码
        [_search AMapGeocodeSearch:_geo];
    });
    
    
    return YES;
}

#pragma mark - 实现正向地理编码的回调函数
- (void)onGeocodeSearchDone:(AMapGeocodeSearchRequest *)request response:(AMapGeocodeSearchResponse *)response
{
    XYLog(@"NSThread %@", [NSThread currentThread]);
    
    if(response.geocodes.count == 0){return;}
    //清除地图上已经加载的大头针，覆盖物
    [self clearMapView];
    //通过AMapGeocodeSearchResponse对象处理搜索结果
    //仅仅取第一个结果
    AMapGeocode *p = response.geocodes[0];
    AMapGeoPoint *location = p.location;
    
    XYLog(@"%@", p);
    
    self.getLocation = [[CLLocation alloc] initWithLatitude:location.latitude longitude:location.longitude];
    //获取坐标，在进行逆向解析
    CLLocationCoordinate2D coordinate = self.getLocation.coordinate;
    _regeo.location = [AMapGeoPoint locationWithLatitude:coordinate.latitude  longitude:coordinate.longitude];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //发起逆地理编码
        [_search AMapReGoecodeSearch: _regeo];
    });
    //移动
    [self moveToSpecialLoc:_getLocation];
}



#pragma mark - 返回上一视图控制器按钮
- (void)goBackToCompose{
    
    if (_getLocation) {
        self.completeRegion = [[CLRegion alloc] initCircularRegionWithCenter:_getLocation.coordinate radius:_overlayRadius identifier:@"completeRegion"];
        if (_leftRemind) {
            self.completeRegion.notifyOnEntry = NO;
            self.completeRegion.notifyOnExit = YES;
        }else{
            self.completeRegion.notifyOnEntry = YES;
            self.completeRegion.notifyOnExit = NO;
        }
        
        if (_remindRegion) {
            _remindRegion(_completeRegion, _completnAddress);
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - MAMapViewDelegate
//设置大头针属性
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        XYAnnotationView *annotationView = [XYAnnotationView annotationViewWithmapView:mapView viewForAnnotation:annotation];
        //设置中心点偏移，使得标注底部中间点成为经纬度对应点
        annotationView.centerOffset = CGPointMake(0, -13);
        return annotationView;
    }
    return nil;
}
/**
 *  地图缩放结束后调用此接口
 *
 *  @param mapView       地图view
 *  @param wasUserAction 标识是否是用户动作
 */
- (void)mapView:(MAMapView *)mapView mapDidZoomByUser:(BOOL)wasUserAction{
    XYLog(@"%f", mapView.zoomLevel);
}
//设置遮盖曾属性
- (MAOverlayView *)mapView:(MAMapView *)mapView viewForOverlay:(id <MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[MACircle class]])
    {
        MACircleView *circleView = [[MACircleView alloc] initWithCircle:overlay];
        
        circleView.lineWidth = 5.f;
        circleView.strokeColor = [UIColor colorWithRed:1.000 green:0.692 blue:0.175 alpha:0.862];
        circleView.fillColor = [UIColor colorWithWhite:0.000 alpha:0.089];
        
        return circleView;
    }
    return nil;
}

- (void)dealloc{
    XYLog(@"map 销毁");
}
@end
