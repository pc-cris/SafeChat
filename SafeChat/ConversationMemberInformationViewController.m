//
//  ConversationMemberInformationViewController.m
//  SafeChat
//
//  Created by Cristina Pocol on 20/06/2017.
//  Copyright © 2017 Cristina Pocol. All rights reserved.
//

#import "ConversationMemberInformationViewController.h"
#import "ConversationMemberInformationTableViewCell.h"

@interface ConversationMemberInformationViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;

@end

@implementation ConversationMemberInformationViewController

#pragma mark -
#pragma mark - Lifecycle

- (void)viewDidLoad {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.allowsSelection = NO;
    
    [self.tableView registerNib:[ConversationMemberInformationTableViewCell nib] forCellReuseIdentifier:[ConversationMemberInformationTableViewCell cellReuseIdentifier]];
    
    UIBarButtonItem *negativeLeftSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeLeftSpacer.width = -2;
    UIBarButtonItem *leftCloseItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_close"] style:UIBarButtonItemStyleDone target:self action:@selector(close)];
    [leftCloseItem setTintColor:[UIColor colorWithRed:42.0/255.0 green:172.0/255.0 blue:77.0/255.0 alpha:1.0]];
    ;
    self.navItem.leftBarButtonItems = @[negativeLeftSpacer, leftCloseItem];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.channel refreshWithCompletionHandler:^(SBDError * _Nullable error) {
        if (error != nil) {
            UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"Error" message:error.domain preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil];
            [vc addAction:closeAction];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:vc animated:YES completion:nil];
            });
            
            return;
        }
        
        self.navItem.title = [NSString stringWithFormat:@"Members - %d", (int)self.channel.memberCount];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)close {
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark -
#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 56;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 56;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForFooterInSection:(NSInteger)section
{
    return 0;
}

#pragma mark -
#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.channel.members count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ConversationMemberInformationTableViewCell *cell = nil;
    
    cell = [tableView dequeueReusableCellWithIdentifier:[ConversationMemberInformationTableViewCell cellReuseIdentifier]];
    [cell setModel:self.channel.members[indexPath.row]];
    
    return cell;
}



@end
