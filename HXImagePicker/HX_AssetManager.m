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
@property (assign, nonatomic) NSInteger TPTableIndex;
@property (assign, nonatomic) NSInteger TPCollectionIndex;
@end

static HX_AssetManager *sharedManager = nil;
static BOOL ifOne = YES;
@implementation HX_AssetManager

+ (instancetype)sharedManager
{
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedManager = [[self alloc] init];
        sharedManager.videoFileNames = [NSMutableArray array];
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

#pragma mark - < 自定义相册的名称 >
- (void)setCustomName:(NSString *)customName
{
    _customName = customName;
    if (_customName.length == 0) {
        _customName = @"自定义相册";
    }
}

#pragma mark - <  获取所有相册信息  >
- (void)getAllAlbumWithStart:(void (^)())start WithEnd:(void (^)(NSArray *, NSArray *))album WithFailure:(void (^)(NSError *))failure
{
    if (start) {
        start();
    }
    
    // 是否第一次
    if (ifOne) {
        // 清空封面数组
        [self.allAlbumAy removeAllObjects];
        // 清空图片数组
        [self.allGroup removeAllObjects];
        
        // 当系统版本是ios8.0以下的时候用AssetsLibrary这个库
        if (VERSION < 8.0f) {
            // 遍历所有的相册
            [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                if (group) {
                    // 筛选类型
                    if (self.type == HX_SelectPhoto) {
                        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                    }else if (self.type == HX_SelectVideo) {
                        [group setAssetsFilter:[ALAssetsFilter allVideos]];
                    }else if (self.type == HX_SelectPhotoAndVieo) {
                        [group setAssetsFilter:[ALAssetsFilter allAssets]];
                    }
                    
                    // 过滤掉空相册
                    if ([group numberOfAssets] != 0) {
                        // 将相册封面对象存放到封面数组中
                        HX_AlbumModel *album = [[HX_AlbumModel alloc] init];
                        album.group = group;
                        [self.allAlbumAy addObject:album];
                        
                        NSMutableArray *ay = [NSMutableArray array];
                        // 相册里图片的数量
                        NSInteger numberOfAssets = [group numberOfAssets];
                        
                        // 遍历相册里面的图片
                        [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                            
                            if (result) {
                                // 每个相册的封面图片 取最后一张
                                if (index == numberOfAssets - 1) {
                                    album.thumbnail = [UIImage imageWithCGImage:[result thumbnail] scale:2.0 orientation:UIImageOrientationUp];
                                }
                                
                                HX_PhotoModel *model = [[HX_PhotoModel alloc] init];
                                // 记录相册里面每张图片所在相册的下标
                                model.tableViewIndex = self.allAlbumAy.count - 1;
                                
                                // 判断图片的类型
                                if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) { // 照片
                                    model.type = HX_Photo;
                                }else if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]) { // 视频
                                    model.type = HX_Video;
                                    NSTimeInterval duration = [[result valueForProperty:ALAssetPropertyDuration] integerValue];
                                    NSString *timeLength = [NSString stringWithFormat:@"%0.0f",duration];
                                    model.videoTime = [self getNewTimeFromDurationSecond:timeLength.integerValue];
                                }else if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeUnknown]) {
                                    model.type = HX_Unknown;
                                }

                                model.asset = result;
                                
                                [ay addObject:model];
                            }
                        }];
                        // 将相册里的所有图片添加到数组中再讲此数组添加到所有组的数组中
                        [self.allGroup addObject:ay];
                    }
                    
                }else {
                    if (self.allAlbumAy.count > 0) {
                        // 判断是否拍照 是的话就把刚刚拍照的对象存放到所有照片的那个数组中
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
        }else { // ios 8.0 以上用Photos.h这个库
            // 相机胶卷
            PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
            
            __weak typeof(self) weakSelf = self;
            
            __block NSInteger index = 0;
            // 遍历相册
            [smartAlbums enumerateObjectsUsingBlock:^(PHAssetCollection *collection, NSUInteger idx, BOOL * _Nonnull stop) {
                
                // 用strong修饰 防止在block里释放
                __strong typeof(weakSelf) strongSelf = weakSelf;
                
                // 是否按创建时间排序
                PHFetchOptions *option = [[PHFetchOptions alloc] init];
                option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
                
                if (self.type == HX_SelectPhoto) {
                    option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
                }else if (self.type == HX_SelectVideo) {
                    option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeVideo];
                }
                
                // 获取所有图片对象
                PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:collection options:option];
                
                NSArray *assets;
                if (result.count > 0) {
                    // 某个相册里面的所有PHAsset对象
                    assets = [strongSelf getAllPhotosAssetInAblumCollection:collection ascending:YES index:index];
                    ++index;
                }
                
                // 过滤掉空相册
                if (assets.count > 0) {
                    // 相册封面信息
                    HX_AlbumModel *model = [[HX_AlbumModel alloc] init];
                    // 相册名称
                    model.albumName = [weakSelf transFormPhotoTitle:collection.localizedTitle];
                    // 照片数量
                    model.photosNum = assets.count;
                    // 封面图片PHAsset对象
                    HX_PhotoModel *photoModel = assets.lastObject;
                    model.PH_Asset = photoModel.PH_Asset;
                    // 封面图片PHAssetCollection对象
                    model.PH_AssetCollection = collection;
                    // 将封面图片模型添加到数组中
                    [weakSelf.allAlbumAy addObject:model];
                    
                    [weakSelf.allGroup addObject:assets];
                }
            }];
            
            // 获取用户自定义相册
            PHFetchResult *userAblums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
            
            // 遍历
            [userAblums enumerateObjectsUsingBlock:^(PHAssetCollection *collection, NSUInteger idx, BOOL * _Nonnull stop) {
                // 用strong修饰 防止在block里释放
                __strong typeof(weakSelf) strongSelf = weakSelf;
                
                // 是否按创建时间排序
                PHFetchOptions *option = [[PHFetchOptions alloc] init];
                option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
                if (self.type == HX_SelectPhoto) {
                    option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
                }else if (self.type == HX_SelectVideo) {
                    option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeVideo];
                }
                
                // 获取所有图片对象
                PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:collection options:option];
                
                NSArray *assets;
                if (result.count > 0) {
                    // 某个相册里面的所有PHAsset对象
                    assets = [strongSelf getAllPhotosAssetInAblumCollection:collection ascending:YES index:index];
                    ++index;
                }
                
                // 过滤掉空相册
                if (assets.count > 0) {
                    // 相册封面信息
                    HX_AlbumModel *model = [[HX_AlbumModel alloc] init];
                    // 相册名称
                    model.albumName = [weakSelf transFormPhotoTitle:collection.localizedTitle];
                    // 照片数量
                    model.photosNum = assets.count;
                    // 封面图片PHAsset对象
                    HX_PhotoModel *photoModel = assets.lastObject;
                    model.PH_Asset = photoModel.PH_Asset;
                    // 封面图片PHAssetCollection对象
                    model.PH_AssetCollection = collection;
                    // 将封面图片模型添加到数组中
                    [weakSelf.allAlbumAy addObject:model];
                    
                    [weakSelf.allGroup addObject:assets];
                }
            }];
            
            if (album) {
                album(self.allAlbumAy,self.allGroup);
                ifOne = NO;
            }
        }
       
    }else {
        if (VERSION < 8.0f) {
            // 判断是否拍照 是的话就把刚刚拍照的对象存放到所有照片的那个数组中
            if (self.ifTakingPictures) {
                self.picturesModel.ifSelect = YES;
                self.picturesModel.ifAdd = YES;
                [self.allGroup.lastObject addObject:self.picturesModel];
                self.ifTakingPictures = NO;
            }
        }
        
        if (album) {
            album(self.allAlbumAy,self.allGroup);
        }
    }
}

#pragma mark - <  获取相册里的所有图片的PHAsset对象  >
- (NSArray *)getAllPhotosAssetInAblumCollection:(PHAssetCollection *)assetCollection ascending:(BOOL)ascending index:(NSInteger)index
{
    // 存放所有图片对象
    NSMutableArray *assets = [NSMutableArray array];
    
    // 是否按创建时间排序
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:ascending]];
    
    if (self.type == HX_SelectPhoto) {
        option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
    }else if (self.type == HX_SelectVideo) {
        option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeVideo];
    }
    
    // 获取所有图片对象
    PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:assetCollection options:option];
    
    // 遍历
    [result enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL * _Nonnull stop) {
        
        HX_PhotoModel *model = [[HX_PhotoModel alloc] init];
        model.tableViewIndex = index;
        model.PH_Asset = asset;
        model.collectionViewIndex = idx;
        
        if (_ifTakingPictures) {
            if (index == _TPTableIndex && idx == _TPCollectionIndex) {
                model.ifAdd = YES;
                model.ifSelect = YES;
                _ifTakingPictures = NO;
            }
        }
        
        if (asset.mediaType == PHAssetMediaTypeImage) {
            model.type = HX_Photo;
        }else if (asset.mediaType == PHAssetMediaTypeVideo) {
            model.type = HX_Video;
            NSString *timeLength = [NSString stringWithFormat:@"%0.0f",asset.duration];
            model.videoTime = [self getNewTimeFromDurationSecond:timeLength.integerValue];
            [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:nil resultHandler:^(AVAsset * _Nullable asset1, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                model.URLAsset = asset1;
            }];
        }else {
            model.type = HX_Unknown;
        }
        
        // 将图片对象存放到数组中
        [assets addObject:model];
    }];
    
    return assets;
}

#pragma mark - <  根据PHAsset获取图片信息  >
- (void)accessToImageAccordingToTheAsset:(PHAsset *)asset size:(CGSize)size resizeMode:(PHImageRequestOptionsResizeMode)resizeMode completion:(void(^)(UIImage *image,NSDictionary *info))completion
{
    static PHImageRequestID requestID = -1;
    
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat width = MIN([UIScreen mainScreen].bounds.size.width, 500);
    if (requestID >= 1 && size.width / width == scale) {
        [[PHCachingImageManager defaultManager] cancelImageRequest:requestID];
    }
    
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    
    option.resizeMode = resizeMode;
    
    requestID = [[PHCachingImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
        
        if (downloadFinined && completion && result) {
            result = [self fixOrientation:result];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(result,info);
            });
        }
    }];
}

#pragma mark - < 判断相册名称 >
-(NSString *)transFormPhotoTitle:(NSString *)englishName{
    NSString *photoName;
    if ([englishName isEqualToString:@"Bursts"]) {
        photoName = @"连拍快照";
    }else if([englishName isEqualToString:@"Recently Added"]){
        photoName = @"最近添加";
    }else if([englishName isEqualToString:@"Screenshots"]){
        photoName = @"屏幕快照";
    }else if([englishName isEqualToString:@"Camera Roll"]){
        photoName = @"相机胶卷";
    }else if([englishName isEqualToString:@"Selfies"]){
        photoName = @"自拍";
    }else if([englishName isEqualToString:@"My Photo Stream"]){
        photoName = @"我的照片流";
    }else if([englishName isEqualToString:@"Videos"]){
        photoName = @"视频";
    }else if([englishName isEqualToString:@"All Photos"]){
        photoName = @"所有照片";
    }else if([englishName isEqualToString:@"Slo-mo"]){
        photoName = @"慢动作";
    }else if([englishName isEqualToString:@"Recently Deleted"]){
        photoName = @"最近删除";
    }else if([englishName isEqualToString:@"Favorites"]){
        photoName = @"个人收藏";
    }else {
        photoName = englishName;
    }
    return photoName;
}

#pragma mark - <  将歪的图片转正  >
- (UIImage *)fixOrientation:(UIImage *)aImage {
    //    if (!self.shouldFixOrientation) return aImage;
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
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

#pragma mark - < 获取一组图片的大小 >
- (void)getPhotosBytes:(void(^)(NSString *bytes))by
{
    __block NSInteger dataLength = 0;
    __block NSInteger assetCount = 0;
    
    NSArray *photos = [NSArray arrayWithArray:self.selectedPhotos];
    
    for (NSInteger i = 0; i < photos.count; i++) {
        
        HX_PhotoModel *model = photos[i];
        if (VERSION < 8.0f) {
            ALAsset *asset = model.asset;
            
            ALAssetRepresentation *representation = [asset defaultRepresentation];
            dataLength += (NSInteger)representation.size;
            
            if (i >= photos.count - 1) {
                NSString *bytes = [self getBytesFromDataLength:dataLength];
                if (by) {
                    by(bytes);
                }
            }
        }else {

            [[PHImageManager defaultManager] requestImageDataForAsset:model.PH_Asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                dataLength += imageData.length;
                assetCount ++;
                if (assetCount >= photos.count) {
                    NSString *bytes = [self getBytesFromDataLength:dataLength];
                    if (by) {
                        by(bytes);
                    }
                }
            }];
        }
    }
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

#pragma mark - 保存图片到自定义相册
#pragma mark - 获取自定义相册
- (PHAssetCollection *)collection
{
    // 先从已存在相册中找到自定义相册对象
    PHFetchResult<PHAssetCollection *> *collectionResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *collection in collectionResult) {
        if ([collection.localizedTitle isEqualToString:self.customName]) {
            return collection;
        }
    }
    
    // 新建自定义相册
    __block NSString *collectionId = nil;
    NSError *error = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        collectionId = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:self.customName].placeholderForCreatedAssetCollection.localIdentifier;
    } error:&error];
    
    if (error) {
        return nil;
    }
    
    return [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[collectionId] options:nil].lastObject;
}

- (void)savePhotoWithImage:(UIImage *)image completion:(void(^)())completion WithError:(void (^)())error
{
    if (VERSION < 8.0f) {
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
    }else {
        NSError *error1 = nil;
        
        // 保存相片到相机胶卷
        __block PHObjectPlaceholder *createdAsset = nil;
        [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
            createdAsset = [PHAssetCreationRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset;
        } error:&error1];
        
        if (error1) {
            if (error) {
                error();
            }
            return;
        }
        
        // 拿到自定义的相册对象
        PHAssetCollection *collection = [self collection];
        if (collection == nil) {
            if (error) {
                error();
            }
            return;
        }
        
        [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
            [[PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection] insertAssets:@[createdAsset] atIndexes:[NSIndexSet indexSetWithIndex:0]];
        } error:&error1];
        
        if (error1) {
            if (error) {
                error();
            }
        }else {
            if (completion) {
                completion();
            }
        }
    }
}

- (void)getJustTakePhotosWithCompletion:(void (^)(NSArray *array))completion
{
    if (VERSION < 8.0f) {
        _ifTakingPictures = YES;
        NSMutableArray *array = [NSMutableArray array];
        __block NSInteger tag = 0;
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
    }else {
        BOOL ifImport = NO;
        
        __weak typeof(self) weakSelf = self;
        
        NSInteger index = 0;
        
        __block BOOL ifCustom = NO;
        
        // 相机胶卷
        PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        
        // 获取用户自定义相册
        PHFetchResult *userAblums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
        
        // 过滤掉空相册
        NSInteger albumsCount = 0;
        for (PHAssetCollection *collection in smartAlbums) {
            // 是否按创建时间排序
            PHFetchOptions *option = [[PHFetchOptions alloc] init];
            option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
            if (self.type == HX_SelectPhoto) {
                option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
            }else if (self.type == HX_SelectVideo) {
                option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeVideo];
            }
            // 获取所有图片对象
            PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:collection options:option];
            if (result.count > 0) {
                albumsCount++;
            }
        }
        
        for (PHAssetCollection *collection in userAblums) {
        
            // 是否按创建时间排序
            PHFetchOptions *option = [[PHFetchOptions alloc] init];
            option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
            if (self.type == HX_SelectPhoto) {
                option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
            }else if (self.type == HX_SelectVideo) {
                option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeVideo];
            }
            // 获取所有图片对象
            PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:collection options:option];
            if (result.count > 0) {
                albumsCount++;
            }
            if ([collection.localizedTitle isEqualToString:@"最新导入"] && result.count > 0) {
                ifImport = YES;
            }
        }
        
        // 获取自定义相册的下标
        if (ifImport) {
            index = albumsCount - 2;
        }else {
            index = albumsCount - 1;
        }
        for (HX_AlbumModel *model in self.allAlbumAy) {
            if ([model.albumName isEqualToString:self.customName]) {
                ifCustom = YES;
            }
        }
        
        __block NSArray *photos;
        // 遍历
        [userAblums enumerateObjectsUsingBlock:^(PHAssetCollection *collection, NSUInteger idx, BOOL * _Nonnull stop) {
            // 用strong修饰 防止在block里释放
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            // 是否按创建时间排序
            PHFetchOptions *option = [[PHFetchOptions alloc] init];
            option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
            if (weakSelf.type == HX_SelectPhoto) {
                option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
            }else if (weakSelf.type == HX_SelectVideo) {
                option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeVideo];
            }
            
            // 获取所有图片对象
            PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:collection options:option];
            
            NSArray *assets;
            if (result.count > 0 && [collection.localizedTitle isEqualToString:self.customName]) {
                // 某个相册里面的所有PHAsset对象
                assets = [strongSelf getAllPhotosAssetInAblumCollection:collection ascending:YES index:index];
                photos = assets.copy;
                HX_PhotoModel *TPModel = assets.lastObject;
                weakSelf.TPTableIndex = TPModel.tableViewIndex;
                weakSelf.TPCollectionIndex = TPModel.collectionViewIndex;
                // 判断是不是第一次请求资源
                if (!ifOne) {
                    
                    if (!ifCustom) {
                        // 相册封面信息
                        HX_AlbumModel *model = [[HX_AlbumModel alloc] init];
                        // 相册名称
                        model.albumName = [weakSelf transFormPhotoTitle:collection.localizedTitle];
                        // 照片数量
                        model.photosNum = assets.count;
                        // 封面图片PHAsset对象
                        HX_PhotoModel *photoModel = assets.lastObject;
                        model.PH_Asset = photoModel.PH_Asset;
                        // 封面图片PHAssetCollection对象
                        model.PH_AssetCollection = collection;
                        
                        [weakSelf.allAlbumAy insertObject:model atIndex:index];
                        NSMutableArray *array = [NSMutableArray array];
                        [weakSelf.allGroup insertObject:array atIndex:index];
                    }
                    
                    // 需要给4个相册添加图片   - 最近添加 - 相机胶卷 - 自定义相册 - 视频
                    for (int i = 0; i < weakSelf.allAlbumAy.count; i++) {
                        HX_AlbumModel *model = weakSelf.allAlbumAy[i];
                        // 更换相册封面
                        if ([model.albumName isEqualToString:@"最近添加"] || [model.albumName isEqualToString:@"相机胶卷"] || [model.albumName isEqualToString:self.customName] || [model.albumName isEqualToString:@"所有照片"]) {
                            // 添加图片PHAsset对象
                            model.photosNum++;
                            NSArray *modelList = assets.copy;
                            HX_PhotoModel *PHModel = modelList.lastObject;
                            [strongSelf accessToImageAccordingToTheAsset:PHModel.PH_Asset size:CGSizeMake(60 * 2.0f, 60 *2.0f) resizeMode:PHImageRequestOptionsResizeModeFast completion:^(UIImage *image, NSDictionary *info) {
                                model.coverImage = image;
                            }];
                            PHModel.tableViewIndex = i;
                            [weakSelf.allGroup[i] addObject:PHModel];
                        }
                    }
                }
            }
        }];
        _ifTakingPictures = YES;
        if (completion) {
            completion(photos);
        }
    }
}

- (void)savePhotoWithVideo:(NSURL *)url completion:(void (^)())completion WithError:(void (^)())error
{
    if (VERSION < 8.0f) {
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

    }else {
        NSError *error1 = nil;
        
        // 保存相片到相机胶卷
        __block PHObjectPlaceholder *createdAsset = nil;
        [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
            createdAsset = [PHAssetCreationRequest creationRequestForAssetFromVideoAtFileURL:url].placeholderForCreatedAsset;
        } error:&error1];
        
        if (error1) {
            if (error) {
                error();
            }
            return;
        }
        
        // 拿到自定义的相册对象
        PHAssetCollection *collection = [self collection];
        if (collection == nil) {
            if (error) {
                error();
            }
            return;
        }
        
        [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
            [[PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection] insertAssets:@[createdAsset] atIndexes:[NSIndexSet indexSetWithIndex:0]];
        } error:&error1];
        
        if (error1) {
            if (error) {
                error();
            }
        }else {
            if (completion) {
                completion();
            }
        }
    }
}

- (void)getJustTakeVideoWithCompletion:(void (^)(NSArray *array))completion
{
    if (VERSION < 8.0f) {
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
    }else {
        BOOL ifImport = NO;
        
        __weak typeof(self) weakSelf = self;
        
        NSInteger index = 0;
        
        __block BOOL ifCustom = NO;
        
        // 相机胶卷
        PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        
        // 获取用户自定义相册
        PHFetchResult *userAblums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
        
        // 过滤掉空相册
        NSInteger albumsCount = 0;
        for (PHAssetCollection *collection in smartAlbums) {
            // 是否按创建时间排序
            PHFetchOptions *option = [[PHFetchOptions alloc] init];
            option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
            if (self.type == HX_SelectPhoto) {
                option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
            }else if (self.type == HX_SelectVideo) {
                option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeVideo];
            }
            // 获取所有图片对象
            PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:collection options:option];
            if (result.count > 0) {
                albumsCount++;
            }
        }
        
        for (PHAssetCollection *collection in userAblums) {
            // 是否按创建时间排序
            PHFetchOptions *option = [[PHFetchOptions alloc] init];
            option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
            if (self.type == HX_SelectPhoto) {
                option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
            }else if (self.type == HX_SelectVideo) {
                option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeVideo];
            }
            // 获取所有图片对象
            PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:collection options:option];
            if (result.count > 0) {
                albumsCount++;
            }
            // 判断用户有没有<最新导入>这个相册  有的话那么新创建的自定义相册就会在这个相册前面需要插入
            if ([collection.localizedTitle isEqualToString:@"最新导入"] && result.count > 0) {
                ifImport = YES;
            }
        }
        
        // 获取自定义相册的下标
        if (ifImport) {
            index = albumsCount - 2;
        }else {
            index = albumsCount - 1;
        }
        for (HX_AlbumModel *model in self.allAlbumAy) {
            if ([model.albumName isEqualToString:self.customName]) {
                ifCustom = YES;
            }
        }
        
        __block NSArray *photos;
        // 遍历
        [userAblums enumerateObjectsUsingBlock:^(PHAssetCollection *collection, NSUInteger idx, BOOL * _Nonnull stop) {
            // 用strong修饰 防止在block里释放
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            // 是否按创建时间排序
            PHFetchOptions *option = [[PHFetchOptions alloc] init];
            option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
            if (weakSelf.type == HX_SelectPhoto) {
                option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
            }else if (weakSelf.type == HX_SelectVideo) {
                option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeVideo];
            }
            
            // 获取所有图片对象
            PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:collection options:option];
            
            NSArray *assets;
            if (result.count > 0 && [collection.localizedTitle isEqualToString:self.customName]) {
                // 某个相册里面的所有PHAsset对象
                assets = [strongSelf getAllPhotosAssetInAblumCollection:collection ascending:YES index:index];
                photos = assets.copy;
                HX_PhotoModel *TPModel = assets.lastObject;
                weakSelf.TPTableIndex = TPModel.tableViewIndex;
                weakSelf.TPCollectionIndex = TPModel.collectionViewIndex;
                // 判断是不是第一次请求资源
                if (!ifOne) {
                    
                    if (!ifCustom) {
                        // 相册封面信息
                        HX_AlbumModel *model = [[HX_AlbumModel alloc] init];
                        // 相册名称
                        model.albumName = [weakSelf transFormPhotoTitle:collection.localizedTitle];
                        // 照片数量
                        model.photosNum = assets.count;
                        // 封面图片PHAsset对象
                        HX_PhotoModel *photoModel = assets.lastObject;
                        model.PH_Asset = photoModel.PH_Asset;
                        // 封面图片PHAssetCollection对象
                        model.PH_AssetCollection = collection;
                        
                        [weakSelf.allAlbumAy insertObject:model atIndex:index];
                        NSMutableArray *array = [NSMutableArray array];
                        [weakSelf.allGroup insertObject:array atIndex:index];
                    }
                    
                    // 需要给4个相册添加图片   - 最近添加 - 相机胶卷 - 自定义相册 - 视频
                    for (int i = 0; i < weakSelf.allAlbumAy.count; i++) {
                        HX_AlbumModel *model = weakSelf.allAlbumAy[i];
                        // 更换相册封面
                        if ([model.albumName isEqualToString:@"最近添加"] || [model.albumName isEqualToString:@"相机胶卷"] || [model.albumName isEqualToString:self.customName] || [model.albumName isEqualToString:@"视频"] || [model.albumName isEqualToString:@"所有照片"]) {
                            // 添加图片PHAsset对象
                            model.photosNum++;
                            NSArray *modelList = assets.copy;
                            HX_PhotoModel *PHModel = modelList.lastObject;
                            [strongSelf accessToImageAccordingToTheAsset:PHModel.PH_Asset size:CGSizeMake(60 * 2.0f, 60 *2.0f) resizeMode:PHImageRequestOptionsResizeModeFast completion:^(UIImage *image, NSDictionary *info) {
                                model.coverImage = image;
                            }];
                            PHModel.tableViewIndex = i;
                            [weakSelf.allGroup[i] addObject:PHModel];
                        }
                    }
                }
            }
        }];
        _ifTakingPictures = YES;
        if (completion) {
            completion(photos);
        }
    }
}
@end
