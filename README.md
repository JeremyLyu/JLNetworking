# JLNetworking

###### _(:3」∠)。。。Wiki不断完善中 

JLNetworking是基于AFNetworking封装的轻量级iOS网络库，希望提供一种对WebAPI方便、可靠的访问方式。
它的设计遵循“易用、简洁、易扩展”的思想。

### 感谢
感谢 [AFNetworking] 的维护人员 和 [田伟宇(Casa Taloyum)] 的无私工作与分享。

### 将JLNetworking引用到项目
1.建议使用CocoaPods，在您的工程的Podfile中添加以下代码即可

    pod 'JLNetworking', :git => 'https://github.com/JeremyLyu/JLNetworking.git'

2.将代码下载到本地，然后将Classes目录手动添加到您的工程中。由于是基于AFNetworking的封装，你的工程中需要引入
AFNetworking。

## 使用方法

您的每个网络请求都需要继承`JLNetworkingReq`类，并实现`JLNetworkingReqBase`协议中的必须方法，每个网络请求都是一个类对象。

  申明一个请求类

    @interface DemoReq : JLNetworkingReq <JLNetworkingReqBase>
    @end
    
    @implementation DemoReq

    - (NSString *)baseUrl
    {
        return @"http://www.kuaidi100.com";
    }

    - (NSString *)pathUrl
    {
        return @"query";
    }

    - (JLNetworkingRequestType)requestType
    {
        //是一个GET请求
        return JLNetworkingRequestTypeGet;
    }
    @end 

    //调用
    - (void)viewDidLoad
    {
        [super viewDidLoad];
        DemoReq *req = [DemoReq new];
        [req sendWithParams:@{@"type":@"shunfeng", @"postid":@(991849911763)} success:^(id responseObject) {
            NSLog(@"%@", responseObject);
        } failure:^(NSError *error) {
            NSLog(@"%@", error);
        }];
    }
    
  为了让调用者更加清晰的知道需要传入的参数，建议为网络请求类增加一个发起访问的方法

    - (void)sendWithType:(NSString *)type
                  postId:(NSNumber*)postId
                 success:(JLNetworkingCompletedBlock)success
                 failure:(JLNetworkingFailedBlock)failure
    {
        NSDictionary *params = @{@"type" : type,@"postid" : postId};
        [self sendWithParams:params success:success failure:failure];
    } 
    
    //调用
    - (void)viewDidLoad
    {
        [super viewDidLoad];
        DemoReq *req = [DemoReq new];
        [req sendWithType:@"shunfeng" postId:@(991849911763) success:^(id responseObject) {
            NSLog(@"%@", responseObject);
        } failure:^(NSError *error){
            NSLog(@"%@", error);
        }];
    }

#### 添加Header

很多WebAPI要求把一些信息放在Header里面的，只需为请求对象设置header属性即可

    @implementation DemoReq

    - (instancetype)init
    {
        self = [super init];
        if(self)
        {
            self.headerDict = @{@"apikey" : @"98f826217b723c9834f341a810e1a67c"};
        }
        return self;
    }

    - (NSString *)baseUrl
    {
        return @"http://apis.baidu.com";
    }

    - (NSString *)pathUrl
    {
        return @"apistore/idservice/id";
    }

    - (void)sendWithId:(NSNumber *)idNum
    success:(JLNetworkingCompletedBlock)success
    failure:(JLNetworkingFailedBlock)failure
    {
        NSDictionary *params = @{@"id" : idNum};
        [self sendWithParams:params success:success failure:failure];
    }

    @end
    
    //调用
    - (void)viewDidLoad
    {
        [super viewDidLoad];
        DemoReq *req = [DemoReq new];
        //也可以在外部设置 req.headerDict = @{@"apikey" : @"98f826217b723c9834f341a810e1a67c"};
        [req sendWithId:@(420106198708257767) success:^(id responseObject) {
            NSLog(@"%@", responseObject);
        } failure:^(NSError *error) {
            NSLog(@"%@", error);
        }];
    }
    
#### 上传数据或文件

一个`JLNetworkingMutiDataObj`对象，对应一份需要上传的 数据/文件 信息。默认 mimeType 为 image/jpg，fileName 为 file.jpg，支持一次上传一组数据。

    - (void)viewDidLoad
    {
        NSString *avatarPath = [[NSBundle mainBundle] pathForResource:@"avatar" ofType:@"jpg"];
        JLNetworkingMultiDataObj *uploadObj = [JLNetworkingMultiData obj new];
        uploadObj.name = @"avatar";
        //如果数据太大也建议是用filePath的方式
        //updataObj.filePath = avatarPath;
        uploadObj.data = [NSData dataWithContentsOfFile:avatarPath];;

        DemoReq *req = [DemoReq new];
        [req sendWithParams:@{@"userId" : @"123456789"} multipartFormData:uploadObj success:^(id responseObject) {
            NSLog(@"%@", responseObject);
        } failure:^(NSError *error) {
            NSLog(@"%@", error);
        }];
    }

#### 其他的功能

除开上面的那些基础请求功能外，`JLNetworkingReq`的对象还支持 设置请求超时、参数校验、返回数据校验、参数签名、钩子方法和返回数据映射。这里就不一一描述，您可以通过查看Demo，来了解它们的具体用法。

## Mapper

`JLNetworkingReqResponseMapper`协议，支持将网络请求的返回数据进行自定义处理后再传递给外部，比如
将返回NSDictionary对象转换成自定义类对象，以方便使用。

用法：在网络请求类中实现responseMapper方法
    
    -(id<JLNetworkingReqResponseMapper>)responseMapper
    {
        //CustomMapper为实现了JLNetworkingReqResponseMapper协议的类
        return [CustomMapper alloc] init];
    }

### 使用JLDefaultMapper

`JLDefaultMapper`是默认提供的mapper，能让您在编写网络交互代码时更加安逸。

它支持以下功能：

1.根据类名，将网络请求返回的数据处理成对应的类对象。

2.如果返回的数据为数组，则会根据类名将数据处理成对应的类对象数组

3.设置需要处理的内容在返回的数据中的路径。

4.利用CocoaPods机制，默认支持了[JSONModel]和[Mantle]


用法：在网络请求类中实现responseMapper方法，并返回`JLDefaultMapper`对象

    -(id<JLNetworkingReqResponseMapper>)responseMapper
    {
        //Entity为实现了JLDefaultMapperProtocol协议的类
        return [JLDefaultMapper mapperWithClassName:NSStringFromClass([Entity class])];
    }
设置处理数据的路径：`JLDefaultMapper`默认会将返回的NSDictionary下data字段对应的数据进行处理，但是有时候实际数据会放在各种千奇百怪的地方，这个时候就需要您自己设置数据路径。

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

如果您在使用[JSONModel]或者[Mantle]，并且使用了CocoaPods将它们引用到工程中。那么JLDefaultMapper已经默认支持将返回数据映射
成JSModel或Mantle的子类对象，不需要您编写相关的支持代码代码。

    -(id<JLNetworkingReqResponseMapper>)responseMapper
    {
        //Model为JSONModel或MTLModel的子类
        return [JLDefaultMapper mapperWithClassName:NSStringFromClass([Model class])];
    }
使用CocoaPods为工程引入JSONModel和Mantle，只需在Podfile增加如下两行

    pod "JSONModel"
    pod "Mantle"

如果您不是使用CocoaPods的方式将JSONModel或者Mantle引用到工程，但是又希望JLDefaultMapper能对它们进行支持，那么只需为JSONModel或Mantel增加一个实现JLDefautMapperProtocol的扩展，或者在在它们的子类实现这个协议即可。

##### 更灵活的映射方式

有时候，我们希望能对返回数据做更灵活的处理，可以转化成任意的类型传递给外部，`JLDefaultMapper`提供更灵活的方式

    - (id<JLNetworkingReqResponseMapper>)responseMapper
    {
        /*WebAPI返回的数据
        {
            retData =     {
                address = "某省某市某街道某号";
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

## 支持作者

点击页面顶部的 `★star` 或提交 `Issues` `Pull requests`，会给作者带来极大鼓舞 (｡・`ω´･)

<!-- external links -->
[AFNetworking]:https://github.com/AFNetworking/AFNetworking
[田伟宇(Casa Taloyum)]:http://casatwy.com/pages/about-me.html
[JSONModel]:https://github.com/icanzilb/JSONModel
[Mantle]:https://github.com/Mantle/Mantle
