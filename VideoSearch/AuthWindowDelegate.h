//
//  AuthWindowDelegate].h
//  VideoSearch
//
//  Created by Easy Proger on 09.08.16.
//  Copyright © 2016 Easy Proger. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@protocol AuthWindowDelegate <NSObject>

-(void)authComplete:(NSString*)accessToken refreshToken:(NSString*)refreshToken userName:(NSString*)userName;

@end