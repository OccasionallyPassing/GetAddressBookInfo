//
//  AddressBookHelper.m
//  GetAddressBookInfo
//
//  Created by apple on 17/2/24.
//  Copyright © 2017年 Wang. All rights reserved.
//

#import "AddressBookHelper.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <ContactsUI/ContactsUI.h>
#import <objc/runtime.h>

#define IS_UP_IOS9  ([[UIDevice currentDevice].systemVersion floatValue]) >= 9.0
NSString *const ADDRESSBOOKHELPER_BINDING_KEY = @"com.fengguowangluo.AddressBookHelperBindingKey";

@interface AddressBookHelper()<ABPeoplePickerNavigationControllerDelegate,CNContactPickerDelegate>
@property (nonatomic, copy) PersonalInfoBlock completionHandler;
@property (nonatomic, strong) UIViewController *fromVC;

@end

@implementation AddressBookHelper

- (void)getAddressBookPersonalInfoFromVC:(UIViewController *)fromVC
                       completionHandler:(PersonalInfoBlock) completionHandler{
    if (completionHandler) {
        self.completionHandler = completionHandler;
    }
    self.fromVC = fromVC;
    objc_setAssociatedObject(self.fromVC, (__bridge const void *)(ADDRESSBOOKHELPER_BINDING_KEY), self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (IS_UP_IOS9) {
        CNContactStore * contactStore = [[CNContactStore alloc]init];
        if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusNotDetermined) {
            [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * __nullable error) {
                if (error){
                    NSLog(@"Error: %@", error);
                }else if (!granted){
                    [self showAlert];
                }else{
                    [self methodForCNContacts];
                }
            }];
        }else if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusAuthorized){
            [self methodForCNContacts];
        }else {
            [self showAlert];
        }
    }else {
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        ABAuthorizationStatus authStatus = ABAddressBookGetAuthorizationStatus();
        if (authStatus == kABAuthorizationStatusNotDetermined)
        {
            ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (error){
                        NSLog(@"Error: %@", (__bridge NSError *)error);
                    }else if (!granted) {
                        [self showAlert];
                    }else {
                        [self methodForABAdressBook];
                    }
                });
            });
        }else if (authStatus == kABAuthorizationStatusAuthorized) {
            [self methodForABAdressBook];
        }else {
            [self showAlert];
        }
    }
}

- (void)methodForCNContacts{
    CNContactPickerViewController *contactPicker = [[CNContactPickerViewController alloc] init];
    contactPicker.delegate = self;
    contactPicker.displayedPropertyKeys = @[CNContactPhoneNumbersKey];
    [self.fromVC presentViewController:contactPicker animated:YES completion:nil];
}

- (void)methodForABAdressBook{
    ABPeoplePickerNavigationController *peoplePicker = [[ABPeoplePickerNavigationController alloc] init];
    peoplePicker.peoplePickerDelegate = self;
    [self.fromVC presentViewController:peoplePicker animated:YES completion:nil];
}

- (void)showAlert{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"请到设置>隐私>通讯录打开本应用的权限设置" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [self.fromVC presentViewController:alertController animated:YES completion:nil];
}
#pragma mark - CNContactPickerDelegate
- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContactProperty:(CNContactProperty *)contactProperty {
    CNPhoneNumber *phoneNumber = (CNPhoneNumber *)contactProperty.value;
    [self.fromVC dismissViewControllerAnimated:YES completion:^{
        /// 联系人
        NSString *text1 = [NSString stringWithFormat:@"%@%@",contactProperty.contact.familyName,contactProperty.contact.givenName];
        /// 电话
        NSString *text2 = phoneNumber.stringValue;
        NSDictionary *dic = @{@"name":text1,@"phone":text2};
        self.completionHandler(dic);

        objc_setAssociatedObject(self.fromVC, (__bridge const void *)(ADDRESSBOOKHELPER_BINDING_KEY), nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }];
}

#pragma mark - ABPeoplePickerNavigationControllerDelegate
- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker didSelectPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    
    ABMultiValueRef valuesRef = ABRecordCopyValue(person, kABPersonPhoneProperty);
    CFIndex index = ABMultiValueGetIndexForIdentifier(valuesRef,identifier);
    CFStringRef value = ABMultiValueCopyValueAtIndex(valuesRef,index);
    CFStringRef anFullName = ABRecordCopyCompositeName(person);
    [self.fromVC dismissViewControllerAnimated:YES completion:^{
        /// 联系人
        NSString *text1 = [NSString stringWithFormat:@"%@",anFullName];
        /// 电话
        NSString *text2 = (__bridge NSString*)value;
        NSDictionary *dic = @{@"name":text1,@"phone":text2};
        self.completionHandler(dic);
        

        objc_setAssociatedObject(self.fromVC, (__bridge const void *)(ADDRESSBOOKHELPER_BINDING_KEY), nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    }];
}

- (void)dealloc{
    
}
@end
