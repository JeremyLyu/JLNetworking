//
//  JLNetworkingReq+cache.h
//  JLNetworking
//
//  Created by jeremyLyu on 16/5/8.
//  Copyright © 2016年 jeremyLyu. All rights reserved.
//

#import "JLNetworkingReq.h"

@interface JLNetworkingReq (cache) 

- (BOOL)cacheEnabled;

- (id)responseObjectFromCache;

- (void)storeResponseObject:(id)responseObject;

@end
