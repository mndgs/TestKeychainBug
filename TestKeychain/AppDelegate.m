//
//  AppDelegate.m
//  TestKeychain
//
//  Created by Mindaugas Paukste on 19/01/2016.
//
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //Populate keychain
    [self setupKeychain];
    
    int count = [[self  searchKeychainWithLimit:(__bridge id)kSecMatchLimitAll] count];
    NSLog(@"Count of values in keychain: %d", count);
    
    OSStatus status = 0;
    
    if ((count == 0) && [[NSUserDefaults standardUserDefaults] valueForKey:@"FirstLaunch"]) {
        //Keychain was populated and Passcode was disabled/set again        
        
        //Lets add some new item to keychain
        
        NSDictionary *param = @{(__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
                                (__bridge id)kSecAttrService: @"TestService",
                                (__bridge id)kSecAttrAccessible: (__bridge id)kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
                                (__bridge id)kSecAttrAccount:@"SomeAccount"
                                };
        status = SecItemAdd((__bridge CFDictionaryRef)param, NULL);
        if (status == errSecSuccess) {

            //query it with match limit all
            count = [[self  searchKeychainWithLimit:(__bridge id)kSecMatchLimitAll] count];
            NSLog(@"Count of values in keychain with kSecMatchLimitAll: %d", count);
            
            //query it with match limit one
            count = [[self  searchKeychainWithLimit:(__bridge id)kSecMatchLimitOne] count];
            NSLog(@"Count of values in keychain with kSecMatchLimitOne: %d", count);
            
            //query with match limit 100
            count = [[self  searchKeychainWithLimit:@(100)] count];
            NSLog(@"Count of values in keychain with limit: 100: %d", count);
            
            //query with match limit 101 (100 "hidden" items + 1 freshly added)
            count = [[self  searchKeychainWithLimit:@(101)] count];
            NSLog(@"Count of values in keychain with limit: 101: %d", count);
            
            
        } else {
            NSLog(@"Passcode not set for the device?");
        }
    } else {
        NSLog(@"Turn off & Turn On Device Passcode and launch app again");
    }
    
    return YES;
}

- (void)setupKeychain
{
    if (![[NSUserDefaults standardUserDefaults] valueForKey:@"FirstLaunch"]) {
        
        NSMutableDictionary *param = [@{(__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
                                        (__bridge id)kSecAttrService: @"TestService",
                                        (__bridge id)kSecAttrAccessible: (__bridge id)kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
                                        } mutableCopy];
        OSStatus status = 0;
        
        for (int i = 0; i < 100; i ++) {
            [param setObject:[NSString stringWithFormat:@"TestAccount%d",i] forKey:(__bridge id)kSecAttrAccount];
            status = SecItemAdd((__bridge CFDictionaryRef)param, NULL);
        }
        
        if (status == errSecSuccess) {
            [[NSUserDefaults standardUserDefaults] setObject:@"Done" forKey:@"FirstLaunch"];
        } else {
            NSLog(@"Passcode not set for the device?");
        }
    }
}

- (NSArray *)searchKeychainWithLimit:(id)limit
{
    NSDictionary *query = @{(__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
                            (__bridge id)kSecAttrService: @"TestService",
                            (__bridge id)kSecMatchLimit:limit,
                            (__bridge id)kSecReturnAttributes:@YES
                            };
    
    CFTypeRef result = NULL;
    
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
    
    return (__bridge NSArray*)result;
}


@end
