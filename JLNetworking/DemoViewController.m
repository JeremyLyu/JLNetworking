//
//  DemoViewController.m
//  JLNetworking
//
//  Created by jeremyLyu on 15/9/6.
//  Copyright (c) 2015年 jeremyLyu. All rights reserved.
//

#import "DemoViewController.h"
#import "DemoReq.h"
#import "DemoEntity.h"

@interface DemoViewController ()

@end

@implementation DemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)btnPressed:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    switch (btn.tag) {
        case 1001:
        {
            //普通请求
            DemoReq *req = [DemoReq new];
            [req sendWithType:@"shunfeng" postId:@(991849911763) success:^(id responseObject) {
                NSLog(@"%@", responseObject);
            } failure:nil];
        }
            break;
        case 1002:
        {
            //带消息头的请求
            DemoReq1 *req = [DemoReq1 new];
            //也可以在外部设置 req.headerDict = @[];
            [req sendWithId:@(420106198708257767) success:^(id responseObject) {
                NSLog(@"%@", responseObject);
            } failure:^(NSError *error) {
                NSLog(@"%@", error);
            }];
        }
            break;
        case 1003:
        {
            //将成功的请求转为失败
            DemoReq2 *req = [DemoReq2 new];
            [req sendWithType:@"shunfeng" postId:@(991849911763) success:nil
             failure:^(NSError *error) {
                 NSLog(@"%@", error);
             }];
        }
            break;
        case 1004:
        {
            //使用默认mapper得到entity数组
            DemoReq3 *req = [DemoReq3 new];
            [req sendWithType:@"shunfeng" postId:@(991849911763) success:^(id responseObject) {
                NSLog(@"%@", responseObject);
            } failure:nil];
        }
            break;
        case 1005:
        {
            //使用默认mapper 修改数据块查找路径得到entity
            DemoReq4 *req = [DemoReq4 new];
            [req sendWithId:@(420106198708257767) success:^(id responseObject) {
                NSLog(@"%@", responseObject);
            } failure:nil];
        }
            break;
        case 1006:
        {
            DemoReq5 *req = [DemoReq5 new];
            [req sendWithId:@(420106198708257767) success:^(id responseObject) {
                NSLog(@"%@", responseObject);
            } failure:nil];
        }
            break;
            
        default:
            break;
    }
}

@end
