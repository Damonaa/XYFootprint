//
//  XYPhotosToolBar.m
//  Footprint
//
//  Created by 李小亚 on 16/4/9.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import "XYPhotosToolBar.h"
#import "XYPhoto.h"

@interface XYPhotosToolBar ()
/**
 *  显示页码
 */
@property (nonatomic, weak) UILabel *indexLabel;
@end

@implementation XYPhotosToolBar
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setPhotos:(NSArray *)photos
{
    _photos = photos;
    
    if (_photos.count > 1) {
        UILabel *indexLabel = [[UILabel alloc] init];
        self.indexLabel = indexLabel;
        _indexLabel.font = [UIFont boldSystemFontOfSize:20];
        _indexLabel.frame = self.bounds;
        _indexLabel.backgroundColor = [UIColor clearColor];
        _indexLabel.textColor = [UIColor whiteColor];
        _indexLabel.textAlignment = NSTextAlignmentCenter;
        _indexLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:_indexLabel];
    }

}


- (void)setCurrentPhotoIndex:(NSUInteger)currentPhotoIndex
{
    _currentPhotoIndex = currentPhotoIndex;
    
    // 更新页码
    _indexLabel.text = [NSString stringWithFormat:@"%lu / %ld", _currentPhotoIndex + 1, (unsigned long)_photos.count];

}
@end
