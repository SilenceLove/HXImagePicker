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
#import <Photos/Photos.h>
#import "HX_AssetManager.h"
#define VERSION [[UIDevice currentDevice].systemVersion doubleValue]
@interface OneViewController ()<HX_AddPhotoViewDelegate>
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
    
    // 自定义相册的名称 - 不设置默认为自定义相册
    addPhotoView.customName = @"郑莹";
    
    addPhotoView.delegate = self;
    addPhotoView.backgroundColor = [UIColor whiteColor];
    addPhotoView.frame = CGRectMake(0, 150, width - 0, 0);
    [self.view addSubview:addPhotoView];
    /**  当前选择的个数  */
    addPhotoView.selectNum;
    __weak typeof(self) weakSelf = self;
    [addPhotoView setSelectPhotos:^(NSArray *photos, NSArray *videoFileNames, BOOL iforiginal) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
//        NSLog(@"photo - %@",photos);
        
        // 选择视频的沙盒文件路径  -  已压缩
//        NSString *videoFileName = videoFileNames.firstObject;
//        NSLog(@"videoFileNames - %@",videoFileNames);
        
        [photos enumerateObjectsUsingBlock:^(id asset, NSUInteger idx, BOOL * _Nonnull stop) {
            
            // ios8.0 以下返回的是ALAsset对象 以上是PHAsset对象
            if (VERSION < 8.0f) {
                ALAsset *oneAsset = (ALAsset *)asset;
                // 缩略图
                //            UIImage *image = [UIImage imageWithCGImage:[asset aspectRatioThumbnail]];
                
                // 原图
                //            CGImageRef fullImage = [[asset defaultRepresentation] fullResolutionImage];
                
                // url
                //            NSURL *url = [[asset defaultRepresentation] url];
            }else {
                PHAsset *twoAsset = (PHAsset *)asset;
                
                CGFloat scale = [UIScreen mainScreen].scale;
                
                // 根据输入的大小来控制返回的图片质量
                CGSize size = CGSizeMake(300 * scale, 300 * scale);
                [[HX_AssetManager sharedManager] accessToImageAccordingToTheAsset:twoAsset size:size resizeMode:PHImageRequestOptionsResizeModeFast completion:^(UIImage *image, NSDictionary *info) {
                    // image为高清图时
                    if (![info objectForKey:PHImageResultIsDegradedKey]) {
                        // 高清图
                        image;
                        
                        NSLog(@"%@",image);
                    }
                }];
            }
            
        }];
    }];
    
    // 只选择视频
    HX_AddPhotoView *addVideoView = [[HX_AddPhotoView alloc] initWithMaxPhotoNum:9 WithSelectType:SelectVideo];
    addVideoView.delegate = self;
    
    addVideoView.frame = CGRectMake(5, 550, width - 10, 0);
    addVideoView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:addVideoView];
    [addVideoView setSelectVideo:^(NSArray *video, NSArray *videoFileNames) {
        NSLog(@"video - %@",video);
        
        // 选择视频的沙盒文件路径  -  已压缩
//        NSString *videoFileName = videoFileNames.firstObject;
        NSLog(@"videoFileNames - %@",videoFileNames);
        
        [video enumerateObjectsUsingBlock:^(id asset, NSUInteger idx, BOOL * _Nonnull stop) {
            
            // ios8.0 以下返回的是ALAsset对象
            if (VERSION < 8.0f) {
                ALAsset *oneAsset = (ALAsset *)asset;
                // 缩略图
                //            UIImage *image = [UIImage imageWithCGImage:[asset aspectRatioThumbnail]];
                
                // 原图
                //            CGImageRef fullImage = [[asset defaultRepresentation] fullResolutionImage];
                
                // url
                //            NSURL *url = [[asset defaultRepresentation] url];
            }else {
                PHAsset *twoAsset = (PHAsset *)asset;
                
                CGFloat scale = [UIScreen mainScreen].scale;
                
                // 根据输入的大小来控制返回的图片质量
                CGSize size = CGSizeMake(300 * scale, 300 * scale);
                [[HX_AssetManager sharedManager] accessToImageAccordingToTheAsset:twoAsset size:size resizeMode:PHImageRequestOptionsResizeModeFast completion:^(UIImage *image, NSDictionary *info) {
                    // image为高清图时
                    if (![info objectForKey:PHImageResultIsDegradedKey]) {
                        // 高清图
                        image;
                    }
                }];
            }
        }];
    }];
    
}

- (void)updateViewFrame:(CGRect)frame WithView:(UIView *)view
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    CGFloat buttonY = CGRectGetMaxY(frame);
    
    button.frame = CGRectMake(0, buttonY, 100, 100);
    [self.view layoutSubviews];
}
@end
