//
//  ViewController.m
//  GetAddressBookInfo
//
//  Created by apple on 17/2/24.
//  Copyright © 2017年 Wang. All rights reserved.
//

#import "ViewController.h"
#import "AddressBookHelper.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    AddressBookHelper *addressBook = [[AddressBookHelper alloc]init];
    [addressBook getAddressBookPersonalInfoFromVC:self completionHandler:^(NSDictionary *data) {
        [self showAlertWithMessage:[NSString stringWithFormat:@"%@,%@",data[@"name"],data[@"phone"]]];
    }];

}
- (void)showAlertWithMessage:(NSString *)message{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    
}

@end
