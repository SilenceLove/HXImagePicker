//
//  HX_AddPhotoView.m
//  测试
//
//  Created by 洪欣 on 16/8/18.
//  Copyright © 2016年 洪欣. All rights reserved.
//

#import "HX_AddPhotoView.h"
#import "HX_AlbumViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "HX_AssetManager.h"
#import "HX_AddPhotoViewCell.h"
#import "HX_AssetContainerVC.h"
#import "MBProgressHUD.h"
#import "HX_VideoContainerVC.h"
#import "HX_AssetContainerVC.h"
#import "HX_VideoManager.h"
#import "DragCellCollectionView.h"
#import <MobileCoreServices/MobileCoreServices.h>

#define iOS8Later ([UIDevice currentDevice].systemVersion.floatValue >= 8.0f)
@interface HX_AddPhotoView ()<DragCellCollectionViewDataSource,DragCellCollectionViewDelegate,UIActionSheetDelegate,UIAlertViewDelegate>

@property (weak, nonatomic) DragCellCollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *photosAy;
@property (assign, nonatomic) NSInteger maxNum;
@property (strong, nonatomic) UICollectionViewFlowLayout *flowLayout;
@property (assign, nonatomic) SelectType type;
@property (assign, nonatomic) BOOL ifVideo;
@property (strong, nonatomic) UIImagePickerController* imagePickerController;
@end

static NSString *addPhotoCellId = @"cellId";
@implementation HX_AddPhotoView

- (UICollectionViewFlowLayout *)flowLayout
{
    if (!_flowLayout) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
    }
    return _flowLayout;
}

- (instancetype)initWithMaxPhotoNum:(NSInteger)num WithSelectType:(SelectType)type
{
    if (self = [super init]) {
        self.maxNum = num;
        self.type = type;
        HX_AssetManager *manager = [HX_AssetManager sharedManager];
        if (type == SelectPhoto) {
            manager.type = HX_SelectPhoto;
        }else if (type == SelectVideo) {
            self.maxNum = 1;
            
            self.ifVideo = YES;
        }else if (type == SelectPhotoAndVideo) {
            manager.type = HX_SelectPhotoAndVieo;
        }
        [self setup];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sureSelectPhotos:) name:@"HX_SureSelectPhotosNotice" object:nil];
    }
    return self;
}

- (NSMutableArray *)photosAy
{
    if (!_photosAy) {
        _photosAy = [NSMutableArray array];
    }
    return _photosAy;
}

- (void)setup
{
    if (self.lineNum == 0) {
        self.lineNum = 4;
    }
    
    HX_PhotoModel *model = [[HX_PhotoModel alloc] init];
    model.image = [UIImage imageNamed:@"tianjiatupian@2x.png"];
    model.ifSelect = NO;
    model.ifAdd = NO;
    model.type = HX_Unknown;
    [self.photosAy addObject:model];
    HX_PhotoModel *model2 = [[HX_PhotoModel alloc] init];
    model2.type = HX_Unknown;
    model2.ifAdd = NO;
    model2.ifSelect = NO;
    [self.photosAy addObject:model2];
    
    self.flowLayout.minimumLineSpacing = 5;
    self.flowLayout.minimumInteritemSpacing = 5;
    DragCellCollectionView *collectionView = [[DragCellCollectionView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) collectionViewLayout:self.flowLayout];
    collectionView.backgroundColor = self.backgroundColor;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.maxNum = self.maxNum;
    collectionView.ifVideo = self.ifVideo;
    [self addSubview:collectionView];
    _collectionView = collectionView;
    
    [collectionView registerClass:[HX_AddPhotoViewCell class] forCellWithReuseIdentifier:addPhotoCellId];
}

- (void)sureSelectPhotos:(NSNotification *)info
{
    [self.photosAy removeAllObjects];
    
    HX_AssetManager *assetManager = [HX_AssetManager sharedManager];
    HX_VideoManager *videoManager = [HX_VideoManager sharedManager];
    
    if (!self.ifVideo) {
        self.photosAy = [NSMutableArray arrayWithArray:assetManager.selectedPhotos.mutableCopy];
        self.selectNum = assetManager.selectedPhotos.count;
        
        NSMutableArray *array = [NSMutableArray array];
        [self.photosAy enumerateObjectsUsingBlock:^(HX_PhotoModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
            
            [array addObject:model.asset];
        }];
        if (self.selectPhotos) {
            self.selectPhotos(array.mutableCopy,[HX_AssetManager sharedManager].ifOriginal);
        }
    }else {
        self.photosAy = [NSMutableArray arrayWithArray:videoManager.selectedPhotos.mutableCopy];
        self.selectNum = videoManager.selectedPhotos.count;
        
        NSMutableArray *array = [NSMutableArray array];
        [self.photosAy enumerateObjectsUsingBlock:^(HX_PhotoModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
            
            [array addObject:model.asset];
        }];
        if (self.selectVideo) {
            self.selectVideo(array.mutableCopy);
        }
    }
    
    NSInteger count = self.photosAy.count;
    HX_PhotoModel *model = self.photosAy.firstObject;
    
    if (model.type == HX_Video) {
        ////
    }else {
        if (self.photosAy.count != self.maxNum) {
            HX_PhotoModel *model = [[HX_PhotoModel alloc] init];
            model.image = [UIImage imageNamed:@"tianjiatupian@2x.png"];
            model.ifSelect = NO;
            model.type = HX_Unknown;
            [self.photosAy addObject:model];
        }
        
        if (count == 0) {
            HX_PhotoModel *model2 = [[HX_PhotoModel alloc] init];
            model.type = HX_Unknown;
            [self.photosAy addObject:model2];
        }

    }
    [self setupNewFrame];
    [self.collectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.photosAy.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    HX_AddPhotoViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:addPhotoCellId forIndexPath:indexPath];

    cell.model = self.photosAy[indexPath.item];
    cell.type = self.type;
    
    __weak typeof(self) weakSelf = self;
    [cell setDeleteBlock:^(UICollectionViewCell *cell) {
        HX_AssetManager *manager = [HX_AssetManager sharedManager];
        HX_VideoManager *videoManager = [HX_VideoManager sharedManager];
        NSIndexPath *indexP = [weakSelf.collectionView indexPathForCell:cell];
        [weakSelf.photosAy removeObjectAtIndex:indexP.item];
        
        if (!weakSelf.ifVideo) {
            HX_PhotoModel *model = manager.selectedPhotos[indexP.item];
            model.ifAdd = NO;
            model.ifSelect = NO;
            [manager.selectedPhotos removeObjectAtIndex:indexP.item];
            weakSelf.selectNum = manager.selectedPhotos.count;
            
            if (manager.selectedPhotos.count == 0) {
                manager.ifOriginal = NO;
            }
            
            for (int i = 0 ; i < manager.selectedPhotos.count ; i++) {
                HX_PhotoModel *PH = manager.selectedPhotos[i];
                PH.index = i;
            }
            
            NSMutableArray *array = [NSMutableArray array];
            [manager.selectedPhotos enumerateObjectsUsingBlock:^(HX_PhotoModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
                [array addObject:model.asset];
            }];
            if (weakSelf.selectPhotos) {
                weakSelf.selectPhotos(array.mutableCopy,[HX_AssetManager sharedManager].ifOriginal);
            }
            
        }else {
            [videoManager.selectedPhotos removeObjectAtIndex:indexP.item];
            weakSelf.selectNum = videoManager.selectedPhotos.count;
            
            NSMutableArray *array = [NSMutableArray array];
            [videoManager.selectedPhotos enumerateObjectsUsingBlock:^(HX_PhotoModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
                [array addObject:model.asset];
            }];
            if (weakSelf.selectVideo) {
                weakSelf.selectVideo(array.mutableCopy);
            }
        }
        
        [weakSelf.collectionView deleteItemsAtIndexPaths:@[indexP]];
        
        if (!weakSelf.ifVideo) {
            NSInteger count = manager.selectedPhotos.count;
            BOOL ifAdd = NO;
            for (int i = 0; i < weakSelf.photosAy.count; i ++) {
                HX_PhotoModel *modeli = weakSelf.photosAy[i];
                if (!modeli.ifSelect) {
                    ifAdd = YES;
                }
            }
            
            if (weakSelf.photosAy.count != weakSelf.maxNum && !ifAdd) {
                HX_PhotoModel *model1 = [[HX_PhotoModel alloc] init];
                model1.image = [UIImage imageNamed:@"tianjiatupian@2x.png"];
                model1.ifSelect = NO;
                model1.ifAdd = NO;
                model1.type = HX_Unknown;
                [weakSelf.photosAy addObject:model1];
            }
            
            if (count == 0) {
                HX_PhotoModel *model2 = [[HX_PhotoModel alloc] init];
                model2.ifSelect = NO;
                model2.ifAdd = NO;
                model2.type = HX_Unknown;
                [weakSelf.photosAy addObject:model2];
            }
            [weakSelf setupNewFrame];
            [weakSelf.collectionView reloadData];
        }else {
            NSInteger count = videoManager.selectedPhotos.count;
            
            if (weakSelf.photosAy.count != weakSelf.maxNum) {
                HX_PhotoModel *model1 = [[HX_PhotoModel alloc] init];
                model1.image = [UIImage imageNamed:@"tianjiatupian@2x.png"];
                model1.ifSelect = NO;
                model1.ifAdd = NO;
                model1.type = HX_Unknown;
                [weakSelf.photosAy addObject:model1];
            }
            
            if (count == 0) {
                HX_PhotoModel *model2 = [[HX_PhotoModel alloc] init];
                model2.ifSelect = NO;
                model2.ifAdd = NO;
                model2.type = HX_Unknown;
                [weakSelf.photosAy addObject:model2];
            }
            [weakSelf setupNewFrame];
            [weakSelf.collectionView reloadData];
        }
    }];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    HX_PhotoModel *model = self.photosAy[indexPath.row];
    if (!self.ifVideo) {
        if (model.type == HX_Video) {
            HX_VideoContainerVC *vc = [[HX_VideoContainerVC alloc] init];
            vc.model = model;
            vc.ifPush = NO;
            [[self viewController:self] presentViewController:vc animated:YES completion:nil];
            return;
        }
        
        if (model.type == HX_Photo) {
            HX_AssetContainerVC *vc = [[HX_AssetContainerVC alloc] init];
            vc.ifLookPic = YES;
            vc.photoAy = [HX_AssetManager sharedManager].selectedPhotos;
            vc.currentIndex = indexPath.item;
            vc.modalPresentationStyle = UIModalTransitionStyleCrossDissolve;
            vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [[self viewController:self] presentViewController:vc animated:YES completion:nil];
            return;
        }
        
        NSInteger count = [HX_AssetManager sharedManager].selectedPhotos.count;
        if (self.photosAy.count == 2 && indexPath.item == 0 && count == 0) {
            [self goAddPhotoVC];
            return;
        }
        
        if (self.photosAy.count <= self.maxNum && indexPath.item == self.photosAy.count - 1) {
            if (count == self.maxNum) return;
            [self goAddPhotoVC];
        }
        
    }else {
        if (model.type == HX_Video) {
            HX_VideoContainerVC *vc = [[HX_VideoContainerVC alloc] init];
            vc.model = model;
            vc.ifPush = NO;
            [[self viewController:self] presentViewController:vc animated:YES completion:nil];
            return;
        }
        NSInteger count = [HX_VideoManager sharedManager].selectedPhotos.count;
        if (self.photosAy.count == 2 && indexPath.item == 0 && count == 0) {
            [self goAddPhotoVC];
            return;
        }
    }
}

- (NSArray *)dataSourceArrayOfCollectionView:(DragCellCollectionView *)collectionView
{
    return self.photosAy;
}

- (void)dragCellCollectionView:(DragCellCollectionView *)collectionView newDataArrayAfterMove:(NSArray *)newDataArray
{
    HX_AssetManager *manager = [HX_AssetManager sharedManager];
    if (manager.selectedPhotos.count != 0 && manager.selectedPhotos.count < self.maxNum) {
        for (int i = 0; i < manager.selectedPhotos.count; i++) {
            HX_PhotoModel *model = newDataArray[i];
            
            [manager.selectedPhotos replaceObjectAtIndex:i withObject:model];
        }
    }else if (manager.selectedPhotos.count != 0 && manager.selectedPhotos.count == self.maxNum) {
        for (int i = 0; i < newDataArray.count; i++) {
            HX_PhotoModel *model = newDataArray[i];
            
            [manager.selectedPhotos replaceObjectAtIndex:i withObject:model];
        }
    }
    
    for (int i = 0 ; i < manager.selectedPhotos.count; i++) {
        HX_PhotoModel *model = manager.selectedPhotos[i];
        model.index = i;
    }
    
    self.photosAy = [NSMutableArray arrayWithArray:newDataArray];
}

- (void)dragCellCollectionViewCellEndMoving:(DragCellCollectionView *)collectionView
{
    NSMutableArray *array = [NSMutableArray array];
    [[HX_AssetManager sharedManager].selectedPhotos enumerateObjectsUsingBlock:^(HX_PhotoModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [array addObject:model.asset];
    }];
    if (self.selectPhotos) {
        self.selectPhotos(array.mutableCopy,[HX_AssetManager sharedManager].ifOriginal);
    }
}

- (void)goAddPhotoVC
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:(id)self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"相机",@"从相册中选取", nil];
    
    [actionSheet showInView:self];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        // 判断是否支持相机
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if ((authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) && iOS8Later) {
            // 无权限
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"无法使用相机" message:@"请在iPhone的""设置-隐私-相机""中允许访问相机" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"设置", nil];
            [alert show];
        } else {
            if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                // 跳转到相机或相册页面
                self.imagePickerController = [[UIImagePickerController alloc] init];
                self.imagePickerController.delegate = (id)self;
                self.imagePickerController.allowsEditing = NO;
                NSString *requiredMediaType = ( NSString *)kUTTypeImage;
                NSString *requiredMediaType1 = ( NSString *)kUTTypeMovie;
                NSArray *arrMediaTypes;
                if (self.type == SelectPhoto) {
                    arrMediaTypes=[NSArray arrayWithObjects:requiredMediaType,nil];
                }else if (self.type == SelectPhotoAndVideo) {
                    HX_AssetManager *manager = [HX_AssetManager sharedManager];
                    if (manager.selectedPhotos.count > 0) {
                        HX_PhotoModel *model = manager.selectedPhotos.firstObject;
                        if (model.type == HX_Photo) {
                            arrMediaTypes=[NSArray arrayWithObjects:requiredMediaType,nil];
                        }else {
                            arrMediaTypes=[NSArray arrayWithObjects:requiredMediaType, requiredMediaType1,nil];
                        }
                    }else {
                        arrMediaTypes=[NSArray arrayWithObjects:requiredMediaType, requiredMediaType1,nil];
                    }
                    
                }else if (self.type == SelectVideo) {
                    arrMediaTypes=[NSArray arrayWithObjects:requiredMediaType1,nil];
                }
                
                [self.imagePickerController setMediaTypes:arrMediaTypes];
                // 设置录制视频的质量
                [self.imagePickerController setVideoQuality:UIImagePickerControllerQualityTypeHigh];
                //设置最长摄像时间
                if (self.videoMaximumDuration == 0) {
                    self.videoMaximumDuration = 60.f;
                }
                [self.imagePickerController setVideoMaximumDuration:self.videoMaximumDuration];

                self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                self.imagePickerController.navigationController.navigationBar.tintColor = [UIColor whiteColor];
                
                if([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0) {
                    
                    self.imagePickerController.modalPresentationStyle=UIModalPresentationOverCurrentContext;
                    
                }
                
                [[self viewController:self] presentViewController:self.imagePickerController animated:YES completion:NULL];
            }else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"警告" message:@"模拟器不支持相机功能,请使用真机调试" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
                return;
            }
        }
    }else if (buttonIndex == 1) {
        NSString *tipTextWhenNoPhotosAuthorization; // 提示语
        // 获取当前应用对照片的访问授权状态
        ALAuthorizationStatus authorizationStatus = [ALAssetsLibrary authorizationStatus];
        // 如果没有获取访问授权，或者访问授权状态已经被明确禁止，则显示提示语，引导用户开启授权
        if (authorizationStatus == ALAuthorizationStatusRestricted || authorizationStatus == ALAuthorizationStatusDenied) {

            tipTextWhenNoPhotosAuthorization = @"请在设备的\"设置-隐私-照片\"选项中，允许访问你的手机相册";
            // 展示提示语

            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
            UIView *view = [[UIView alloc] init];

            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"qrcode_ar_failed@2x.png"]];
            [view addSubview:imageView];

            view.frame = CGRectMake(0, 0, imageView.image.size.width, imageView.image.size.height + 10);

            hud.customView = view;
            hud.mode = MBProgressHUDModeCustomView;
            hud.labelText = tipTextWhenNoPhotosAuthorization;
            hud.labelFont = [UIFont systemFontOfSize:12];
            hud.margin = 10.f;

            [hud hide:YES afterDelay:3.0f];
        }
        //    NSLog(@"%f",VERSION);

        HX_AlbumViewController *photo = [[HX_AlbumViewController alloc] init];
        photo.maxNum = self.maxNum;
        photo.ifVideo = self.ifVideo;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:photo];
        [[self viewController:self] presentViewController:nav animated:YES completion:nil];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) { // 去设置界面，开启相机访问权限
        if (iOS8Later) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        } else {

        }
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{}];
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    
    hud.labelText = @"正在保存";
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        __weak typeof(self) weakSelf = self;
        [[HX_AssetManager sharedManager] savePhotoWithImage:image completion:^{
            [[HX_AssetManager sharedManager] getJustTakePhotosWithCompletion:^(NSArray *array) {
                HX_PhotoModel *model = array.lastObject;
                model.ifSelect = YES;
                model.ifAdd = YES;
                model.type = HX_Photo;
                model.image = image;
                [[HX_AssetManager sharedManager].selectedPhotos addObject:model];
                
                [weakSelf sureSelectPhotos:nil];
                
                UIImage *image = [UIImage imageNamed:@"37x-Checkmark.png"];
                UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
                hud.customView = imageView;
                hud.labelText = @"保存成功";
                hud.mode = MBProgressHUDModeCustomView;
                [hud hide:YES afterDelay:1.f];
            }];
        } WithError:^{
            hud.labelFont = [UIFont systemFontOfSize:15];
            hud.labelText = @"保存失败";
            [hud hide:YES afterDelay:3.f];
        }];
        
    }else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie] ) {
        
        NSURL *url = info[UIImagePickerControllerMediaURL];
        __weak typeof(self) weakSelf = self;
        
        if (self.ifVideo) {
            [[HX_VideoManager sharedManager] savePhotoWithVideo:url completion:^{
                [[HX_VideoManager sharedManager] getJustTakeVideoWithCompletion:^(NSArray *array) {
                    HX_PhotoModel *model = array.lastObject;
                    model.ifAdd = YES;
                    model.ifSelect = YES;
                    model.type = HX_Video;
                    model.image = [UIImage imageWithCGImage:[model.asset aspectRatioThumbnail]];
                    if (weakSelf.type == SelectPhotoAndVideo) {
                        [[HX_AssetManager sharedManager].selectedPhotos addObject:model];
                    }else if (weakSelf.type == SelectVideo) {
                        [[HX_VideoManager sharedManager].selectedPhotos addObject:model];
                    }
                    
                    [weakSelf sureSelectPhotos:nil];
                    UIImage *image = [UIImage imageNamed:@"37x-Checkmark.png"];
                    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
                    hud.customView = imageView;
                    hud.labelText = @"保存成功";
                    hud.mode = MBProgressHUDModeCustomView;
                    [hud hide:YES afterDelay:1.f];
                }];
            } WithError:^{
                hud.labelFont = [UIFont systemFontOfSize:15];
                hud.labelText = @"保存失败";
                [hud hide:YES afterDelay:3.f];
            }];

        }else {
            [[HX_AssetManager sharedManager] savePhotoWithVideo:url completion:^{
                [[HX_AssetManager sharedManager] getJustTakeVideoWithCompletion:^(NSArray *array) {
                    HX_PhotoModel *model = array.lastObject;
                    model.ifAdd = YES;
                    model.ifSelect = YES;
                    model.type = HX_Video;
                    model.image = [UIImage imageWithCGImage:[model.asset aspectRatioThumbnail]];
                    if (weakSelf.type == SelectPhotoAndVideo) {
                        [[HX_AssetManager sharedManager].selectedPhotos addObject:model];
                    }else if (weakSelf.type == SelectVideo) {
                        [[HX_VideoManager sharedManager].selectedPhotos addObject:model];
                    }
                    
                    [weakSelf sureSelectPhotos:nil];
                    UIImage *image = [UIImage imageNamed:@"37x-Checkmark.png"];
                    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
                    hud.customView = imageView;
                    hud.labelText = @"保存成功";
                    hud.mode = MBProgressHUDModeCustomView;
                    [hud hide:YES afterDelay:1.f];
                }];
            } WithError:^{
                hud.labelFont = [UIFont systemFontOfSize:15];
                hud.labelText = @"保存失败";
                [hud hide:YES afterDelay:3.f];
            }];

        }
    }
}

- (UIViewController*)viewController:(UIView *)view {
    for (UIView* next = [view superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UINavigationController class]] || [nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}

- (void)setupNewFrame
{
    CGFloat width = self.frame.size.width;
    CGFloat x = self.frame.origin.x;
    CGFloat y = self.frame.origin.y;
    
    CGFloat left = _margin_Left;
    CGFloat top = _margin_Top;
    
    CGFloat lineSpacing = _lineSpacing <= 5 ? 5 : _lineSpacing;
    
    CGFloat itemW = ((width - left * 2) - lineSpacing * (self.lineNum - 1)) / self.lineNum;
    
    self.flowLayout.itemSize = CGSizeMake(itemW, itemW);
    
    static NSInteger numofLinesOld = 1;
    
    NSInteger numOfLinesNew = (_photosAy.count / self.lineNum) + 1;
    
    if (_photosAy.count % _lineNum == 0) {
        numOfLinesNew -= 1;
    }

    if (numOfLinesNew == 1) {
        self.flowLayout.minimumLineSpacing = 0;
    }else {
        self.flowLayout.minimumLineSpacing = lineSpacing;
    }
    
    if (numOfLinesNew != numofLinesOld) {
        
        CGFloat newHeight = numOfLinesNew * itemW + lineSpacing * (numOfLinesNew - 1) + top * 2;
        
        self.frame = CGRectMake(x, y, width, newHeight);

        numofLinesOld = numOfLinesNew;
        if ([self.delegate respondsToSelector:@selector(updateViewFrame:WithView:)]) {
            [self.delegate updateViewFrame:self.frame WithView:self];
        }
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self setupNewFrame];
    CGFloat width = self.frame.size.width;
    CGFloat left = _margin_Left;
    CGFloat top = _margin_Top;
    
    CGFloat lineSpacing = _lineSpacing <= 5 ? 5 : _lineSpacing;
    
    if (self.photosAy.count == 2) {
        
        CGFloat itemW = ((width - left * 2) - lineSpacing * (self.lineNum - 1)) / self.lineNum;
        self.bounds = CGRectMake(0, 0, width, itemW + top * 2);
    }
    NSInteger numOfLinesNew = (_photosAy.count / _lineNum) + 1;
    if (_photosAy.count % _lineNum == 0) {
        numOfLinesNew -= 1;
    }
    
    _collectionView.frame = CGRectMake(left, top, width - left * 2, self.frame.size.height - top * 2);
}

- (void)dealloc
{
    HX_AssetManager *manager = [HX_AssetManager sharedManager];
    manager.ifRefresh = YES;
    for (HX_PhotoModel *model in manager.selectedPhotos) {
        model.ifAdd = NO;
        model.ifSelect = NO;
    }
    [manager.selectedPhotos removeAllObjects];
    manager.ifOriginal = NO;
    [manager.allAlbumAy removeAllObjects];
    [manager.allGroup removeAllObjects];
    
    [HX_VideoManager sharedManager].ifRefresh = YES;
    [[HX_VideoManager sharedManager].selectedPhotos removeAllObjects];
    [[HX_VideoManager sharedManager].allAlbumAy removeAllObjects];
    [[HX_VideoManager sharedManager].allGroup removeAllObjects];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}
@end
