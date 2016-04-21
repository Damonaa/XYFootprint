//
//  XYSearchField.m
//  Footprint
//
//  Created by 李小亚 on 16/4/13.
//  Copyright © 2016年 李小亚. All rights reserved.
//

#import "XYSearchField.h"

@implementation XYSearchField

+ (instancetype)searchField{
    XYSearchField *searchField = [[self alloc] init];
    
    searchField.clearButtonMode = UITextFieldViewModeWhileEditing;
    searchField.returnKeyType = UIReturnKeySearch;
    searchField.background = [UIImage stretchableImage:[UIImage imageNamed:@"searchbar_textfield_background"]];
    searchField.font = [UIFont systemFontOfSize:12];
    
    UIImageView *leftIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"searchbar_textfield_search_icon"]];
    leftIV.contentMode = UIViewContentModeLeft;
    leftIV.width += 10;
    searchField.leftView = leftIV;
    searchField.leftViewMode = UITextFieldViewModeAlways;
    
    return searchField;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
