//
//  HX_AlbumViewController.h
//  测试
//
//  Created by 洪欣 on 16/8/18.
//  Copyright © 2016年 洪欣. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HX_AlbumModel.h"

@interface HX_AlbumViewController : UIViewController
@property (assign, nonatomic) BOOL ifVideo;
@property (assign, nonatomic) NSInteger maxNum;
@end

@interface HX_TableViewCell : UITableViewCell
@property (assign, nonatomic) NSInteger count;
@property (strong, nonatomic) UIImage *photoImg;
@property (copy, nonatomic) NSString *photoName;
@property (assign, nonatomic) NSInteger photoNum;
@property (strong, nonatomic) HX_AlbumModel *model;
@end