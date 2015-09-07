//
//  JLNetworkingReqProtocols.h
//  JLNetworking
//
//  Created by jeremyLyu on 15/8/28.
//  Copyright (c) 2015年 jeremyLyu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JLNetworkingReq;
/**
 *  以下为 JLNetworkingReq 提供附加支持的一些协议
 */

/****************************************************************************************/
/*                       JLNetworkingReqSignature                                       */
/*        签名协议:用于请求参数签名或者加密，它是在发起请求前对参数的最后一次修改                   */
/****************************************************************************************/
@protocol JLNetworkingReqSignature <NSObject>
/**
 *  对参数进行签名的方法
 *
 *  @param params 请求参数
 *
 *  @return 进行了签名后的参数
 */
- (NSDictionary *)req:(JLNetworkingReq *)req signRequestParams:(NSDictionary *)params;
@end


/****************************************************************************************/
/*                    JLNetworkingReqResponseMapper                                     */
/*   数据映射协议：用于网络数据返回给外部前，做一次映射处理并将最终得到的新对象返回给外部             */
/****************************************************************************************/
@protocol JLNetworkingReqResponseMapper <NSObject>
/**
 *  对网络返回的数据映射成新的对象
 *
 *  @param req            网络请求对象
 *  @param responseObject 用于映射的数据，建议为NSDictionary对象，这样便于处理
 *
 *  @return 映射后的数据
 */
- (id)req:(JLNetworkingReq *)req mapResponseObject:(id)responseObject;
@end


/****************************************************************************************/
/*                      JLNetworkingReqHook                                             */
/*  钩子(拦截)协议：用于网络请求中的一些关键点前后做点处理，这些方法对参数的处理不会影响到实际请求      */
/****************************************************************************************/
@protocol JLNetworkingReqHook <NSObject>
//发起请求前做点操作
- (void)req:(JLNetworkingReq *)req beforeRequestWithParams:(NSDictionary *)params;

//在请求成功回调前做点操作
- (void)req:(JLNetworkingReq *)req beforeResponseSuccess:(id)responseObject;
//在请求成功回调后做点操作
- (void)req:(JLNetworkingReq *)req afterResponseSucess:(id)responseObject;

//在请求失败回调前做点操作
- (void)req:(JLNetworkingReq *)req beforeResponseFailure:(NSError *)error;
//在请求失败回调后做点操作
- (void)req:(JLNetworkingReq *)req afterResponseFailure:(NSError *)error;
@end