//
//  ViewController.m
//  VideoSearch
//
//  Created by Easy Proger on 24.07.16.
//  Copyright © 2016 Easy Proger. All rights reserved.
//

#import "ViewController.h"
#import "TagShower.h"
#import "AFURLRequestSerialization.h"
#import "AFURLSessionManager.h"



@interface ViewController ()

@end

@implementation ViewController


#define ACCESS_TOKEN @"accessToken"
#define REFRESH_TOKEN @"refreshToken"

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    serverPath = @"http://easyprogerdeveloper1.com.mastertest.ru/";
    
    //serverPath = @"http://192.168.200.2/videoSearch/http/";
    
    isStoped = true;
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    [self.navigationController.view setFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    
    //
    
    
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    self.accessToken = [[defaults objectForKey:ACCESS_TOKEN] mutableCopy];
    self.refreshToken = [[defaults objectForKey:REFRESH_TOKEN] mutableCopy];
    
    
    
    progressView.hidden = YES;
    
    
    
    
    
    [self checkAuth];
}

-(IBAction)logout:(id)sender {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    
    self.accessToken = nil;
    self.refreshToken = nil;
    
    [defaults setObject:self.accessToken forKey:ACCESS_TOKEN];
    [defaults setObject:self.refreshToken forKey:REFRESH_TOKEN];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self checkAuth];
}

-(void)authComplete:(NSString *)accessToken refreshToken:(NSString *)refreshToken userName:(NSString*)userName {
    if (authWindow) {
        [authWindow dismissViewControllerAnimated:YES completion:nil];
        authWindow = nil;
    }
    
    userNameLabel.text = userName;
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    
    self.accessToken = accessToken;
    self.refreshToken = refreshToken;

    [defaults setObject:accessToken forKey:ACCESS_TOKEN];
    [defaults setObject:refreshToken forKey:REFRESH_TOKEN];
    
    [[NSUserDefaults standardUserDefaults] synchronize];;
    
    
    self.view.userInteractionEnabled = YES;
    
    
}

-(void)authWindow {
    
    authWindow = [[AuthWindow alloc] initWithNibName:@"AuthWindow" bundle:nil];
    authWindow.serverPath = serverPath;
    authWindow.delegate = self;
    
    [self.navigationController presentViewController:authWindow animated:YES completion:nil];
    
}



-(void)checkAuth {
    
    
    
    if (!self.accessToken && !self.refreshToken) {
        
        [self authWindow];
        
        return;
    }
    
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    
    NSURL *URL = [NSURL URLWithString:[serverPath stringByAppendingFormat:@"videoSearch.php?request=testAuth&accessToken=%@&refreshToken=%@",self.accessToken,self.refreshToken]];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            NSString*string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSLog(@"%@",string);
            NSError*e = nil;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&e];
            
            self.view.userInteractionEnabled = YES;
            
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
                userNameLabel.text = [json objectForKey:@"user_id"] ;
            }else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not login"
                                                                message:[json objectForKey:@"error"]
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                
                [self authWindow];
            }

        }
    }];
    [dataTask resume];
}



-(IBAction)choiseFromPath:(id)sender {
    
 
    
    
    if (!isStoped) return;
    
    isStoped = false;
    currentIndexRequest = 0;
    currentIndexFrame = 0;
    
    NSURL*url = [NSURL URLWithString:path.text];
    fileName = [url absoluteString];
    
    
    
    
    
    
}






-(IBAction)choiseVideo:(id)sender {
    
    
    
    
    
    
    
    if (!isStoped) return;
    
    
    GMImagePickerController *picker = [[GMImagePickerController alloc] init];
    picker.delegate = self;
    picker.title = @"Custom title";
    
    picker.customDoneButtonTitle = @"Finished";
    picker.customCancelButtonTitle = @"Nope";
    picker.customNavigationBarPrompt = @"Take a new photo or select an existing one!";
    
    picker.colsInPortrait = 3;
    picker.colsInLandscape = 5;
    picker.minimumInteritemSpacing = 2.0;
    
    //    picker.allowsMultipleSelection = NO;
    //    picker.confirmSingleSelection = YES;
    //    picker.confirmSingleSelectionPrompt = @"Do you want to select the image you have chosen?";
    
    //    picker.showCameraButton = YES;
    //    picker.autoSelectCameraImages = YES;
    
    picker.modalPresentationStyle = UIModalPresentationPopover;
    
    //    picker.mediaTypes = @[@(PHAssetMediaTypeImage)];
    
    //    picker.pickerBackgroundColor = [UIColor blackColor];
    //    picker.pickerTextColor = [UIColor whiteColor];
    //    picker.toolbarBarTintColor = [UIColor darkGrayColor];
    //    picker.toolbarTextColor = [UIColor whiteColor];
    //    picker.toolbarTintColor = [UIColor redColor];
    //    picker.navigationBarBackgroundColor = [UIColor blackColor];
    //    picker.navigationBarTextColor = [UIColor whiteColor];
    //    picker.navigationBarTintColor = [UIColor redColor];
    //    picker.pickerFontName = @"Verdana";
    //    picker.pickerBoldFontName = @"Verdana-Bold";
    //    picker.pickerFontNormalSize = 14.f;
    //    picker.pickerFontHeaderSize = 17.0f;
    //    picker.pickerStatusBarStyle = UIStatusBarStyleLightContent;
    //    picker.useCustomFontForNavigationBar = YES;
    
    UIPopoverPresentationController *popPC = picker.popoverPresentationController;
    popPC.permittedArrowDirections = UIPopoverArrowDirectionAny;
    popPC.sourceView = pickerButton;
    popPC.sourceRect = pickerButton.bounds;
    //    popPC.backgroundColor = [UIColor blackColor];
    
    //[self showViewController:picker sender:nil];

    [self presentViewController:picker animated:YES completion:nil];
    
    
}



#pragma mark - GMImagePickerControllerDelegate

- (void)assetsPickerController:(GMImagePickerController *)picker didFinishPickingAssets:(NSArray *)assetArray
{
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    
    
    
    if (!assetArray.count) return;
    
    
    if (dataToPushOnServer){
        [dataToPushOnServer removeAllObjects];
    }else {
        dataToPushOnServer = [[NSMutableDictionary alloc] init];
    }
    
    
    numProcessFile = assetArray.count;
    
  
    
    self.view.userInteractionEnabled = NO;
    
    progressView.hidden = NO;
    
    for (int i = 0; i < assetArray.count; i++) {
        PHAsset*asset = [assetArray objectAtIndex:i];
        NSLog(@"assetGet %d %@",i,asset);
        if (asset.mediaType == PHAssetMediaTypeVideo) {
            
            
            
            PHVideoRequestOptions* options = [[PHVideoRequestOptions alloc] init];
            options.version = PHVideoRequestOptionsVersionOriginal;
            options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
            options.networkAccessAllowed = YES;
            options.progressHandler =  ^(double progress,NSError *error,BOOL* stop, NSDictionary* dict) {
                NSLog(@"progress %lf",progress);  //never gets called
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    progressView.progress = progress;
                });
                
            };
            
            [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset * _Nullable avasset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                NSString*location = @"";
                if (asset.location && asset.location.description) {
                    location = asset.location.description;
                }
                

                [self compressVideo:avasset location:location urlToPlay:asset.localIdentifier type:asset.mediaType isLocalIdentifer:1];
            }];
            
            
        }else if (asset.mediaType == PHAssetMediaTypeImage) {
            
            PHContentEditingInputRequestOptions* options = [[PHContentEditingInputRequestOptions alloc] init];

            options.networkAccessAllowed = YES;
            options.progressHandler = ^(double progress, BOOL *stop) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    progressView.progress = progress;
                });
            };
            
            [asset requestContentEditingInputWithOptions:options completionHandler:^(PHContentEditingInput * _Nullable contentEditingInput, NSDictionary * _Nonnull info) {
                
                NSURL *urlToResource = contentEditingInput.fullSizeImageURL;
                
                
                
                
                
                
                UIImage* displaySizeImage = contentEditingInput.displaySizeImage;
                NSString*location = @"";
                if (asset.location && asset.location.description) {
                    location = asset.location.description;
                }
                
                
                [self compressImage:displaySizeImage urlToResource:urlToResource location:location urlToPlay:asset.localIdentifier type:asset.mediaType isLocalIdentifer:1];
                
            }];
            
        }
    }
    
    
    
    
    NSLog(@"GMImagePicker: User ended picking assets. Number of selected items is: %lu", (unsigned long)assetArray.count);
}





-(IBAction)pushFromLinks:(id)sender {
    
    if (dataToPushOnServer){
        [dataToPushOnServer removeAllObjects];
    }else {
        dataToPushOnServer = [[NSMutableDictionary alloc] init];
    }
    
    
    NSMutableArray*paths = [NSMutableArray arrayWithArray:[path.text componentsSeparatedByString:@"&&&"]];
    
        
    if (!paths.count) return;
    
    numProcessFile = paths.count;
    
    
    self.view.userInteractionEnabled = NO;
    
    progressView.hidden = NO;
    progressView.progress = 0;
    
    for (int i = 0; i < paths.count; i++) {
        NSString*pathFile = [paths objectAtIndex:i];
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        NSURL *URL = [NSURL URLWithString:pathFile];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
        NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                progressView.progress = downloadProgress.fractionCompleted;
            });
            
            
        } destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
            NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
            
            NSString*fileNameSuggested = [response suggestedFilename];
            NSString*extension = [fileNameSuggested pathExtension];
            
            NSDateFormatter *dateFormat=[[NSDateFormatter alloc]init];
            [dateFormat setDateFormat:@"yyyyMMddhhmmssa"];
            NSString *currDate = [dateFormat stringFromDate:[NSDate date]];
            
            
            return [documentsDirectoryURL URLByAppendingPathComponent:
                        [@"video" stringByAppendingFormat:@"%@.%@",currDate,extension]
                    ];
        } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
            NSLog(@"File downloaded to: %@", filePath);
            progressView.progress = 1.0;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                progressView.progress = 1.0;
            });
            
            NSString*extension = [[[filePath lastPathComponent] pathExtension] lowercaseString];
            if ([extension isEqualToString:@"mp4"] || [extension isEqualToString:@"mov"]) {
                
                [self compressVideo:[AVURLAsset  assetWithURL:filePath] location:@"" urlToPlay:pathFile type:PHAssetMediaTypeVideo isLocalIdentifer:0];
                
                
            }else if ([extension isEqualToString:@"jpg"] || [extension isEqualToString:@"png"]){
                
                UIImage*image = [UIImage imageWithContentsOfFile:[filePath path]];
                
                if (image) {
                    [self compressImage:image urlToResource:filePath location:@"" urlToPlay:pathFile type:PHAssetMediaTypeImage isLocalIdentifer:0];
                }else {
                    numProcessFile--;
                    [self preocessFileEnd];
                }
            }else {
                numProcessFile--;
                [self preocessFileEnd];
            }
        }];
        [downloadTask resume];
        
        
    }
    
    
}



-(void)compressImage:(UIImage*)displaySizeImage urlToResource:(NSURL*)urlToResource location:(NSString*)location urlToPlay:(NSString*)urlToPlay type:(int)type isLocalIdentifer:(int)isLocalIdentifer {
   
    
    if (!urlToResource || !displaySizeImage) {
        numProcessFile--;
        [self preocessFileEnd];
        return;
    }
    
    NSString* documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString*tmpName = [urlToResource lastPathComponent];
    
    NSString* myDocumentPath= [documentsDirectory stringByAppendingPathComponent:tmpName];
    
    CGSize originalSize = [displaySizeImage size];
    
    float delta = originalSize.width/320.0;
    CGSize newSize = CGSizeMake(320.0, originalSize.height/delta);
    
    UIGraphicsBeginImageContext( newSize );
    [displaySizeImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    NSData *pngData = UIImagePNGRepresentation(newImage);
    [pngData writeToFile:myDocumentPath atomically:YES];
    
    
    
    [dataToPushOnServer setObject:@{
                                    @"isLocalIdentifer":[NSNumber numberWithInt:isLocalIdentifer],
                                    @"typeID":[NSNumber numberWithInt:type],
                                    @"location":location,
                                    @"urlPush":myDocumentPath,
                                    @"url":urlToPlay,
                                    @"type":@"image"
                                    } forKey:tmpName];
    
    [self preocessFileEnd];
}


-(void)compressVideo:(AVAsset*)avasset  location:(NSString*)location urlToPlay:(NSString*)urlToPlay type:(int)type isLocalIdentifer:(int)isLocalIdentifer {
    AVURLAsset*urlAsset = (AVURLAsset*)avasset;
    
    if (!urlAsset){
        numProcessFile--;
        [self preocessFileEnd];
        return;
    }
    NSURL* localVideoUrl = urlAsset.URL;
    if (!localVideoUrl) {
        numProcessFile--;
        [self preocessFileEnd];
        return;
    }
    
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:urlAsset presetName:AVAssetExportPresetLowQuality];
    NSString* documentsDirectory=     [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    
    NSString*tmpName = [localVideoUrl lastPathComponent];
    
    NSString* myDocumentPath= [documentsDirectory stringByAppendingPathComponent:tmpName];
    NSURL *url = [[NSURL alloc] initFileURLWithPath:myDocumentPath];
    
    
    NSLog(@"%@",[url absoluteString]);
    
    //Check if the file already exists then remove the previous file
    if ([[NSFileManager defaultManager]fileExistsAtPath:myDocumentPath])
    {
        [[NSFileManager defaultManager]removeItemAtPath:myDocumentPath error:nil];
    }
    
    
    
    
    
    
    exportSession.outputURL = url;
    //set the output file format if you want to make it in other file format (ex .3gp)
    exportSession.outputFileType = AVFileTypeMPEG4;
    exportSession.shouldOptimizeForNetworkUse = YES;
    
    
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        switch ([exportSession status])
        {
            case AVAssetExportSessionStatusFailed:
            {
                NSLog(@"Export session failed %@",[exportSession error]);
                numProcessFile--;
                [self preocessFileEnd];
            }
                break;
            case AVAssetExportSessionStatusCancelled:
            {
                NSLog(@"Export canceled");
            }
                break;
            case AVAssetExportSessionStatusCompleted:
            {
                
                [dataToPushOnServer setObject:@{
                                                @"isLocalIdentifer":[NSNumber numberWithInt:isLocalIdentifer],
                                                @"typeID":[NSNumber numberWithInt:type],
                                                @"location":location,
                                                @"urlPush":myDocumentPath,
                                                @"url":urlToPlay,
                                                @"type":@"video"
                                                } forKey:tmpName];
                NSLog(@"Successful!");
                [self preocessFileEnd];
            }
                break;
            case AVAssetExportSessionStatusExporting:
            {
                float progress = [exportSession progress];
                NSLog(@"progress %f",progress);
            }
                break;
            default:
                break;
        }
    }];
}


-(void)DownloadVideo
{
    
}




-(void)preocessFileEnd {
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        progressView.progress = (float)numProcessFile/(float)[[dataToPushOnServer allKeys] count];
    });
    
    
    if (numProcessFile == [[dataToPushOnServer allKeys] count]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //Update the progress view
            [self readyToSendData:dataToPushOnServer];
        });
    }
    
    
}




-(void)readyToSendData:(NSMutableDictionary*)dataToSend {
    progressView.progress = 0.0;
    
    NSString *urlString=[NSString stringWithFormat:@"%@", [serverPath stringByAppendingString:@"videoSearch.php"]];
    NSLog(@"url=== %@", urlString);

    
    NSMutableDictionary*parametrs = [NSMutableDictionary dictionaryWithDictionary:dataToSend];
    
    [parametrs setObject:@"pushFiles" forKey:@"request"];
    [parametrs setObject:self.accessToken forKey:@"accessToken"];
    [parametrs setObject:self.refreshToken forKey:@"refreshToken"];
    
    
    
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:urlString parameters:parametrs constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        for (int i = 0; i < [[dataToSend allKeys] count]; i++) {
            
            NSString*key = [[dataToSend allKeys] objectAtIndex:i];
            NSDictionary*object = [dataToSend objectForKey:key];
            
            NSLog(@"%@",object);
            
            NSString*fileNamePush = [[object objectForKey:@"urlPush"] lastPathComponent];
            NSString* pathExt = [fileNamePush pathExtension];
            
            NSString*mimeType = @"";
            if ([[pathExt lowercaseString] isEqualToString:@"jpg"]) {
                mimeType = @"image/jpeg";
            }else if ([[pathExt lowercaseString] isEqualToString:@"png"]) {
                mimeType = @"image/png";
            }else if ([[pathExt lowercaseString] isEqualToString:@"mp4"]) {
                mimeType = @"video/mp4";
            }else if ([[pathExt lowercaseString] isEqualToString:@"mov"]) {
                mimeType = @"video/mpeg";
            }
            NSLog(@"add %@ %@",[object objectForKey:@"urlPush"],fileNamePush);
            [formData appendPartWithFileURL:[NSURL fileURLWithPath:[object objectForKey:@"urlPush"]] name:key fileName:fileNamePush mimeType:mimeType error:nil];
        }
        
        
        
    } error:nil];
    
    
    
    
    
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSURLSessionUploadTask *uploadTask;
    uploadTask = [manager
                  uploadTaskWithStreamedRequest:request
                  progress:^(NSProgress * _Nonnull uploadProgress) {
                      // This is not called back on the main queue.
                      // You are responsible for dispatching to the main queue for UI updates
                      dispatch_async(dispatch_get_main_queue(), ^{
                          //Update the progress view
                          dispatch_async(dispatch_get_main_queue(), ^{
                              progressView.progress = uploadProgress.fractionCompleted;

                          });
                          
                          //[progressView setProgress:uploadProgress.fractionCompleted];
                      });
                  }
                  completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                      if (error) {
                          NSLog(@"Error: %@", error);
                      } else {
                          NSLog(@"%@ %@", response, responseObject);
                          
                          NSError*e = nil;
                          NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&e];
                          
                          NSString*string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                          NSLog(@"%@",string);
                          //
                          
                          
                          for (int i = 0; i < [[dataToSend allKeys] count]; i++) {
                              
                              NSString*key = [[dataToSend allKeys] objectAtIndex:i];
                              NSDictionary*object = [dataToSend objectForKey:key];
                              
                              NSLog(@"%@",object);
                              
                              
                              NSString*fileNamePush = [[object objectForKey:@"urlPush"] lastPathComponent];
                              
                              
                              NSFileManager *fileManager = [NSFileManager defaultManager];
                              NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                              
                              NSString *filePath = [documentsPath stringByAppendingPathComponent:fileNamePush];
                              NSError *error;
                              BOOL success = [fileManager removeItemAtPath:filePath error:&error];
                              if (!success) {
                                  NSLog(@"%@",error);
                              }
                          }
                          
                      }
                      
                      
                      self.view.userInteractionEnabled = YES;
                      progressView.hidden = YES;
                  }];
    
    [uploadTask resume];
    
}


//Optional implementation:
-(void)assetsPickerControllerDidCancel:(GMImagePickerController *)picker
{
    NSLog(@"GMImagePicker: User pressed cancel button");
}





-(IBAction)showTag:(id)sender {
    
       
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    
    NSURL *URL = [NSURL URLWithString:[serverPath stringByAppendingFormat:@"videoSearch.php?request=searchTag&accessToken=%@&refreshToken=%@&labels=%@&rule=%@",self.accessToken,self.refreshToken,[tagToShow.text lowercaseString],[ruleSearching titleForSegmentAtIndex:[ruleSearching selectedSegmentIndex]]]];
    
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
                
                [self analyzeResultsShowTag:responseObject];
                
            }else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error API"
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



-(void)analyzeResultsShowTag:(NSData*)data {
  
    dispatch_async(dispatch_get_main_queue(), ^{
        
        
        NSError *e = nil;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&e];
        
        
        NSLog(@"%@",json);
        
        NSNumber *responses = [json objectForKey:@"result"];
        
        if ([responses boolValue]) {
            NSArray*dataToShow = [json objectForKey:@"data"];
           
            if (dataToShow && [dataToShow isKindOfClass:[NSArray class] ] && [dataToShow count]) {
                tableTagShow = [[TagShower alloc] initWithStyle:UITableViewStylePlain];
                [tableTagShow setDataToShow:dataToShow];
                [self.navigationController pushViewController:tableTagShow animated:YES];
            }else {
                labelMessage.text = [json objectForKey:@"data"];
            }
            
        }else {
            // error here
            [self errorMessage:[json objectForKey:@"data"] code:113];
        }
    });
}






-(void)errorMessage:(NSString*)message code:(int)code {
    if (isStoped) return;
    
    labelMessage.text = message;
        
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
