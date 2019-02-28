//
//  HantePayOrder.h
//  HantePayDemo_iOS
//
//  Created by 钟亮 on 2019/1/7.
//  Copyright © 2019 zhongliang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HantePayOrder : NSObject

@property(nonatomic, copy) NSString * hanteApiUrl;// HantePay Api Url
@property(nonatomic, copy) NSString * hanteApiToken;// HantePay Api Token
@property(nonatomic, copy) NSString * vender;
@property(nonatomic, copy) NSString * reference;
@property(nonatomic, copy) NSString * amount;
@property(nonatomic, copy) NSString * currency;
@property(nonatomic, copy) NSString * ipnUrl;
@property(nonatomic, copy) NSString * desc;//Optional
@property(nonatomic, copy) NSString * note; //Optional
- (NSString *)requestParamsSting;
-(instancetype)initWithAPIinfo:(NSString *)apiUrl addToken:(NSString *)apiToken;

-(void) doPostWithBlock:(void (^)(NSDictionary *dic))block;
@end

NS_ASSUME_NONNULL_END
