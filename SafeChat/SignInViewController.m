//
//  SignInViewController.m
//  SafeChat
//
//  Created by Cristina Pocol on 05/01/2017.
//  Copyright © 2017 Cristina Pocol. All rights reserved.
//

#import <SendBirdSDK/SendBirdSDK.h>
#import "SignInViewController.h"
#import "UserListViewController.h"

@interface SignInViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *usernameLabelBottomConstraint;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UILabel *passwordLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *passwordLabelBottomConstraint;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
- (IBAction)signInButtonAction:(id)sender;

@end

@implementation SignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.usernameTextField.delegate = self;
    self.passwordTextField.delegate = self;
    
    self.usernameLabel.alpha = 0;
    self.passwordLabel.alpha = 0;

    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"safechat.Username"];
    NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:@"safechat.Password"];
    
    if (username != nil && username.length > 0) {
        self.usernameLabelBottomConstraint.constant = 0;
        [self.view setNeedsUpdateConstraints];
        self.usernameLabel.alpha = 1;
        [self.view layoutIfNeeded];
    }
    
    if (password != nil && password.length > 0) {
        self.passwordLabelBottomConstraint.constant = 0;
        [self.view setNeedsUpdateConstraints];
        self.passwordLabel.alpha = 1;
        [self.view layoutIfNeeded];
    }
    
    self.usernameTextField.text = username;
    self.passwordTextField.text = password;
    
    //[self.signInButton setBackgroundColor:[UIColor greenColor]];
//
//    [self.indicatorView setHidesWhenStopped:YES];
    
    [self.usernameTextField addTarget:self action:@selector(usernameTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.passwordTextField addTarget:self action:@selector(passwordTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];

}

- (void)usernameTextFieldDidChange:(UITextField *)sender {
    if (sender.text.length == 0) {
        self.usernameLabelBottomConstraint.constant = -12;
        [self.view setNeedsUpdateConstraints];
        [UIView animateWithDuration:0.1 animations:^{
            self.usernameLabel.alpha = 0;
            [self.view layoutIfNeeded];
        }];
    }
    else {
        self.usernameLabelBottomConstraint.constant = 0;
        [self.view setNeedsUpdateConstraints];
        [UIView animateWithDuration:0.2 animations:^{
            self.usernameLabel.alpha = 1;
            [self.view layoutIfNeeded];
        }];
    }
}

- (void)passwordTextFieldDidChange:(UITextField *)sender {
    if (sender.text.length == 0) {
        self.passwordLabelBottomConstraint.constant = -12;
        [self.view setNeedsUpdateConstraints];
        [UIView animateWithDuration:0.1 animations:^{
            self.passwordLabel.alpha = 0;
            [self.view layoutIfNeeded];
        }];
    }
    else {
        self.passwordLabelBottomConstraint.constant = 0;
        [self.view setNeedsUpdateConstraints];
        [UIView animateWithDuration:0.2 animations:^{
            self.passwordLabel.alpha = 1;
            [self.view layoutIfNeeded];
        }];
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.view endEditing:YES];
}

#pragma mark - UITextField delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.usernameTextField) {
        //self.usernameTextField.borderStyle = UITextBorderStyleLine;
    }
    else if (textField == self.passwordTextField) {
        //self.passwordTextField.borderStyle = UITextBorderStyleLine;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.usernameTextField) {
        //self.usernameTextField.borderStyle = UITextBorderStyleNone;
    }
    else if (textField == self.passwordTextField) {
        //self.passwordTextField.borderStyle = UITextBorderStyleNone;
    }
}


#pragma mark - UI Actions

- (IBAction)signInButtonAction:(id)sender {
    NSString *trimmedUsername = [self.usernameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *trimmedPassword = [self.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (!trimmedUsername.length || !trimmedPassword.length) {
        UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"SafeChat" message:@"Please enter your credentials." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [vc addAction:okAction];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:vc animated:YES completion:nil];
        });
        return;
    }
    if (trimmedUsername.length > 0 && trimmedPassword.length > 0) {
        [self.usernameTextField setEnabled:NO];
        [self.passwordTextField setEnabled:NO];
        
        [self.activityIndicator startAnimating];
        [SBDMain connectWithUserId:trimmedUsername completionHandler:^(SBDUser * _Nullable user, SBDError * _Nullable error) {
            if (error != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.usernameTextField setEnabled:YES];
                    [self.passwordTextField setEnabled:YES];
                    
                    [self.activityIndicator stopAnimating];
                });
                
                UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"Error" message:error.domain preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil];
                [vc addAction:closeAction];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self presentViewController:vc animated:YES completion:nil];
                });
                
                return;
            }
            
            [SBDMain registerDevicePushToken:[SBDMain getPendingPushToken] unique:YES completionHandler:^(SBDPushTokenRegistrationStatus status, SBDError * _Nullable error) {
                if (error == nil) {
                    if (status == SBDPushTokenRegistrationStatusPending) {
                        NSLog(@"Push registration is pending.");
                    }
                    else {
                        NSLog(@"APNS Token is registered.");
                    }
                }
                else {
                    NSLog(@"APNS registration failed.");
                }
            }];
            
            [SBDMain updateCurrentUserInfoWithNickname:trimmedUsername profileUrl:nil completionHandler:^(SBDError * _Nullable error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.usernameTextField setEnabled:YES];
                    [self.passwordTextField setEnabled:YES];
                    
                    [self.activityIndicator stopAnimating];
                });
                
                if (error != nil) {
                    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"Error" message:error.domain preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil];
                    [vc addAction:closeAction];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self presentViewController:vc animated:YES completion:nil];
                    });
                    
                    [SBDMain disconnectWithCompletionHandler:^{
                        
                    }];
                    
                    return;
                }
                
                [[NSUserDefaults standardUserDefaults] setObject:[SBDMain getCurrentUser].userId forKey:@"safechat.Username"];
                [[NSUserDefaults standardUserDefaults] setObject:trimmedPassword forKey:@"safechat.Password"];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    UserListViewController *vc = [[UserListViewController alloc] init];
                    [self presentViewController:vc animated:NO completion:nil];
                });
            }];
        }];
    }

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