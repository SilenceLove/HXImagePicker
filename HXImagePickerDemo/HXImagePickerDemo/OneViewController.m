//
//  OneViewController.m
//  HXImagePickerDemo
//
//  Created by 洪欣 on 16/9/9.
//  Copyright © 2016年 洪欣. All rights reserved.
//

#import "OneViewController.h"
#import "HX_AddPhotoView.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import "MBProgressHUD.h"
@interface OneViewController ()<HX_AddPhotoViewDelegate>
@property (strong, nonatomic) NSURL *videoUrl;
@end

@implementation OneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.title = @"DemoOne";
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
    self.view.backgroundColor = [UIColor brownColor];
    
    // 只选择照片
    HX_AddPhotoView *addPhotoView = [[HX_AddPhotoView alloc] initWithMaxPhotoNum:9 WithSelectType:SelectPhoto];
    
    // 每行最大个数  不设置默认为4
    addPhotoView.lineNum = 3;
    
    // collectionView 距离顶部的距离  底部与顶部一样  不设置,默认为0
    addPhotoView.margin_Top = 5;
    
    // 距离左边的距离  右边与左边一样  不设置,默认为0
    addPhotoView.margin_Left = 10;
    
    // 每个item间隔的距离  如果最小不能小于5   不设置,默认为5
    addPhotoView.lineSpacing = 5;
    
    // 录制视频时最大多少秒   默认为60;
    addPhotoView.videoMaximumDuration = 60.f;
    
    addPhotoView.delegate = self;
    addPhotoView.backgroundColor = [UIColor whiteColor];
    addPhotoView.frame = CGRectMake(0, 150, width - 0, 0);
    [self.view addSubview:addPhotoView];
    
    /**  当前选择的个数  */
    addPhotoView.selectNum;
    
    [addPhotoView setSelectPhotos:^(NSArray *photos, BOOL iforiginal) {
        NSLog(@"photo - %@",photos);
        [photos enumerateObjectsUsingBlock:^(ALAsset *asset, NSUInteger idx, BOOL * _Nonnull stop) {
            
            // 缩略图
            //            UIImage *image = [UIImage imageWithCGImage:[asset aspectRatioThumbnail]];
            
            // 原图
            //            CGImageRef fullImage = [[asset defaultRepresentation] fullResolutionImage];
            
            // url
            //            NSURL *url = [[asset defaultRepresentation] url];
            
        }];
    }];
    
    // 只选择视频
    HX_AddPhotoView *addVideoView = [[HX_AddPhotoView alloc] initWithMaxPhotoNum:1 WithSelectType:SelectVideo];
    addVideoView.delegate = self;
    
    addVideoView.frame = CGRectMake(5, 550, width - 10, 0);
    addVideoView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:addVideoView];
    __weak typeof(self) weakSelf = self;
    [addVideoView setSelectVideo:^(NSArray *video) {
        NSLog(@"video - %@",video);
        [video enumerateObjectsUsingBlock:^(ALAsset *asset, NSUInteger idx, BOOL * _Nonnull stop) {
            
            // 缩略图
            //            UIImage *image = [UIImage imageWithCGImage:[asset aspectRatioThumbnail]];
            
            // 原图
            //            CGImageRef fullImage = [[asset defaultRepresentation] fullResolutionImage];
            
            // url
            NSURL *url = [[asset defaultRepresentation] url];
            weakSelf.videoUrl = url;
        }];
    }];
    
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"写入" style:UIBarButtonItemStylePlain target:self action:@selector(writeVideo)];
}

// 开始写入
- (void)writeVideo
{
    if (!self.videoUrl) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
        UIView *view = [[UIView alloc] init];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"qrcode_ar_failed@2x.png"]];
        [view addSubview:imageView];
        
        view.frame = CGRectMake(0, 0, imageView.image.size.width, imageView.image.size.height + 10);
        
        hud.customView = view;
        hud.mode = MBProgressHUDModeCustomView;
        hud.labelText = @"视频url不能为空!";
        hud.margin = 10.f;
        hud.removeFromSuperViewOnHide = YES;
        
        [hud hide:YES afterDelay:1.5f];
        return;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    
    hud.labelText = @"正在写入";
    
    [self CompressedVideoWithURL:self.videoUrl success:^(NSString *fileName) {
        
        NSLog(@"%@",fileName); // 沙盒路径
        
        UIImage *image = [UIImage imageNamed:@"37x-Checkmark.png"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        hud.customView = imageView;
        hud.labelText = @"写入成功";
        hud.mode = MBProgressHUDModeCustomView;
        [hud hide:YES afterDelay:1.f];
        self.videoUrl = nil;
    } failure:^{
        hud.labelText = @"写入失败";
        [hud hide:YES afterDelay:3.f];
    }];
}

// 压缩视频并写入沙盒文件
- (void)CompressedVideoWithURL:(NSURL *)url success:(void(^)(NSString *fileName))success failure:(void(^)())failure
{
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:url options:nil];
    
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


- (void)updateViewFrame:(CGRect)frame WithView:(UIView *)view
{
    [self.view layoutSubviews];
}
@end
