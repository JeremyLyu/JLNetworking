//
//  JLDefaultBaseReq.m
//  JLNetworking
//
//  Created by JeremyLyu on 16/3/4.
//  Copyright © 2016年 jeremyLyu. All rights reserved.
//

#import "JLDefaultBaseReq.h"
#import "JLDefaultMapper.h"

@implementation JLDefaultBaseReq
- (instancetype)init {
    self = [super init];
    if(self) {
        self.baseURL = @"";
        self.pathURL = @"";
        self.dataPath = @"data";
    }
    return self;
}

- (NSString *)baseUrl {
    return self.baseURL;
}

- (NSString *)pathUrl {
    return self.pathURL;
}

- (JLNetworkingRequestType)requestType {
    return JLNetworkingRequestTypePost;
}

#pragma mark - Response
//判断业务是否正确
/* 以下代码，请在自己的实际业务基类中自定义实现
- (NSError *)makeSuccessToFailureWithResponseObject:(id)reponseObject {
    NSNumber *ret = reponseObject[@"ret"];
    if (ret == nil) {
        NSAssert(0, @"接口返回内容错误");
    }
    if([ret isEqualToNumber:@(1)]) return nil;
    NSString *msg = reponseObject[@"msg"] ? reponseObject[@"msg"] : @"";
    return [NSError errorWithDomain:NSStringFromClass([self class]) code:ret.integerValue userInfo:@{NSLocalizedDescriptionKey : msg}];
}
 */

@end
