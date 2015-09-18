//
//  DemoEntity.h
//  JLNetworking
//
//  Created by jeremyLyu on 15/9/1.
//  Copyright (c) 2015年 jeremyLyu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JSONModel.h>

@interface DemoEntity : JSONModel

@property (nonatomic, strong) NSString *context;
@property (nonatomic, strong) NSString *ftime;
@property (nonatomic, strong) NSString *time;
@end

@interface DemoEntity1 : JSONModel
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *birthday;
@property (nonatomic, strong) NSString *sex;
@end
