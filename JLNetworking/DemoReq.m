//
//  DemoReq.m
//  JLNetworking
//
//  Created by jeremyLyu on 15/8/31.
//  Copyright (c) 2015年 jeremyLyu. All rights reserved.
//

#import "DemoReq.h"
#import "JLNetworkingDefaultMapper.h"
#import "DemoEntity.h"

@interface DemoReq ()
@end

@implementation DemoReq

- (NSString *)baseUrl
{
    return @"http://www.kuaidi100.com";
}

- (NSString *)pathUrl
{
    return @"query";
}

- (JLNetworkingRequestType)requestType
{
    return JLNetworkingRequestTypeGet;
}

- (void)sendWithType:(NSString *)type
              postId:(NSNumber*)postId
             success:(JLNetworkingCompletedBlock)success
             failure:(JLNetworkingFailedBlock)failure
{
    NSDictionary *params = @{@"type" : type,
                             @"postid" : postId};
    [self sendWithParams:params success:success failure:failure];
}

@end

@implementation DemoReq1
- (instancetype)init
{
    self = [super init];
    if(self)
    {
        self.headerDict = @{@"apikey" : @"98f826217b723c9834f341a810e1a67c"};
    }
    return self;
}

- (NSString *)baseUrl
{
    return @"http://apis.baidu.com";
}

- (NSString *)pathUrl
{
    return @"heweather/weather/free";
}

- (JLNetworkingRequestType)requestType
{
    return JLNetworkingRequestTypeGet;
}

- (void)sendWithCity:(NSString *)city success:(JLNetworkingCompletedBlock)success failure:(JLNetworkingFailedBlock)failure
{
    NSDictionary *params = @{@"city": city};
    [self sendWithParams:params success:success failure:failure];
}
@end

@implementation DemoReq2

- (NSError *)makeSuccessToFailureWithResponseObject:(id)reponseObject
{
    return [NSError errorWithDomain:@"成功返回了，但业务需求，让它变为失败的回掉" code:1234 userInfo:nil];
}
@end