//
//  TwoViewController.m
//  HXImagePickerDemo
//
//  Created by 洪欣 on 16/9/9.
//  Copyright © 2016年 洪欣. All rights reserved.
//

#import "TwoViewController.h"
#import "HX_AddPhotoView.h"
#import <AssetsLibrary/AssetsLibrary.h>
@interface TwoViewController ()<HX_AddPhotoViewDelegate>

@end

@implementation TwoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.navigationBar.translucent = YES;
    
    self.title = @"DemoTwo";
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
    self.view.backgroundColor = [UIColor brownColor];
    
    // 选择照片和视频
    HX_AddPhotoView *addPhotoView = [[HX_AddPhotoView alloc] initWithMaxPhotoNum:8 WithSelectType:SelectPhotoAndVideo];
    addPhotoView.lineNum = 4;
    addPhotoView.margin_Left = 5;
    addPhotoView.margin_Top = 5;
    addPhotoView.lineSpacing = 5;
    addPhotoView.delegate = self;
    addPhotoView.backgroundColor = [UIColor whiteColor];
    addPhotoView.frame = CGRectMake(5, 150, width - 10, 0);
    [self.view addSubview:addPhotoView];
    
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
    addVideoView.frame = CGRectMake(5, self.view.frame.size.height - 100, width - 10, 0);
    addVideoView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:addVideoView];
    
    [addVideoView setSelectVideo:^(NSArray *video) {
        NSLog(@"video - %@",video);
        [video enumerateObjectsUsingBlock:^(ALAsset *asset, NSUInteger idx, BOOL * _Nonnull stop) {
            
            // 缩略图
            //            UIImage *image = [UIImage imageWithCGImage:[asset aspectRatioThumbnail]];
            
            // 原图
            //            CGImageRef fullImage = [[asset defaultRepresentation] fullResolutionImage];
            
            // url
            //            NSURL *url = [[asset defaultRepresentation] url];
            
        }];
    }];
}

- (void)updateViewFrame:(CGRect)frame WithView:(UIView *)view
{
    [self.view layoutSubviews];
}

@end
