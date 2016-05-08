//
//  JLNetBatchRequest.m
//  JLNetworking
//
//  Created by jeremyLyu on 16/5/6.
//  Copyright © 2016年 jeremyLyu. All rights reserved.
//

#import "JLNetBatchRequest.h"

@interface JLNetBatchRequest ()
@property (strong, nonatomic) NSArray *requests;
@property (assign, nonatomic) BOOL isFailure;
@property (strong, nonatomic) NSError *error;

@property (copy ,nonatomic) JLNetBatchCompletedBlock completedBlock;
@property (copy, nonatomic) JLNetworkingFailedBlock failedBlock;

@property (strong, nonatomic) JLNetBatchRequest *holdSelf;
@end

@implementation JLNetBatchRequest

#pragma mark - public
+ (JLNetBatchRequest *)batchWithRequests:(NSArray<JLNetworkingReq *> *)requests {
    JLNetBatchRequest *batchRequest = [JLNetBatchRequest new];
    batchRequest.requests = requests;
    return batchRequest;
}

- (void)sendWithSuccess:(JLNetBatchCompletedBlock)success failure:(JLNetworkingFailedBlock)failure {
    self.holdSelf = self;
    self.completedBlock = success;
    self.failedBlock = failure;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_group_t group = dispatch_group_create();
        //发出单个请求
        __weak typeof(self) weakSelf = self;
        for (JLNetworkingReq *request in self.requests) {
            dispatch_group_enter(group);
            [request sendWithSuccess:^(id responseObject) {
                dispatch_group_leave(group);
            } progress:nil failure:^(NSError *error) {
                dispatch_group_leave(group);
                [weakSelf requestFailed:error];
            }];
        }
        //请求结束
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            if (self.isFailure) {
                [self batchRequestFailed];
            } else {
                [self batchRequestSuccess];
            }
            self.holdSelf = nil;
        });
    });
}

- (void)cancel {
    JLNetworkingReq *request = [self.requests firstObject];
    [request cancel];
}

#pragma mark - private
- (void)requestFailed:(NSError *)error {
    if (self.error == nil) {
        self.error = error;
    }
    self.isFailure = YES;
    for(JLNetworkingReq *request in self.requests) {
        [request cancel];
    }
}

- (void)batchRequestSuccess {
    NSMutableArray *responseObjs = [NSMutableArray new];
    for (JLNetworkingReq *request in self.requests) {
        if (request.responseObject) {
            [responseObjs addObject:request.responseMappedObject];
        }
    }
    if (self.completedBlock) {
        self.completedBlock(responseObjs);
        self.completedBlock = nil;
    }
}

- (void)batchRequestFailed {
    if (self.error) {
        self.failedBlock(self.error);
        self.failedBlock = nil;
    }
}

@end
