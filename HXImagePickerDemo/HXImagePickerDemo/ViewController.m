//
//  ViewController.m
//  HXImagePickerDemo
//
//  Created by 洪欣 on 16/9/9.
//  Copyright © 2016年 洪欣. All rights reserved.
//

#import "ViewController.h"
#import "OneViewController.h"
#import "TwoViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor brownColor];
    
    self.title = @"图片选择器";

    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [button1 setTitle:@"选择照片 和 选择视频" forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(goVC1) forControlEvents:UIControlEventTouchUpInside];
    button1.frame = CGRectMake(0, 100, self.view.frame.size.width, 50);
    [self.view addSubview:button1];
    
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [button2 setTitle:@"选择照片and视频  和  选择视频" forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(goVC2) forControlEvents:UIControlEventTouchUpInside];
    button2.frame = CGRectMake(0, 250, self.view.frame.size.width, 50);
    [self.view addSubview:button2];
}

- (void)goVC1
{
    [self.navigationController pushViewController:[[OneViewController alloc] init] animated:YES];
}

- (void)goVC2
{
    [self.navigationController pushViewController:[[TwoViewController alloc] init] animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
