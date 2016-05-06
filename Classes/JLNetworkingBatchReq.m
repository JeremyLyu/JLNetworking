//
//  JLNetworkingBatchReq.m
//  JLNetworking
//
//  Created by jeremyLyu on 16/5/5.
//  Copyright © 2016年 jeremyLyu. All rights reserved.
//

#import "JLNetworkingBatchReq.h"
#import "JLNetworkingReq.h"

@interface JLNetworkingBatchReq ()
@property (strong, nonatomic) NSMutableArray *responseArray;
@end

@implementation JLNetworkingBatchReq

- (void)sendWithReqs:(NSArray<JLNetworkingReq *> *)reqs {
    for (JLNetworkingReq *req in reqs) {
        __block id responseObj;
        [self.responseArray addObject:responseObj];
        [req sendWithParams:nil success:^(id responseObject) {
            responseObj = responseObject;
        } failure:^(NSError *error) {
            
        }];
    }
}

@end
