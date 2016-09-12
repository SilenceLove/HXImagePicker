//
//  HX_PhotosViewController.h
//  测试
//
//  Created by 洪欣 on 16/8/18.
//  Copyright © 2016年 洪欣. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface HX_PhotosViewController : UIViewController
@property (assign, nonatomic) BOOL ifVideo;
@property (strong, nonatomic) NSMutableArray *allPhotosArray;
@property (assign, nonatomic) NSInteger cellIndex;
@property (assign, nonatomic) NSInteger maxNum;
@end
