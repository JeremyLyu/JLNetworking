//
//  JLNetworkingManager.h
//  JLNetworking
//
//  Created by jeremyLyu on 15/8/27.
//  Copyright (c) 2015年 jeremyLyu. All rights reserved.
//

#import <Foundation/Foundation.h>
//请求的类型，目前只支持了Post和Get,暂时没有发现别的需要扩展的地方
typedef NS_ENUM(NSInteger, JLNetworkingRequestType)
{
    JLNetworkingRequestTypeGet,
    JLNetworkingRequestTypePost
};

//请求成功的回调
typedef void(^JLNetworkingCompletedBlock)(id responseObject);
//请求失败的回调
typedef void(^JLNetworkingFailedBlock)(NSError *error);

//协议：使用JLNetworking的来做请求管理的对象都必须满足此协议
@protocol JLNetworkingRequestIdProtocol <NSObject>

@required
@property (nonatomic, strong) NSNumber *requestId;
@end

/**
 *  数据块上传类，一个对象对应一个key。支持NSData和filePath的方式上传。支持一次上传一组数据
 */
@interface JLNetworkingMultiDataObj : NSObject
@property (nonatomic, strong) NSString *name;
//default： file.jpg
@property (nonatomic, strong) NSString* fileName;
//default： image/jpg
@property (nonatomic, strong) NSString* mimeType;

@property (nonatomic, strong) NSString* filePath;
//default：nil。 如果给data传值，则将忽略 fileURL
@property (nonatomic, strong) NSData* data;
//default：nil。 如果给datas传值, 则忽略 fileUrl 和 data
@property (nonatomic, strong) NSArray* datas;
@end

/********************************************************************************************************/
/*                                              Alert                                                   */
/*                                  不建议直接使用Manager进行网络请求                                       */
/*                                  使用JLNetworkingReq的派生类最佳                                       */
/*******************************************************************************************************/
@interface JLNetworkingManager : NSObject

+ (instancetype)sharedManager;

/**
 *  发起一个网络请求，并将请求对象交于Manager统一管理
 *
 *  @param requestObj      满足协议的请求对象
 *  @param URLString       绝对地址
 *  @param requestType     类型
 *  @param param           参数
 *  @param timeoutInterval 超时，如果小于0将使用默认超时
 *  @param success         成功的回调
 *  @param failure         失败的回调
 */
- (void)sendWithRequestObj:(id<JLNetworkingRequestIdProtocol>)requestObj
                 URLString:(NSString *)URLString
               requestType:(JLNetworkingRequestType)requestType
                     params:(NSDictionary *)params
                   timeout:(NSTimeInterval)timeoutInterval
                   success:(JLNetworkingCompletedBlock)success
                   failure:(JLNetworkingFailedBlock)failure;

/**
 *  发起一个网络请求，并将请求对象交于Manager统一管理
 *
 *  @param requestObj      满足协议的请求对象
 *  @param URLString       地址
 *  @param requestType     类型
 *  @param params          参数
 *  @param multiDataObj    用于上传的multipartFormData对象
 *  @param headerDict      请求头
 *  @param timeoutInterval 超时
 *  @param success         成功的回调
 *  @param failure         失败的回调
 */
- (void)sendWithRequestObj:(id<JLNetworkingRequestIdProtocol>)requestObj
                 URLString:(NSString *)URLString
               requestType:(JLNetworkingRequestType)requestType
                    params:(NSDictionary *)params
         multipartFormData:(JLNetworkingMultiDataObj *)multiDataObj
                headerDict:(NSDictionary *)headerDict
                   timeout:(NSTimeInterval)timeoutInterval
                   success:(JLNetworkingCompletedBlock)success
                   failure:(JLNetworkingFailedBlock)failure;

/**
 *  取消一个网络请求
 *
 *  @param requestObj 实现JLNetworkingRequestProtocol协议的对象
 */
- (void)cancelRequest:(id<JLNetworkingRequestIdProtocol>)requestObj;

//TODO: 并发情况考虑，还是可以考虑之前的QueueName方案，让manager持有一个OperationQueueName字典

/**
 *  取消manager管理的所有网络请求
 */
- (void)cancelAllRequest;
@end
