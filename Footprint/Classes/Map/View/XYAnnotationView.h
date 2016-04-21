//
//  XYAnnotationView.h
//  Footprint
//
//  Created by 李小亚 on 16/4/13.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import <MAMapKit/MAMapKit.h>

@interface XYAnnotationView : MAAnnotationView

+ (instancetype)annotationViewWithmapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation;

@end
