//
//  NSObject+DLIntrospection.m
//  JLNetworking
//
//  Created by jeremyLyu on 15/9/1.
//  Copyright (c) 2015年 jeremyLyu. All rights reserved.
//

#import "NSObject+DLIntrospection.h"
#import <objc/runtime.h>

@interface NSString (DLIntrospection)

+ (NSString *)decodeType:(const char *)cString;

@end

@implementation NSString (DLIntrospection)

//https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
+ (NSString *)decodeType:(const char *)cString {
    if (!strcmp(cString, @encode(id))) return @"id";
    if (!strcmp(cString, @encode(void))) return @"void";
    if (!strcmp(cString, @encode(float))) return @"float";
    if (!strcmp(cString, @encode(int))) return @"int";
    if (!strcmp(cString, @encode(BOOL))) return @"BOOL";
    if (!strcmp(cString, @encode(char *))) return @"char *";
    if (!strcmp(cString, @encode(double))) return @"double";
    if (!strcmp(cString, @encode(Class))) return @"class";
    if (!strcmp(cString, @encode(SEL))) return @"SEL";
    if (!strcmp(cString, @encode(unsigned int))) return @"unsigned int";
    
    //@TODO: do handle bitmasks
    NSString *result = [NSString stringWithCString:cString encoding:NSUTF8StringEncoding];
    if ([[result substringToIndex:1] isEqualToString:@"@"] && [result rangeOfString:@"?"].location == NSNotFound) {
        result = [[result substringWithRange:NSMakeRange(2, result.length - 3)] stringByAppendingString:@""];
    } else
        if ([[result substringToIndex:1] isEqualToString:@"^"]) {
            result = [NSString stringWithFormat:@"%@ *",
                      [NSString decodeType:[[result substringFromIndex:1] cStringUsingEncoding:NSUTF8StringEncoding]]];
        }
    return result;
}

@end

static void getSuper(Class class, NSMutableString *result) {
    [result appendFormat:@" -> %@", NSStringFromClass(class)];
    if ([class superclass]) { getSuper([class superclass], result); }
}


@implementation NSObject (DLIntrospection)
+( NSArray *)classes {
    unsigned int classesCount;
    Class *classes = objc_copyClassList(&classesCount);
    NSMutableArray *result = [NSMutableArray array];
    for (int i = 0 ; i < classesCount; i++) {
        [result addObject:NSStringFromClass(classes[i])];
    }
    return [result sortedArrayUsingSelector:@selector(compare:)];
}



+ (NSArray *)properties {
    unsigned int outCount;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    NSMutableArray *result = [NSMutableArray array];
    for (int i = 0; i < outCount; i++) {
        [result addObject:[self formattedPropery:properties[i]]];
    }
    free(properties);
    return result.count ? [result copy] : nil;
}


+ (NSString *)parentClassHierarchy {
    NSMutableString *result = [NSMutableString string];
    getSuper([self class], result);
    return result;
}


#pragma mark - Private

+ (NSString *)formattedPropery:(objc_property_t)prop {
    unsigned int attrCount;
    objc_property_attribute_t *attrs = property_copyAttributeList(prop, &attrCount);
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    for (int idx = 0; idx < attrCount; idx++) {
        NSString *name = [NSString stringWithCString:attrs[idx].name encoding:NSUTF8StringEncoding];
        if ([name isEqualToString:@"hash"]) continue;
        else if ([name isEqualToString:@"superclass"]) continue;
        else if ([name isEqualToString:@"description"]) continue;
        else if ([name isEqualToString:@"debugDescription"]) continue;
        NSString *value = [NSString stringWithCString:attrs[idx].value encoding:NSUTF8StringEncoding];
        [attributes setObject:value forKey:name];
    }
    free(attrs);
    NSMutableString *property = [[NSMutableString alloc]init];
    
    
    NSMutableArray *attrsArray = [NSMutableArray array];
    
    //https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html#//apple_ref/doc/uid/TP40008048-CH101-SW5
    [attrsArray addObject:[attributes objectForKey:@"N"] ? @"nonatomic" : @"atomic"];
    
    if ([attributes objectForKey:@"&"]) {
        [attrsArray addObject:@"strong"];
    } else if ([attributes objectForKey:@"C"]) {
        [attrsArray addObject:@"copy"];
    } else if ([attributes objectForKey:@"W"]) {
        [attrsArray addObject:@"weak"];
    } else {
        [attrsArray addObject:@"assign"];
    }
    if ([attributes objectForKey:@"R"]) {[attrsArray addObject:@"readonly"];}
    if ([attributes objectForKey:@"G"]) {
        [attrsArray addObject:[NSString stringWithFormat:@"getter=%@", [attributes objectForKey:@"G"]]];
    }
    if ([attributes objectForKey:@"S"]) {
        [attrsArray addObject:[NSString stringWithFormat:@"setter=%@", [attributes objectForKey:@"G"]]];
    }
    
    [property appendFormat:@"%@,%@",
     //[attrsArray componentsJoinedByString:@", "],
     [NSString decodeType:[[attributes objectForKey:@"T"] cStringUsingEncoding:NSUTF8StringEncoding]],
     [NSString stringWithCString:property_getName(prop) encoding:NSUTF8StringEncoding]];
    return [property copy];
}
@end
