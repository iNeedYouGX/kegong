//
//  GXNetTool.m
//  GXAtlanticOceanCar
//  Copyright © 2016年 LGX. All rights reserved.
//

#import "GXNetTool.h"
#import "KCUtilMd5.h"

@interface GXNetTool()
@property (nonatomic, strong) AFHTTPSessionManager *manager;
@property (nonatomic, strong) NSString *urlPath;
@property (nonatomic, strong) id bodyParam;
@end

@implementation GXNetTool

+ (NSDictionary *)setupHeader
{
    NSString *CONSTANT_KEY = @"shop";
    NSString *timestamp = [self getNowTimeTimestamp3];
    NSString *MD5string = [KCUtilMd5 stringToMD5:[NSString stringWithFormat:@"%@%@", CONSTANT_KEY, timestamp]];
    // 获取UUID
    NSString *deviceUUID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSDictionary *paramHeader = @{
                                  @"timestamp" : timestamp,
//                                  @"sign" : MD5string,
//                                  @"token" : JPTOKEN ? JPTOKEN : @"",
//                                  @"uuid" : deviceUUID
                                  };
    return paramHeader;
}

+ (AFHTTPSessionManager *)GetNetWithUrl:(NSString *)url
                 body:(id)body
               header:(NSDictionary *)headers
             response:(GXResponseStyle)response
              success:(blockOfSuccess)success
              failure:(blockOfFailure)failure
{
    //(1)获取网络管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    //(2)请求头的设置
    headers = [self setupHeader];
    for (NSString *key in headers.allKeys) {
        [manager.requestSerializer setValue:headers[key] forHTTPHeaderField:key];
    }
    if (JPTOKEN != nil) {
        [manager.requestSerializer setValue:JPTOKEN forHTTPHeaderField:@"Cookie"];
    }

//    //cookies获取
//    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
//    NSArray *cookieArr = [cookieJar cookies];
//    for(NSHTTPCookie *cookie in cookieArr) {
////         获取cooker
//        NSMutableDictionary *properties = [[cookie properties] mutableCopy];
//        properties[NSHTTPCookieValue] = @"hahaha";
//        NSLog(@"---------%@", properties[NSHTTPCookieValue]);
//
//        NSLog(@"cookie －> %@", cookie);
//        NSLog(@"cookie.name －> %@", cookie.name);
//        NSLog(@"cookie.value －> %@", cookie.value);
//        if ([cookie.name isEqualToString:@"access_token"]) {
//            //存储cookies
//        }
////        存储之后删除cookies
//        [cookieJar deleteCookie:cookie];
////         修改cookies
//         [cookieJar setCookie:[NSHTTPCookie cookieWithProperties:properties]];
//    }


    
    //(3)设置返回数据的类型
    switch (response) {
        case GXResponseStyleJSON:
            manager.responseSerializer = [AFJSONResponseSerializer serializer];
            break;
        case GXResponseStyleXML:
            manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
            break;
        case GXResponseStyleDATA:
            manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            break;
            
        default:
            break;
    }

    //(4)设置数据响应类型
    [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/css",@"text/plain", @"application/javascript",@"image/jpeg", @"text/vnd.wap.wml", nil]];
    //(5)IOS9--UTF-8转码
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    //(6)发送请求
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithDictionary:body];
    [manager GET:url parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

        NSDictionary *result = responseObject;
        success([result deleteAllNullValue]);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure ? : failure(error);
        [CZProgressHUD hideAfterDelay:0];
        NSInteger codeStatus = [error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey] statusCode];
        NSLog(@"statusCode--%ld", codeStatus);
        if (codeStatus == 401) {
            CZLoginController *vc = [CZLoginController shareLoginController];
            UITabBarController *tabbar = (UITabBarController *)[[UIApplication sharedApplication].keyWindow rootViewController];
            UINavigationController *nav = tabbar.selectedViewController;
            UIViewController *currentVc = nav.topViewController;
            if (currentVc.navigationController.viewControllers.count > 0) {
                [currentVc.navigationController popViewControllerAnimated:YES];
            }
            if (nav.presentedViewController == nil) {
                [nav presentViewController:vc animated:YES completion:^{
                    [CZProgressHUD showProgressHUDWithText:@"请重新登录"];
                    [CZProgressHUD hideAfterDelay:2];
                }];
            }
        }
        NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        if (errorData) {
            NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
            NSLog(@"error--%@",serializedData);
        }

    }];
    return manager;
}


+ (void)PostNetWithUrl:(NSString *)url body:(id)body bodySytle:(GXRequsetStyle)bodyStyle header:(NSDictionary *)headers response:(GXResponseStyle)response success:(blockOfSuccess)success failure:(blockOfFailure)failure
{
    //(1)获取网络管理者
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager  manager] initWithBaseURL:[NSURL URLWithString:url]];
    
//    NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"apijipinchengcn" ofType:@"cer"];
//    NSData *certData = [NSData dataWithContentsOfFile:cerPath];
    
    //AFSSLPinningModeNone 这个模式表示不做 SSL pinning，只跟浏览器一样在系统的信任机构列表里验证服务端返回的证书。若证书是信任机构签发的就会通过，若是自己服务器生成的证书，这里是不会通过的。
    //AFSSLPinningModeCertificate 这个模式表示用证书绑定方式验证证书，需要客户端保存有服务端的证书拷贝，这里验证分两步，第一步验证证书的域名/有效期等信息，第二步是对比服务端返回的证书跟客户端返回的是否一致。
    //AFSSLPinningModePublicKey 这个模式同样是用证书绑定方式验证，客户端要有服务端的证书拷贝，只是验证时只验证证书里的公钥，不验证证书的有效期等信息。只要公钥是正确的，就能保证通信不会被窃听，因为中间人没有私钥，无法解开通过公钥加密的数据。
//    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
//    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModePublicKey];
//    if (certData) {
//        NSSet *cerSet = [[NSSet alloc]initWithObjects:certData, nil];
//        securityPolicy.pinnedCertificates = cerSet;
//    }
    
    // 不验证证书的域名NO, 如果是需要验证自建证书，需要设置为YES
//    securityPolicy.validatesDomainName = NO;
    // 是否允许无效证书（也就是自建的证书），默认为NO
//    如果是需要验证自建证书，需要设置为YES
//    securityPolicy.allowInvalidCertificates = YES;
//    manager.securityPolicy = securityPolicy;

    //设置body数据类型
    switch (bodyStyle) {
        case GXRequsetStyleBodyJSON:
             manager.requestSerializer = [AFJSONRequestSerializer serializer];
            break;
        case GXRequsetStyleBodyString:
            [manager.requestSerializer setQueryStringSerializationWithBlock:^NSString * _Nonnull(NSURLRequest * _Nonnull request, id  _Nonnull parameters, NSError * _Nullable * _Nullable error) {
                return parameters;
            }];
            break;
        case GXRequsetStyleBodyHTTP:
            manager.requestSerializer = [AFHTTPRequestSerializer serializer];
            break;

        default:
            break;
    }

    //cookies获取
//    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
//    NSArray *cookieArr = [cookieJar cookies];
//    for(NSHTTPCookie *cookie in cookieArr) {
//        NSLog(@"cookie －> %@", cookie);
//        NSLog(@"cookie.name －> %@", cookie.name);
//        NSLog(@"cookie.value －> %@", cookie.value);
//        if ([cookie.name isEqualToString:@"access_token"]) {
//            //存储cookies
//        }
//        //        存储之后删除cookies
//        [cookieJar deleteCookie:cookie];
//    }

    //(2)请求头的设置
    headers = [self setupHeader];
    for (NSString *key in headers.allKeys) {
        [manager.requestSerializer setValue:headers[key] forHTTPHeaderField:key];
    }
    if (JPTOKEN != nil) {
        [manager.requestSerializer setValue:JPTOKEN forHTTPHeaderField:@"Cookie"];
    }
    
    //(3)设置返回数据的类型
    switch (response) {
        case GXResponseStyleJSON:
            manager.responseSerializer = [AFJSONResponseSerializer serializer];
            break;
        case GXResponseStyleXML:
            manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
            break;
        case GXResponseStyleDATA:
            manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            break;
            
        default:
            break;
    }

    //(4)设置数据响应类型
    [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/css",@"text/plain", @"application/javascript",@"image/jpeg", @"text/vnd.wap.wml",@"application/xml", @"text/xml", nil]];
    //(5)IOS9--UTF-8转码
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    //加载菊花
//    [CZProgressHUD showProgressHUDWithText:nil];
    //(6)发送请求
   
    
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithDictionary:body];
    [manager POST:url parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

        // 除去NSNUll
        NSDictionary *result = responseObject;
        success([result deleteAllNullValue]);
        //隐藏菊花
//        [CZProgressHUD hideAfterDelay:0];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        !failure ? : failure(error);
        [CZProgressHUD hideAfterDelay:2];
        NSInteger codeStatus = [error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey] statusCode];
        NSLog(@"statusCode--%ld", codeStatus);
        
        if (codeStatus == 401) {
            CZLoginController *vc = [CZLoginController shareLoginController];
            UITabBarController *tabbar = (UITabBarController *)[[UIApplication sharedApplication].keyWindow rootViewController];
            UINavigationController *nav = tabbar.selectedViewController;
            UIViewController *currentVc = nav.topViewController;
            [currentVc.navigationController popViewControllerAnimated:YES];
            [nav presentViewController:vc animated:YES completion:^{
                [CZProgressHUD showProgressHUDWithText:@"请重新登录"];
                [CZProgressHUD hideAfterDelay:2];
            }];

        }
        NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        if (errorData != nil) {
            NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
            NSLog(@"error--%@",serializedData);
        }
    }];
}

#pragma mark - 上传文件
+ (void)uploadNetWithUrl:(NSString *)url body:(id)body fileSource:(id)fileSource success:(blockOfSuccess)success failure:(blockOfFailure)failure
{
    // 获取管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //(2)请求头的设置
    for (NSString *key in [self setupHeader].allKeys) {
        [manager.requestSerializer setValue:[self setupHeader][key] forHTTPHeaderField:key];
    }
    if (JPTOKEN != nil) {
        [manager.requestSerializer setValue:JPTOKEN forHTTPHeaderField:@"Cookie"];
    }
    //(3)设置返回数据的类型
    manager.responseSerializer = [AFJSONResponseSerializer serializer];


        
    //IOS9--UTF-8转码
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [manager POST:url parameters:body constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        if ([fileSource isKindOfClass:[UIImage class]]) {
            NSData *imageData = [UIImagePNGRepresentation(fileSource) length] > 102400 ?UIImageJPEGRepresentation(fileSource, 0.7) : UIImagePNGRepresentation(fileSource);
            [formData appendPartWithFileData:imageData name:@"file" fileName:@"imageFile.png" mimeType:@"image/png"];
        }
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = responseObject;
        success([result deleteAllNullValue]);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}

- (AFHTTPSessionManager *)manager
{
    if (_manager == nil) {
        _manager = [AFHTTPSessionManager  manager];
    }
    return _manager;
}

- (GXNetTool *(^)(NSString *))url
{
    return ^(NSString *entityUrl){
        entityUrl = [entityUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        self.urlPath = entityUrl;
        return self;
    };
}

- (GXNetTool *(^)(NSDictionary *))header
{
    GXNetTool * (^block)(NSDictionary *) = ^(NSDictionary *headers) {
        if (headers) {
            for (NSString *key in headers.allKeys) {
                [self.manager.requestSerializer setValue:headers[key] forHTTPHeaderField:key];
            }
        }
        return self;
    };
    return block;
}

- (GXNetTool *(^)(id))body
{
    return ^(id object){
        self.bodyParam = object;
        return self;
    };
}

- (GXNetTool *(^)(GXRequsetStyle))bodySytle
{
    return ^(GXRequsetStyle type) {
        //设置body数据类型
        switch (type) {
            case GXRequsetStyleBodyJSON:
                self.manager.requestSerializer = [AFJSONRequestSerializer serializer];
                break;
            case GXRequsetStyleBodyString:
                [self.manager.requestSerializer setQueryStringSerializationWithBlock:^NSString * _Nonnull(NSURLRequest * _Nonnull request, id  _Nonnull parameters, NSError * _Nullable * _Nullable error) {
                    return parameters;
                }];
                break;
            case GXRequsetStyleBodyHTTP:
                self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
                break;
                
            default:
                break;
        }
        return self;
    };
}

- (GXNetTool *(^)(GXResponseStyle))responseStyle
{
    return ^(GXResponseStyle type) {
        //(3)设置返回数据的类型
        switch (type) {
            case GXResponseStyleJSON:
                self.manager.responseSerializer = [AFJSONResponseSerializer serializer];
                break;
            case GXResponseStyleXML:
                self.manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
                break;
            case GXResponseStyleDATA:
                self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
                break;
                
            default:
                break;
        }
        return self;
    };
}


+ (void)netWorkMaker:(void (^)(GXNetTool *))maker success:(blockOfSuccess)success failure:(blockOfFailure)failure
{
    GXNetTool *tool = [[self alloc] init];
    maker(tool);
    [tool.manager POST:tool.urlPath parameters:tool.bodyParam progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
        NSLog(@"%@", error);
    }];
}

+ (NSString *)getNowTimeTimestamp3
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss SSS"]; // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    
    //设置时区,这个对于时间的处理有时很重要
    
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    
    [formatter setTimeZone:timeZone];
    
    NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式
    
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]*1000];
    
    return timeSp;
}

@end
