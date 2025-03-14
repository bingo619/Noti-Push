//
// WCPLRedEnvelopConfig.h
//
// Created by dyf on 17/4/6.
// Copyright © 2017 dyf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NotiPushConfig : NSObject

+ (instancetype)sharedConfig;

@property ( copy , nonatomic) NSString* cerPath;
@property ( copy , nonatomic) NSString* myDeviceToken;
@property ( copy , nonatomic) NSString* toDeviceToken;
@property (assign, nonatomic) BOOL pushOrReceive;
@property (copy, nonatomic) NSString* receiverBundleID;
@property (assign, nonatomic) BOOL prodOrDev;
@property (assign, nonatomic) int currentMsgCount;

@end
