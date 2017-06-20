//
//  UserListViewController.m
//  SafeChat
//
//  Created by Cristina Pocol on 26/02/2017.
//  Copyright © 2017 Cristina Pocol. All rights reserved.
//

#import <SendBirdSDK/SendBirdSDK.h>
#import "UserListViewController.h"
#import "UserListTableViewCell.h"
#import "OneToOneConversationViewController.h"
#import "UserProfileViewController.h"
#import "DesignConstants.h"
#import "AppDelegate.h"

@interface UserListViewController ()

@property (weak, nonatomic) IBOutlet UINavigationItem *userListNavigationItem;
@property (weak, nonatomic) IBOutlet UITableView *userListTableView;
@property (strong, nonatomic) UIRefreshControl *userListRefreshControl;

@property (strong, nonatomic) NSMutableArray<SBDUser *> *users;
@property (strong, nonatomic) SBDUserListQuery *userListQuery;

@end

@implementation UserListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *disconnectButton = [[UIBarButtonItem alloc] initWithTitle:@"Disconnect" style:UIBarButtonItemStyleDone target:self action:@selector(disconnect)];
    [disconnectButton setTitleTextAttributes:@{NSFontAttributeName: [DesignConstants navigationBarButtonItemFont], NSForegroundColorAttributeName: [UIColor colorWithRed:42.0/255.0 green:172.0/255.0 blue:77.0/255.0 alpha:1.0]} forState:UIControlStateNormal];
    
    UIBarButtonItem *profileButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"user_profile"] style:UIBarButtonItemStylePlain target:self action:@selector(showProfile)];
    [profileButton setTintColor:[UIColor colorWithRed:42.0/255.0 green:172.0/255.0 blue:77.0/255.0 alpha:1.0]];
    
    self.userListNavigationItem.rightBarButtonItem = disconnectButton;
    self.userListNavigationItem.leftBarButtonItem = profileButton;
    
    self.userListTableView.delegate = self;
    self.userListTableView.dataSource = self;

    self.userListRefreshControl = [[UIRefreshControl alloc] init];
    [self.userListRefreshControl addTarget:self action:@selector(refreshUserList) forControlEvents:UIControlEventValueChanged];
    [self.userListTableView addSubview:self.userListRefreshControl];
    
    [self.view layoutIfNeeded];
    [self loadUserList:YES];

}

- (void)refreshUserList {
    [self loadUserList:YES];
}

- (void)loadUserList:(BOOL)initial {
    if (initial == YES) {
        if (self.users == nil) {
            self.users = [[NSMutableArray alloc] init];
        }
        
        [self.users removeAllObjects];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.userListTableView reloadData];
        });
        
        self.userListQuery = nil;
    }
    
    if (self.userListQuery == nil) {
        self.userListQuery = [SBDMain createAllUserListQuery];
        self.userListQuery.limit = 25;
    }
    
    if (self.userListQuery.hasNext == NO) {
        [self.userListRefreshControl endRefreshing];
        return;
    }
    
    [self.userListQuery loadNextPageWithCompletionHandler:^(NSArray<SBDUser *> * _Nullable users, SBDError * _Nullable error) {
        if (error != nil) {
            UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"Error" message:error.domain preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil];
            [vc addAction:closeAction];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:vc animated:YES completion:nil];
            });
            [self.userListRefreshControl endRefreshing];
            return;
        }
        
        for (SBDUser *user in users) {
            if ([user.userId isEqualToString:[SBDMain getCurrentUser].userId]) {
                continue;
            }
            [self.users addObject:user];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.userListTableView reloadData];
        });
        [self.userListRefreshControl endRefreshing];
    }];
}

- (void)disconnect {
    [SBDMain unregisterAllPushTokenWithCompletionHandler:^(NSDictionary * _Nullable response, SBDError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Unregister all push tokens. Error: %@", error);
        }
        
        [SBDMain disconnectWithCompletionHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
                [self dismissViewControllerAnimated:NO completion:nil];
            });
        }];
    }];
}

- (void)showProfile {
    UserProfileViewController *vc = [[UserProfileViewController alloc] init];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:vc animated:NO completion:nil];
    });

    
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForFooterInSection:(NSInteger)section {
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    SBDUser *selectedUser = self.users[indexPath.row];
    NSLog(@"you have selected the user with name: %@",[selectedUser userId]);
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.userListTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    });
    
    [self createChannelForUser:selectedUser];
    
}

- (void)createChannelForUser:(SBDUser*)user {
    [SBDGroupChannel createChannelWithUsers:@[user] isDistinct:YES completionHandler:^(SBDGroupChannel * _Nullable channel, SBDError * _Nullable error) {
        if (error != nil) {
            UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"Error creating channel" message:error.domain preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [vc addAction:closeAction];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:vc animated:YES completion:nil];
            });
            
            //[self.activityIndicator stopAnimating];
            
            return;
        }
        
//        UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"Created channel" message:@"Successfully created message channel" preferredStyle:UIAlertControllerStyleAlert];
       // UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            //[self dismissViewControllerAnimated:NO completion:^{
                [self didFinishCreatingGroupChannel:channel viewController:self];
           // }];
      //  }];
       // [vc addAction:closeAction];
       // [self presentViewController:vc animated:YES completion:^{
            
     //   }];
        
        //[self.activityIndicator stopAnimating];
    }];
}

#pragma mark - CreateGroupChannelSelectOptionViewControllerDelegate
- (void)didFinishCreatingGroupChannel:(SBDGroupChannel *)channel viewController:(UIViewController *)vc {
    //[self dismissViewControllerAnimated:NO completion:^{
        [self openGroupChannel:channel viewController:self];
   // }];
}

- (void)openGroupChannel:(SBDGroupChannel *)channel viewController:(UIViewController *)vc {
    dispatch_async(dispatch_get_main_queue(), ^{
        OneToOneConversationViewController *conv = [[OneToOneConversationViewController alloc] init];
        conv.channel = channel;
        [self presentViewController:conv animated:NO completion:nil];
    });
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserListTableViewCell *cell = (UserListTableViewCell*) [tableView dequeueReusableCellWithIdentifier:[UserListTableViewCell cellReuseIdentifier]];
    if (!cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"UserListTableViewCell" owner:self options:nil];
        cell = [nib firstObject];
    }
    
    [cell setModel:self.users[indexPath.row]];
    
//    if ([self.selectedUsers indexOfObject:self.users[indexPath.row]] == NSNotFound) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [cell setSelectedUser:NO];
//        });
//    }
//    else {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [cell setSelectedUser:YES];
//        });
//    }
    
    if (self.users.count > 0 && indexPath.row + 1 == self.users.count) {
        [self loadUserList:NO];
    }
    
    return cell;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
