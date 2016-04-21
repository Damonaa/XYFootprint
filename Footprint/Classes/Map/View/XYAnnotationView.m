//
//  XYAnnotationView.m
//  Footprint
//
//  Created by 李小亚 on 16/4/13.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import "XYAnnotationView.h"

@implementation XYAnnotationView

+ (instancetype)annotationViewWithmapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation{
    static NSString *reuseIndetifier = @"annotationReuseIndetifier";
    XYAnnotationView *annotationView = (XYAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseIndetifier];
    if (annotationView == nil)
    {
        annotationView = [[self alloc] initWithAnnotation:annotation
                                                      reuseIdentifier:reuseIndetifier];
    }
    annotationView.image = [UIImage imageNamed:@"balloon"];
    annotationView.canShowCallout = YES;
    
    return annotationView;
}
@end
