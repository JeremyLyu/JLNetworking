//
//  JLNetworkingManager.m
//  JLNetworking
//
//  Created by jeremyLyu on 15/8/27.
//  Copyright (c) 2015年 jeremyLyu. All rights reserved.
//

#import "JLNetworkingManager.h"
#import <AFNetworking/AFHTTPRequestOperationManager.h>

@interface JLNetworkingManager ()
@property (nonatomic, strong) NSMutableDictionary *operationQueueDict;
@end

@implementation JLNetworkingMultiDataObj

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        //default Value
        self.fileName = @"file.jpg";
        self.mimeType = @"image/jpg";
    }
    return self;
}

#pragma mark - setter
- (void)setFilePath:(NSString *)filePath
{
    _filePath = filePath;
    _data = nil;
    _datas = nil;
}

- (void)setData:(NSData *)data
{
    _data = data;
    _datas = nil;
    _filePath = nil;
}

- (void)setDatas:(NSArray *)datas
{
    _datas = datas;
    _filePath = nil;
    _data = nil;
}

@end

@interface JLNetworkingManager ()
//请求数组，用于保持正在进行请求的请求对象
@property (nonatomic, strong) NSMutableArray *requestList;
//requestId字典，用于查找实际的网络访问operation
@property (nonatomic, strong) NSMutableDictionary *requestIdDict;
//下一个请求的requestId
@property (nonatomic, strong) NSNumber *nextRequestId;

@property (nonatomic, strong) AFHTTPRequestOperationManager *mainOperationManager;

@end

static const NSTimeInterval JLNetworkingDefaultTimeoutInterval = 30;

@implementation JLNetworkingManager

+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    static JLNetworkingManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [[JLNetworkingManager alloc] init];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        self.requestList = [NSMutableArray new];
        self.requestIdDict = [NSMutableDictionary new];
        self.nextRequestId = @(1);
        self.operationQueueDict = [NSMutableDictionary new];
        //配置operationManager
        self.mainOperationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:nil];
        self.mainOperationManager.requestSerializer.timeoutInterval = JLNetworkingDefaultTimeoutInterval;
        //TODO: LXJ 是否真的应该添加这个兼容性代码，这原本使用来兼容一些返回JSON的API不规范的contentType
        //暂且写在这里吧，谁叫国内写接口的服务器程序员都这么炫呢。╮(╯▽╰)╭
        [self.mainOperationManager.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"text/html",
                                                                                 @"text/json",
                                                                                 @"application/json",
                                                                                 @"text/plain", nil]];
    }
    return self;
}

#pragma mark - public

- (void)sendWithRequestObj:(id<JLNetworkingRequestIdProtocol>)requestObj
                 URLString:(NSString *)URLString
               requestType:(JLNetworkingRequestType)requestType
                     params:(NSDictionary *)params
                   timeout:(NSTimeInterval)timeoutInterval
                   success:(JLNetworkingCompletedBlock)success
                   failure:(JLNetworkingFailedBlock)failure;
{
    [self sendWithRequestObj:requestObj URLString:URLString
                 requestType:requestType
                      params:params
           multipartFormData:nil
                  headerDict:nil
                     timeout:timeoutInterval
                     success:success
                     failure:failure];
}

//发送请求, 使用这个方法的好处是可以不将AFNetworking暴露给外部，便于集中维护
- (void)sendWithRequestObj:(id<JLNetworkingRequestIdProtocol>)requestObj
                 URLString:(NSString *)URLString
               requestType:(JLNetworkingRequestType)requestType
                    params:(NSDictionary *)params
         multipartFormData:(JLNetworkingMultiDataObj *)multiDataObj
                headerDict:(NSDictionary *)headerDict
                   timeout:(NSTimeInterval)timeoutInterval
                   success:(JLNetworkingCompletedBlock)success
                   failure:(JLNetworkingFailedBlock)failure
{
    if(requestObj == nil) return ;
    NSNumber *requestId = [self getRequestId];
    [requestObj setRequestId:requestId];
    NSMutableURLRequest *request;
    if(multiDataObj)
    {
        request = [self getRequestWithURLString:URLString requestType:requestType params:params multipartFormData:requestObj timeout:timeoutInterval];
    }
    else
    {
        request = [self getRequestWithURLString:URLString requestType:requestType params:params timeout:timeoutInterval];
    }
    //设置请求头
    if(headerDict)
    {
        [headerDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [request addValue:obj forHTTPHeaderField:key];
        }];
    }
    //实际请求
    __weak typeof(self) weakSelf = self;
    //TODO: 这里有点问题，在operation的callbackBlock会保持requestObj，是否有必要在用字典来统一保持requestObj和operation
    AFHTTPRequestOperation *operation = [self.mainOperationManager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //TODO: LXJ 打印Log
        if(success) success(responseObject);
        
        [weakSelf.requestIdDict removeObjectForKey:requestId];
        [weakSelf.requestList removeObject:requestObj];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //TODO: LXJ 打印Log
        if(failure) failure(error);
        
        [weakSelf.requestIdDict removeObjectForKey:requestId];
        [weakSelf.requestList removeObject:requestObj];
    }];
    [self.requestList addObject:requestObj];
    self.requestIdDict[requestId] = operation;
    [self.mainOperationManager.operationQueue addOperation:operation];
}


- (void)cancelRequest:(id<JLNetworkingRequestIdProtocol>)requestObj
{
    if([requestObj conformsToProtocol:@protocol(JLNetworkingRequestIdProtocol)])
    {
        NSOperation *operation = self.requestIdDict[[requestObj requestId]];
        [operation cancel];
    }
}

- (void)cancelAllRequest
{
    for(id<JLNetworkingRequestIdProtocol> requestObj in self.requestList)
    {
        [self cancelRequest:requestObj];
    }
}

#pragma mark - private

//生成请求
- (NSMutableURLRequest *)getRequestWithURLString:(NSString *)URLString
                              requestType:(JLNetworkingRequestType)requestType
                                    params:(NSDictionary *)params
                                  timeout:(NSTimeInterval)timeoutInterval
{
    
    NSString *method;
    switch (requestType) {
        case JLNetworkingRequestTypeGet:
            if([self.mainOperationManager.requestSerializer isKindOfClass:[AFJSONRequestSerializer class]]){
                self.mainOperationManager.requestSerializer = [AFHTTPRequestSerializer serializer];
            }
            method = @"GET";
            break;
        case JLNetworkingRequestTypePost:
            if([self.mainOperationManager.requestSerializer isKindOfClass:[AFJSONRequestSerializer class]]){
                self.mainOperationManager.requestSerializer = [AFHTTPRequestSerializer serializer];
            }
            method = @"POST";
            break;
        case JLNetworkingRequestTypeJSONPost:
            if([self.mainOperationManager.requestSerializer isKindOfClass:[AFJSONRequestSerializer class]] == NO){
                self.mainOperationManager.requestSerializer = [AFJSONRequestSerializer serializer];
            }
            method = @"POST";
            break;
    }
    NSMutableURLRequest *request = [self.mainOperationManager.requestSerializer requestWithMethod:method URLString: URLString parameters:params error:nil];
    //设置自定义超时
    if(timeoutInterval > 0)
    {
        [request setTimeoutInterval:timeoutInterval];
    }
    //TODO: LXJ 日志打印
    return request;
}

//生产multipartFormData的请求
- (NSMutableURLRequest *)getRequestWithURLString:(NSString *)URLString
                              requestType:(JLNetworkingRequestType)requestType
                                    params:(NSDictionary *)params
                        multipartFormData:(JLNetworkingMultiDataObj*)multiDataObj
                                  timeout:(NSTimeInterval)timeoutInterval
{
    NSMutableURLRequest *request = [self.mainOperationManager.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:URLString parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if(multiDataObj)
        {
            NSString *name = multiDataObj.name;
            //上传一组数据
            if(multiDataObj.datas)
            {
                NSString* newName = [NSString stringWithFormat:@"%@[]",name];
                for(NSData* data in multiDataObj.datas)
                {
                    [formData appendPartWithFileData:data name:newName fileName:multiDataObj.fileName mimeType:multiDataObj.mimeType];
                }
            }
            //上传一个数据
            else if(multiDataObj.data)
            {
                [formData appendPartWithFileData:multiDataObj.data name:name fileName:multiDataObj.fileName mimeType:multiDataObj.mimeType];
            }
            //上传一个本地文件
            else if(multiDataObj.filePath)
            {
                //url的方式
                if(multiDataObj.filePath == nil)
                {
                    NSLog(@"%s:未能找到文件路径", __FUNCTION__);
                    return ;
                }
                //验证filePath是否有效
                if(![[NSFileManager defaultManager] fileExistsAtPath:multiDataObj.filePath])
                {
                    NSLog(@"%s: 上传的文件路径不存在", __FUNCTION__);
                    return ;
                }
                
                NSURL* url = [NSURL fileURLWithPath:multiDataObj.filePath];
                NSError* error = nil;
                BOOL isFailed =  [formData  appendPartWithFileURL:url name:name fileName:multiDataObj.fileName mimeType:multiDataObj.mimeType error:&error];
                if(isFailed)
                {
                    NSLog(@"multiDataError:%@", error.localizedDescription);
                }
            }
        }
    } error:nil];
    //设置自定义超时
    if(timeoutInterval > 0)
    {
        [request setTimeoutInterval:timeoutInterval];
    }
    //TODO: 日志打印
    return request;
}

//TODO: LXJ POST自定义data处理

//获取新的requestId
- (NSNumber *)getRequestId
{
    if(_nextRequestId.integerValue == NSIntegerMax)
    {
        @synchronized(self.nextRequestId)
        {
            self.nextRequestId = @(1);
        }
        _nextRequestId = @(1);
    }
    else
    {
        @synchronized(self.nextRequestId)
        {
            self.nextRequestId = @([_nextRequestId integerValue] + 1);
        }
    }
    return [_nextRequestId copy];
}
@end
