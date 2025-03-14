//
// WCPLRedEnvelopConfig.m
//
// Created by dyf on 17/4/6.
// Copyright © 2017年 dyf. All rights reserved.
//

#import "NotiPushConfig.h"

static NSString *const kNotiCerPath = @"kNotiCerPath";
static NSString *const kNotiMyDeviceToken = @"kNotiMyDeviceToken";
static NSString *const kNotiToDeviceToken = @"kNotiToDeviceToken";
static NSString *const kNotiPushOrReceive = @"kNotiPushOrReceive";
static NSString *const kNotiReceiverBundleID = @"kNotiReceiverBundleID";
static NSString *const kNotiProdOrDev = @"kNotiProdOrDev";

@interface NotiPushConfig ()

@end

@implementation NotiPushConfig

+ (instancetype)sharedConfig {
    static NotiPushConfig *config = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        config = [NotiPushConfig new];
    });
    return config;
}

- (instancetype)init {
    if (self = [super init]) {
        _cerPath  = [[NSUserDefaults standardUserDefaults] stringForKey: kNotiCerPath];
        _myDeviceToken = [[NSUserDefaults standardUserDefaults] stringForKey: kNotiMyDeviceToken];
        _toDeviceToken = [[NSUserDefaults standardUserDefaults] stringForKey: kNotiToDeviceToken];
        _prodOrDev = [[NSUserDefaults standardUserDefaults] boolForKey: kNotiProdOrDev];
        _pushOrReceive = [[NSUserDefaults standardUserDefaults] boolForKey: kNotiPushOrReceive];
        _receiverBundleID = [[NSUserDefaults standardUserDefaults] stringForKey: kNotiReceiverBundleID];
        _currentMsgCount = 0;
    }
    return self;
}

- (void) setCerPath:(NSString *)cerPath {
    _cerPath = cerPath;
    [[NSUserDefaults standardUserDefaults] setObject:cerPath forKey:kNotiCerPath];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) setMyDeviceToken:(NSString *)deviceToken {
    _myDeviceToken = deviceToken;
    [[NSUserDefaults standardUserDefaults] setObject:deviceToken forKey:kNotiMyDeviceToken];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) setToDeviceToken:(NSString *)deviceToken {
    _toDeviceToken = deviceToken;
    [[NSUserDefaults standardUserDefaults] setObject:deviceToken forKey:kNotiToDeviceToken];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) setProdOrDev:(BOOL)prodOrDev {
    _prodOrDev = prodOrDev;
    [[NSUserDefaults standardUserDefaults] setBool:prodOrDev forKey:kNotiProdOrDev];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) setPushOrReceive:(BOOL)pushOrReceive {
    _pushOrReceive = pushOrReceive;
    [[NSUserDefaults standardUserDefaults] setBool:pushOrReceive forKey:kNotiPushOrReceive];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) setReceiverBundleID:(NSString *)receiverBundleID {
    _receiverBundleID = receiverBundleID;
    [[NSUserDefaults standardUserDefaults] setObject:receiverBundleID forKey:kNotiReceiverBundleID];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end
