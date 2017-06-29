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
#import "SafeChatConstantsAndKeys.h"
#import "EncryptionManager.h"

@interface SignInViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *usernameLabelBottomConstraint;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UILabel *passwordLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *passwordLabelBottomConstraint;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (atomic) BOOL keyboardShown;

- (IBAction)signInButtonAction:(id)sender;

@end

@implementation SignInViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.usernameTextField.delegate = self;
    self.passwordTextField.delegate = self;
    
    self.usernameLabel.alpha = 0;
    self.passwordLabel.alpha = 0;

    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:kSafeChatUserDefaultsUsernameKey];
    NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:kSafeChatUserDefaultsPasswordKey];
    
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
    
    
    [self.usernameTextField addTarget:self action:@selector(usernameTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.passwordTextField addTarget:self action:@selector(passwordTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];


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
        //self.usernameTextField.borderStyle = UITextBorderStyleBezel;
    }
    else if (textField == self.passwordTextField) {
        //self.passwordTextField.borderStyle = UITextBorderStyleBezel;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.usernameTextField) {
        //self.usernameTextField.borderStyle = UITextBorderStyleNone;
    }
    else if (textField == self.passwordTextField) {
        self.passwordTextField.borderStyle = UITextBorderStyleNone;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.usernameTextField || textField == self.passwordTextField) {
        [textField resignFirstResponder];
        return NO;
    }
    return YES;
}

#pragma mark - UI Actions

- (void)signInUser {
    
    NSString *trimmedUsername = [self.usernameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *trimmedPassword = [self.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (!trimmedUsername.length || !trimmedPassword.length) {
        UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"SafeChat" message:@"Please enter your credentials." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
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
                
                [[NSUserDefaults standardUserDefaults] setObject:[SBDMain getCurrentUser].userId forKey:kSafeChatUserDefaultsUsernameKey];
                [[NSUserDefaults standardUserDefaults] setObject:trimmedPassword forKey:kSafeChatUserDefaultsPasswordKey];
                [self setupKeysIfNecessary];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    UserListViewController *vc = [[UserListViewController alloc] init];
                    [self presentViewController:vc animated:NO completion:nil];
                });
            }];
        }];
    }

}

- (IBAction)signInButtonAction:(id)sender {
    
    [self signInUser];
        //TODO: check for existing username in Firebase:
    
//        NSString *savedUsername = [[NSUserDefaults standardUserDefaults] valueForKey:kSafeChatUserDefaultsUsernameKey];
//        if (![self.usernameTextField.text isEqualToString:savedUsername]) {
//    
//            FIRDatabaseReference *reference = [[FIRDatabase database] reference];
//            [[reference child:kSafeChatFirebaseRootUser] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
//
//                NSDictionary *users = snapshot.value;
//                if ([[users allKeys] containsObject:self.usernameTextField.text]) {
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        //Your main thread code goes in here
//                        NSLog(@"Im on the main thread");
//                        UIAlertController *alertCtrl = [UIAlertController
//                                                        alertControllerWithTitle:@"User exists"
//                                                        message:@"This username already exists. Please pick another."
//                                                        preferredStyle:UIAlertControllerStyleAlert];
//                        UIAlertAction *okAction = [UIAlertAction
//                                                   actionWithTitle:@"OK"
//                                                   style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                                                   }];
//                        [alertCtrl addAction:okAction];
//                        [self presentViewController:alertCtrl animated:YES completion:^{
//                        }];
//                    });
//
//                } else {
//                    [self signInUser];
//                }
//                
//            } withCancelBlock:^(NSError * _Nonnull error) {
//                NSLog(@"%@", error.localizedDescription);
//            }];
//        } else {
//            [self signInUser];
//        }
    
}
            

- (void)setupKeysIfNecessary {
        
    if(![[[NSUserDefaults standardUserDefaults] valueForKey:kSafeChatUserDefaultsDidSendInitialKeyToFirebaseKey] isEqualToString:@"sent"]) {
        NSDictionary *myDefaultKeys = [[EncryptionManager sharedInstance] generateKeysUsePregenerated:YES];
        NSString *user = [[NSUserDefaults standardUserDefaults] objectForKey:kSafeChatUserDefaultsUsernameKey];
        BOOL didSend = [[EncryptionManager sharedInstance] setUserDefaultPublicKeys:myDefaultKeys user:user];
        if (didSend) {
            [[NSUserDefaults standardUserDefaults] setObject:@"sent" forKey:kSafeChatUserDefaultsDidSendInitialKeyToFirebaseKey];
        }
    }
}

#pragma mark -
#pragma mark - Keyboard delegate methods

- (void)keyboardDidShow:(NSNotification *)notification {
    
    self.keyboardShown = YES;
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.bottomConstraint.constant = keyboardFrameBeginRect.size.height;
        [self.view layoutIfNeeded];
    });
}

- (void)keyboardDidHide:(NSNotification *)notification {
    
    self.keyboardShown = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.bottomConstraint.constant = 0;
        [self.view layoutIfNeeded];
    });
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
