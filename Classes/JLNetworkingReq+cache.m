//
//  JLNetworkingReq+cache.m
//  JLNetworking
//
//  Created by jeremyLyu on 16/5/8.
//  Copyright © 2016年 jeremyLyu. All rights reserved.
//

#import "JLNetworkingReq+cache.h"
#import "JLNetSupport.h"

@implementation JLNetworkingReq (cache)

- (id)responseObjectFromCache {
    id responseObject = nil;
    if ([self cacheEnabled]) {
        NSTimeInterval maxExistenceTime = [(id<JLNetworkingReqBase>)self cacheMaxExistenceTime];
        if (maxExistenceTime > 0) {
            NSString *path = [self cacheFilePath];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if ([fileManager fileExistsAtPath:path]) {
                //检查是否过期
                NSTimeInterval exitenceTime = [self cacheExistenceTimeWithPath:path];
                if (exitenceTime >= 0 && exitenceTime < maxExistenceTime) {
                    responseObject = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
                } else {
                    NSLog(@"缓存过期");
                }
            }
        }
    }
    return responseObject;
}

- (void)storeResponseObject:(id)responseObject {
    if ([self cacheEnabled]) {
        NSTimeInterval maxExistenceTime = [(id<JLNetworkingReqBase>)self cacheMaxExistenceTime];
        if (maxExistenceTime > 0) {
            if([responseObject isKindOfClass:[NSDictionary class]]) {
                [NSKeyedArchiver archiveRootObject:responseObject toFile:[self cacheFilePath]];
            }
        }
    }
}

- (BOOL)cacheEnabled {
    return [(id<JLNetworkingReqBase>)self respondsToSelector:@selector(cacheMaxExistenceTime)];
}


#pragma mark - cache file control
- (NSTimeInterval)cacheExistenceTimeWithPath:(NSString *)cacheFilePath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSDictionary *attributes = [fileManager attributesOfItemAtPath:cacheFilePath error:&error];
    if (attributes == nil) {
        NSLog(@"获取缓存存在时间失败，Error:%@", error);
        return -1;
    }
    return [[NSDate date] timeIntervalSinceDate:[attributes fileModificationDate]];
}

- (NSString *)cacheFilePath {
    NSString *cacheFilePath = nil;
    NSString *basePath = [self cacheBasePath];
    if (basePath) {
        NSString *fileName = [self cacheFileName];
        if (fileName) {
            cacheFilePath = [basePath stringByAppendingPathComponent:fileName];
        }
    }
    return cacheFilePath;
}

- (NSString *)cacheFileName {
    id<JLNetworkingReqBase> request = (id<JLNetworkingReqBase>)self;
    NSURL *baseUrl = [NSURL URLWithString:[request baseUrl]];
    NSString *URLString = [[NSURL URLWithString:[request pathUrl] relativeToURL:baseUrl] absoluteString];
    long requestType = [request requestType];
    NSDictionary *params = self.params;
    NSString *appVersion = [JLNetSupport appVersion];
    NSString *requestInfo = [NSString stringWithFormat:@"Type:%ld URL:%@ Params:%@ AppVersion:%@", requestType, URLString, params, appVersion];
    NSString *cacheFileName = [JLNetSupport md5StringWithString:requestInfo];
    return cacheFileName;
}

- (NSString *)cacheBasePath {
    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *basePath = [libraryPath stringByAppendingPathComponent:@"JLNetworkingReqCache"];
    //判断缓存目录存在与否，不存在就创建
    BOOL isDir;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    if([fileManager fileExistsAtPath:basePath isDirectory:&isDir] == NO) {
        error = [self createDirWithPath:basePath];
    } else {
        if(isDir == NO) {
            [fileManager removeItemAtPath:basePath error:nil];
            error = [self createDirWithPath:basePath];
        }
    }
    if(error) {
        NSLog(@"获取网络请求缓存根目录失败，Error:%@", error);
        return nil;
    }
    return basePath;
}

- (NSError *)createDirWithPath:(NSString *)path {
    NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
    return error;
}
@end
