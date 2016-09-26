//
//  ViewController.h
//  VideoSearch
//
//  Created by Easy Proger on 24.07.16.
//  Copyright © 2016 Easy Proger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "TagShower.h"
#import "Settings.h"
#import "GMImagePickerController.h"
#import "AuthWindow.h"

@interface ViewController : UIViewController<GMImagePickerControllerDelegate,AuthWindowDelegate> {
   IBOutlet UIImageView*_imgView;
    IBOutlet UITextField*path;
    IBOutlet UILabel*labelMessage;
    IBOutlet UITextField*tagToShow;
    IBOutlet UILabel*userNameLabel;
    IBOutlet UISegmentedControl*ruleSearching;
    IBOutlet UIProgressView* progressView;
    
    
    AuthWindow*authWindow;
    
    IBOutlet UIButton*pickerButton;
    
    int numProcessFile;
    NSMutableDictionary*dataToPushOnServer;
    
    NSString*serverPath;
    TagShower*tableTagShow;
    
    NSString*fileName;
    CGSize naturalSize;
    AVAssetImageGenerator *generator;
    Float64 currentIndexFrame;
    Float64 currentIndexRequest;
    Float64 currentDurationVideo;
    
    bool isStoped;
}

@property(nonatomic,readwrite) NSString* accessToken;
@property(nonatomic,readwrite) NSString* refreshToken;

@end

