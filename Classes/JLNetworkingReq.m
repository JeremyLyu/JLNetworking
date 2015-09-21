//
//  JLNetworkReq.m
//  JLNetworking
//
//  Created by jeremyLyu on 15/8/27.
//  Copyright (c) 2015年 jeremyLyu. All rights reserved.
//

#import "JLNetworkingReq.h"

@interface JLNetworkingReq () <JLNetworkingRequestIdProtocol>
{
    NSNumber *_requestId;
}
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, weak) NSObject<JLNetworkingReqBase> *child;

@end

@implementation JLNetworkingReq

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        //防止基类被直接使用，并限定子类必须实现这个基础协议
        if([self conformsToProtocol:@protocol(JLNetworkingReqBase)])
        {
            self.child = (NSObject<JLNetworkingReqBase> *)self;
        }
        else
        {
            NSAssert(NO, @"请勿直接实例化基类,子类必须实现JLNetworkingReqBase协议");
        }
        _isLoading = NO;
    }
    return self;
}

#pragma mark - public
- (void)sendWithParams:(NSDictionary *)params
              success:(JLNetworkingCompletedBlock)success
              failure:(JLNetworkingFailedBlock)failure
{
    [self sendWithParams:params multipartFormData:nil success:success failure:failure];
}

- (void)sendWithParams:(NSDictionary *)params
     multipartFormData:(JLNetworkingMultiDataObj *)multiDataObj
               success:(JLNetworkingCompletedBlock)success
               failure:(JLNetworkingFailedBlock)failure
{
    //TODO: 想一下对 isLoading 进行线程保护的必要性。貌似这种情况，必要性不是很大
    if(self.isLoading)
    {
        NSLog(@"%s:正在请求中，请勿重复请求", __FUNCTION__);
        return;
    }
    self.isLoading = YES;
    
    //参数校验
    if([self.child respondsToSelector:@selector(isCorrectWithRequestParams:)])
    {
        if([self.child isCorrectWithRequestParams:params] == NO)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *error = [NSError errorWithDomain:@"请求参数未能通过，正确性校验" code:NSURLErrorCannotParseResponse userInfo:nil];
                [self responseWithFailure:failure error:error];
            });
            return ;
        }
    }
    //发起请求前的拦截
    NSDictionary *actualParams = [self beforeRequestWithParams:params];
    if([self.hook respondsToSelector:@selector(req:beforeRequestWithParams:)])
    {
        [self.hook req:self beforeRequestWithParams:[actualParams copy]];
    }
    //最后的参数签名
    if([self.signature respondsToSelector:@selector(req:signRequestParams:)])
    {
        actualParams = [self.signature req:self signRequestParams:actualParams];
    }
    
    //请求地址
    NSURL *baseUrl = [NSURL URLWithString:[self.child baseUrl]];
    NSString *URLString = [[NSURL URLWithString:[self.child pathUrl] relativeToURL:baseUrl] absoluteString];
    //请求类型
    JLNetworkingRequestType requestType = [self.child requestType];
    //超时
    NSTimeInterval timeoutInterval = -1;
    if([self.child respondsToSelector:@selector(timeoutInterval)]) timeoutInterval = [self.child timeoutInterval];
    //实际网络请求
    __weak typeof(self) weakSelf = self;
    [[JLNetworkingManager sharedManager] sendWithRequestObj:self
                                                  URLString:URLString
                                                requestType:requestType
                                                     params:actualParams
                                          multipartFormData:multiDataObj
                                                 headerDict:self.headerDict
                                                    timeout:timeoutInterval
                                                    success:^(id responseObject)
    {
        weakSelf.isLoading = NO;
        
        [weakSelf responseWithSuccess:success failure:failure responseObject:responseObject];
    } failure:^(NSError *error) {
        weakSelf.isLoading = NO;
        
        [weakSelf responseWithFailure:failure error:error];
    }];
}

- (void)cancel
{
    if(self.isLoading)
    {
        [[JLNetworkingManager sharedManager] cancelRequest:self];
    }
}

#pragma mark - private

#pragma mark - 网络请求结束的处理
//成功的处理
- (void)responseWithSuccess:(JLNetworkingCompletedBlock)success failure:(JLNetworkingFailedBlock)failure responseObject:(id)responseObject
{
    //确定业务是否真正的成功
    NSError *error = [self makeSuccessToFailureWithResponseObject:responseObject];
    if(error)
    {
        [self responseWithFailure:failure error:error];
        return ;
    }
    
    //response数据正确性校验
    if([self.child respondsToSelector:@selector(isCorrectWithResponseObject:)])
    {
        if([self.child isCorrectWithResponseObject:responseObject] == NO)
        {
            NSError *error = [NSError errorWithDomain:@"返回数据未能通过校验" code:NSURLErrorCannotParseResponse userInfo:nil];
            [self responseWithFailure:failure error:error];
            return ;
        }
    }
        
    id newResponseObject = [self beforeResponseSuccess:responseObject];
    if([self.hook respondsToSelector:@selector(req:beforeResponseSuccess:)])
    {
        [self.hook req:self beforeResponseSuccess:responseObject];
    }
    
    if(success)
    {
        id actualResponseObject = newResponseObject;
        if([self.child respondsToSelector:@selector(responseMapper)])
        {
            id<JLNetworkingReqResponseMapper> mapper = [self.child responseMapper];
            if([mapper respondsToSelector:@selector(req:mapResponseObject:)])
            {
                actualResponseObject = [mapper req:self mapResponseObject:newResponseObject];
            }
        }
        success(actualResponseObject);
    }
    
    [self afterResponseSucess:newResponseObject];
    if([self.hook respondsToSelector:@selector(req:afterResponseSucess:)])
    {
        [self.hook req:self afterResponseSucess:newResponseObject];
    }
}

//失败的处理
- (void)responseWithFailure:(JLNetworkingFailedBlock)failure error:(NSError *)error
{
    NSError *newError = [self beforeResponseFailure:error];
    if([self.hook respondsToSelector:@selector(req:beforeResponseFailure:)])
    {
        [self.hook req:self beforeResponseFailure:[newError copy]];
    }
    
    if(failure)
    {
        failure(newError);
    }
    
    [self afterResponseFailure:newError];
    if([self.hook respondsToSelector:@selector(req:afterResponseFailure:)])
    {
        [self.hook req:self afterResponseFailure:newError];
    }
}

#pragma mark - 内部钩子方法
- (NSError *)makeSuccessToFailureWithResponseObject:(id)reponseObject
{
    return nil;
}

- (NSDictionary *)beforeRequestWithParams:(NSDictionary *)params
{
    return params;
}

- (id)beforeResponseSuccess:(id)responseObject{
    return responseObject;
}

- (void)afterResponseSucess:(id)responseObject{
    
}

- (NSError *)beforeResponseFailure:(NSError *)error{
    return error;
}

- (void)afterResponseFailure:(NSError *)error{
    
}

#pragma mark - JLNetworkingRequestId 
- (void)setRequestId:(NSNumber *)requestId
{
    _requestId = requestId;
}

- (NSNumber *)requestId
{
    return _requestId;
}

@end
