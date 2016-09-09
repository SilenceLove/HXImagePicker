//
//  HX_PhotosFooterView.m
//  测试
//
//  Created by 洪欣 on 16/8/24.
//  Copyright © 2016年 洪欣. All rights reserved.
//

#import "HX_PhotosFooterView.h"
#import "HX_AssetManager.h"
@interface HX_PhotosFooterView ()
@property (weak, nonatomic) UILabel *label;
@end

@implementation HX_PhotosFooterView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:15];
    label.textColor = [UIColor lightGrayColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.frame = CGRectMake(0, 0, width, height);
    [self addSubview:label];
    _label = label;
}

- (void)setTotal:(NSInteger)total
{
    _total = total;
    
    NSString *str;
    if ([HX_AssetManager sharedManager].type == HX_SelectPhoto) {
        str = [NSString stringWithFormat:@"共%ld张图片",total];
    }else if ([HX_AssetManager sharedManager].type == HX_SelectVideo) {
        str = [NSString stringWithFormat:@"共%ld个视频",total];
    }else if ([HX_AssetManager sharedManager].type == HX_SelectPhotoAndVieo) {
        str = [NSString stringWithFormat:@"共%ld张图片、视频",total];
    }
    _label.text = str;
}

@end
