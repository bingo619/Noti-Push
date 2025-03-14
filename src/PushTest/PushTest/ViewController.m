//
//  ViewController.m
//  PushTest
//
//  Created by Hongbin Liu on 2024/10/5.
//

#import "ViewController.h"
#import <Security/Security.h>
#import "SecureRequest.h"
#import "NotiPushSettingTableViewController.h"

@interface ViewController ()
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Initialize the data array
       self.dataArray = @[@"Item 1", @"Item 2", @"Item 3", @"Item 4"];
       
       // Create the UITableView
       self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
       
       // Set delegate and dataSource to self
       self.tableView.delegate = self;
       self.tableView.dataSource = self;
       
       // Register UITableViewCell class
       [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
       
       // Add the UITableView to the main view
       [self.view addSubview:self.tableView];
}

#pragma mark - UITableViewDataSource Methods

// Number of sections in the table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Number of rows in the section (based on the dataArray count)
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

// Configure the cell for a given index path
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    // Set the text for the cell
    cell.textLabel.text = self.dataArray[indexPath.row];
    
    return cell;
}

#pragma mark - UITableViewDelegate Methods

// Handle the selection of a row
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Deselect the row after selection
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Get the selected item
    NSString *selectedItem = self.dataArray[indexPath.row];
    
    // Log the selected item
    NSLog(@"Selected: %@", selectedItem);
    
    if (indexPath.row == 3) {
        NSString *payload = @"{\"aps\":{\"alert\":\"你收到了通话邀请\",\"sound\": \"default\"}}";

        [[SecureRequest sharedManager] postWithPayload:payload];
    }
    
    NotiPushSettingTableViewController *controller = [[NotiPushSettingTableViewController alloc] init];
    
    [self.navigationController pushViewController:controller animated:YES];
    

    
//    int num = 1;
//    
//    // Perform any actions on selection (like navigating to another view)
//    NSString *payload = [NSString stringWithFormat:@"{\"aps\":{\"alert\":\"您收到一条消息\",\"badge\":%d,\"sound\": \"default\"}}", num];
//
//    [[SecureRequest sharedManager] postWithPayload:payload
//                                            toToken:@"b91c5a5c093873d3ccbbea55659698e94b4117958517a3b84b18272d93e2562d"
//                                          withTopic:@"com.tencent.wexin100"
//                                           priority:10
//                                         collapseID:@""
//                                        payloadType:@"alert"
//                                          inSandbox:true
//                                         exeSuccess:^(id  _Nonnull responseObject) {
//
//    } exeFailed:^(NSString * _Nonnull error) {
//
//    }];
}

- (NSString *)getFilePathFromBundle:(NSString *)fileName withExtension:(NSString *)extension {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:extension];
    return filePath;
}


@end
