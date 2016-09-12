//
//  HX_VideoContainerVC.m
//  测试
//
//  Created by 洪欣 on 16/8/23.
//  Copyright © 2016年 洪欣. All rights reserved.
//

#import "HX_VideoContainerVC.h"
#import <MediaPlayer/MediaPlayer.h>
#import "HX_AssetManager.h"
#import "HX_VideoManager.h"
@interface HX_VideoContainerVC ()
@property (assign, nonatomic) BOOL ifAddVideo;
@property (weak, nonatomic) UIImageView *imageView;

@property (strong, nonatomic) MPMoviePlayerController *player;

@property (weak, nonatomic) UIButton *playBtn;
@property (weak, nonatomic) UIButton *rightBtn;
@end

@implementation HX_VideoContainerVC

- (MPMoviePlayerController *)player
{
    if (!_player) {
        _player = [[MPMoviePlayerController alloc] init];
        _player.view.frame = self.view.bounds;
        _player.view.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _player.controlStyle = MPMovieControlStyleNone;
    }
    return _player;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNotification];
    [self setup];
}

/**
 *  添加通知监控媒体播放控制器状态
 */
-(void)addNotification{
    NSNotificationCenter *notificationCenter=[NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(mediaPlayerPlaybackStateChange:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:self.player];
    [notificationCenter addObserver:self selector:@selector(mediaPlayerPlaybackFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:self.player];
}
/**
 *  播放状态改变，注意播放完成时的状态是暂停
 *
 *  @param notification 通知对象
 */
-(void)mediaPlayerPlaybackStateChange:(NSNotification *)notification{
    switch (self.player.playbackState) {
        case MPMoviePlaybackStatePlaying: // 正在播放

            break;
        case MPMoviePlaybackStatePaused: // 暂停播放

            break;
        case MPMoviePlaybackStateStopped: // 停止播放
            
            break;
        default:

            break;
    }
}

/**
 *  播放完成
 *
 *  @param notification 通知对象
 */
-(void)mediaPlayerPlaybackFinished:(NSNotification *)notification{
    _imageView.hidden = NO;
    _playBtn.selected = NO;
    [self.player.view removeFromSuperview];
    _ifAddVideo = NO;
}

- (void)setup
{
    self.view.backgroundColor = [UIColor blackColor];
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    
    UIImageView *imageView = [[UIImageView alloc] init];
    
    [self.view addSubview:imageView];
    _imageView = imageView;
    
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, height - 80, width, 80)];
    bottomView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    [self.view addSubview:bottomView];
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setTitle:@"取消" forState:UIControlStateNormal];
    [leftBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    leftBtn.frame = CGRectMake(0, 0, 100, 80);
    [bottomView addSubview:leftBtn];
    
    UIButton *playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [playBtn setImage:[UIImage imageNamed:@"qmusic_player_pause_default@2x.png"] forState:UIControlStateNormal];
    
    [playBtn setImage:[UIImage imageNamed:@"qmusic_player_play_default@2x.png"] forState:UIControlStateSelected];
    
    [playBtn addTarget:self action:@selector(playVideoClick:) forControlEvents:UIControlEventTouchUpInside];
    
    playBtn.frame = CGRectMake(0, 0, playBtn.currentImage.size.width, playBtn.currentImage.size.height);
    playBtn.center = CGPointMake(width / 2, 40);
    
    [bottomView addSubview:playBtn];
    _playBtn = playBtn;
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [rightBtn setTitle:@"选取" forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [rightBtn addTarget:self action:@selector(selectVideoClick:) forControlEvents:UIControlEventTouchUpInside];
    rightBtn.frame = CGRectMake(width - 100, 0, 100, 80);
    
    [bottomView addSubview:rightBtn];
    _rightBtn = rightBtn;
}

- (void)setIfPush:(BOOL)ifPush
{
    _ifPush = ifPush;
    _rightBtn.hidden = !ifPush;
}

- (void)playVideoClick:(UIButton *)button
{
    button.selected = !button.selected;
    
    if (button.selected) {
        
        if (!_ifAddVideo) {
            [self.view insertSubview:self.player.view atIndex:0];
            _ifAddVideo = YES;
        }
        
        _imageView.hidden = YES;
        [self.player play];
    }else {
        [self.player pause];
    }
}

- (void)selectVideoClick:(UIButton *)button
{
    HX_AssetManager *assetManager = [HX_AssetManager sharedManager];
    HX_VideoManager *videoManager = [HX_VideoManager sharedManager];
    if (!_ifVideo) {
        [assetManager.selectedPhotos addObject:_model];
    }else {
        [videoManager.selectedPhotos addObject:_model];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HX_SureSelectPhotosNotice" object:nil];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setModel:(HX_PhotoModel *)model
{
    _model = model;
    
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    CGFloat imgWidth = model.imageSize.width;
    CGFloat imgHeight = model.imageSize.height;
    
    self.player.contentURL = model.url;
    
    if (imgWidth < width) {
        
        _imageView.frame = CGRectMake(0, 0, imgWidth, imgHeight);
        
    }else {
        imgHeight = width / imgWidth * imgHeight;
        
        _imageView.frame = CGRectMake(0, 0, width, imgHeight);
        _imageView.center = CGPointMake(width / 2, imgHeight / 2);
    }
    
    if (imgHeight > height) {
        _imageView.center = CGPointMake(width / 2, imgHeight / 2);
    }else {
        _imageView.center = CGPointMake(width / 2, height / 2);
    }
    
    if (!model.screenImage) {
        _imageView.image = [UIImage imageWithCGImage:[model.asset thumbnail] scale:2.0f orientation:UIImageOrientationUp];
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            UIImage *image = [UIImage imageWithCGImage:[model.asset aspectRatioThumbnail]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.imageView.image = image;
                model.screenImage = image;
            });
            
        });
    }else {
        _imageView.image = model.screenImage;
    }
}

- (void)backClick
{
    if (_ifPush) {
        [self.navigationController popViewControllerAnimated:YES];
    }else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)dealloc
{
    [self.player.view removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

@end
