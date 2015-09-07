//
//  JLNetworkingDefaultMapper.h
//  JLNetworking
//
//  Created by jeremyLyu on 15/9/1.
//  Copyright (c) 2015年 jeremyLyu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JLNetworkingReqProtocols.h"

/**
 *  想通过反射直接得到的类对象必须实现此协议
 */
@protocol JLDefaultMapperProtocol <NSObject>
@required
- (void)setValueWithPropertyDict:(NSDictionary *)propertyDict;
@end

@interface JLNetworkingDefaultMapper : NSObject <JLNetworkingReqResponseMapper>
/**
 *  查找数据块的路径,默认为@“data”;
 *  比如返回的内容为{@"code":@(123), @"msg":@"提示", @"info":{@"data":{}, @"other":{}}},实际的数据内容在key为data 所对应的内容
 *  那么将dataPath设置为@“info.data”,即可;
 */
@property (nonatomic, strong) NSString *dataPath;

/**
 *  获取一个mapper
 *
 *  @param className 要映射得到的对象类名
 *
 *  @return JLNetworkingDefaulMapper对象
 */
+ (instancetype)mapperWithClassName:(NSString *)className;

//TODO: 专门增加一个针对数组的Mapper.

@end
