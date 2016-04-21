//
//  XYWeatherTool.h
//  Footprint
//
//  Created by 李小亚 on 16/4/17.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AMapSearchKit/AMapSearchKit.h>


typedef void(^WeatherToolBlock)(NSArray *forcasts);

//@class XYEvent;

@interface XYWeatherTool : NSObject


+ (instancetype)sharedXYWeatherTool;

/**
 *  请求某地的实时的天气
 *
 *  @param location 地点
 */
- (void)requestLiveWeatherWithLocation:(NSString *)location;
/**
 *  请求本地的未来三天的天气
 */
- (void)requestLoaclForecastsWeather;
/**
 *  请求某地的未来三天的天气
 */
- (void)requestForecastsWheaterWithLocation:(NSString *)location;

@end
