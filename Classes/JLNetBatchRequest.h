//
//  JLNetBatchRequest.h
//  JLNetworking
//
//  Created by jeremyLyu on 16/5/6.
//  Copyright © 2016年 jeremyLyu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JLNetworkingReq.h"

typedef void(^JLNetBatchCompletedBlock)(NSArray *responseObjects);

@interface JLNetBatchRequest : NSObject

+ (JLNetBatchRequest *)batchWithRequests:(NSArray<JLNetworkingReq *> *)requests;

- (void)sendWithSuccess:(JLNetBatchCompletedBlock)success failure:(JLNetworkingFailedBlock)failure;

- (void)cancel;
@end
