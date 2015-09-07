//
//  DemoReq.h
//  JLNetworking
//
//  Created by jeremyLyu on 15/8/31.
//  Copyright (c) 2015年 jeremyLyu. All rights reserved.
//

#import "JLNetworkingReq.h"

@interface DemoReq : JLNetworkingReq <JLNetworkingReqBase>

- (void)sendWithType:(NSString *)type
              postId:(NSNumber*)postId
             success:(JLNetworkingCompletedBlock)success
             failure:(JLNetworkingFailedBlock)failure;
@end

@interface DemoReq1 : JLNetworkingReq <JLNetworkingReqBase>

- (void)sendWithCity:(NSString *)city
             success:(JLNetworkingCompletedBlock)success
             failure:(JLNetworkingFailedBlock)failure;
@end

@interface DemoReq2 : DemoReq
@end

@interface DemoReq3 : DemoReq

@end