# JLNetworking

Wiki还在搭建中，库的使用方法：请fork工程，然后查看Demo里面的用法

将库引用到项目

pod 'JLNetworking', :git => 'https://github.com/JeremyLyu/JLNetworking.git'


## Mapper

JLNetworkingReqResponseMapper协议，支持将网络请求的返回数据进行自定义处理后再传递给外部，比如
将返回NSDictionary对象转换成自定义类对象，以方便使用。

用法：在网络请求类中实现responseMapper方法
    
    -(id<JLNetworkingReqResponseMapper>)responseMapper
    {
        //CustomMapper为实现了JLNetworkingReqResponseMapper协议的类
        return [CustomMapper alloc] init];
    }


### 使用JLDefaultMapper

JLDefaultMapper是默认提供的mapper，能让您在编写网络交互代码时更加安逸。

它支持以下功能：

1.根据类名，将网络请求返回的数据处理成对应的类对象。

2.如果返回的数据为数组，则会根据类名将数据处理成对应的类对象数组

3.设置需要处理的内容在返回的数据中的路径。

4.利用CocoaPods机制，默认支持了JSONModel和Mantle


用法：在网络请求类中实现responseMapper方法，并return JLDefaultMapper对象

    -(id<JLNetworkingReqResponseMapper>)responseMapper
    {
        //Entity为实现了JLDefaultMapperProtocol协议的类
        return [JLDefaultMapper mapperWithClassName:NSStringFromClass([Entity class])];
    }
设置处理数据的路径：JLDefaultMapper默认会将返回的NSDictionary下data字段对应的数据进行处理，但是有时候实际数据会放在各种千奇百怪的地方，这个时候就需要您自己设置数据路径。

假设当前访问的WebAPI返回数据如下

    {
        message: "成功",
        code: 200,
        data: {
            desc: "这是一个人的数据",
            info: {
                name: "小明",
                sex: "M",
                age: 16,
                sexualOrientation: "M"
            }
        }
    }
显然需要映射成类对象的数据在info字段下，则只需要如下使用:

    -(id<JLNetworkingReqResponseMapper>)responseMapper
    {
        //Entity为实现了JLDefaultMapperProtocol协议的类
        return [JLDefaultMapper mapperWithClassName:NSStringFromClass([Entity class]) dataPath:@"data.info"];
    }

##### 对JSONModel与Mantle的支持

如果您在使用JSONModel或者Mantle，并且使用了CocoaPods将它们引用到工程中。那么JLDefaultMapper已经默认支持将返回数据映射
成JSModel或Mantle的子类对象，不需要您编写相关的支持代码代码。

    -(id<JLNetworkingReqResponseMapper>)responseMapper
    {
        //Model为JSONModel或MTLModel的子类
        return [JLDefaultMapper mapperWithClassName:NSStringFromClass([Model class])];
    }
使用CocoaPods为工程引入JSONModel和MTLModel，只需在Podfile增加如下两行

    pod "JSONModel"
    pod "Mantle"

如果您不是使用CocoaPods的方式将JSONModel或者Mantle引用到工程，但是又希望JLDefaultMapper能对它们进行支持，那么只需为JSONModel或Mantel增加一个实现JLDefautMapperProtocol的扩展，或者在在它们的子类实现这个协议即可。

##### 更灵活的映射方式

有时候，我们希望能对返回数据做更灵活的处理，可以转化成任意的类型传递给外部，JLDefaultMapper提供更灵活的方式

    - (id<JLNetworkingReqResponseMapper>)responseMapper
    {
        /*WebAPI返回的数据
        {
            retData =     {
                address = "\U6e56\U5317\U7701\U6b66\U6c49\U5e02\U6b66\U660c\U533a";
                birthday = "1987-08-25";
                sex = F;
            };
            retMsg = success;
        }
        */

        return [JLDefaultMapper mapperWithTransformer:^id(id responseObject) {
            NSString *birth = responseObject[@"retData"][@"birthday"];
            return [NSString stringWithFormat:@"生日是:%@", birth];
        }];
    }
如果请求成功，则返回给外部的数据为 @"生日是 1987-08-25"。

