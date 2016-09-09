//
//  HX_PhotosViewController.m
//  测试
//
//  Created by 洪欣 on 16/8/18.
//  Copyright © 2016年 洪欣. All rights reserved.
//

#import "HX_PhotosViewController.h"
#import <Photos/Photos.h>
#import "HX_PhotoPreviewViewCell.h"
#import "HX_AssetContainerVC.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "HX_AssetManager.h"
#import "HX_VideoContainerVC.h"
#import "MBProgressHUD.h"
#import "HX_PhotosFooterView.h"
@interface HX_PhotosViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>
@property (weak, nonatomic) UICollectionView *collectionView;
@property (weak, nonatomic) UIButton *previewBtn;
@property (weak, nonatomic) UIButton *originalBtn;
@property (weak, nonatomic) UIButton *confirmBtn;
@end


static NSString *cellId = @"photoPreviewCell";
static NSString *cellFooterId = @"photoCellFooterId";
@implementation HX_PhotosViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(closeAsset)];
    
    [self setup];
    
    // 改变选中状态的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeSelectPhotoAy:) name:@"HX_SelectPhotosNotica" object:nil];
}

#pragma mark - < 取消按钮 删除改变过的选择 >
- (void)closeAsset
{
    HX_AssetManager *manager = [HX_AssetManager sharedManager];
    
    if (!_ifVideo) {
        manager.ifOriginal = manager.recordOriginal;
        
        for (int i = 0 ; i < manager.selectedPhotos.count; i++) {
            HX_PhotoModel *model = manager.selectedPhotos[i];
            model.ifAdd = NO;
            model.ifSelect = NO;
        }
        [manager.selectedPhotos removeAllObjects];
        
        for (int i = 0 ; i < manager.recordPhotos.count; i++) {
            HX_PhotoModel *model = manager.recordPhotos[i];
            model.ifAdd = YES;
            model.ifSelect = YES;
            [manager.selectedPhotos addObject:model];
        }
        
        [manager.recordPhotos removeAllObjects];
        
        for (int i = 0 ; i < manager.selectedPhotos.count; i++) {
            HX_PhotoModel *model = manager.selectedPhotos[i];
            
            model.index = i;
        }
        
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setup
{
    CGFloat width = self.view.frame.size.width;
    CGFloat heght = self.view.frame.size.height;
    
    NSInteger count = [HX_AssetManager sharedManager].selectedPhotos.count;
    
    CGFloat CVwidth = (width - 15 ) / 4;
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(CVwidth, CVwidth);
    flowLayout.minimumInteritemSpacing = 5;
    flowLayout.minimumLineSpacing = 5;
    flowLayout.footerReferenceSize = CGSizeMake(width, 40);
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 5, width, heght - 50) collectionViewLayout:flowLayout];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.alwaysBounceVertical = YES;
    collectionView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:collectionView];
    _collectionView = collectionView;
    
    [collectionView registerClass:[HX_PhotoPreviewViewCell class] forCellWithReuseIdentifier:cellId];
    [collectionView registerClass:[HX_PhotosFooterView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:cellFooterId];
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, heght - 45, width, 45)];
    
    [self.view addSubview:bottomView];
    
    UIButton *previewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [previewBtn setTitle:@"预览" forState:UIControlStateNormal];
    [previewBtn setTitleColor:[UIColor colorWithRed:18/255.0 green:183/255.0 blue:245/255.0 alpha:1] forState:UIControlStateNormal];
    [previewBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [previewBtn addTarget:self action:@selector(didPreviewClick:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:previewBtn];
    previewBtn.frame = CGRectMake(5, 0, 60, 45);
    _previewBtn = previewBtn;
    
    UIButton *originalBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [originalBtn setTitle:@"原图" forState:UIControlStateNormal];
    originalBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [originalBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [originalBtn setTitleColor:[UIColor colorWithRed:18/255.0 green:183/255.0 blue:245/255.0 alpha:1] forState:UIControlStateNormal];
    [originalBtn setImage:[UIImage imageNamed:@"activate_friends_not_seleted@2x.png"] forState:UIControlStateNormal];
    [originalBtn setImage:[UIImage imageNamed:@"activate_friends_seleted@2x.png"] forState:UIControlStateSelected];
    originalBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 7, 0, 0);
    [originalBtn addTarget:self action:@selector(didOriginalClick:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:originalBtn];
    originalBtn.frame = CGRectMake(65, 0, 200, 45);
    _originalBtn = originalBtn;
    
    UIButton *confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
    [confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [confirmBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    
    [confirmBtn addTarget:self action:@selector(sureClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [confirmBtn setBackgroundImage:[UIImage imageNamed:@"login_bg@2x.png"] forState:UIControlStateDisabled];
    [confirmBtn setBackgroundImage:[UIImage imageNamed:@"login_btn_blue_nor@2x.png"] forState:UIControlStateNormal];
    confirmBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    
    confirmBtn.layer.masksToBounds = YES;
    confirmBtn.layer.cornerRadius = 3;
    
    [bottomView addSubview:confirmBtn];
    confirmBtn.frame = CGRectMake(width - 70, 0, 60, 30);
    confirmBtn.center = CGPointMake(confirmBtn.center.x, 22.5);
    _confirmBtn = confirmBtn;
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 0.5)];
    line.backgroundColor = [UIColor lightGrayColor];
    [bottomView addSubview:line];
    
    if ([HX_AssetManager sharedManager].type == HX_SelectVideo) {
        bottomView.hidden = YES;
        collectionView.frame = CGRectMake(0, 5, width, heght - 10);
    }
    
    NSInteger row = _allPhotosArray.count / 4 + 1;

    CGFloat maxY = (row - 1) * 5 + row * CVwidth + 40;
    
    [collectionView setContentOffset:CGPointMake(0, maxY) animated:NO];
    
    if (!self.ifVideo) {
        for (int i = 0; i < [HX_AssetManager sharedManager].selectedPhotos.count; i ++) {
            HX_PhotoModel *modelPH = [HX_AssetManager sharedManager].selectedPhotos[i];
            
            if (modelPH.tableViewIndex == _cellIndex) {
                [collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:modelPH.collectionViewIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
                break;
            }
        }
    }else {
        bottomView.hidden = YES;
        collectionView.frame = CGRectMake(0, 5, width, heght - 10);
    }
    
    BOOL bl = count == 0 ? NO : YES;

    _previewBtn.enabled = bl;
    _originalBtn.enabled = bl;
    _confirmBtn.enabled = bl;
    if (count > 0) {
        [_confirmBtn setTitle:[NSString stringWithFormat:@"确定(%ld)",count] forState:UIControlStateNormal];
        _originalBtn.selected = [HX_AssetManager sharedManager].ifOriginal;
        if ([HX_AssetManager sharedManager].ifOriginal) {
            [_originalBtn setTitle:[NSString stringWithFormat:@"原图（%@）",[HX_AssetManager sharedManager].totalBytes] forState:UIControlStateNormal];
        }
    }else {
        [_confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
        [_originalBtn setTitle:@"原图" forState:UIControlStateNormal];
        _originalBtn.enabled = NO;
        _originalBtn.selected = NO;
    }
    
    for (int i = 0 ; i < [HX_AssetManager sharedManager].selectedPhotos.count; i++) {
        HX_PhotoModel *model = [HX_AssetManager sharedManager].selectedPhotos[i];
        model.index = i;
    }
}

#pragma mark - < 改变选中状态的通知 >
- (void)changeSelectPhotoAy:(NSNotification *)info
{
    HX_AssetManager *manager = [HX_AssetManager sharedManager];
//    NSInteger tableIndex = [info.userInfo[@"tableViewIndex"] integerValue];
//    HX_PhotoModel *model = [self.allPhotosArray firstObject];
    
    NSInteger index = [info.userInfo[@"index"] integerValue];
    
    BOOL ifSelect = [info.userInfo[@"ifSelect"] boolValue];
    
    if (!ifSelect) {
        if (index < manager.selectedPhotos.count) {
            [self.collectionView reloadData];
        }
    }
    
    // 获取选择的图片数组
    NSArray *ay = manager.selectedPhotos;
    NSInteger count = ay.count;
    
    // 判断数组里面有没有内容
    BOOL bl = count == 0 ? NO : YES;

    _previewBtn.enabled = bl;
    _originalBtn.enabled = bl;
    _confirmBtn.enabled = bl;
    
    if (count > 0) {
        // 如果有内容就需要给底部的按钮重新赋值
        [_confirmBtn setTitle:[NSString stringWithFormat:@"确定(%ld)",count] forState:UIControlStateNormal];
        
        
        _originalBtn.selected = manager.ifOriginal;
        
        // 判断是否点击了原图按钮
        if (manager.ifOriginal) {
            [_originalBtn setTitle:[NSString stringWithFormat:@"原图（%@）",[HX_AssetManager sharedManager].totalBytes] forState:UIControlStateNormal];
        }
    }else {
        // 没有内容就初始化
        [_confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
        [_originalBtn setTitle:@"原图" forState:UIControlStateNormal];
        _originalBtn.enabled = NO;
        _originalBtn.selected = NO;
    }
}

#pragma mark - < 确定 >
- (void)sureClick:(UIButton *)button
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HX_SureSelectPhotosNotice" object:nil];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

#pragma mark - < 是否原图 >
- (void)didOriginalClick:(UIButton *)button
{
    button.selected = !button.selected;
    [HX_AssetManager sharedManager].ifOriginal = button.selected;
    if (button.selected) {
        [_originalBtn setTitle:[NSString stringWithFormat:@"原图（%@）",[HX_AssetManager sharedManager].totalBytes] forState:UIControlStateNormal];
    }else {
        [_originalBtn setTitle:@"原图" forState:UIControlStateNormal];
    }
}
#pragma mark - < 预览 >
- (void)didPreviewClick:(UIButton *)button
{
    HX_AssetContainerVC *vc = [[HX_AssetContainerVC alloc] init];
    vc.ifPreview = YES;
    vc.photoAy = [HX_AssetManager sharedManager].selectedPhotos;
    vc.maxNum = self.maxNum;
    [self.navigationController pushViewController:vc animated:YES];
    
    __weak typeof(self) weakSelf = self;
    [vc setDidOriginalBlock:^() {
        [weakSelf didOriginalClick:weakSelf.originalBtn];
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.allPhotosArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    HX_PhotoPreviewViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    
    cell.model = self.allPhotosArray[indexPath.item];
    cell.maxNum = self.maxNum;
    cell.index = indexPath.item;
    
    __weak typeof(self) weakSelf = self;
    [cell setDidPHBlock:^(UICollectionViewCell *cell) {
        NSIndexPath *indexPt = [weakSelf.collectionView indexPathForCell:cell];
        
        HX_PhotoModel *model = weakSelf.allPhotosArray[indexPt.row];

        if (model.type == HX_Video) {
            if (!weakSelf.ifVideo) {
                if ([HX_AssetManager sharedManager].selectedPhotos.count > 0) {
                    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
                    
                    UIView *view = [[UIView alloc] init];
                    
                    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"qrcode_ar_failed@2x.png"]];
                    [view addSubview:imageView];
                    
                    view.frame = CGRectMake(0, 0, imageView.image.size.width, imageView.image.size.height + 10);
                    
                    hud.customView = view;
                    hud.mode = MBProgressHUDModeCustomView;
                    hud.labelText = @"图片和视频不能同时选择";
                    hud.margin = 10.f;
                    hud.removeFromSuperViewOnHide = YES;
                    
                    [hud hide:YES afterDelay:1.5f];
                    
                }else {
                    HX_VideoContainerVC *vc = [[HX_VideoContainerVC alloc] init];
                    vc.model = model;
                    vc.ifPush = YES;
                    vc.ifVideo = weakSelf.ifVideo;
                    [weakSelf.navigationController pushViewController:vc animated:YES];
                }
            }else {
                HX_VideoContainerVC *vc = [[HX_VideoContainerVC alloc] init];
                vc.model = model;
                vc.ifPush = YES;
                vc.ifVideo = weakSelf.ifVideo;
                [weakSelf.navigationController pushViewController:vc animated:YES];
            }
            
        }else {
            HX_AssetContainerVC *vc = [[HX_AssetContainerVC alloc] init];
            vc.photoAy = weakSelf.allPhotosArray;
            vc.currentIndex = indexPt.item;
            vc.maxNum = weakSelf.maxNum;
            
            [vc setDidOriginalBlock:^() {
                [weakSelf didOriginalClick:weakSelf.originalBtn];
            }];
            
            [vc setDidRgihtBtnBlock:^(NSInteger index) {
                [weakSelf.collectionView reloadData];
            }];
            [weakSelf.navigationController pushViewController:vc animated:YES];
        }
    }];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        HX_PhotosFooterView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:cellFooterId forIndexPath:indexPath];
        footerView.total = self.allPhotosArray.count;
        return footerView;
    }
    return nil;
}

@end
