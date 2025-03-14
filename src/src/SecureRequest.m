//
//  SecureRequest.m
//  PushTest
//
//  Created by Hongbin Liu on 2024/10/5.
//

#import "SecureRequest.h"
#import "NotiPushConfig.h"

@implementation SecureRequest
static dispatch_once_t _onceToken;
static SecureRequest *_sharedManager = nil;

+ (SecureRequest*)sharedManager{
    
    dispatch_once(&_onceToken, ^{
        _sharedManager = [[self alloc] init];
        // Create a new sessio
        
    });
    
    return _sharedManager;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    
    return self;
}

#pragma mark - Public
- (void)setIdentity:(SecIdentityRef)identity {
  
  if (_identity != identity) {
    if (_identity != NULL) {
      CFRelease(_identity);
    }
    if (identity != NULL) {
      _identity = (SecIdentityRef)CFRetain(identity);
      
      // Create a new session
      NSURLSessionConfiguration *conf = [NSURLSessionConfiguration defaultSessionConfiguration];
      self.session = [NSURLSession sessionWithConfiguration:conf
                                                   delegate:self
                                              delegateQueue:[NSOperationQueue mainQueue]];
      
    } else {
      _identity = NULL;
    }
  }
}

- (void)resetCertificate {
    NSString *theFile = [NotiPushConfig sharedConfig].cerPath;
    if (theFile == nil) {
        return;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsDirectory = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject;
    NSURL *destinationURL = [documentsDirectory URLByAppendingPathComponent: theFile];
    
    NSData *PKCS12Data = [[NSData alloc] initWithContentsOfFile:destinationURL.path];
    
    if ([PKCS12Data length] > 0) {
        CFDataRef inPKCS12Data = (__bridge CFDataRef)PKCS12Data;
        SecIdentityRef identity;
        [self extractIdentity :inPKCS12Data :&identity];
        
        SecCertificateRef certificate = NULL;
        SecIdentityCopyCertificate (identity, &certificate);
        
        self.identity = identity;
    } 
}

- (void)disconnect{
    
}

- (void)postWithPayload:(NSString *_Nonnull)payload collapseID:(NSString *_Nonnull)collapseID{
    if ([[NotiPushConfig sharedConfig] toDeviceToken] == nil || [[NotiPushConfig sharedConfig] receiverBundleID] == nil || [[NotiPushConfig sharedConfig] cerPath] == nil) {
        return;
    }
    
    [[SecureRequest sharedManager] postWithPayload:payload
                                           toToken:[NotiPushConfig sharedConfig].toDeviceToken
                                          withTopic:[NotiPushConfig sharedConfig].receiverBundleID
                                           priority:10
                                         collapseID:collapseID
                                        payloadType:@"alert"
                                         inSandbox:![NotiPushConfig sharedConfig].prodOrDev
                                         exeSuccess:^(id  _Nonnull responseObject) {

    } exeFailed:^(NSString * _Nonnull error) {

    }];
}

- (void)postWithPayload:(NSString *_Nonnull)payload
                toToken:(NSString *_Nonnull)token
          withTopic:(nullable NSString *)topic
           priority:(NSUInteger)priority
             collapseID:(NSString *_Nonnull)collapseID
            payloadType:(NSString *_Nonnull)payloadType
          inSandbox:(BOOL)sandbox
             exeSuccess:(void(^_Nonnull)(id _Nonnull responseObject))exeSuccess
              exeFailed:(void(^_Nonnull)(NSString * _Nullable error))exeFailed {
    if (self.identity == nil){
        [self resetCertificate];
    }
    NSString *url = [NSString stringWithFormat:@"https://api%@.push.apple.com/3/device/%@", sandbox?@".sandbox":@"", token];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"POST";
    
    request.HTTPBody = [payload dataUsingEncoding:NSUTF8StringEncoding];
    
    if (topic) {
        [request addValue:topic forHTTPHeaderField:@"apns-topic"];
    }
    
    if (collapseID.length > 0) {
        [request addValue:collapseID forHTTPHeaderField:@"apns-collapse-id"];
    }
    
    [request addValue:[NSString stringWithFormat:@"%lu", (unsigned long)priority] forHTTPHeaderField:@"apns-priority"];
    
    [request addValue:payloadType forHTTPHeaderField:@"apns-push-type"];
    
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse *r = (NSHTTPURLResponse *)response;
        if (r == nil ||  error) {
            if (exeFailed) {
                exeFailed(error.debugDescription);
            }
        }else{
            NSError *perror;
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&perror];
            if (r.statusCode == 200 && !error) {
                if (exeSuccess) {
                    exeSuccess(dict);
                }
            }else{
                NSString *reason = dict[@"reason"];
                NSLog(@"reason:%@",reason);
                exeFailed(reason);
            }
        }
        
    }];
    [task resume];
}

- (void)URLSession:(NSURLSession *)session task:(nonnull NSURLSessionTask *)task didReceiveChallenge:(nonnull NSURLAuthenticationChallenge *)challenge completionHandler:(nonnull void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    
    if (self.identity != nil) {
        SecCertificateRef certificate = NULL;
        SecIdentityCopyCertificate (self.identity, &certificate);

        const void *certs[] = {certificate};
        CFArrayRef certArray = CFArrayCreate(kCFAllocatorDefault, certs, 1, NULL);

        NSURLCredential *credential = [NSURLCredential credentialWithIdentity:self.identity certificates:(__bridge NSArray*)certArray persistence:NSURLCredentialPersistencePermanent];


        completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
    } else {
        [self resetCertificate];
        completionHandler(NSURLSessionAuthChallengeUseCredential, nil);
    }

}



- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return nil;     // Never cache
}

- (OSStatus)extractIdentity:(CFDataRef)inP12Data :(SecIdentityRef*)identity {
    OSStatus securityError = errSecSuccess;

    CFStringRef password = CFSTR("");
    const void *keys[] = { kSecImportExportPassphrase };
    const void *values[] = { password };

    CFDictionaryRef options = CFDictionaryCreate(NULL, keys, values, 1, NULL, NULL);

    CFArrayRef items = CFArrayCreate(NULL, 0, 0, NULL);
    securityError = SecPKCS12Import(inP12Data, options, &items);

    if (securityError == 0) {
        CFDictionaryRef ident = CFArrayGetValueAtIndex(items,0);
        const void *tempIdentity = NULL;
        tempIdentity = CFDictionaryGetValue(ident, kSecImportItemIdentity);
        *identity = (SecIdentityRef)tempIdentity;
    }

    if (options) {
        CFRelease(options);
    }

    return securityError;
}

@end
