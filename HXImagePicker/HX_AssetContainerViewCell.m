//
//  HX_AssetContainerViewCell.m
//  测试
//
//  Created by 洪欣 on 16/8/20.
//  Copyright © 2016年 洪欣. All rights reserved.
//

#import "HX_AssetContainerViewCell.h"

@interface HX_AssetContainerViewCell ()<UIScrollViewDelegate>
@property (weak, nonatomic) UIScrollView *scrollView;
@property (weak, nonatomic) UIImageView *imageView;
@property (assign, nonatomic) CGPoint imageCenter;
//@property (assign, nonatomic) BOOL ifAddVideo;
@end

@implementation HX_AssetContainerViewCell

//- (MPMoviePlayerController *)player
//{
//    if (!_player) {
//        _player = [[MPMoviePlayerController alloc] init];
//        _player.view.frame = self.bounds;
//        _player.view.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
//        _player.controlStyle = MPMovieControlStyleNone;
//    }
//    return _player;
//}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup
{
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaPlayerPlaybackFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:self.player];

//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaPlayerPlaybackStateChange:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:self.player];
    
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    scrollView.delegate = self;
//    scrollView.minimumZoomScale = 1.0;     // 最小缩放值
//    scrollView.maximumZoomScale = 2.0;    // 最大缩放值
//    [scrollView setZoomScale:scrollView.minimumZoomScale];
    
    scrollView.contentSize = CGSizeMake(width, height);
    scrollView.userInteractionEnabled = YES;
    [scrollView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didImgClick:)]];
    [self.contentView addSubview:scrollView];
    _scrollView = scrollView;
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.center = CGPointMake(width / 2, height / 2);
    [scrollView addSubview:imageView];
    _imageView = imageView;
    
//    UIButton *playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    
//    [playBtn setImage:[UIImage imageNamed:@"qmusic_player_pause_default@2x.png"] forState:UIControlStateNormal];
//    [playBtn setImage:[UIImage imageNamed:@"qmusic_player_play_default@2x.png"] forState:UIControlStateSelected];
//    [playBtn addTarget:self action:@selector(playVideoClick:) forControlEvents:UIControlEventTouchUpInside];
//    
//    playBtn.frame = CGRectMake(0, 0, width, width);
//    playBtn.center = CGPointMake(width / 2, height / 2);
//    
//    [self.contentView addSubview:playBtn];
//    _playBtn = playBtn;
}

- (void)didImgClick:(UITapGestureRecognizer *)tap
{
    if (self.didImgBlock) {
        self.didImgBlock();
    }
}

/*
- (void)playVideoClick:(UIButton *)button
{
    button.selected = !button.selected;
    if (button.selected) {
        if (!_ifAddVideo) {
            [self.contentView insertSubview:self.player.view belowSubview:button];
        }
        
        [self.player play];
    }else {
        [self.player pause];
    }
}
*/

/**
 *  播放完成
 *
 *  @param notification 通知对象
 */

/*
-(void)mediaPlayerPlaybackFinished:(NSNotification *)notification{
    _playBtn.selected = NO;
    [self.player.view removeFromSuperview];
    _ifAddVideo = NO;
}
*/

/**
 *  播放状态改变，注意播放完成时的状态是暂停
 *
 *  @param notification 通知对象
 */

/*
-(void)mediaPlayerPlaybackStateChange:(NSNotification *)notification{
    switch (self.player.playbackState) {
        case MPMoviePlaybackStatePlaying: // 正在播放
            _playBtn.selected = YES;
            break;
        case MPMoviePlaybackStatePaused: // 暂停播放
            _playBtn.selected = NO;
            break;
        case MPMoviePlaybackStateStopped: // 停止播放
            _playBtn.selected = NO;
            break;
        default:
            _playBtn.selected = NO;
            break;
    }
}
*/

#pragma mark - 返回需要缩放的控件
//- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
//    return _imageView;
//}
//
//- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
//    if (self.scrollView.zoomScale > 1) {
//        _imageView.center = CGPointMake(self.scrollView.contentSize.width / 2, self.scrollView.contentSize.height / 2);
//    }
//    else {
//        _imageView.center = _imageCenter;
//    }
//}

- (void)setModel:(HX_PhotoModel *)model
{
    _model = model;
    
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    CGFloat imgWidth = model.imageSize.width;
    CGFloat imgHeight = model.imageSize.height;
    
//    [self.player stop];
//    [self.player.view removeFromSuperview];
//    _ifAddVideo = NO;
//    _playBtn.selected = NO;
//    if (model.type == HX_Video) {
//        _playBtn.hidden = NO;
//        self.player.contentURL = model.url;
//    }else {
//        _playBtn.hidden = YES;
//    }
    
    if (imgWidth < width) {
        _imageView.frame = CGRectMake(0, 0, imgWidth, imgHeight);
        _scrollView.contentSize = CGSizeMake(width, imgHeight);
    }else {
        imgHeight = width / imgWidth * imgHeight;
        _imageView.frame = CGRectMake(0, 0, width, imgHeight);
        _scrollView.contentSize = CGSizeMake(width, imgHeight);
        _imageView.center = CGPointMake(width / 2, imgHeight / 2);
    }
    
    if (imgHeight > height) {
        _imageView.center = CGPointMake(width / 2, imgHeight / 2);
    }else {
        _imageView.center = CGPointMake(width / 2, height / 2);
    }
    
    __weak typeof(self) weakSelf = self;
    if (model.type == HX_Video) {
        if (!model.screenImage) {
            _imageView.image = [UIImage imageNamed:@"shenmedoumeiyou"];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                CGImageRef fullScreen = [[model.asset defaultRepresentation] fullScreenImage];
                
                UIImage *image = [UIImage imageWithCGImage:fullScreen scale:2.0f orientation:UIImageOrientationUp];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.imageView.image = image;
                    model.screenImage = image;
                });
            });
        }else {
            _imageView.image = model.screenImage;
        }
    }else {
        if (imgHeight > height * 1.5) {
            if (!model.resolutionImage) {
             _imageView.image = [UIImage imageNamed:@"shenmedoumeiyou"];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    
                    CGImageRef Resolution = [[model.asset defaultRepresentation] fullResolutionImage];
                    
                    UIImage *image = [UIImage imageWithCGImage:Resolution scale:2.0 orientation:UIImageOrientationUp];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weakSelf.imageView.image = image;
                        model.resolutionImage = image;
                    });
                });
            }else {
                _imageView.image = model.resolutionImage;
            }
        }else {
            if (!model.screenImage) {
                _imageView.image = [UIImage imageNamed:@"shenmedoumeiyou"];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    
                    CGImageRef fullScreen = [[model.asset defaultRepresentation] fullScreenImage];
                    
                    UIImage *image = [UIImage imageWithCGImage:fullScreen scale:1.0f orientation:UIImageOrientationUp];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weakSelf.imageView.image = image;
                        model.screenImage = image;
                    });
                });
            }else {
                _imageView.image = model.screenImage;
            }
        }
    }
    _imageCenter = _imageView.center;
}

- (void)dealloc
{
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    _playBtn.selected = NO;
//    [self.player.view removeFromSuperview];
//    _ifAddVideo = NO;
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

@end
