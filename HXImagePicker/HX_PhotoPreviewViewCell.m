//
//  HX_AddPhotoCollectionViewCell.m
//  测试
//
//  Created by 洪欣 on 16/8/19.
//  Copyright © 2016年 洪欣. All rights reserved.
//

#import "HX_PhotoPreviewViewCell.h"
#import "HX_PhotoModel.h"
#import "HX_AssetManager.h"
#import "MBProgressHUD.h"
@interface HX_PhotoPreviewViewCell ()

@property (weak, nonatomic) UIImageView *imgeView;
@property (weak, nonatomic) UIButton *selectBtn;
@property (weak, nonatomic) UIButton *bgBtn;
@property (assign, nonatomic) CGPoint sBtnCenter;
@property (weak, nonatomic) UIImageView *videoIcon;
@property (weak, nonatomic) UILabel *videoTime;
@property (weak, nonatomic) UIView *videoBgView;
@property (weak, nonatomic) UIButton *SB;
@end

@implementation HX_PhotoPreviewViewCell

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
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    [self.contentView addSubview:imageView];
    _imgeView = imageView;
    _imgeView.frame = CGRectMake(0, 0, width, height);
    
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
    
    UIButton *bgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [bgBtn addTarget:self action:@selector(didPHClick) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:bgBtn];
    bgBtn.frame = CGRectMake(0, 0, width, height);
    _bgBtn = bgBtn;
    
    UIButton *selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [selectBtn setBackgroundImage:[UIImage imageNamed:@"album_checkbox_gray@2x.png"] forState:UIControlStateNormal];
    [selectBtn setBackgroundImage:[UIImage imageNamed:@"album_checkbox_blue@2x.png"] forState:UIControlStateSelected];
    [selectBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [selectBtn addTarget:self action:@selector(didSelectClick:) forControlEvents:UIControlEventTouchUpInside];
    selectBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.contentView addSubview:selectBtn];
    selectBtn.tag = 0;
    selectBtn.frame = CGRectMake(width - 27, 3, 25, 25);
    _selectBtn = selectBtn;
    _sBtnCenter = selectBtn.center;
    
    UIButton *SB = [UIButton buttonWithType:UIButtonTypeCustom];
    SB.tag = 1;
    [SB addTarget:self action:@selector(didSelectClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:SB];
    SB.frame = CGRectMake(width - 40, 0, 40, 40);
    _SB = SB;
}

- (void)didPHClick
{
    if (self.didPHBlock) {
        self.didPHBlock(self);
    }
}

- (void)didSelectClick:(UIButton *)button
{
    HX_AssetManager *manager = [HX_AssetManager sharedManager];
    
    // 判断是否达到了最大的限制
    if (!_selectBtn.selected) {
        if (manager.selectedPhotos.count >= _maxNum) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
            UIView *view = [[UIView alloc] init];
            
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"qrcode_ar_failed@2x.png"]];
            [view addSubview:imageView];
            
            view.frame = CGRectMake(0, 0, imageView.image.size.width, imageView.image.size.height + 10);
            
            hud.customView = view;
            hud.mode = MBProgressHUDModeCustomView;
            hud.labelText = [NSString stringWithFormat:@"最多只能选择%ld张图片",_maxNum];
            hud.margin = 10.f;
            hud.removeFromSuperViewOnHide = YES;
            
            [hud hide:YES afterDelay:1.5f];
            return;
        }
    }
    
    _selectBtn.selected = !_selectBtn.selected;
    
    _model.ifSelect = _selectBtn.selected;
    _model.collectionViewIndex = _index;

    if (_selectBtn.selected) {
        
        [self buttonAnimation];
        
        [_bgBtn setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.3]];
        _model.ifAdd = YES;
        
        [manager.selectedPhotos addObject:_model];
        _model.index = manager.selectedPhotos.count - 1;
        
        [_selectBtn setTitle:[NSString stringWithFormat:@"%ld",_model.index + 1] forState:UIControlStateNormal];
    }else {
        [_bgBtn setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0]];
        [_selectBtn setTitle:@"" forState:UIControlStateNormal];
        
        // 已经添加的图片数组
        for (int i = 0; i < manager.selectedPhotos.count; i++) {
            HX_PhotoModel *model = manager.selectedPhotos[i];
            if (model.index == _model.index) {
                _model.ifAdd = NO;
                [manager.selectedPhotos removeObjectAtIndex:i];
                break;
            }
        }
        for (int i = 0; i < manager.selectedPhotos.count; i++) {
            HX_PhotoModel *model = manager.selectedPhotos[i];
            
            model.index = i;
        }
        
        if (manager.selectedPhotos.count == 0) {
            manager.ifOriginal = NO;
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HX_SelectPhotosNotica" object:nil userInfo:
     @{@"tableViewIndex" : [NSString stringWithFormat:@"%ld",_model.tableViewIndex] ,
       @"collectionViewIndex" : [NSString stringWithFormat:@"%ld",_model.collectionViewIndex],
       @"ifSelect" : [NSString stringWithFormat:@"%d",_model.ifSelect],
       @"ifPreview" : @"0",@"index": [NSString stringWithFormat:@"%ld",_model.index]}];
}

- (void)setModel:(HX_PhotoModel *)model
{
    _model = model;
    
    if (model.type == HX_Photo) {
        _videoBgView.hidden = YES;
        _selectBtn.hidden = NO;
        _SB.hidden = NO;
    }else if (model.type == HX_Video) {
        _videoBgView.hidden = NO;
        _videoTime.text = model.videoTime;
        _selectBtn.hidden = YES;
        _SB.hidden = YES;
    }else {
        _videoBgView.hidden = YES;
        _selectBtn.hidden = NO;
        _SB.hidden = NO;
    }
    
    if (!model.image) {
        _imgeView.image = [UIImage imageWithCGImage:[model.asset thumbnail] scale:2.0 orientation:UIImageOrientationUp];
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            CGImageRef thumbnail = [model.asset thumbnail];
            
            UIImage *image = [UIImage imageWithCGImage:thumbnail scale:2.0 orientation:UIImageOrientationUp];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.imgeView.image = image;
                model.image = image;
            });
        });
    }else {
        _imgeView.image = model.image;
    }
    
    // 因为有个未知bug  所有这里做了这个判断
    if ([HX_AssetManager sharedManager].selectedPhotos.count == 0) {
        model.ifSelect = NO;
    }
    
    _selectBtn.selected = model.ifSelect;
    
    if (model.ifSelect) {
        [_bgBtn setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.3]];
        [_selectBtn setTitle:[NSString stringWithFormat:@"%ld",model.index + 1] forState:UIControlStateNormal];
    }else {
        [_selectBtn setTitle:@"" forState:UIControlStateNormal];
        [_bgBtn setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0]];
    }
}

- (void)buttonAnimation
{
    CABasicAnimation *scaleAnimation1 = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation1.fromValue = [NSNumber numberWithFloat:1.0];
    scaleAnimation1.toValue = [NSNumber numberWithFloat:1.2];
    [scaleAnimation1 setBeginTime:0.0f];
    [scaleAnimation1 setDuration:0.1f];
    
    CABasicAnimation *scaleAnimation2 = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation2.fromValue = [NSNumber numberWithFloat:1.2];
    scaleAnimation2.toValue = [NSNumber numberWithFloat:1.05];
    [scaleAnimation2 setBeginTime:0.1f];
    [scaleAnimation2 setDuration:0.1f];
    
    CABasicAnimation *scaleAnimation3 = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation3.fromValue = [NSNumber numberWithFloat:1.05];
    scaleAnimation3.toValue = [NSNumber numberWithFloat:1.15];
    [scaleAnimation3 setBeginTime:0.2f];
    [scaleAnimation3 setDuration:0.1f];
    
    CABasicAnimation *scaleAnimation4 = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation4.fromValue = [NSNumber numberWithFloat:1.15];
    scaleAnimation4.toValue = [NSNumber numberWithFloat:1.05];
    [scaleAnimation4 setBeginTime:0.3f];
    [scaleAnimation4 setDuration:0.1f];
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];

    animationGroup.duration = 0.4f;

    [animationGroup setAnimations:[NSArray arrayWithObjects:scaleAnimation1,scaleAnimation2, scaleAnimation3,scaleAnimation4, nil]];
    
    [_selectBtn.layer addAnimation:animationGroup forKey:nil];
}

@end
