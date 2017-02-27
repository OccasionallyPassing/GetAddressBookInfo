//
//  AddressBookHelper.h
//  GetAddressBookInfo
//
//  Created by apple on 17/2/24.
//  Copyright © 2017年 Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^PersonalInfoBlock)(NSDictionary *data);
@interface AddressBookHelper : NSObject

- (void)getAddressBookPersonalInfoFromVC:(UIViewController *)fromVC
                       completionHandler:(PersonalInfoBlock) completionHandler;

@end
