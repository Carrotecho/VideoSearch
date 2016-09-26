//
//  AuthWindow.m
//  VideoSearch
//
//  Created by Easy Proger on 09.08.16.
//  Copyright © 2016 Easy Proger. All rights reserved.
//

#import "AuthWindow.h"


#import "AFNetworking/AFURLSessionManager.h"

@implementation AuthWindow



-(IBAction)registerUser:(id)sender {
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    
    NSURL *URL = [NSURL URLWithString:[self.serverPath stringByAppendingFormat:@"videoSearch.php?request=registerUser&login=%@&pass=%@",loginText.text,passText.text]];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            NSString*string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSLog(@"%@",string);
            NSError*e = nil;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&e];
            
            
            if (!json) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error json"
                                                                message:string
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                return;
            }
            
            Boolean result = [[json objectForKey:@"result"] boolValue];
            if (result) {
                
                NSString*access_token = [json objectForKey:@"access_token"];
                if (access_token == nil) {
                    access_token = [[json objectForKey:@"data"] objectForKey:@"access_token"];
                }
                
                NSString*refresh_token = [json objectForKey:@"refresh_token"];
                if (refresh_token == nil) {
                    refresh_token = [[json objectForKey:@"data"] objectForKey:@"refresh_token"];
                }
                
                if (self.delegate!=nil && [self.delegate respondsToSelector:@selector(authComplete:refreshToken:userName:)]) {
                    [self.delegate authComplete:access_token refreshToken:refresh_token userName:loginText.text];
                }
                
            }else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not Register"
                                                                message:[json objectForKey:@"error"]
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
            
            
            
        }
    }];
    [dataTask resume];
    

    
}


-(IBAction)login:(id)sender {
    
    
    
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    
    NSURL *URL = [NSURL URLWithString:[self.serverPath stringByAppendingFormat:@"videoSearch.php?request=auth&login=%@&pass=%@",loginText.text,passText.text]];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            NSString*string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSLog(@"%@",string);
            NSError*e = nil;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&e];
            
            
            if (!json) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error json"
                                                                message:string
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                return;
            }
            
            Boolean result = [[json objectForKey:@"result"] boolValue];
            if (result) {
                
                if (self.delegate!=nil && [self.delegate respondsToSelector:@selector(authComplete:refreshToken:userName:)]) {
                    [self.delegate authComplete:[[json objectForKey:@"data"] objectForKey:@"access_token"] refreshToken:[[json objectForKey:@"data"] objectForKey:@"refresh_token"] userName:loginText.text];
                }
                
            }else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not login"
                                                                message:[json objectForKey:@"error"]
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
            
            
            
        }
    }];
    [dataTask resume];
    
    
    
    
}


@end
