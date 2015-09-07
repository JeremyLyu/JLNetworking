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

#pragma mark - JLNetworkingReqResponseMapper

- (id)req:(JLNetworkingReq *)req mapResponseObject:(id)responseObject
{
    id newResponseObj = responseObject;
    if([responseObject isKindOfClass:[NSDictionary class]])
    {
        //查找数据块
        id dataObject = [responseObject valueForKeyPath:self.dataPath];
        if(dataObject)
        {
            //只支持字典类型和数组类型
            if([dataObject isKindOfClass:[NSArray class]])
            {
                NSMutableArray *entitys = [NSMutableArray new];
                BOOL isDataIntegrity = YES;
                for(id eachObject in (NSArray *)dataObject)
                {
                    if([eachObject isKindOfClass:[NSDictionary class]] == NO)
                    {
                        isDataIntegrity = NO;
                        break;
                    }
                    [entitys addObject:[self getEntityWithDict:eachObject]];
                }
                if(isDataIntegrity)
                {
                    newResponseObj = entitys;
                }
            }
            else if([dataObject isKindOfClass:[NSDictionary class]])
            {
                newResponseObj = [self getEntityWithDict:dataObject];
            }
        }
    }
    return newResponseObj;
}

#pragma mark - private
- (id)getEntityWithDict:(NSDictionary *)propertyDict
{
    if(_className == nil) return propertyDict;
    Class entityClass = NSClassFromString(_className);
    if(entityClass == NULL) return propertyDict;
    
    id entity = [[entityClass alloc] init];
    if([entityClass conformsToProtocol:@protocol(JLDefaultMapperProtocol)] == NO) return propertyDict;
    
    [(id<JLDefaultMapperProtocol>)entity setValueWithPropertyDict:propertyDict];
    return entity;
}
    

@end
