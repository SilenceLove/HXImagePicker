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
#import "MBProgressHUD.h"

#define VERSION [[UIDevice currentDevice].systemVersion doubleValue]
@interface HX_VideoContainerVC ()
@property (assign, nonatomic) BOOL ifAddVideo;
@property (weak, nonatomic) UIImageView *imageView;

@property (strong, nonatomic) MPMoviePlayerController *player;
@property (strong, nonnull) AVPlayer *playVideo;

@property (weak, nonatomic) UIButton *playBtn;
@property (weak, nonatomic) UIButton *rightBtn;
@property (strong, nonatomic) NSTimer *timer;
@property (weak, nonatomic) UIView *progressBgView;
@property (weak, nonatomic) UIProgressView *progressView;
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
    
    if (VERSION < 8.0f) {
        UIImageView *imageView = [[UIImageView alloc] init];
        
        [self.view addSubview:imageView];
        _imageView = imageView;
    }
    
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
    
    UIView *progressBgView = [[UIView alloc] init];
    progressBgView.frame = CGRectMake(0, height - 120, width, 40);
    progressBgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [self.view addSubview:progressBgView];
    progressBgView.hidden = YES;
    _progressBgView = progressBgView;
    
    UIProgressView *progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    progressView.frame = CGRectMake(10, 10, width - 20, 2);
    [progressBgView addSubview:progressView];
    _progressView = progressView;
    
    UILabel *progressLb = [[UILabel alloc] init];
    progressLb.frame = CGRectMake(0, 18, width, 15);
    progressLb.text = @"正在导出视频,请稍等片刻";
    progressLb.textColor = [UIColor whiteColor];
    progressLb.font = [UIFont systemFontOfSize:14];
    progressLb.textAlignment = NSTextAlignmentCenter;
    progressLb.center = CGPointMake(width / 2, progressLb.center.y);;
    [progressBgView addSubview:progressLb];
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
        if (VERSION < 8.0f) {
            if (!_ifAddVideo) {
                [self.view insertSubview:self.player.view atIndex:0];
                _ifAddVideo = YES;
            }
            _imageView.hidden = YES;
            [self.player play];
        }else {
            [self.playVideo play];
        }
        
    }else {
        if (VERSION < 8.0f) {
            [self.player pause];
        }else {
            [self.playVideo pause];
        }
    }
}

- (void)selectVideoClick:(UIButton *)button
{
    self.playBtn.selected = NO;
    
    if (VERSION < 8.0f) {
        [self.player pause];
    }else {
        [self.playVideo pause];
    }
    
    HX_AssetManager *assetManager = [HX_AssetManager sharedManager];
    HX_VideoManager *videoManager = [HX_VideoManager sharedManager];
    
    button.enabled = NO;
    _progressBgView.hidden = NO;
    
    NSArray *array;
    if (!_ifVideo) {
        [assetManager.selectedPhotos addObject:_model];
        array = assetManager.selectedPhotos;
    }else {
        [videoManager.selectedPhotos addObject:_model];
        array = videoManager.selectedPhotos;
    }
    
    __block int num = 0;
    
    __weak typeof(assetManager) weakManager = assetManager;
    __weak typeof(videoManager) weakVideoManager = videoManager;
    __weak typeof(self) weakSelf = self;
    [array enumerateObjectsUsingBlock:^(HX_PhotoModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
        num++;
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf compressedVideoWithURL:model.url success:^(NSString *fileName) {
            if (!weakSelf.ifVideo) {
                [weakManager.videoFileNames addObject:fileName];
            }else {
                [weakVideoManager.videoFileNames addObject:fileName];
            }
            
            if (num == array.count) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"HX_SureSelectPhotosNotice" object:nil];

                [strongSelf dismissViewControllerAnimated:YES completion:nil];
            }
            
        } failure:^{
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:weakSelf.navigationController.view animated:YES];

            hud.mode = MBProgressHUDModeText;
            hud.labelText = @"导出视频失败,请重试";
            hud.margin = 10.f;
            hud.removeFromSuperViewOnHide = YES;

            [hud hide:YES afterDelay:0.25];
            button.enabled = YES;
            _progressBgView.hidden = YES;
        }];
    }];
}

// 压缩视频并写入沙盒文件
- (void)compressedVideoWithURL:(NSURL *)url success:(void(^)(NSString *fileName))success failure:(void(^)())failure
{
    AVURLAsset *avAsset;
    if (VERSION < 8.0f) {
        avAsset = [AVURLAsset URLAssetWithURL:url options:nil];
    }else {
        avAsset = (AVURLAsset *)_model.URLAsset;
    }
    
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality]) {
        
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetMediumQuality];
        
        NSString *fileName = @"";
        
        // ``````
        NSDate *nowDate = [NSDate date];
        NSString *dateStr = [NSString stringWithFormat:@"%ld", (long)[nowDate timeIntervalSince1970]];
        
        NSString *numStr = [NSString stringWithFormat:@"%d",arc4random()%10000];
        fileName = [fileName stringByAppendingString:dateStr];
        fileName = [fileName stringByAppendingString:numStr];
        
        // ````` 这里取的是时间加上一些随机数  保证每次写入文件的路径不一样
        
        fileName = [fileName stringByAppendingString:@".mp4"]; // 视频后缀
        
        NSString *fileName1 = [NSTemporaryDirectory() stringByAppendingString:fileName]; //文件名称
        
        exportSession.outputURL = [NSURL fileURLWithPath:fileName1];
        
        exportSession.outputFileType = AVFileTypeMPEG4;
        
        exportSession.shouldOptimizeForNetworkUse = YES;
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(lookVideoProgress:) userInfo:@{@"session" : exportSession} repeats:YES];
        
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            
            switch (exportSession.status) {
                case AVAssetExportSessionStatusCancelled:
                {
                    
                }
                    break;
                case AVAssetExportSessionStatusCompleted:
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (success) {
                            success(fileName1);
                        }
                    });
                }
                    break;
                case AVAssetExportSessionStatusExporting:
                {
                    
                }
                    break;
                case AVAssetExportSessionStatusFailed:
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (failure) {
                            failure();
                        }
                    });
                }
                    break;
                case AVAssetExportSessionStatusUnknown:
                {
                    
                }
                    break;
                case AVAssetExportSessionStatusWaiting:
                {
                    
                }
                    break;
                default:
                    break;
            }
        }];
    }
}

- (void)lookVideoProgress:(NSTimer *)timer
{
    AVAssetExportSession *exportSession = timer.userInfo[@"session"];
    _progressView.progress = exportSession.progress;
    if (exportSession.progress == 1.0) {
        [timer invalidate];
    }
}

- (void)setModel:(HX_PhotoModel *)model
{
    _model = model;
    
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    CGFloat imgWidth = model.imageSize.width;
    CGFloat imgHeight = model.imageSize.height;
    
    if (VERSION < 8.0f) {
        self.player.contentURL = model.url;
    }

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
    
     __weak typeof(self) weakSelf = self;
    CGFloat scale = [UIScreen mainScreen].scale;
    if (VERSION < 8.0f) {
        if (!model.screenImage) {
            _imageView.image = [UIImage imageWithCGImage:[model.asset thumbnail] scale:scale orientation:UIImageOrientationUp];
            
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
    }else {
        [[PHImageManager defaultManager] requestPlayerItemForVideo:model.PH_Asset options:nil resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.playVideo = [AVPlayer playerWithPlayerItem:playerItem];
                AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.playVideo];
                playerLayer.frame = self.view.bounds;
                [self.view.layer insertSublayer:playerLayer atIndex:0];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pausePlayerAndShowNaviBar) name:AVPlayerItemDidPlayToEndTimeNotification object:self.playVideo.currentItem];
            });
        }];
    }
}

- (void)pausePlayerAndShowNaviBar {
    [self.playVideo pause];
    self.playBtn.selected = NO;
    [self.playVideo.currentItem seekToTime:CMTimeMake(0, 1)];
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
    if (VERSION < 8.0f) {
        [self.player.view removeFromSuperview];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

@end
