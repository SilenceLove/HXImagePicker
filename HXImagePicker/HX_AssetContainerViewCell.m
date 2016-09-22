//
//  HX_AssetContainerViewCell.m
//  测试
//
//  Created by 洪欣 on 16/8/20.
//  Copyright © 2016年 洪欣. All rights reserved.
//

#import "HX_AssetContainerViewCell.h"
#import "HX_AssetManager.h"
#define VERSION [[UIDevice currentDevice].systemVersion doubleValue]

@interface HX_AssetContainerViewCell ()<UIScrollViewDelegate>
@property (weak, nonatomic) UIScrollView *scrollView;
@property (weak, nonatomic) UIImageView *imageView;
@property (assign, nonatomic) CGPoint imageCenter;
@end

@implementation HX_AssetContainerViewCell

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
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    scrollView.delegate = self;
    scrollView.bouncesZoom = YES;
    scrollView.maximumZoomScale = 2.5;
    scrollView.minimumZoomScale = 1.0;
    scrollView.multipleTouchEnabled = YES;
    scrollView.scrollsToTop = NO;
    scrollView.contentSize = CGSizeMake(width, height);
    scrollView.userInteractionEnabled = YES;
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    scrollView.delaysContentTouches = NO;
    scrollView.canCancelContentTouches = YES;
    scrollView.alwaysBounceVertical = NO;
    
    [self.contentView addSubview:scrollView];
    _scrollView = scrollView;
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.center = CGPointMake(width / 2, height / 2);
    [scrollView addSubview:imageView];
    _imageView = imageView;
    
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    [scrollView addGestureRecognizer:tap1];
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    tap2.numberOfTapsRequired = 2;
    [tap1 requireGestureRecognizerToFail:tap2];
    [self addGestureRecognizer:tap2];
}

- (void)singleTap:(UITapGestureRecognizer *)tap {
    if (self.didImgBlock) {
        self.didImgBlock();
    }
}

- (void)doubleTap:(UITapGestureRecognizer *)tap {
    if (_scrollView.zoomScale > 1.0) {
        [_scrollView setZoomScale:1.0 animated:YES];
    } else {
        CGPoint touchPoint = [tap locationInView:self.imageView];
        CGFloat newZoomScale = _scrollView.maximumZoomScale;
        CGFloat xsize = self.frame.size.width / newZoomScale;
        CGFloat ysize = self.frame.size.height / newZoomScale;
        [_scrollView zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
    }
}

#pragma mark - 返回需要缩放的控件
- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollView.frame.size.width > scrollView.contentSize.width) ? (scrollView.frame.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.frame.size.height > scrollView.contentSize.height) ? (scrollView.frame.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    self.imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
}

- (void)updateImageSize
{
    [_scrollView setZoomScale:1.0 animated:NO];
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    CGFloat imgWidth = _model.imageSize.width;
    CGFloat imgHeight = _model.imageSize.height;
    
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
}

- (void)setModel:(HX_PhotoModel *)model
{
    _model = model;
    [_scrollView setZoomScale:1.0 animated:NO];
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    CGFloat imgWidth = model.imageSize.width;
    CGFloat imgHeight = model.imageSize.height;
    
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
    
    CGFloat scale = [UIScreen mainScreen].scale;
    __weak typeof(self) weakSelf = self;
    if (model.type == HX_Video) {
        if (!model.screenImage) {
            _imageView.image = [UIImage imageNamed:@"shenmedoumeiyou"];
            if (VERSION < 8.0f) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    
                    CGImageRef fullScreen = [[model.asset defaultRepresentation] fullScreenImage];
                    
                    UIImage *image = [UIImage imageWithCGImage:fullScreen scale:scale orientation:UIImageOrientationUp];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weakSelf.imageView.image = image;
                        model.screenImage = image;
                    });
                });
            }else {
                [[HX_AssetManager sharedManager] accessToImageAccordingToTheAsset:model.PH_Asset size:CGSizeMake(model.PH_Asset.pixelWidth * scale, model.PH_Asset.pixelHeight * scale) resizeMode:PHImageRequestOptionsResizeModeFast completion:^(UIImage *image, NSDictionary *info) {
                    weakSelf.imageView.image = image;
                    model.screenImage = image;
                }];
            }
        }else {
            _imageView.image = model.screenImage;
        }
    }else {
        if (imgHeight > height * 1.5) {
            if (!model.resolutionImage) {
             _imageView.image = [UIImage imageNamed:@"shenmedoumeiyou"];
                
                if (VERSION < 8.0f) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        
                        CGImageRef Resolution = [[model.asset defaultRepresentation] fullResolutionImage];
                        
                        UIImage *image = [UIImage imageWithCGImage:Resolution scale:scale orientation:UIImageOrientationUp];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            weakSelf.imageView.image = image;
                            model.resolutionImage = image;
                        });
                    });
                }else {
                    [[HX_AssetManager sharedManager] accessToImageAccordingToTheAsset:model.PH_Asset size:CGSizeMake(model.PH_Asset.pixelWidth * scale, model.PH_Asset.pixelHeight * scale) resizeMode:PHImageRequestOptionsResizeModeFast completion:^(UIImage *image, NSDictionary *info) {
                        weakSelf.imageView.image = image;
                        model.resolutionImage = image;
                    }];
                }
            }else {
                _imageView.image = model.resolutionImage;
            }
        }else {
            if (!model.screenImage) {
                _imageView.image = [UIImage imageNamed:@"shenmedoumeiyou"];
                if (VERSION < 8.0f) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        
                        CGImageRef fullScreen = [[model.asset defaultRepresentation] fullScreenImage];
                        
                        UIImage *image = [UIImage imageWithCGImage:fullScreen scale:scale orientation:UIImageOrientationUp];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            weakSelf.imageView.image = image;
                            model.screenImage = image;
                        });
                    });
                }else {
                    [[HX_AssetManager sharedManager] accessToImageAccordingToTheAsset:model.PH_Asset size:CGSizeMake(width * scale, height * scale) resizeMode:PHImageRequestOptionsResizeModeFast completion:^(UIImage *image, NSDictionary *info) {
                        weakSelf.imageView.image = image;
                        model.screenImage = image;
                    }];
                }
            }else {
                _imageView.image = model.screenImage;
            }
        }
    }
    _imageCenter = _imageView.center;
}

- (void)dealloc
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

@end
