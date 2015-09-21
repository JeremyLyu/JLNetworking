# JLNetworking

Wiki还在搭建中，库的使用方法：请fork工程，然后查看Demo里面的用法

将库引用到项目

pod 'JLNetworking', :git => 'https://github.com/JeremyLyu/JLNetworking.git'


## Mapper

JLNetworkingReqResponseMapper协议，支持将网络请求的返回数据进行自定义处理后再传递给外部，比如
将返回NSDictionary对象转换成自定义类对象，以方便使用。

方法：在自己的网络请求类中实现 -(id<JLNetworkingReqResponseMapper>)responseMapper 方法
    
    -(id<JLNetworkingReqResponseMapper>)responseMapper
    {
        return [CustomMapper alloc] init];
    }

CustomMapper为实现了JLNetworkingReqResponseMapper协议的类

## 使用JLDefaultMapper

JLDefaultMapper是默认提供的mapper，能让您在编写网络交互的程序过程中更加身心愉悦。

它支持以下功能：

1.根据类名，将网络请求返回的数据处理成对应的类对象。

2.如果返回的数据为数组，则会根据类名将数据处理成对应的类对象数组

3.设置需要处理的内容在返回的数据中的路径。


