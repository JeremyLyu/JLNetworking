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
#import "JLNetBatchRequest.h"

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
            NSString *avatarPath = [[NSBundle mainBundle] pathForResource:@"avatar" ofType:@"jpg"];
            [NSData dataWithContentsOfFile:avatarPath];
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
            //返回过滤
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
            } failure:^(NSError *error) {
                NSLog(@"%@", error);
            }];
        }
            break;
        case 1007:
        {
            JLNetworkingReq *req1 = [DemoReq reqWithType:@"shunfeng" postId:@(991849911763)];
            JLNetworkingReq *req2 = [DemoReq4 reqWithId:@(420106198708257767)];
            JLNetworkingReq *req3 = [DemoReq1 reqWithId:@(420106198708257766)];
            JLNetBatchRequest *batchReq = [JLNetBatchRequest batchWithRequests:@[req1, req2, req3]];
            [batchReq sendWithSuccess:^(NSArray *responseObjects) {
                NSLog(@"%@", responseObjects);
            } failure:^(NSError *error) {
                NSLog(@"%@", error);
            }];
        }
            break;
        case 1008:
        {
            JLNetworkingReq *req1 = [DemoReq reqWithType:@"shunfen" postId:@(991849911763)];
            JLNetworkingReq *req2 = [DemoReq1 reqWithId:@(420106198708257767)];
            JLNetBatchRequest *batchReq = [JLNetBatchRequest batchWithRequests:@[req1, req2]];
            [batchReq sendWithSuccess:^(NSArray *responseObjects) {
                NSLog(@"%@", responseObjects);
            } failure:^(NSError *error) {
                NSLog(@"%@", error);
            }];
        }
            break;
        case 1009:
        {
            DemoReq6 *req = [DemoReq6 new];
            [req sendWithId:@(420106198708257767) success:^(id responseObject) {
                NSLog(@"%@", responseObject);
            } failure:^(NSError *error) {
                NSLog(@"%@", error);
            }];
        }
            break;
        case 1010:
        {
            DemoReq6 *req = [DemoReq6 new];
            [req sendWithId:@(420106198708257766) success:^(id responseObject) {
                NSLog(@"%@", responseObject);
            } failure:^(NSError *error) {
                NSLog(@"%@", error);
            }];
        }
            break;
            
        default:
            break;
    }
}

@end
