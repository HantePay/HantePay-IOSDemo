//
//  ViewController.m
//  HantePayDemo_iOS
//
//  Created by 钟亮 on 2019/1/7.
//  Copyright © 2019 zhongliang. All rights reserved.
//

#import "ViewController.h"
#import <AlipaySDK/AlipaySDK.h>
#import "HantePayOrder.h"
#import "WXApiManager.h"
#import "WXApi.h"
@interface ViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *alipayActionBtn;
@property (weak, nonatomic) IBOutlet UIButton *wechatpayActionBtn;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.amountTF.delegate = self;
    self.referenceTF.text = [self generateReference];
    self.referenceTF.enabled = YES;
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)getReference:(id)sender {
    
    self.referenceTF.text = [self generateReference];
}

- (IBAction)payAction:(UIButton *)sender {
    
    if ([self.amountTF.text floatValue] <= 0) {
        [self showAlertWithTitle:nil Message:@"请输入非零金额" CompletionHandler:nil];
        return;
    }

    //Init HantePay object
    // HantePay API Token should be stored on the server side
    
    HantePayOrder *hanteOrder = [[HantePayOrder alloc] initWithAPIinfo:@"https://api.hantepay.cn/v1.3/transactions/app/pay" addToken:@"123456"];

    //order info
    hanteOrder.amount = [NSString stringWithFormat:@"%@",@([self.amountTF.text floatValue] * 100)];  //The unit is cents     E.g 1 = $0.01
    hanteOrder.currency = @"USD";
    hanteOrder.reference = self.referenceTF.text;
    hanteOrder.ipnUrl = @"http://www.hante.com";
    hanteOrder.note = @"note for merchant";
    hanteOrder.desc = @"Product Description";
    NSString *appScheme = @"hantepaydemo";
    
    if (sender == self.wechatpayActionBtn) {
        hanteOrder.vender = @"wechatpay";
    }else{
        hanteOrder.vender = @"alipay";
    }
    [hanteOrder doPostWithBlock:^(NSDictionary *dic) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (sender == self.wechatpayActionBtn) {
                [self paySting:[dic objectForKey:@"orderInfo"]];
            }else{
                [[AlipaySDK defaultService] payOrder:dic[@"orderInfo"] fromScheme:appScheme callback:^(NSDictionary *resultDic) {
                    
                    NSLog(@"result = %@",resultDic);
                    
                }];
                
            }
 
        });
        
    }];
    
}
//generate reference to HantePay (only Demo), merchant can use their orderid
- (NSString *)generateReference
{
    static int kNumber = 6;
    NSDate *date= [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *dateString = [dateFormatter stringFromDate:date];
    
    NSString *sourceStr = @"abcdefghijklmnopqrstuvwxyz";
    NSMutableString *resultStr = [[NSMutableString alloc] init];
    srand((unsigned)time(0));
    for (int i = 0; i < kNumber; i++)
    {
        unsigned index = rand() % [sourceStr length];
        NSString *oneStr = [sourceStr substringWithRange:NSMakeRange(index, 1)];
        [resultStr appendString:oneStr];
    }
    return [dateString stringByAppendingString: resultStr];
}

- (void)showAlertWithTitle:( NSString * _Nullable )title Message:(NSString *)message CompletionHandler:(CompletionHandler)completionHandler{
    [self showAlertWithTitle:title Message:message CompletionHandler:completionHandler CancelHandler:nil];
}

- (void)showAlertWithTitle:( NSString * _Nullable )title Message:(NSString *)message CompletionHandler:(CompletionHandler)completionHandler CancelHandler:(CompletionHandler _Nullable)cancelHandler{
    __weak typeof(self) weakSelf = self;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    if (cancelHandler) {
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
            cancelHandler();
        }]];
    }
    
    [alert addAction:[UIAlertAction actionWithTitle:@"" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        if (completionHandler) {
            completionHandler();
        }

    }]];
    
    [weakSelf presentViewController:alert animated:YES completion:nil];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}


- (void)paySting:(NSString *)string{
    NSDictionary *dict = [self dictionaryWithJsonString:string];
    NSMutableString *stamp  = [dict objectForKey:@"timestamp"];
    
    //调起微信支付
    PayReq* req             = [[PayReq alloc] init];
    req.partnerId           = [dict objectForKey:@"partnerid"];
    req.prepayId            = [dict objectForKey:@"prepayid"];
    req.nonceStr            = [dict objectForKey:@"noncestr"];
    req.timeStamp           = stamp.intValue;
    req.package             = [dict objectForKey:@"package"];
    req.sign                = [dict objectForKey:@"sign"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [WXApi sendReq:req];
    });
    
}
- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if ([string isEqualToString:@""]) {
        return [string isEqualToString:@""];
    }
    NSString *oldAmountStr = textField.text;
    NSString * amountStr = @"";
    
    BOOL  isHaveDian = [textField.text rangeOfString:@"."].location != NSNotFound;
    
    if ([oldAmountStr isEqualToString:@"0.00"]){
        oldAmountStr = @"";
    }
    unichar single = [string characterAtIndex:0];
    
    if ((single >= '0' && single <= '9') || single == '.'){
        
        if (single == '.') {
            if (!isHaveDian){
                
                if (oldAmountStr.length == 0){
                    amountStr = @"0.";
                }else {
                    amountStr = [oldAmountStr stringByAppendingString:@"."];
                }
                
            }else {
                
                amountStr = oldAmountStr;
                
            }
        }else{
            
            if (isHaveDian){
                
                NSRange ran = [oldAmountStr rangeOfString:@"."];
                
                
                if ((oldAmountStr.length - ran.location == 3) && [oldAmountStr floatValue] != 0){
                    amountStr = oldAmountStr;
                }
                else if (oldAmountStr.length == 0 && [string isEqualToString:@"0"]){
                    amountStr = @"0.";
                }else {
                    amountStr = [oldAmountStr stringByAppendingString:string];
                }
                
            }else {
                if (oldAmountStr.length == 0){
                    if ([string isEqualToString:@"0"]){
                        amountStr = @"0.";
                    }else {
                        amountStr = [oldAmountStr stringByAppendingString:string];
                    }
                }else {
                    amountStr = [oldAmountStr stringByAppendingString:string];
                    
                }
            }
        }
        
        if ([amountStr doubleValue] > 10000.00) {
            amountStr = [NSString stringWithFormat:@"%.2f",10000.00] ;
        }
        
        textField.text = amountStr;
        
    }
    return NO;
    
}

@end
