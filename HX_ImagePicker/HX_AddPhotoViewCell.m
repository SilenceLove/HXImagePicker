//
//  HX_AddPhotoViewCell.m
//  测试
//
//  Created by 洪欣 on 16/8/22.
//  Copyright © 2016年 洪欣. All rights reserved.
//

#import "HX_AddPhotoViewCell.h"
#import "HX_AssetManager.h"
@interface HX_AddPhotoViewCell ()

@property (weak, nonatomic) UIButton *deleteBtn;
@property (weak, nonatomic) UIImageView *videoIcon;
@property (weak, nonatomic) UILabel *videoTime;
@property (weak, nonatomic) UIView *videoBgView;
@property (weak, nonatomic) UILabel *label;
@end

@implementation HX_AddPhotoViewCell

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
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.clipsToBounds = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.frame = CGRectMake(0, 0, width, height);
    [self.contentView addSubview:imageView];
    _imageView = imageView;
    
    UIView *videoBgView = [[UIView alloc] init];
    videoBgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    videoBgView.frame = CGRectMake(0, height - 20, width, 20);
    [self.contentView addSubview:videoBgView];
    _videoBgView = videoBgView;
    
    UIImageView *videoIcon = [[UIImageView alloc] init];
    videoIcon.image = [UIImage imageNamed:@"VideoSendIcon@2x.png"];
    videoIcon.frame = CGRectMake(5, 0, videoIcon.image.size.width, videoIcon.image.size.width);
    videoIcon.center = CGPointMake(videoIcon.center.x, 10);
    [videoBgView addSubview:videoIcon];
    _videoIcon = videoIcon;
    
    UILabel *videoTime = [[UILabel alloc] init];
    videoTime.textAlignment = NSTextAlignmentRight;
    videoTime.font = [UIFont systemFontOfSize:12];
    videoTime.textColor = [UIColor whiteColor];
    
    CGFloat videoIconMaxX = CGRectGetMaxX(videoIcon.frame);
    videoTime.frame = CGRectMake(videoIconMaxX, 0, width - videoIconMaxX - 5, 20);
    
    [videoBgView addSubview:videoTime];
    _videoTime = videoTime;
    
    UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [deleteBtn setBackgroundImage:[UIImage imageNamed:@"back_single@2x.png"] forState:UIControlStateNormal];
    deleteBtn.frame = CGRectMake(width - 27, 2, 25, 25);
    deleteBtn.hidden = YES;
    [deleteBtn addTarget:self action:@selector(deleteClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:deleteBtn];
    _deleteBtn = deleteBtn;
    
    UILabel *label = [[UILabel alloc] init];
    
    label.textColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.8];
    label.font = [UIFont systemFontOfSize:15];
    label.frame = CGRectMake(10, 0, 200, 20);
    label.center = CGPointMake(label.center.x, height / 2);
    [self.contentView addSubview:label];
    
    HX_AssetManager *manger = [HX_AssetManager sharedManager];
    
    if (manger.type == HX_SelectPhoto) {
        label.text = @"添加照片";
    }else if (manger.type == HX_SelectVideo) {
        label.text = @"添加视频";
    }else if (manger.type == HX_SelectPhotoAndVieo) {
        label.text = @"添加照片、视频";
    }
    
    _label = label;
}

- (void)setType:(NSInteger)type
{
    _type = type;
    if (type == 0) {
        _label.text = @"添加照片";
    }else if (type == 1) {
        _label.text = @"添加视频";
    }else if (type == 2) {
        _label.text = @"添加照片、视频";
    }
}

- (void)deleteClick:(UIButton *)button
{
    if (self.deleteBlock) {
        self.deleteBlock(self);
    }
}

- (void)setModel:(HX_PhotoModel *)model
{
    _model = model;
    
    if (!model.image) {
        _label.hidden = NO;
        _videoBgView.hidden = YES;
        _imageView.hidden = YES;
        _deleteBtn.hidden = YES;
    }else {
        if (model.type == HX_Video) {
            _videoBgView.hidden = NO;
            _deleteBtn.hidden = NO;
            _videoTime.text = model.videoTime;
        }else {
            _videoBgView.hidden = YES;
            _deleteBtn.hidden = !model.ifSelect;
        }
        _label.hidden = YES;
        _imageView.image = model.image;
        _imageView.hidden = NO;
    }
}

@end
