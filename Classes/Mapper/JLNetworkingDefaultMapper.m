//
//  JLNetworkingDefaultMapper.m
//  JLNetworking
//
//  Created by jeremyLyu on 15/9/1.
//  Copyright (c) 2015年 jeremyLyu. All rights reserved.
//

#import "JLNetworkingDefaultMapper.h"

@interface JLNetworkingDefaultMapper ()
@property (nonatomic, strong) NSString *className;

@end

@implementation JLNetworkingDefaultMapper

+ (instancetype)mapperWithClassName:(NSString *)className
{
    if(className == nil) return nil;
    JLNetworkingDefaultMapper *mapper = [JLNetworkingDefaultMapper new];
    mapper.dataPath = @"data";
    mapper.className = className;
    return mapper;
}

- (id)req:(JLNetworkingReq *)req mapResponseObject:(id)responseObject
{
    id newResponseObj = responseObject;

    //必须是字典类型才会做反射处理
    if([responseObject isKindOfClass:[NSDictionary class]])
    {
        if(_className != nil)
        {
            Class entityClass = NSClassFromString(_className);
            if(entityClass != NULL)
            {
                newResponseObj = [self getEntityWithEntityClass:entityClass propertyDict:responseObject];
            }
        }
    }
    return newResponseObj;
}

#pragma mark - private
- (id)getEntityWithEntityClass:(Class)entityClass propertyDict:(NSDictionary *)propertyDict
{
    id entity = [[entityClass alloc] init];
    if([entityClass conformsToProtocol:@protocol(JLDefaultMapperProtocol)])
    {
        //查找数据块
        NSDictionary *dataDict = [propertyDict valueForKeyPath:self.dataPath];
        [(id<JLDefaultMapperProtocol>)entity setValueWithPropertyDict:dataDict];
        return entity;
    }
    else
    {
        return propertyDict;
    }
}

@end
