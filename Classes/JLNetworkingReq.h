//
//  JLNetworkReq.h
//  JLNetworking
//
//  Created by jeremyLyu on 15/8/27.
//  Copyright (c) 2015年 jeremyLyu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JLNetworkingManager.h"
#import "JLNetworkingReqProtocols.h"

/**
 *  JLNetworkingReq的子类，必须满足此协议
 */
@protocol JLNetworkingReqBase <NSObject>
@required
- (NSString *)baseUrl;
- (NSString *)pathUrl;
- (JLNetworkingRequestType)requestType;

//以下为可选方法，如果有对应的功能需求，在实际的请求类中实现即可
@optional
//请求超时时长
- (NSTimeInterval)timeoutInterval;
//检验请求参数是否正确
- (BOOL)validateRequestParams:(NSDictionary *)params;
//检验返回的内容是否正确
- (BOOL)validateResponseObject:(NSDictionary *)responseObject;
//参数签名，返回签名后的参数字典
- (NSDictionary *)signParams:(NSDictionary *)params;

/**
 *  过滤网络返回，有时候需要根据返回数据的内容，自行判断请求成功与否。
 *  如果需要做以上的处理，请把判断是否成功的方法，写在这个方法里面。
 *
 *  @param reponseObject 返回的数据
 *
 *  @return NSError对象，默认返回为nil表示请求成功
 */
- (NSError *)filterResponseObject:(id)responseObject;

//映射方法，如果希望最终返回给外部的数据，是经过映射处理内容，请实现此方法
- (id)mapResponseObject:(id)responseObject;

//开启请求缓存
- (NSTimeInterval)cacheMaxExistenceTime;
@end





/**************************************************************************************/
/*                   JLNetworkingReq 网络请求基类                                       */
/*          使用方法：继承它，并实现JLNetworkingReqBase协议                                */
/**************************************************************************************/

@interface JLNetworkingReq : NSObject
//请求头字典，默认为nil
@property (nonatomic, strong) NSDictionary *headerDict;
//请求参数，默认为nil
@property (nonatomic, strong) NSDictionary *params;
//上传数据对象，默认为nil
@property (nonatomic, strong) JLNetworkingMultiDataObj *multiDataObj;

//请求成功返回的对象
@property (nonatomic, strong, readonly) id responseObject;
//请求成功返回进行映射后过的对象
@property (nonatomic, strong, readonly) id responseMappedObject;


//外部钩子，可以在这里面做点日志记录啊什么的
//TODO: LXJ hook这个考虑丢个数组进去
@property (nonatomic, weak) id<JLNetworkingReqHook> hook;

/**
 *  发送请求  此方法会使用请求对象的 headerDict、params、multiDataObj属性，如果需要传递这些内容请为它们赋值。
 *
 *  @param success  成功的回调
 *  @param progress 进度回调
 *  @param failure  失败的回调
 */
- (void)sendWithSuccess:(JLNetworkingCompletedBlock)success
               progress:(JLNetworkingProgressBlock)progress
                failure:(JLNetworkingFailedBlock)failure;
/**
 *  发送请求
 *
 *  @param params   参数
 *  @param success 请求成功的回调
 *  @param failure 请求失败的回调
 */
- (void)sendWithParams:(NSDictionary *)params
              success:(JLNetworkingCompletedBlock)success
              failure:(JLNetworkingFailedBlock)failure;

/**
 *  发送请求
 *
 *  @param params   参数
 *  @param success 请求成功的回调
 *  @param progress 进度的回调
 *  @param failure 请求失败的回调
 */
- (void)sendWithParams:(NSDictionary *)params
               success:(JLNetworkingCompletedBlock)success
              progress:(JLNetworkingProgressBlock)progress
               failure:(JLNetworkingFailedBlock)failure;


/**
 *  发送请求
 *
 *  @param params   参数
 *  @param multiDataObj JLNetworkingMultiDataObj对象，用于上传文件或数据
 *  @param success 请求成功的回调
 *  @param failure 请求失败的回调
 */
- (void)sendWithParams:(NSDictionary *)params
     multipartFormData:(JLNetworkingMultiDataObj *)multiDataObj
               success:(JLNetworkingCompletedBlock)success
               failure:(JLNetworkingFailedBlock)failure;

/**
 *  发送请求
 *
 *  @param params   参数
 *  @param multiDataObj JLNetworkingMultiDataObj对象，用于上传文件或数据
 *  @param success 请求成功的回调
 *  @param progress 进度的回调
 *  @param failure 请求失败的回调
 */
- (void)sendWithParams:(NSDictionary *)params
     multipartFormData:(JLNetworkingMultiDataObj *)multiDataObj
               success:(JLNetworkingCompletedBlock)success
              progress:(JLNetworkingProgressBlock)progress
               failure:(JLNetworkingFailedBlock)failure;


/**
 *  取消当前的网络请求
 */
- (void)cancel;


/*************************************************************************************/
/*  内部钩子(拦截)方法：子类如果希望在一些节点前后做点自定义操作，重载以下方法并先调用super        */
/*************************************************************************************/

/**
 *  在发送请求前做点操作
 *
 *  @param params 参数字典
 *
 *  @return 新的参数字典
 */
- (NSDictionary *)beforeRequestWithParams:(NSDictionary *)params;

/**
 *  在请求成功回调前做点操作
 *
 *  @param responseObject 回调给外部的数据
 *
 *  @return 新的回调给外部的数据
 */
- (id)beforeResponseSuccess:(id)responseObject;

/**
 *  在请求成功回调后做点操作
 *
 *  @param responseObject 回调给外部的数据
 */
- (void)afterResponseSucess:(id)responseObject;

/**
 *  在请求失败回调前做点操作
 *
 *  @param error 回调给外部的错误信息
 *
 *  @return 新的回调给外部的错误信息
 */
- (NSError *)beforeResponseFailure:(NSError *)error;

/**
 *  在请求失败回调后做点操作
 *
 *  @param error 新的回调给外部的错误信息
 */
- (void)afterResponseFailure:(NSError *)error;
@end
