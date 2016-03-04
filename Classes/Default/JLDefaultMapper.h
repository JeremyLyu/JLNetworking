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
- (instancetype)entityWithDictionary:(NSDictionary *)dict;
@end




/*****************************************************************************************/
/* 使用默认Mapper得到的数据为 mapperWithClassName: 方法中的 className对应的对象 或 对象数组      */
/* 如果映射不成功(找不到对应的类，或类没有实现JLDefaultMapperProtocol，则得到映射前数据)           */
/*****************************************************************************************/
@interface JLDefaultMapper : NSObject <JLNetworkingReqResponseMapper>

/**
 *  获取一个mapper,默认映射返回中，data字段下数据
 *
 *  @param className 要映射得到的对象类名
 *
 *  @return mapper对象
 */
+ (instancetype)mapperWithClassName:(NSString *)className;

/**
 *  获取一个mapper
 *
 *  @param className 要映射得到的对象类名
 *  @param dataPath  查找数据块的路径
 *  比如返回的内容为{@"code":@(123), @"msg":@"提示", @"info":{@"data":{}, @"other":{}}},实际的数据为"data"字段对应的内容, 那么将dataPath设置为@“info.data”,即可;
 *
 *  @return mapper对象
 */
+ (instancetype)mapperWithClassName:(NSString *)className dataPath:(NSString *)dataPath;

/**
 *  获取一个mapper
 *
 *  @param transformer 对返回内容进行处理的block，其中block返回的数据，将作为映射结果传输给外部
 *
 *  @return mapper对象
 */
+ (instancetype)mapperWithTransformer:(id(^)(id responseObject))transformer;

@end
