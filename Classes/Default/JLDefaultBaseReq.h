//
//  JLDefaultBaseReq.h
//  JLNetworking
//
//  Created by JeremyLyu on 16/3/4.
//  Copyright © 2016年 jeremyLyu. All rights reserved.
//

#import "JLNetworkingReq.h"
/**
 *  网络请求公有类，做通用处理操作。提供一种更自由的网络请求使用方式
 */
@interface JLDefaultBaseReq : JLNetworkingReq
@property (nonatomic, strong) NSString *baseURL;        //baseURL地址-必须
@property (nonatomic, strong) NSString *pathURL;        //pathURL地址-必须
@property (nonatomic, strong) NSString *modelName;      //网络返回数据对应的Model类名-非必须
@property (nonatomic, strong) NSString *dataPath;       //model反射的data路径，默认为查找 data 字段
@end
