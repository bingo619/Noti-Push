//
//  SecureRequest.h
//  PushTest
//
//  Created by Hongbin Liu on 2024/10/5.
//
#import <Foundation/Foundation.h>
#import <Foundation/NSURL.h>
@interface SecureRequest : NSObject<NSURLSessionDelegate>
@property (nonatomic, strong) NSURLSession * _Nullable session;
@property (nonatomic, strong, nullable) __attribute__((NSObject)) SecIdentityRef identity;
+ (SecureRequest*_Nonnull)sharedManager;
//https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server/sending_notification_requests_to_apns?language=objc
- (void)resetCertificate;

- (void)postWithPayload:(NSString *_Nonnull)payload collapseID:(NSString *_Nonnull)collapseID;

- (void)postWithPayload:(NSString *_Nonnull)payload
                toToken:(NSString *_Nonnull)token
          withTopic:(nullable NSString *)topic
           priority:(NSUInteger)priority
             collapseID:(NSString *_Nonnull)collapseID
            payloadType:(NSString *_Nonnull)payloadType
          inSandbox:(BOOL)sandbox
             exeSuccess:(void(^_Nonnull)(id _Nonnull responseObject))exeSuccess
              exeFailed:(void(^_Nonnull)(NSString * _Nullable error))exeFailed;
-(void)disconnect;
@end
