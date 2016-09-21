//
//  HX_AssetManager.h
//  测试
//
//  Created by 洪欣 on 16/8/20.
//  Copyright © 2016年 洪欣. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "HX_PhotoModel.h"
#import "HX_AlbumModel.h"
typedef enum{
    HX_SelectPhoto,
    HX_SelectVideo,
    HX_SelectPhotoAndVieo
}HX_SelectType;

@interface HX_AssetManager : NSObject
@property (strong, nonatomic) NSMutableArray *allAlbumAy;
@property (strong, nonatomic) NSMutableArray *allGroup;
@property (assign, nonatomic) BOOL ifRefresh;

/**  用于记录的数组  */
@property (strong, nonatomic) NSMutableArray *recordPhotos;
@property (assign, nonatomic) BOOL recordOriginal;

@property (assign, nonatomic) HX_SelectType type;

/**  已经添加的图片数组  */
@property (strong, nonatomic) NSMutableArray *selectedPhotos;

@property (assign, nonatomic) BOOL ifOriginal;

//@property (copy, nonatomic) NSString *totalBytes;

/**  存放视频压缩后的地址  */
@property (strong, nonatomic) NSMutableArray *videoFileNames;

/**  自定义相册的名称  */
@property (copy, nonatomic) NSString *customName;

+ (instancetype)sharedManager;

/**  获取所有相册信息  */
- (void)getAllAlbumWithStart:(void(^)())start WithEnd:(void(^)(NSArray *allAlbum,NSArray *photosAy))album WithFailure:(void(^)(NSError *error))failure;

/**  根据PHAsset获取图片信息  */
- (void)accessToImageAccordingToTheAsset:(PHAsset *)asset size:(CGSize)size resizeMode:(PHImageRequestOptionsResizeMode)resizeMode completion:(void(^)(UIImage *image,NSDictionary *info))completion;

- (void)savePhotoWithImage:(UIImage *)image completion:(void(^)())completion WithError:(void(^)())error;
- (void)getJustTakePhotosWithCompletion:(void(^)(NSArray *array))completion;

- (void)savePhotoWithVideo:(NSURL *)url completion:(void(^)())completion WithError:(void(^)())error;
- (void)getJustTakeVideoWithCompletion:(void(^)(NSArray *array))completion;


- (void)getPhotosBytes:(void(^)(NSString *bytes))by;
@end
