//
//  ViewController.h
//  HantePayDemo_iOS
//
//  Created by 钟亮 on 2019/1/7.
//  Copyright © 2019 zhongliang. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^CompletionHandler)(void);
@interface ViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *amountTF;
@property (weak, nonatomic) IBOutlet UITextField *referenceTF;


@end

