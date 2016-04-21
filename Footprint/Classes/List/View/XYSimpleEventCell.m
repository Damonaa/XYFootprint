//
//  XYSimpleEventCell.m
//  Footprint
//
//  Created by 李小亚 on 16/4/19.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import "XYSimpleEventCell.h"
#import "XYEvent.h"

#define XYTagEventCellContentFontSize [UIFont systemFontOfSize:15]

@interface XYSimpleEventCell ()
/**
 *  显示是否完成
 */
@property (nonatomic, weak) UIImageView *completedImageView;
/**
 *  显示事件内容
 */
@property (nonatomic, weak) UILabel *contentLabel;
/**
 *  补充说明
 */
@property (nonatomic, weak) UILabel *suppleLabel;
@end

@implementation XYSimpleEventCell
/**
 *  创建自定义的cell
 */
+ (instancetype)simpleEventCellWithTableView:(UITableView *)tableView{
    static NSString *reusedCell = @"tagEventCell";
    XYSimpleEventCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedCell];
    
    if (!cell) {
        cell = [[XYSimpleEventCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusedCell];
    }
    return cell;

}

//自定义布局cell的控件
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        //设置子控件
        [self setupAllChildView];
    }
    return self;
}

#pragma mark - 设置子控件
- (void)setupAllChildView{
    //图片，显示完成/未完成
    UIImageView *completedImageView = [[UIImageView alloc] init];
    [self.contentView addSubview:completedImageView];
    self.completedImageView = completedImageView;
    completedImageView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tapIV = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tagCompletedIV:)];
    [completedImageView addGestureRecognizer:tapIV];
    
    //显示事件内容 label
    UILabel *contentLabel = [[UILabel alloc] init];
    [self.contentView addSubview:contentLabel];
    self.contentLabel = contentLabel;
    contentLabel.textAlignment = NSTextAlignmentLeft;
    contentLabel.font = XYTagEventCellContentFontSize;
//    contentLabel.numberOfLines = 0;
//    contentLabel.backgroundColor = [UIColor orangeColor];
    contentLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    
    //辅助信息, 补充说明
    UILabel *suppleLabel = [[UILabel alloc] init];
    [self.contentView addSubview:suppleLabel];
    self.suppleLabel = suppleLabel;
    suppleLabel.textAlignment = NSTextAlignmentLeft;
    suppleLabel.font = [UIFont systemFontOfSize:10];
//    suppleLabel.backgroundColor = [UIColor magentaColor];
    
}


- (void)tagCompletedIV:(UITapGestureRecognizer *)gesture{
//    gesture.view.superview.superview
    
    if ([self.delegate respondsToSelector:@selector(simpleEventCell:didTapCompletedImageView:)]) {
        [self.delegate simpleEventCell:self didTapCompletedImageView:(UIImageView *)gesture.view];
    }
}

- (void)setEvent:(XYEvent *)event{
    _event = event;
    //图片，显示完成/未完成
    if (event.completeEvent) {
        self.completedImageView.image = [UIImage imageNamed:@"completed"];
    }else{
        self.completedImageView.image = [UIImage imageNamed:@"uncompleted"];
    }
    self.completedImageView.frame = CGRectMake(5, 5, 40, 40);
    
    //显示事件内容 label
    if (![event.text isEqualToString:@"(null)"]) {//有文字
        self.contentLabel.text = event.text;
        self.suppleLabel.hidden = NO;
        //有声音 图像
        if (event.images.count > 0 && event.audioDuration > 0.0) {
            self.suppleLabel.text = [NSString stringWithFormat:@"有声音, 有图像%ld张",event.images.count];
        }else if(event.images.count == 0 && event.audioDuration > 0.0){//有声音，没图像
            self.suppleLabel.text = @"有声音";
        }else if (event.images.count > 0 && event.audioDuration == 0.0){//无声音，有图像
            self.suppleLabel.text = [NSString stringWithFormat:@"有图像%ld张",event.images.count];
        }else{
            self.suppleLabel.hidden = YES;
        }
    }else{//无文字,不显示补充说明
        //有声音 图像
        if (event.images.count > 0 && event.audioDuration > 0.0) {
            self.contentLabel.text = [NSString stringWithFormat:@"有声音, 有图像%ld张",event.images.count];
        }else if(event.images.count == 0 && event.audioDuration > 0.0){//有声音，没图像
            self.contentLabel.text = @"有声音";
        }else if (event.images.count > 0 && event.audioDuration == 0.0){//无声音，有图像
            self.contentLabel.text = [NSString stringWithFormat:@"有图像%ld张",event.images.count];
        }
    }
    

    //内容标签的X
    CGFloat contentX = CGRectGetMaxX(_completedImageView.frame) + 10;
    //内容标签的最大宽度
    CGFloat maxWidth = XYScreenWidth - contentX - 20;
    
    [self.contentLabel sizeToFit];
    if (self.contentLabel.width > maxWidth) {
        self.contentLabel.width = maxWidth;
    }

    self.contentLabel.x = contentX;
    
    if (self.suppleLabel.hidden) {//无补充说明， 内容label居中
        self.contentLabel.y = (self.height - self.contentLabel.height) / 2;
    }else{//有补充说明
        [self.suppleLabel sizeToFit];
        CGFloat contentY = (self.height - self.contentLabel.height - self.suppleLabel.height - 5) / 2;
        self.contentLabel.y = contentY;
        
        self.suppleLabel.x = contentX;
        self.suppleLabel.y = CGRectGetMaxY(_contentLabel.frame) + 5;
    }
    
}
@end
