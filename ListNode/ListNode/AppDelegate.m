//
//  AppDelegate.m
//  ListNode
//
//  Created by ZZJ on 2019/9/12.
//  Copyright © 2019 Jion. All rights reserved.
//

#import "AppDelegate.h"
@interface ListNode :NSObject{
    @package
    __unsafe_unretained ListNode *next;
    int val;
}
@end

@implementation ListNode
-(instancetype)initByVal:(int)val {
    if (self = [super init]) {
        self->val = val;
    }
    return self;
}
@end

@interface AppDelegate ()

@end

@implementation AppDelegate

-(ListNode*)deleteDuplicates:(ListNode*)head {
    if (head == nil || head->next == nil) {
        return head;
    }
    
    ListNode *temp_head = head;
    ListNode *p = head;
    
    while ((temp_head = temp_head->next) != nil) {
        if (p->val != temp_head->val) {
            p->next = temp_head;
            p = p->next;
        }
    }
    p->next = nil;
    return head;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    ListNode *list1 = [[ListNode alloc] initByVal:1];
    ListNode *list2 = [[ListNode alloc] initByVal:1];
    ListNode *list3 = [[ListNode alloc] initByVal:4];
    ListNode *list4 = [[ListNode alloc] initByVal:5];
    ListNode *list5 = [[ListNode alloc] initByVal:5];
    ListNode *list6 = [[ListNode alloc] initByVal:4];
    
    list5->next = list6;
    list4->next = list5;
    list3->next = list4;
    list2->next = list3;
    list1->next = list2;
    
    ListNode *list = [self deleteDuplicates:list1];
    NSLog(@"%@",list);
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
