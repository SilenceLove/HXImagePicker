//
//  HX_AssetContainerVC.m
//  测试
//
//  Created by 洪欣 on 16/8/19.
//  Copyright © 2016年 洪欣. All rights reserved.
//

#import "HX_AssetContainerVC.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "HX_PhotoModel.h"
#import "HX_AssetContainerViewCell.h"
#import "HX_AssetManager.h"

#import "MBProgressHUD.h"
#define WIDTH  [UIScreen mainScreen].bounds.size.width
#define HEIGHT  [UIScreen mainScreen].bounds.size.height
@interface HX_AssetContainerVC ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
@property (assign, nonatomic) BOOL ifDid;
@property (weak, nonatomic) UILabel *titleLb;
@property (weak, nonatomic) UIButton *rightBtn;
@property (weak, nonatomic) UIView *bottomView;
@property (weak, nonatomic) UIButton *originalBtn;
@property (weak, nonatomic) UIButton *confirmBtn;
@property (assign, nonatomic) CGPoint sBtnCenter;
@property (weak, nonatomic) UILabel *topLb;
@property (weak, nonatomic) UICollectionView *collectionView;
@end


static NSString *containerCellId = @"cellId";
@implementation HX_AssetContainerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeSelectPhotoAy:) name:@"HX_SelectPhotosNotica" object:nil];
    
    [self setup];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

- (void)didRightBtnClick:(UIButton *)button
{
    HX_AssetManager *manager = [HX_AssetManager sharedManager];
    
    if (!button.selected) {
        if (manager.selectedPhotos.count >= _maxNum) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
            UIView *view = [[UIView alloc] init];
            
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"qrcode_ar_failed@2x.png"]];
            [view addSubview:imageView];
            
            view.frame = CGRectMake(0, 0, imageView.image.size.width, imageView.image.size.height + 10);
            
            hud.customView = view;
            hud.mode = MBProgressHUDModeCustomView;
            hud.labelText = [NSString stringWithFormat:@"最多只能选择%ld张图片",_maxNum];
            hud.margin = 10.f;
            hud.removeFromSuperViewOnHide = YES;
            
            [hud hide:YES afterDelay:1.5f];
            return;
        }
    }
    
    button.selected = !button.selected;
    HX_PhotoModel *model = self.photoAy[button.tag];
    model.ifSelect = button.selected;
    
    // 果冻弹簧效果动画
    CABasicAnimation *scaleAnimation1 = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation1.fromValue = [NSNumber numberWithFloat:1.0];
    scaleAnimation1.toValue = [NSNumber numberWithFloat:1.2];
    [scaleAnimation1 setBeginTime:0.0f];
    [scaleAnimation1 setDuration:0.1f];
    
    CABasicAnimation *scaleAnimation2 = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation2.fromValue = [NSNumber numberWithFloat:1.2];
    scaleAnimation2.toValue = [NSNumber numberWithFloat:1.05];
    [scaleAnimation2 setBeginTime:0.1f];
    [scaleAnimation2 setDuration:0.1f];
    
    CABasicAnimation *scaleAnimation3 = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation3.fromValue = [NSNumber numberWithFloat:1.05];
    scaleAnimation3.toValue = [NSNumber numberWithFloat:1.15];
    [scaleAnimation3 setBeginTime:0.2f];
    [scaleAnimation3 setDuration:0.1f];
    
    CABasicAnimation *scaleAnimation4 = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation4.fromValue = [NSNumber numberWithFloat:1.15];
    scaleAnimation4.toValue = [NSNumber numberWithFloat:1.05];
    [scaleAnimation4 setBeginTime:0.3f];
    [scaleAnimation4 setDuration:0.1f];
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    
    animationGroup.duration = 0.4f;
    
    [animationGroup setAnimations:[NSArray arrayWithObjects:scaleAnimation1,scaleAnimation2, scaleAnimation3,scaleAnimation4, nil]];
    
    [button.layer addAnimation:animationGroup forKey:nil];

    model.collectionViewIndex = button.tag;
    
    if (button.selected) {
        model.ifAdd = YES;
        
        [manager.selectedPhotos addObject:model];
        model.index = manager.selectedPhotos.count - 1;
        
        [button setTitle:[NSString stringWithFormat:@"%ld",model.index + 1] forState:UIControlStateNormal];
    }else {
 
        for (int i = 0; i < manager.selectedPhotos.count; i++) {
            HX_PhotoModel *model1 = manager.selectedPhotos[i];
            if (model1.index == model.index) {
                model.ifAdd = NO;

                [manager.selectedPhotos removeObjectAtIndex:i];
                break;
            }
        }
        for (int i = 0; i < manager.selectedPhotos.count; i++) {
            HX_PhotoModel *model1 = manager.selectedPhotos[i];
            model1.index = i;
        }

        [button setTitle:@"" forState:UIControlStateNormal];
        if (manager.selectedPhotos.count == 0) {
            manager.ifOriginal = NO;
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HX_SelectPhotosNotica" object:nil userInfo:
  @{@"tableViewIndex" : [NSString stringWithFormat:@"%ld",model.tableViewIndex] ,
    @"collectionViewIndex" : [NSString stringWithFormat:@"%ld",model.collectionViewIndex],
    @"ifSelect" : [NSString stringWithFormat:@"%d",button.selected],
    @"ifPreview" : [NSString stringWithFormat:@"%d",_ifPreview],@"index": [NSString stringWithFormat:@"%ld",model.index]}];
    
//    if (!_ifPreview) {
        if (self.didRgihtBtnBlock) {
            self.didRgihtBtnBlock(button.tag);
        }
//    }
}

- (void)changeSelectPhotoAy:(NSNotification *)info
{
    NSArray *ay = [HX_AssetManager sharedManager].selectedPhotos;
    NSInteger count = ay.count;
    
    BOOL bl = count == 0 ? NO : YES;
    
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
}

- (void)setup
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setBackgroundImage:[UIImage imageNamed:@"album_checkbox_gray@2x.png"] forState:UIControlStateNormal];
    [rightBtn setBackgroundImage:[UIImage imageNamed:@"album_checkbox_blue@2x.png"] forState:UIControlStateSelected];
    [rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    rightBtn.tag = _currentIndex;
    [rightBtn addTarget:self action:@selector(didRightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    rightBtn.frame = CGRectMake(0, 0, 25, 25);
    [view addSubview:rightBtn];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:view];
    _rightBtn = rightBtn;
    HX_PhotoModel *model = self.photoAy[_currentIndex];
    _rightBtn.selected = model.ifSelect;
    if (model.ifSelect) {
        [rightBtn setTitle:[NSString stringWithFormat:@"%ld",model.index + 1] forState:UIControlStateNormal];
    }
    _sBtnCenter = rightBtn.center;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    
    flowLayout.itemSize = CGSizeMake(WIDTH, HEIGHT);
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing = 20;
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(-10, 0, WIDTH + 20, HEIGHT) collectionViewLayout:flowLayout];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.pagingEnabled = YES;
    collectionView.contentSize = CGSizeMake(self.photoAy.count * (WIDTH + 20), 0);
    [self.view addSubview:collectionView];
    _collectionView = collectionView;
    
    [collectionView registerClass:[HX_AssetContainerViewCell class] forCellWithReuseIdentifier:containerCellId];
    
    UILabel *titleLb = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
    titleLb.text = [NSString stringWithFormat:@"%ld/%ld",_currentIndex + 1,_photoAy.count];
    titleLb.textColor = [UIColor whiteColor];
    titleLb.textAlignment = NSTextAlignmentCenter;
    titleLb.font = [UIFont systemFontOfSize:17];
    self.navigationItem.titleView = titleLb;
    _titleLb = titleLb;
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, HEIGHT - 45, WIDTH, 45)];
    bottomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottomView];
    _bottomView = bottomView;
    
    UIButton *originalBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [originalBtn setTitle:@"原图" forState:UIControlStateNormal];
    originalBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [originalBtn setTitleColor:[UIColor colorWithRed:18/255.0 green:183/255.0 blue:245/255.0 alpha:1] forState:UIControlStateNormal];
    [originalBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [originalBtn setImage:[UIImage imageNamed:@"activate_friends_not_seleted@2x.png"] forState:UIControlStateNormal];
    [originalBtn setImage:[UIImage imageNamed:@"activate_friends_seleted@2x.png"] forState:UIControlStateSelected];
    originalBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 7, 0, 0);
    [originalBtn addTarget:self action:@selector(didOriginalClick:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:originalBtn];
    originalBtn.frame = CGRectMake(10, 0, 200, 45);
    _originalBtn = originalBtn;
    
    UIButton *confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [confirmBtn addTarget:self action:@selector(sureClick:) forControlEvents:UIControlEventTouchUpInside];
    [confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
    [confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [confirmBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [confirmBtn setBackgroundImage:[UIImage imageNamed:@"login_bg@2x.png"] forState:UIControlStateDisabled];
    [confirmBtn setBackgroundImage:[UIImage imageNamed:@"login_btn_blue_nor@2x.png"] forState:UIControlStateNormal];
    confirmBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    
    confirmBtn.layer.masksToBounds = YES;
    confirmBtn.layer.cornerRadius = 3;
    
    [bottomView addSubview:confirmBtn];
    confirmBtn.frame = CGRectMake(WIDTH - 70, 0, 60, 30);
    confirmBtn.center = CGPointMake(confirmBtn.center.x, 22.5);
    _confirmBtn = confirmBtn;
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 0.5)];
    line.backgroundColor = [UIColor lightGrayColor];
    [bottomView addSubview:line];
    
    if ([HX_AssetManager sharedManager].type == HX_SelectVideo) {
        originalBtn.hidden = YES;
    }else {
        originalBtn.hidden = NO;
    }
    
    NSInteger count = [HX_AssetManager sharedManager].selectedPhotos.count;
    
    if (model.type == HX_Video) {
        _rightBtn.hidden = YES;
        
        if (count == 0) {
            _originalBtn.enabled = NO;
            _confirmBtn.enabled = YES;
        }else {
            _originalBtn.enabled = NO;
            _confirmBtn.enabled = NO;
        }
    }else {
        _rightBtn.hidden = NO;
        
        BOOL bl = count == 0 ? NO : YES;
        
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
    }
    
    if (_ifLookPic) {
        _bottomView.hidden = YES;
        
        UILabel *topLb = [[UILabel alloc] init];
        topLb.text = [NSString stringWithFormat:@"%ld/%ld",_currentIndex + 1,_photoAy.count];
        topLb.textAlignment = NSTextAlignmentCenter;
        topLb.textColor = [UIColor whiteColor];
        topLb.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        topLb.frame = CGRectMake(0, 30, 70, 25);
        topLb.center = CGPointMake(WIDTH / 2, topLb.center.y);
        topLb.font = [UIFont systemFontOfSize:17];
        topLb.layer.masksToBounds = YES;
        topLb.layer.cornerRadius = 5;
        [self.view addSubview:topLb];
        _topLb = topLb;
        if (_photoAy.count == 1) {
            topLb.hidden = YES;
        }
    }
    
    [collectionView setContentOffset:CGPointMake(_currentIndex * (WIDTH + 20), 0) animated:NO];
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
    
    if (self.didOriginalBlock) {
        self.didOriginalBlock();
    }
}

#pragma mark - < 确定 >
- (void)sureClick:(UIButton *)button
{
    HX_PhotoModel *model;
    if (_currentIndex != 0) {
        model = self.photoAy[_currentIndex - 1];
    }else {
        model = self.photoAy.firstObject;
    }
    
    if (model.type == HX_Video) {
        [[HX_AssetManager sharedManager].selectedPhotos addObject:model];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HX_SureSelectPhotosNotice" object:nil];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.photoAy.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    HX_AssetContainerViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:containerCellId forIndexPath:indexPath];
    
    HX_PhotoModel *model = self.photoAy[indexPath.item];
    cell.model = model;

    __weak typeof(self) weakSelf = self;
    [cell setDidImgBlock:^{
        if (weakSelf.ifLookPic) {
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        }else {
            [weakSelf.navigationController setNavigationBarHidden:!weakSelf.ifDid animated:NO];
            weakSelf.bottomView.hidden = !weakSelf.ifDid;
            weakSelf.ifDid = !weakSelf.ifDid;
            [weakSelf setNeedsStatusBarAppearanceUpdate];
        }
    }];
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offSetWidth = scrollView.contentOffset.x;
    offSetWidth = offSetWidth +  ((WIDTH + 20) * 0.5);
    
    NSInteger currentIndex = offSetWidth / (WIDTH + 20) + 1;
    
    if (_currentIndex != currentIndex) {
        _currentIndex = currentIndex;
        
        HX_PhotoModel *model = self.photoAy[_currentIndex - 1];
        
        _rightBtn.selected = model.ifSelect;
        if (model.ifSelect) {
            [_rightBtn setTitle:[NSString stringWithFormat:@"%ld",model.index + 1] forState:UIControlStateNormal];
        }else {
            [_rightBtn setTitle:@"" forState:UIControlStateNormal];
        }
        
        NSInteger count = [HX_AssetManager sharedManager].selectedPhotos.count;
        if (model.type == HX_Video) {
            _rightBtn.hidden = YES;
            if (count == 0) {
                _originalBtn.enabled = NO;
                _confirmBtn.enabled = YES;
            }else {
                _originalBtn.enabled = NO;
                _confirmBtn.enabled = NO;
            }
            
        }else {
            _rightBtn.hidden = NO;
            
            BOOL bl = count == 0 ? NO : YES;
            
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
        }
        
        _rightBtn.tag = _currentIndex - 1;
        _titleLb.text = [NSString stringWithFormat:@"%ld/%ld",_currentIndex,_photoAy.count];
        _topLb.text = _titleLb.text;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:18/255.0 green:183/255.0 blue:245/255.0 alpha:1]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.navigationController.navigationBar setBarTintColor:[[UIColor blackColor] colorWithAlphaComponent:0.1]];
}

- (BOOL)prefersStatusBarHidden
{
    return _ifDid;
}

@end
