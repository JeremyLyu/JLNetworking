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
@interface JLDefaultMapper : NSObject

+ (id)mappedResponseObj:(id)responseObject className:(NSString *)className;

+ (id)mappedResponseObj:(id)responseObject className:(NSString *)className dataPath:(NSString *)dataPath;
@end
