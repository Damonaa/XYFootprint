//
//  XYCircleTagsView.m
//  Footprint
//
//  Created by 李小亚 on 16/4/18.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import "XYCircleTagsView.h"
#import "XYTagView.h"
#import "XYSingleTag.h"
#import "XYTagsTool.h"
#import "XYSqliteTool.h"

@interface XYCircleTagsView ()<UICollisionBehaviorDelegate>
/**
 *  全部的tag （名）
 */
@property (nonatomic, strong) NSMutableArray *tags;
//
///**
// *  全部数据成员由 XYSingleTag组成
// */
//@property (nonatomic, strong) NSMutableArray *allTagsEvents;
@end

@implementation XYCircleTagsView

#pragma mark - 懒加载
- (NSMutableArray *)tagViews{
    if (!_tagViews) {
        _tagViews = [NSMutableArray array];
    }
    return _tagViews;
}

//tag的名字,多添加一项 （其他 空）
- (NSMutableArray *)tags{
    if (!_tags) {
        _tags = [NSMutableArray array];
        //添加
        [_tags addObjectsFromArray:[XYTagsTool sharedTagsTool].tags];
        [_tags addObject:@"(null)"];
    }
    return _tags;
}
//从数据库中取得全部的数据
- (NSMutableArray *)allTagsEvents{
    if (!_allTagsEvents) {
        _allTagsEvents = [NSMutableArray array];
        for (NSString *tag in self.tags) {
            XYSingleTag *singleTag = [[XYSingleTag alloc] init];
            
            singleTag.tagName = tag;
            singleTag.tagEvents = [NSMutableArray arrayWithArray:[XYSqliteTool executeTagQuaryWithName:singleTag.tagName]];
            
            [_allTagsEvents addObject:singleTag];
        }
    }
    return _allTagsEvents;
}

#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupAllChildView];
        self.backgroundColor = [UIColor clearColor];
        
        //创建新的的标签
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(insertNewTag:) name:@"insertNewTagInListVC" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(insertNewTag:) name:@"insertNewTag" object:nil];
        
    }
    return self;
}

//监听到有新的标签创建
- (void)insertNewTag:(NSNotification *)noti{
    NSString *newTag = noti.userInfo[@"newTag"];
    //新的模型
    XYSingleTag *singleTag = [[XYSingleTag alloc] init];
    singleTag.tagName = newTag;
    singleTag.tagEvents = [NSMutableArray array];
    [self.allTagsEvents addObject:singleTag];
    
    //新的View
    XYTagView *newTagView = [self createOnewTagView];
    newTagView.singleTag = singleTag;
    
    
    [self layoutSubviews];
}

#pragma mark - 添加子控件
- (void)setupAllChildView{
    //添加tag View
    for (XYSingleTag *singleTag in self.allTagsEvents) {
        XYTagView *tagView = [self createOnewTagView];
        tagView.singleTag = singleTag;
    }
   
}

- (XYTagView *)createOnewTagView{
    XYTagView *tagView = [[XYTagView alloc] init];
    tagView.backgroundColor = [UIColor orangeColor];
    
    tagView.bounds = CGRectMake(0, 0, 60, 60);
    [self addSubview:tagView];
    
    tagView.tag = self.tagViews.count;
    
    [self.tagViews addObject:tagView];
    //单击
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTag:)];
    [tagView addGestureRecognizer:tap];
    //长按
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressTag:)];
    [tagView addGestureRecognizer:longPress];
    
    return tagView;
}
//单击
- (void)tapTag:(UITapGestureRecognizer *)gesture{
    if ([self.delegate respondsToSelector:@selector(circleTagsView:didTapTagView:)]) {
        [self.delegate circleTagsView:self didTapTagView:(XYTagView *)gesture.view];
    }
}
//长按
- (void)longPressTag:(UILongPressGestureRecognizer *)gesture{
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        //放大
        XYTagView *tagView = (XYTagView *)gesture.view;
        
        CABasicAnimation *scale = [CABasicAnimation animation];
        scale.keyPath = @"transform.scale";
        scale.fromValue = @1.0;
        scale.toValue = @1.5;
        
        scale.duration = 0.5;
        
        [tagView.layer addAnimation:scale forKey:nil];

        
    }else if (gesture.state == UIGestureRecognizerStateEnded){
        if ([self.delegate respondsToSelector:@selector(circleTagsView:didLongPressTagView:)]) {
            [self.delegate circleTagsView:self didLongPressTagView:(XYTagView *)gesture.view];
        }
    }

}

#pragma mark - 布局frame
- (void)layoutSubviews{
    [super layoutSubviews];
//    CGFloat wh = 60;
    CGFloat margin = 10;
    CGFloat tagX = margin;
    CGFloat tagY = 0;
    //上一行的最大Y
    CGFloat maxLastRowY = 0.0;
    for (int i = 0; i < self.allTagsEvents.count; i ++) {
        XYTagView *tagView = self.tagViews[i];
        
        
        if (i > 0) { //从第二个tagView开始，X上上一个的最大X + margin
            XYTagView *lastTagView = self.tagViews[i - 1];
            tagView.x = CGRectGetMaxX(lastTagView.frame) + margin;
            tagView.y = lastTagView.y;
            
            //如果最大X值超出了屏幕
            if (tagView.x + tagView.width > self.width) {
                
                tagView.x = margin;
                tagView.y = maxLastRowY;
            }
            //上一行的最大Y,最大的Y值
            if (CGRectGetMaxY(tagView.frame) > maxLastRowY) {
                maxLastRowY = CGRectGetMaxY(tagView.frame);
            }
//            XYLog(@"after %@", NSStringFromCGRect(tagView.frame));
        }else{
            tagView.x = tagX;
            tagView.y = tagY;
        }
        //设置圆角，阴影
        tagView.layer.cornerRadius = tagView.width / 2;
//        tagView.layer.masksToBounds = YES;
        tagView.layer.shadowColor = [UIColor blackColor].CGColor;
        tagView.layer.shadowOffset = CGSizeMake(5, 5);
        tagView.layer.shadowOpacity = 0.7;
    }
    self.height = maxLastRowY + margin;
    self.width = XYScreenWidth;
    
//    self.y = (XYScreenWidth - self.height) / 2;
}


- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    XYLog(@"销毁 circle tags view");
}

//渐变色
//        NSMutableArray *rgbs = [NSMutableArray array];
//        for (int j = 0; j < 9; j ++) {
//            float rgb = arc4random_uniform(100) / 100.0;
//            [rgbs addObject:@(rgb)];
//        }

//        CAGradientLayer *one = [CAGradientLayer layer];
//
////        one.colors = @[(id)[UIColor colorWithRed:[rgbs[0] floatValue] green:[rgbs[1] floatValue] blue:[rgbs[2] floatValue] alpha:0.8].CGColor,
////                       (id)[UIColor colorWithRed:[rgbs[3] floatValue] green:[rgbs[4] floatValue] blue:[rgbs[5] floatValue] alpha:0.8].CGColor,
////                       (id)[UIColor colorWithRed:[rgbs[6] floatValue] green:[rgbs[7] floatValue] blue:[rgbs[8] floatValue] alpha:0.8].CGColor];
//
//        one.colors = @[(id)[UIColor colorWithRed:0.8 green:[rgbs[1] floatValue] blue:[rgbs[2] floatValue] alpha:0.8].CGColor,
//                       (id)[UIColor colorWithRed:0.7 green:[rgbs[4] floatValue] blue:[rgbs[5] floatValue] alpha:0.8].CGColor,
//                       (id)[UIColor colorWithRed:0.6 green:[rgbs[7] floatValue] blue:[rgbs[8] floatValue] alpha:0.8].CGColor];
//
//        one.frame = tagView.bounds;
//
//        [tagView.layer insertSublayer:one atIndex:0];

@end
