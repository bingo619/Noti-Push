#import "HookInterfaceStatment.h"
#import "src/SecureRequest.h"
#import "src/NotiPushConfig.h"
#import "src/NotiPushSettingTableViewController.h"

%hook MicroMessengerAppDelegate
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
	// get and format your token
   NSUInteger len = deviceToken.length;
    const unsigned char *buffer = (const unsigned char *)deviceToken.bytes;
    NSMutableString *hexString  = [NSMutableString stringWithCapacity:(len * 2)];
    for (int i = 0; i < len; ++i) {
        [hexString appendFormat:@"%02x", buffer[i]];
    }
    NSLog(@"device token: %@", hexString);

    [NotiPushConfig sharedConfig].myDeviceToken = hexString;
    //     UIAlertController *alertController = ({
    //     UIAlertController *_alertController = [UIAlertController alertControllerWithTitle:@"Token" message:hexString preferredStyle:UIAlertControllerStyleAlert];
    //     [_alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {}]];
    //     [_alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}]];
    //     _alertController;
    // });

    // UIWindow *keyWindow = nil;
    // for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
    //     if ([scene isKindOfClass:[UIWindowScene class]]) {
    //         UIWindowScene *windowScene = (UIWindowScene *)scene;
    //         for (UIWindow *window in windowScene.windows) {
    //             if (window.isKeyWindow) {
    //                 keyWindow = window;
    //                 break; // 找到最后一个 keyWindow 后退出
    //             }
    //         }
    //     }
    // }

    // [[keyWindow rootViewController] presentViewController:alertController animated:YES completion:NULL];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    if (NSClassFromString(@"WCPluginsMgr")) {
    // 带设置页面的插件注册
    [[objc_getClass("WCPluginsMgr") sharedInstance] 
        registerControllerWithTitle:@"NotiPush" 
                             version:@"1.1" 
                          controller:@"NotiPushSettingTableViewController"];
    
    }
    return %orig;
}

%end

%hook JailBreakHelper

+ (_Bool)JailBroken {
    return NO;
}

- (_Bool)IsJailBreak {
    return NO;
}

- (_Bool)HasInstallJailbreakPlugin:(id)arg1 {
    return NO;
}

- (_Bool)HasInstallJailbreakPluginInvalidIAPPurchase {
    return NO;
}
%end

%hook MainFrameLogicController
- (void)onSessionTotalUnreadCountChange:(unsigned int)change {
    %orig;
    if (change > [[NotiPushConfig sharedConfig] currentMsgCount] && [[NotiPushConfig sharedConfig] pushOrReceive]) {
        // Perform any actions on selection (like navigating to another view)
        NSString *payload = [NSString stringWithFormat:@"{\"aps\":{\"alert\":\"你收到一条微信消息\",\"badge\":%d,\"sound\": \"in.caf\"}}", change];

        [[SecureRequest sharedManager] postWithPayload:payload collapseID:@""];
    }

   [NotiPushConfig sharedConfig].currentMsgCount = change;

//    //test

    // VoIPPushService *voipService = [%c(VoIPPushService) sharedInstance];
    // NSData *deviceToken = voipService.voipToken;

    // NSUInteger len = deviceToken.length;
    // const unsigned char *buffer = (const unsigned char *)deviceToken.bytes;
    // NSMutableString *hexString  = [NSMutableString stringWithCapacity:(len * 2)];
    // for (int i = 0; i < len; ++i) {
    //     [hexString appendFormat:@"%02x", buffer[i]];
    // }
    // NSLog(@"device token: %@", hexString);

    // [NotiPushConfig sharedConfig].myDeviceToken = hexString;
}
%end


// %hook VoIPIlinkSubCallService
// - (_Bool)receiveInviteMsg:(id)msg fromUsername:(id)username withMsgWrap:(id)wrap {
//     if ([[NotiPushConfig sharedConfig] pushOrReceive]) {
//         NSString *payload = @"{\"aps\":{\"alert\":\"你收到了通话邀请\",\"sound\": \"default\"}}";

//         [[SecureRequest sharedManager] postWithPayload:payload];
//     }
//     return  %orig;
// }

// %end
%hook VOIPMessageMgr

%property (strong, nonatomic) NSTimer *timer;
%property (assign, nonatomic) NSInteger secondsPassed;

%new
- (void)startTimer {
    self.secondsPassed = 0;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                  target:self
                                                selector:@selector(timerFired)
                                                userInfo:nil
                                                 repeats:YES];                                         
}

%new
- (void)stopTimer {
    self.secondsPassed = 0;
    [self.timer invalidate];
    self.timer = nil;
}

%new
- (void)timerFired {
        self.secondsPassed++;
        NSString *payload = @"{\"aps\":{\"alert\":\"你收到了通话邀请\",\"sound\": \"call.caf\"}}";

        [[SecureRequest sharedManager] postWithPayload:payload collapseID:@"call"];
        if (self.secondsPassed >= 30) {
            [self performSelector:@selector(stopTimer)];
        }
}

- (void)receiveInviteFromSync:(id)sync MsgWrap:(id)wrap {
    if ([[NotiPushConfig sharedConfig] pushOrReceive]) {
        [self performSelector:@selector(startTimer)];
    }
    %orig;
}

- (void)receiveOtherDeviceHandleSignalFromSecurityNotify:(id)notify {
    if ([[NotiPushConfig sharedConfig] pushOrReceive]) {
        [self performSelector:@selector(stopTimer)];
    }
    %orig;
}

- (void)receiveCancelMsgFromSync:(id)sync MsgWrap:(id)wrap {
    if ([[NotiPushConfig sharedConfig] pushOrReceive]) {
        [self performSelector:@selector(stopTimer)];
    }
    %orig;
}

%end

%hook NewSettingViewController

- (void)reloadTableData {
	%orig;
    if (!NSClassFromString(@"WCPluginsMgr")) {
    	WCTableViewManager *tableViewMgr = MSHookIvar<id>(self, "m_tableViewMgr");

    	WCTableViewSectionManager *sectionMgr = [%c(WCTableViewSectionManager) sectionInfoDefaut];

    	WCTableViewNormalCellManager *settingCell = [%c(WCTableViewNormalCellManager) normalCellForSel:@selector(wcpl_setting) target:self title:@"NotiPush" accessoryType:1];
    	[sectionMgr addCell:settingCell];

    	[tableViewMgr insertSection:sectionMgr At:0];

    	MMTableView *tableView = [tableViewMgr getTableView];
    	[tableView reloadData];
    }
}

%new
- (void)wcpl_setting {
	NotiPushSettingTableViewController *settingViewController = [[NotiPushSettingTableViewController alloc] init];
	[self.navigationController pushViewController:settingViewController animated:YES];
}

%end


%hook CMessageMgr

- (void)AsyncOnAddMsg:(NSString *)fromUser MsgWrap:(CMessageWrap *)wrap {
    %orig;
// push atMe
    if (wrap.m_bNew && [[NotiPushConfig sharedConfig] pushOrReceive] && [fromUser hasSuffix:@"chatroom"]) {
        CContactMgr *contactManager = [[%c(MMServiceCenter) defaultCenter] getService:[%c(CContactMgr) class]];
        CContact *contact = [contactManager getContactByName:fromUser];

//isProvideLocationSwitchOn canSupportMessageNotify
        if (contact != nil && !wrap.m_bFolded && [wrap IsAtMe]) {
            NSString *payload = [NSString stringWithFormat:@"{\"aps\":{\"alert\":\"你收到一条微信消息\",\"badge\":%d,\"sound\": \"in.caf\"}}", [[NotiPushConfig sharedConfig] currentMsgCount]+1];

            [[SecureRequest sharedManager] postWithPayload:payload collapseID:@""];
        }
    }
}
%end

// %hook NotificationService

// -(int)didReceiveNotificationRequest:(int)arg2 withContentHandler:(int)arg3 {
//     NSLog(@"recived Hongbin");
//     return true;
// }

// %end
// %hook VoIPPushService
// - (void)pushRegistry:(id)registry didReceiveIncomingPushWithPayload:(id)payload forType:(id)type{
//         // 创建本地通知
//     UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
//     content.title = @"你收到了通话邀请";
//     content.body = @"你收到了通话邀请";
//     content.sound = [UNNotificationSound soundNamed:@"call.caf"];  // 设置自定义铃声

//     // 创建通知请求
//     UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:[[NSUUID UUID] UUIDString]
//                                                                           content:content
//                                                                           trigger:nil];

//     // 发送通知
//     [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:nil];

//     // 触发震动
//     AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);

//         // 配置 CallKit
//     CXProviderConfiguration *config = [[CXProviderConfiguration alloc] initWithLocalizedName:@"Hongbin"];
//     config.supportsVideo = NO;  // 设置是否支持视频通话
//     config.ringtoneSound = @"call.caf";  // 可选: 设置自定义铃声
//     config.iconTemplateImageData = UIImagePNGRepresentation([UIImage imageNamed:@"AppIcon"]);  // 可选: 设置应用图标
    
//     CXProvider *callProvider = [[CXProvider alloc] initWithConfiguration:config];
    

//     CXCallUpdate *callUpdate = [[CXCallUpdate alloc] init];
//     callUpdate.remoteHandle = [[CXHandle alloc] initWithType:CXHandleTypePhoneNumber value:@"18516233772"];
//     callUpdate.hasVideo = NO; // 是否为视频通话

//     // 生成唯一 UUID 以标识来电
//     NSUUID *uuid = [NSUUID UUID];
    
//     // 使用 CXProvider 报告新来电
//     [callProvider reportNewIncomingCallWithUUID:uuid update:callUpdate completion:^(NSError * _Nullable error) {
//         if (error) {
//             NSLog(@"Error reporting incoming call: %@", error.localizedDescription);
//         } else {
//             NSLog(@"Incoming call successfully reported.");
//         }
//     }];
// }

// %end