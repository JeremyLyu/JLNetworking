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