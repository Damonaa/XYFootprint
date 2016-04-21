//
//  XYWeatherTool.m
//  Footprint
//
//  Created by 李小亚 on 16/4/17.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import "XYWeatherTool.h"
#import "XYEvent.h"
#import <AMapLocationKit/AMapLocationKit.h>


@interface XYWeatherTool ()<AMapSearchDelegate>

/**
 *  高德搜索
 */
@property (nonatomic, strong) AMapSearchAPI *search;
/**
 *  位置管理
 */
@property (nonatomic, strong) AMapLocationManager *locationManager;

@end

@implementation XYWeatherTool

static XYWeatherTool *weatherTool;

+ (instancetype)sharedXYWeatherTool{
    if (!weatherTool) {
        weatherTool = [[self alloc] init];
    }
    return weatherTool;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        weatherTool = [super allocWithZone:zone];
        //初始化检索对象
        weatherTool.search = [[AMapSearchAPI alloc] init];
        weatherTool.search.delegate = weatherTool;
        
        weatherTool.locationManager = [[AMapLocationManager alloc] init];
        //        _locationManager.delegate = self;
        // 带逆地理信息的一次定位（返回坐标和地址信息）
        [weatherTool.locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
        //   定位超时时间，可修改，最小2s
        weatherTool.locationManager.locationTimeout = 5;
        //   逆地理请求超时时间，可修改，最小2s
        weatherTool.locationManager.reGeocodeTimeout = 5;
 
    });
    
    return weatherTool;
}


/**
 *  请求某地的实时的天气
 *
 *  @param location 地点
 */
- (void)requestLiveWeatherWithLocation:(NSString *)location{
    //构造AMapWeatherSearchRequest对象，配置查询参数
    AMapWeatherSearchRequest *request = [[AMapWeatherSearchRequest alloc] init];
    request.city = location;
    request.type = AMapWeatherTypeLive;
    //            发起行政区划查询
    [_search AMapWeatherSearch:request];

}
/**
 *  请求本地的未来三天的天气
 */
- (void)requestLoaclForecastsWeather{
    //构造AMapWeatherSearchRequest对象，配置查询参数
    AMapWeatherSearchRequest *request = [[AMapWeatherSearchRequest alloc] init];
    [self.locationManager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
        XYLog(@" 请求本地的未来三天的天气 %@", [NSThread currentThread]);
        if (regeocode)
        {
            request.city = regeocode.city != nil ? regeocode.city : regeocode.province;
            request.type = AMapWeatherTypeForecast;
            [_search AMapWeatherSearch:request];

        }
        
        if (error) {
            XYLog(@"%@", error);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"getWeatherFailure" object:self userInfo:nil];
        }
    }];
}
/**
 *  请求某地的未来三天的天气
 */
- (void)requestForecastsWheaterWithLocation:(NSString *)location{
    //构造AMapWeatherSearchRequest对象，配置查询参数
    AMapWeatherSearchRequest *request = [[AMapWeatherSearchRequest alloc] init];
    request.city = location;
    request.type = AMapWeatherTypeForecast;
    //            发起行政区划查询
    [_search AMapWeatherSearch:request];
}

//实现天气查询的回调函数
- (void)onWeatherSearchDone:(AMapWeatherSearchRequest *)request response:(AMapWeatherSearchResponse *)response
{//238 188
    
    XYLog(@"查询天气 %@", [NSThread currentThread]);
    //如果是实时天气
    if(request.type == AMapWeatherTypeLive)
    {
        if(response.lives.count == 0)
        {
            return;
        }
       
    }
    //如果是预报天气
    else
    {
        if(response.forecasts.count == 0)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"getWeatherFailure" object:self userInfo:nil];
            return;
        }
        AMapLocalWeatherForecast *forecastLocal = response.forecasts[0];
        
        //发出通知
        [[NSNotificationCenter defaultCenter] postNotificationName:@"getWeatherInfo" object:self userInfo:@{@"info": forecastLocal.casts}];

//        for (AMapLocalWeatherForecast *forecast in response.forecasts) {
//            XYLog(@"reportTime %@, casts %@", forecast.reportTime,forecast.casts );
//            for (AMapLocalDayWeatherForecast *localDW in forecast.casts) {
//                XYLog(@"dayWeather %@, dayTemp %@, date :%@", localDW.dayWeather, localDW.dayTemp, localDW.date);
//            }
//        }
    }
}


@end
