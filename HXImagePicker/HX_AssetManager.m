//
//  HX_AssetManager.m
//  测试
//
//  Created by 洪欣 on 16/8/20.
//  Copyright © 2016年 洪欣. All rights reserved.
//

#import "HX_AssetManager.h"


#define VERSION [[UIDevice currentDevice].systemVersion doubleValue]

@interface HX_AssetManager ()
@property (strong, nonatomic) ALAssetsLibrary *assetsLibrary;
@property (assign, nonatomic) BOOL ifTakingPictures;
@property (strong, nonatomic) HX_PhotoModel *picturesModel;
@end

static HX_AssetManager *sharedManager = nil;
static BOOL ifOne = YES;
@implementation HX_AssetManager

+ (instancetype)sharedManager
{
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (NSMutableArray *)selectedPhotos
{
    if (!_selectedPhotos) {
        _selectedPhotos = [NSMutableArray array];
    }
    
    return _selectedPhotos;
}

- (NSMutableArray *)recordPhotos
{
    if (!_recordPhotos) {
        _recordPhotos = [NSMutableArray array];
    }
    return _recordPhotos;
}

- (ALAssetsLibrary *)assetsLibrary
{
    if (!_assetsLibrary) {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    return _assetsLibrary;
}

#pragma mark - < 所有相册封面信息 >
- (NSMutableArray *)allAlbumAy
{
    if (!_allAlbumAy) {
        _allAlbumAy = [NSMutableArray array];
    }
    return _allAlbumAy;
}

#pragma mark - < 所有相册里的所有图片信息 >
- (NSMutableArray *)allGroup
{
    if (!_allGroup) {
        _allGroup = [NSMutableArray array];
    }
    return _allGroup;
}

#pragma mark - < 是否重新加载图片 >
- (void)setIfRefresh:(BOOL)ifRefresh
{
    _ifRefresh = ifRefresh;
    
    ifOne = ifRefresh;
}

#pragma mark - < 是否原图 >
- (BOOL)ifOriginal
{
    if (self.selectedPhotos.count == 0) {
        return NO;
    }
    return _ifOriginal;
}

/**  获取所有相册信息  */
- (void)getAllAlbumWithStart:(void (^)())start WithEnd:(void (^)(NSArray *, NSArray *))album WithFailure:(void (^)(NSError *))failure
{
    if (start) {
        start();
    }
    
    if (ifOne) {
        [self.allAlbumAy removeAllObjects];
        [self.allGroup removeAllObjects];
  
        [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if (group) {
                if (self.type == HX_SelectPhoto) {
                    [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                }else if (self.type == HX_SelectVideo) {
                    [group setAssetsFilter:[ALAssetsFilter allVideos]];
                }else if (self.type == HX_SelectPhotoAndVieo) {
                    [group setAssetsFilter:[ALAssetsFilter allAssets]];
                }
                
                if ([group numberOfAssets] != 0) {
                    HX_AlbumModel *album = [[HX_AlbumModel alloc] init];
 
//                    album.coverImage = [UIImage imageWithCGImage:[group posterImage]];
//                    
                    album.group = group;
                    [self.allAlbumAy addObject:album];
           
                    NSMutableArray *ay = [NSMutableArray array];
                    
                    NSInteger numberOfAssets = [group numberOfAssets];
                    
                    [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                        
                        if (result) {
                            if (index == numberOfAssets - 1) {
                                album.thumbnail = [UIImage imageWithCGImage:[result thumbnail] scale:2.0 orientation:UIImageOrientationUp];
                            }
                            
                            HX_PhotoModel *model = [[HX_PhotoModel alloc] init];
                            model.tableViewIndex = self.allAlbumAy.count - 1;
  
                            
                            if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                                model.type = HX_Photo;
                            }else if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]) {
                                model.type = HX_Video;
                                NSTimeInterval duration = [[result valueForProperty:ALAssetPropertyDuration] integerValue];
                                NSString *timeLength = [NSString stringWithFormat:@"%0.0f",duration];
                                model.videoTime = [self getNewTimeFromDurationSecond:timeLength.integerValue];
                            }else if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeUnknown]) {
                                model.type = HX_Unknown;
                            }
//                            if (self.ifTakingPictures && index == numberOfAssets - 1) {
//                                model.ifAdd = YES;
//                                model.ifSelect = YES;
//                            }
//                            model.image = [UIImage imageWithCGImage:[result aspectRatioThumbnail]];
                            model.asset = result;
                            
                            [ay addObject:model];
                        }
                    }];
                    [self.allGroup addObject:ay];
                }
                
            }else {
                if (self.allAlbumAy.count > 0) {
                    if (self.ifTakingPictures) {
                        self.picturesModel.ifSelect = YES;
                        self.picturesModel.ifAdd = YES;
                        [self.allGroup.lastObject addObject:self.picturesModel];
                        self.ifTakingPictures = NO;
                    }
                    if (album) {
                        album(self.allAlbumAy,self.allGroup);
                        ifOne = NO;
                    }
                }
            }
        } failureBlock:^(NSError *error) {
            if (failure) {
                failure(error);
            }
        }];
    }else {
        if (self.ifTakingPictures) {
            self.picturesModel.ifSelect = YES;
            self.picturesModel.ifAdd = YES;
            [self.allGroup.lastObject addObject:self.picturesModel];
            self.ifTakingPictures = NO;
        }
        if (album) {
            album(self.allAlbumAy,self.allGroup);
        }
    }
}

- (void)IOS8UpGetAllAlbumWithStart:(void (^)())start WithEnd:(void (^)(NSArray *, NSArray *))album WithFailure:(void (^)(NSError *))failure
{
    if (start) {
        start();
    }
    
    if (ifOne) {
        
        // 获取系统相册
        PHFetchResult *smartAlbum = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        
        
        
    }else {
        
    }
}

#pragma mark - < 获取视频的大小 >
- (NSString *)getNewTimeFromDurationSecond:(NSInteger)duration {
    NSString *newTime;
    if (duration < 10) {
        newTime = [NSString stringWithFormat:@"00:0%zd",duration];
    } else if (duration < 60) {
        newTime = [NSString stringWithFormat:@"00:%zd",duration];
    } else {
        NSInteger min = duration / 60;
        NSInteger sec = duration - (min * 60);
        if (sec < 10) {
            newTime = [NSString stringWithFormat:@"%zd:0%zd",min,sec];
        } else {
            newTime = [NSString stringWithFormat:@"%zd:%zd",min,sec];
        }
    }
    return newTime;
}

#pragma mark - < 图片大小 >
- (NSString *)totalBytes
{
    return [self getPhotosBytesWithArray:self.selectedPhotos];
}

#pragma mark - < 获取一组图片的大小 >
- (NSString *)getPhotosBytesWithArray:(NSArray *)photos
{
    __block NSInteger dataLength = 0;

    for (NSInteger i = 0; i < photos.count; i++) {
        
        HX_PhotoModel *model = photos[i];
        
        ALAsset *asset = model.asset;
        
            ALAssetRepresentation *representation = [asset defaultRepresentation];
             dataLength += (NSInteger)representation.size;

            if (i >= photos.count - 1) {
                NSString *bytes = [self getBytesFromDataLength:dataLength];
                return bytes;
            }
    }
    return @"";
}


#pragma mark - < 换算图片的大小 >
- (NSString *)getBytesFromDataLength:(NSInteger)length
{
    if(length<1024)
        return [NSString stringWithFormat:@"%ldB",(long)length];
    else if(length>=1024&&length<1024*1024)
        return [NSString stringWithFormat:@"%.0fK",(float)length/1024];
    else if(length >=1024*1024&&length<1024*1024*1024)
        return [NSString stringWithFormat:@"%.1fM",(float)length/(1024*1024)];
    else
        return [NSString stringWithFormat:@"%.1fG",(float)length/(1024*1024*1024)];
}

- (void)savePhotoWithImage:(UIImage *)image completion:(void(^)())completion WithError:(void (^)())error
{
    
    [self.assetsLibrary writeImageToSavedPhotosAlbum:image.CGImage orientation:(ALAssetOrientation)image.imageOrientation completionBlock:^(NSURL *assetURL, NSError *error1) {
        if (error1) {
            if (error) {
                error();
            }
        }else {
            if (completion) {
                completion();
            }
        }
    }];
}

- (void)getJustTakePhotosWithCompletion:(void (^)(NSArray *array))completion
{
    _ifTakingPictures = YES;
    __block NSInteger tag = 0;
    NSMutableArray *array = [NSMutableArray array];
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (self.type == HX_SelectPhoto) {
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        }else if (self.type == HX_SelectVideo) {
            [group setAssetsFilter:[ALAssetsFilter allVideos]];
        }else if (self.type == HX_SelectPhotoAndVieo) {
            [group setAssetsFilter:[ALAssetsFilter allAssets]];
        }
        if ([group numberOfAssets] > 0) {
            NSString *name = [group valueForProperty:ALAssetsGroupPropertyName];
            
            tag++;
            if ([name isEqualToString:@"Camera Roll"] || [name isEqualToString:@"相机胶卷"] || [name isEqualToString:@"所有照片"] || [name isEqualToString:@"All Photos"]) {
                
                HX_AlbumModel *albumModel = self.allAlbumAy.lastObject;
                albumModel.photosNum = [group numberOfAssets];
                
                [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                    if (result) {
                        HX_PhotoModel *model = [[HX_PhotoModel alloc] init];
                        model.collectionViewIndex = index;
                        model.asset = result;
                        model.tableViewIndex = tag -1;
                        [array addObject:model];
                    }
                }];
                self.picturesModel = array.lastObject;
                if (completion) completion(array);
                *stop = YES;
            }
        }
        
    } failureBlock:nil];
}

- (void)savePhotoWithVideo:(NSURL *)url completion:(void (^)())completion WithError:(void (^)())error
{
    [self.assetsLibrary writeVideoAtPathToSavedPhotosAlbum:url completionBlock:^(NSURL *assetURL, NSError *error1) {
        if (error1) {
            if (error) {
                error();
            }
        }else {
            if (completion) {
                completion();
            }
        }
    }];
}

- (void)getJustTakeVideoWithCompletion:(void (^)(NSArray *array))completion
{
    _ifTakingPictures = YES;
    __block NSInteger tag = 0;
    NSMutableArray *array = [NSMutableArray array];
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (self.type == HX_SelectPhoto) {
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        }else if (self.type == HX_SelectVideo) {
            [group setAssetsFilter:[ALAssetsFilter allVideos]];
        }else if (self.type == HX_SelectPhotoAndVieo) {
            [group setAssetsFilter:[ALAssetsFilter allAssets]];
        }
        if ([group numberOfAssets] > 0) {
            NSString *name = [group valueForProperty:ALAssetsGroupPropertyName];
            
            tag++;
            if ([name isEqualToString:@"Camera Roll"] || [name isEqualToString:@"相机胶卷"] || [name isEqualToString:@"所有照片"] || [name isEqualToString:@"All Photos"]) {
                
                HX_AlbumModel *albumModel = self.allAlbumAy.lastObject;
                albumModel.photosNum = [group numberOfAssets];
                
                [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                    if (result) {
                        HX_PhotoModel *model = [[HX_PhotoModel alloc] init];
                        model.collectionViewIndex = index;
                        model.asset = result;
                        model.tableViewIndex = tag -1;
                        if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]) {
                            NSTimeInterval duration = [[result valueForProperty:ALAssetPropertyDuration] integerValue];
                            NSString *timeLength = [NSString stringWithFormat:@"%0.0f",duration];
                            model.videoTime = [self getNewTimeFromDurationSecond:timeLength.integerValue];
                        }
                        [array addObject:model];
                    }
                }];
                self.picturesModel = array.lastObject;
                if (completion) completion(array);
                *stop = YES;
            }
        }
        
    } failureBlock:nil];
}

+ (void)destruction
{
    sharedManager = nil;
}
@end
