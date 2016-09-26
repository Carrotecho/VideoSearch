//
//  AuthWindow.h
//  VideoSearch
//
//  Created by Easy Proger on 09.08.16.
//  Copyright © 2016 Easy Proger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "AuthWindowDelegate.h"



@interface AuthWindow : UIViewController {
    IBOutlet UITextField*loginText;
    IBOutlet UITextField*passText;
    IBOutlet UIButton*loginButton;

    
    
    
}



@property(nonatomic,readwrite) NSString* serverPath;
@property(nonatomic,readwrite) id<AuthWindowDelegate> delegate;
@end

