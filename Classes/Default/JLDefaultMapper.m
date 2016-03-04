//
//  JLNetworkingDefaultMapper.m
//  JLNetworking
//
//  Created by jeremyLyu on 15/9/1.
//  Copyright (c) 2015年 jeremyLyu. All rights reserved.
//

#import "JLDefaultMapper.h"

@interface JLDefaultMapper ()
@property (nonatomic, strong) NSString *className;
@property (nonatomic, strong) NSString *dataPath;
@property (nonatomic, copy) id(^transformer)(id responseObject);
@end

@implementation JLDefaultMapper

+ (instancetype)mapperWithClassName:(NSString *)className
{
    return [JLDefaultMapper mapperWithClassName:className dataPath:@"data"];
}

+ (instancetype)mapperWithClassName:(NSString *)className dataPath:(NSString *)dataPath
{
    if(className == nil) return nil;
    JLDefaultMapper *mapper = [JLDefaultMapper new];
    mapper.dataPath = dataPath;
    mapper.className = className;
    return mapper;
}

+ (instancetype)mapperWithTransformer:(id(^)(id responseObject))transformer
{
    JLDefaultMapper *mapper = [JLDefaultMapper new];
    mapper.transformer = transformer;
    return mapper;
}

#pragma mark - JLNetworkingReqResponseMapper

- (id)req:(JLNetworkingReq *)req mapResponseObject:(id)responseObject
{
    //block的方法
    if(self.transformer)
    {
        return self.transformer(responseObject);
    }
    //类名映射entity的方式
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
                //生成数组逻辑
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
        else
        {
            NSLog(@"未能找到正确的数据块，请检查设置的dataPath是否正确");
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
    
    if([entityClass conformsToProtocol:@protocol(JLDefaultMapperProtocol)] == NO) return propertyDict;
    id entity = [[entityClass alloc] entityWithDictionary:propertyDict];
    entity = entity == nil ? propertyDict : entity;
    return entity;
}
    

@end
