//
//  NotoPushSettingTableViewController.m
//  PushTest
//
//  Created by Hongbin Liu on 2024/10/6.
//

#import "NotiPushSettingTableViewController.h"
#import "NotiPushConfig.h"
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>
#import "SecureRequest.h"

@interface NotiPushSettingTableViewController ()

@end

@implementation NotiPushSettingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"kpush"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
//    [NotiPushConfig sharedConfig].myDeviceToken = @"test device token";
//    [NotiPushConfig sharedConfig].toDeviceToken = @"b91c5a5c093873d3ccbbea55659698e94b4117958517a3b84b18272d93e2562d";
//    [NotiPushConfig sharedConfig].receiverBundleID = @"com.tencent.wexin100";
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self initTitle];

}

- (void)initTitle {
    self.title = @"NotiPush";
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if ([[NotiPushConfig sharedConfig] pushOrReceive]) {
        if ([[NotiPushConfig sharedConfig] toDeviceToken] != nil && [[NotiPushConfig sharedConfig] receiverBundleID] != nil && [[NotiPushConfig sharedConfig] cerPath] != nil) {
            return 7;
        } else {
            return 6;
        }
        
    } else {
        return 2;
    }
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"kpush"];
//    }

    switch (indexPath.row) {
        case 0: {
            // Configure the cell...
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Value1"];

            cell.textLabel.text = @"设置为接收端 || 推送端";
            UISwitch *switchview = [[UISwitch alloc] initWithFrame:CGRectZero];
            switchview.tag = indexPath.row;
            [switchview setOn:[NotiPushConfig sharedConfig].pushOrReceive];
            [switchview addTarget:self action:@selector(toggglePush:) forControlEvents:UIControlEventTouchUpInside];


            cell.accessoryView = switchview;
            
            cell.detailTextLabel.text = [NotiPushConfig sharedConfig].pushOrReceive ? @"发送端" : @"接收端";
            break;
        }
        case 1: {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Value1"];

            cell.textLabel.text = @"本机Device Token";
            cell.accessoryView = nil;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.detailTextLabel.text = [[NotiPushConfig sharedConfig] myDeviceToken];
            break;
        }
        case 2: {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Value1"];
            cell.textLabel.text = @"设置接收端Device Token";
            cell.accessoryView = nil;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.detailTextLabel.text = [[NotiPushConfig sharedConfig] toDeviceToken];
            break;
        }
            
        case 3: {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Value1"];
            cell.textLabel.text = @"设置接收端Bundle ID";
            cell.accessoryView = nil;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.detailTextLabel.text = [[NotiPushConfig sharedConfig] receiverBundleID];
            break;
        }
            
        case 4: {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Value4"];
            cell.textLabel.text = @"设置推送证书pfx文件";
            cell.accessoryView = nil;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.detailTextLabel.text = [[NotiPushConfig sharedConfig] cerPath];
            break;
        }

        case 5: {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Value1"];
            cell.textLabel.text = @"推送证书  开发 || 生产";
            UISwitch *switchview = [[UISwitch alloc] initWithFrame:CGRectZero];
            switchview.tag = indexPath.row;
            [switchview setOn:[NotiPushConfig sharedConfig].prodOrDev];
            [switchview addTarget:self action:@selector(togggleProdDev:) forControlEvents:UIControlEventTouchUpInside];
            cell.accessoryView = switchview;
            cell.detailTextLabel.text = [NotiPushConfig sharedConfig].prodOrDev ? @"生产" : @"开发";
            
            break;
        }
            
        case 6: {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Value1"];
            cell.textLabel.text = @"测试推送";
            cell.accessoryView = nil;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
            
        default:
            break;
    }
    // Configure the cell..
    return cell;
}

- (void)toggglePush:(UISwitch *)aswitch{
//    FFLog(@"%i",aswitch.tag);
    [NotiPushConfig sharedConfig].pushOrReceive = aswitch.isOn;
    [self.tableView reloadData];
}

- (void)togggleProdDev:(UISwitch *)aswitch{
//    FFLog(@"%i",aswitch.tag);
    [NotiPushConfig sharedConfig].prodOrDev = aswitch.isOn;
    [self.tableView reloadData];
}

- (void)copyTextToClipboard:(NSString *)text {
    // Get the general pasteboard
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    
    // Set the string to the pasteboard
    pasteboard.string = text;
    
    // Optionally, show a message to indicate the text has been copied
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                   message:[NSString stringWithFormat:@"本机device token复制成功: %@", text]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}


#pragma mark - UITableViewDelegate Methods

// Handle the selection of a row
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Deselect the row after selection
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    switch (indexPath.row) {
        case 0: {
            // Configure the cell...
//            @"接收 || 推送";

            break;
        }
        case 1: {
//            @"本机Device Token";
            [self copyTextToClipboard: [NotiPushConfig sharedConfig].myDeviceToken];
            break;
        }
        case 2: {
//            @"接收机Device Token";
            [self inputToDeviceToken];
            break;
        }
            
        case 3: {
//            @"接收机Bundle ID";
            [self inputBundleID];
            break;
        }
            
        case 4: {
//            @"推送证书pfx文件";
            [self presentDocumentPicker];
            break;
        }

        case 5: {
//            @"推送证书  开发 || 生产";
            
            break;
        }
            
        case 6: {
//            @"测试推送";
            [self testPush];
        }
            
        default:
            break;
    }
}

- (void)inputToDeviceToken {
    // Create an alert controller
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请输入推送目标的Device Token"
                        message:@""
                 preferredStyle:UIAlertControllerStyleAlert];
    
    // Add a text field to the alert
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = [NotiPushConfig sharedConfig].toDeviceToken;
        textField.keyboardType = UIKeyboardTypeDefault;
    }];
    
    // Add the "OK" action
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *inputField = alertController.textFields.firstObject;
        NSString *userInput = inputField.text;
        
        [NotiPushConfig sharedConfig].toDeviceToken = userInput;
        [self.tableView reloadData];
        // Handle the user input here
        NSLog(@"User input: %@", userInput);
    }];
    
    // Add the "Cancel" action
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    // Add the actions to the alert
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    
    // Present the alert
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)inputBundleID {
    // Create an alert controller
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请输入推送目标的Bundle ID"
                        message:@""
                 preferredStyle:UIAlertControllerStyleAlert];
    
    // Add a text field to the alert
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = [NotiPushConfig sharedConfig].receiverBundleID;
        textField.keyboardType = UIKeyboardTypeDefault;
    }];
    
    // Add the "OK" action
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *inputField = alertController.textFields.firstObject;
        NSString *userInput = inputField.text;
        
        [NotiPushConfig sharedConfig].receiverBundleID = userInput;
        [self.tableView reloadData];
        // Handle the user input here
        NSLog(@"User input: %@", userInput);
    }];
    
    // Add the "Cancel" action
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    // Add the actions to the alert
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    
    // Present the alert
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void) testPush {
        // Perform any actions on selection (like navigating to another view)
        NSString *payload = @"{\"aps\":{\"alert\":\"您收到一条消息\",\"badge\":1,\"sound\": \"default\"}}";
    
        [[SecureRequest sharedManager] postWithPayload:payload
                                               toToken:[NotiPushConfig sharedConfig].toDeviceToken
                                              withTopic:[NotiPushConfig sharedConfig].receiverBundleID
                                               priority:10
                                             collapseID:@""
                                            payloadType:@"alert"
                                             inSandbox:![NotiPushConfig sharedConfig].prodOrDev
                                             exeSuccess:^(id  _Nonnull responseObject) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示"
                                 message: @"推送成功"
                       preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:okAction];
            [self presentViewController:alert animated:YES completion:nil];
        } exeFailed:^(NSString * _Nonnull error) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"推送错误"
                                 message: error
                       preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:okAction];
            [self presentViewController:alert animated:YES completion:nil];
        }];
}

- (void)presentDocumentPicker {
    // Define the document types you want to allow (e.g., PDF, text files)
    UTType *documentType = UTTypeData;
    
    // Initialize the document picker
    UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initForOpeningContentTypes:@[documentType]];
    documentPicker.delegate = self;
    documentPicker.modalPresentationStyle = UIModalPresentationFullScreen;
    
    // Present the document picker
    [self presentViewController:documentPicker animated:YES completion:nil];
}

#pragma mark - UIDocumentPickerDelegate

// Called when the user picks a document
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    NSURL *selectedFileURL = [urls firstObject];
    
    // Ensure that the document can be accessed securely
        if ([selectedFileURL startAccessingSecurityScopedResource]) {
            // Get the destination URL in the app's document directory
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSURL *documentsDirectory = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject;
            NSURL *destinationURL = [documentsDirectory URLByAppendingPathComponent:selectedFileURL.lastPathComponent];
            
            NSError *error = nil;
            
            // Remove existing file at destination if it exists
            if ([fileManager fileExistsAtPath:destinationURL.path]) {
                [fileManager removeItemAtURL:destinationURL error:&error];
                if (error) {
                    NSLog(@"Error removing existing file: %@", error.localizedDescription);
                }
            }
            
            // Copy the file to the app's document directory
            [fileManager copyItemAtURL:selectedFileURL toURL:destinationURL error:&error];
            
            if (error) {
                NSLog(@"Error copying file: %@", error.localizedDescription);
            } else {
                NSLog(@"File copied to: %@", destinationURL);
                [NotiPushConfig sharedConfig].cerPath = destinationURL.lastPathComponent;
                [[SecureRequest sharedManager] resetCertificate];
                [self.tableView reloadData];
            }
            
            // Stop accessing the file when done
            [selectedFileURL stopAccessingSecurityScopedResource];
        } else {
            NSLog(@"Failed to access the document.");
        }
}

// Called when the user cancels the document picker
- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    NSLog(@"Document picker was cancelled");
}

@end
