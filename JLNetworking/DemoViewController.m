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
            [req sendWithCity:@"成都" success:^(id responseObject) {
                NSLog(@"%@", responseObject);
            } failure:nil];
        }
            break;
        case 1003:
        {
            DemoReq2 *req = [DemoReq2 new];
            [req sendWithType:@"shunfeng" postId:@(991849911763) success:nil
             failure:^(NSError *error) {
                 NSLog(@"%@", error);
             }];
        }
            break;
        case 1004:
            
            break;
            
        default:
            break;
    }
}

@end
