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
//TODO: 添加debugURL的必要性，再考虑下

@optional
//映射器方法，如果希望最终返回给外部的数据，是经过映射处理内容，请实现此方法
- (id<JLNetworkingReqResponseMapper>)responseMapper;
//超时
- (NSTimeInterval)timeoutInterval;
/*下面两个方法为输出输入正确检测方法，建议在实现。实际上有效的参数的检查，能够规避很多主逻辑上的错误，防止造成项目灾难*/
//检验参数是否正确
- (BOOL)isCorrectWithRequestParams:(NSDictionary *)params;
//检验返回的内容是否正确
- (BOOL)isCorrectWithResponseObject:(NSDictionary *)responseObject;
@end


/**************************************************************************************/
/*                   JLNetworkingReq 网络请求基类                                       */
/*          使用方法：继承它，并实现JLNetworkingReqBase协议                                */
/**************************************************************************************/

@interface JLNetworkingReq : NSObject
//请求头字典，默认为nil
@property (nonatomic, strong) NSDictionary *headerDict;
//TODO: 这个signature或许有点多余的样子。还是留着吧，保持一点灵活度╮(╯3╰)╭
@property (nonatomic, weak) id<JLNetworkingReqSignature> signature;     //用于请求前，参数签名的代理
@property (nonatomic, weak) id<JLNetworkingReqHook> hook; //外部钩子，可以在这里面做点日志记录啊什么的

//TODO: 请求Cache。这个东西，感觉还是很有必要

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
 *  @param multiDataObj JLNetworkingMultiDataObj对象，用于上传文件或数据
 *  @param success 请求成功的回调
 *  @param failure 请求失败的回调
 */
- (void)sendWithParams:(NSDictionary *)params
     multipartFormData:(JLNetworkingMultiDataObj *)multiDataObj
               success:(JLNetworkingCompletedBlock)success
               failure:(JLNetworkingFailedBlock)failure;


/**
 *  取消当前的网络请求
 */
- (void)cancel;


/*************************************************************************************/
/*  内部钩子(拦截)方法：子类如果希望在一些节点前后做点自定义操作，重载以下方法并先调用super        */
/*************************************************************************************/
/**
 *  将成功响应转为错误响应，有时候需要根据返回数据的内容，自行判断业务成功与否。
 *  如果需要做以上的处理，请把判断业务失败的方法，写在这个方法里面。
 *
 *  @param reponseObject 返回的数据
 *
 *  @return NSError对象，默认返回为nil，不需要做成功转错误的处理
 */
- (NSError *)makeSuccessToFailureWithResponseObject:(id)reponseObject;

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
