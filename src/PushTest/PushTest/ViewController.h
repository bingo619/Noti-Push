//
//  ViewController.h
//  PushTest
//
//  Created by Hongbin Liu on 2024/10/5.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController  <UITableViewDelegate, UITableViewDataSource>
{
    
}
- (NSString *)getFilePathFromBundle:(NSString *)fileName withExtension:(NSString *)extension;

@end

