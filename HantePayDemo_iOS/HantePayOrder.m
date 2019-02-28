//
//  HantePayOrder.m
//  HantePayDemo_iOS
//
//  Created by 钟亮 on 2019/1/7.
//  Copyright © 2019 zhongliang. All rights reserved.
//

#import "HantePayOrder.h"

@implementation HantePayOrder
-(instancetype)initWithAPIinfo:(NSString *)apiUrl addToken:(NSString *)apiToken{
    self=[super init];
    if(apiUrl == nil || apiToken == nil){
        NSException* exception = [NSException exceptionWithName:@"HantePay Exception" reason:@"apiUrl or apiToken is null" userInfo:nil];
        @throw exception;
    }
    self.hanteApiUrl = apiUrl;
    self.hanteApiToken = apiToken;
    return self;
}
- (NSString *)requestParamsSting {
    NSMutableString * description = [NSMutableString string];
    
    if(self.amount){
        [description appendFormat:@"amount=%@", self.amount];
    }
    
    if(self.currency){
        [description appendFormat:@"&currency=%@", self.currency];
    }
    
    if(self.ipnUrl){
        [description appendFormat:@"&ipn_url=%@", self.ipnUrl];
    }
    
    if(self.reference){
        [description appendFormat:@"&reference=%@", self.reference];
    }
    
    if(self.note){
        [description appendFormat:@"&note=%@", self.note];
    }
    
    if(self.desc){
        [description appendFormat:@"&description=%@", self.desc];
    }
    if(self.vender){
        [description appendFormat:@"&vender=%@", self.vender];
    }
    
    NSLog(@"request HantePay params: %@",description);
    
    return description;
}

- (NSDictionary *)requestParamsDic{
    return @{@"amount":self.amount,
             @"currency":self.currency,
             @"ipn_url":self.ipnUrl,
             @"reference":self.reference,
             @"note":self.note,
             @"description":self.desc,
             @"vendor":self.vender,
             };
}


-(void)doPostWithBlock:(void (^)(NSDictionary *dic))block{
    
    NSString *payUrl=[NSString stringWithFormat:@"%@",self.hanteApiUrl];
    
    
    payUrl = [payUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest * request= [[NSMutableURLRequest alloc] initWithURL:[[NSURL alloc] initWithString:payUrl]];
    
    request.HTTPMethod = @"POST";
    
    request.allHTTPHeaderFields = @{@"Authorization":[NSString stringWithFormat:@"Bearer %@",self.hanteApiToken],@"Content-Type": @"application/json"};
    
    //    NSString *string = [self requestParams];
    //
    //    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *dic = [self requestParamsDic];
    
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    
    request.HTTPBody = data;
    
    request.timeoutInterval = 20;
    
    NSURLSession * session= [NSURLSession sharedSession];
    
    NSURLSessionDataTask * task= [session dataTaskWithRequest:request  completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSMutableDictionary * dic=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        
        NSLog(@"Generate order results：%@\n%@\n%@",dic,response,error);
        
        block(dic);
        
    }];
    
    
    [task resume];
    
    
}

@end
