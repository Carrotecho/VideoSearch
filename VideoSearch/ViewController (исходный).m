//
//  ViewController.m
//  VideoSearch
//
//  Created by Easy Proger on 24.07.16.
//  Copyright © 2016 Easy Proger. All rights reserved.
//

#import "ViewController.h"
#import "TagShower.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    serverPath = @"http://videosearchd-ru.1gb.ru/";
    
    isStoped = true;
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    [self.navigationController.view setFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    
    
    
    
}


- (NSData *)generatePostDataForData:(NSData *)uploadData
{
    // Generate the post header:
    NSString *post = [NSString stringWithCString:"--AaB03x\r\nContent-Disposition: form-data; name=\"upload[file]\"; filename=\"somefile\"\r\nContent-Type: application/octet-stream\r\nContent-Transfer-Encoding: binary\r\n\r\n" encoding:NSASCIIStringEncoding];
    
    // Get the post header int ASCII format:
    NSData *postHeaderData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    // Generate the mutable data variable:
    NSMutableData *postData = [[NSMutableData alloc] initWithLength:[postHeaderData length] ];
    [postData setData:postHeaderData];
    
    // Add the image:
    [postData appendData: uploadData];
    
    // Add the closing boundry:
    [postData appendData: [@"\r\n--AaB03x--" dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]];
    
    // Return the post data:
    return postData;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissModalViewControllerAnimated:YES];
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:@"public.image"]){
        NSLog(@"found an image");
    }
    else if ([mediaType isEqualToString:@"public.movie"]){
        NSURL* url = [info objectForKey:UIImagePickerControllerMediaURL];
        fileName = [url absoluteString];
        
        NSData *imageData = [NSData dataWithContentsOfURL:url];
        
        NSString *urlString=[NSString stringWithFormat:@"%@", [serverPath stringByAppendingString:@"upload.php"]];
        NSLog(@"url=== %@", urlString);
        
        NSMutableURLRequest*request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:urlString]];
        [request setHTTPMethod:@"POST"];
        
        NSString *boundary = @"---------------------------14737809831466499882746641449";
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
        [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
        
        /*  body of the post */
        
        NSMutableData *body = [NSMutableData data];
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        //Video Name with Date-Time
        NSDateFormatter *dateFormat=[[NSDateFormatter alloc]init];
        [dateFormat setDateFormat:@"yyyy-MM-dd-hh:mm:ssa"];
        NSString *currDate = [dateFormat stringFromDate:[NSDate date]];
        
        NSString *str = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"video-%@.mov\"\r\n", currDate];
        NSLog(@"String name::  %@",str);
        
        
        [body appendData:[[NSString stringWithString:str] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[NSData dataWithData:imageData]];
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        [request setHTTPBody:body];
        
        NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
        
        NSLog(@"result from webservice:::--> %@", returnString);
        
        
        NSError *e = nil;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:returnData options:kNilOptions error:&e];
        
        NSNumber *responses = [json objectForKey:@"result"];
        
        
        if (![responses boolValue]) {
            [self errorMessage:@"error upload video" code:114];
            return;
        }
        
        NSString*pathUploaded = [serverPath stringByAppendingString:[json objectForKey:@"data"]];
        
        if (!isStoped) return;
        
        isStoped = false;
        
        currentIndexRequest = 0;
        currentIndexFrame = 0;
        
        url = [NSURL URLWithString: pathUploaded];
        fileName = [url absoluteString];
        
        [self createDecompressor:url];
        [self generateImage:currentIndexFrame];
        
        NSLog(@"found a video");
        //NSData *webData = [NSData dataWithContentsOfURL:videoURL];
    }
    
}


-(IBAction)choiseFromPath:(id)sender {
    
 
    
    
    if (!isStoped) return;
    
    isStoped = false;
    currentIndexRequest = 0;
    currentIndexFrame = 0;
    
    NSURL*url = [NSURL URLWithString:path.text];
    fileName = [url absoluteString];
    [self createDecompressor:url];
    [self generateImage:currentIndexFrame];
}




-(IBAction)stopAll:(id)sender {
    currentIndexFrame = currentDurationVideo;
    isStoped = true;
}



-(IBAction)choiseVideo:(id)sender {
    
    
    
    
    
    
    
    if (!isStoped) return;
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.mediaTypes =
    [UIImagePickerController availableMediaTypesForSourceType:
     imagePicker.sourceType];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentModalViewController:imagePicker animated:YES];
}



-(void)imagesDone:(NSMutableArray*)images {
    
    
    //[_imgView setImage:[images objectAtIndex:0]];
    
    
    
}


- (NSString *) base64EncodeImage: (UIImage*)image {
    NSData *imagedata = UIImagePNGRepresentation(image);
    
    // Resize the image if it exceeds the 2MB API limit
    if ([imagedata length] > 2097152) {
        CGSize oldSize = [image size];
        CGSize newSize = CGSizeMake(800, oldSize.height / oldSize.width * 800);
        image = [self resizeImage: image toSize: newSize];
        imagedata = UIImagePNGRepresentation(image);
    }
    
    NSString *base64String = [imagedata base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn];
    return base64String;
}
- (UIImage *) resizeImage: (UIImage*) image toSize: (CGSize)newSize {
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(void)createDecompressor:(NSURL*)url {
    
    AVURLAsset *asset=[[AVURLAsset alloc] initWithURL:url  options:nil];
    
    naturalSize= asset.naturalSize;
    
    float scale = naturalSize.width/200.0;
    
    CGRect fff = _imgView.frame;
    fff.size.width = naturalSize.width/scale;
    fff.size.height = naturalSize.height/scale;
    [_imgView setFrame:fff];
    
    
    generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.requestedTimeToleranceAfter =  kCMTimeZero;
    generator.requestedTimeToleranceBefore =  kCMTimeZero;
    
    currentDurationVideo = CMTimeGetSeconds(asset.duration) *  FPS;
    
}


-(void)imageDoneCreateRequest:(NSArray*)data {

    if (isStoped) return;
    UIImage*image = [data objectAtIndex:0];
    
    
    
    [_imgView setImage:image];
    
    
    NSString *binaryImageData = [self base64EncodeImage:image];
    
    NSString *urlString = @"https://vision.googleapis.com/v1/images:annotate?key=";
    NSString *API_KEY = @"AIzaSyDjtqbhoOF9OmcDsAdZEye-til0nyh5BQI";
    
    NSString *requestString = [NSString stringWithFormat:@"%@%@", urlString, API_KEY];
    
    NSURL *url = [NSURL URLWithString: requestString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod: @"POST"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[[NSBundle mainBundle] bundleIdentifier] forHTTPHeaderField:@"X-Ios-Bundle-Identifier"];
    
    
    // Build our API request
    NSDictionary *paramsDictionary =
    @{@"requests":@[
              @{
                  @"image":
                      @{@"content":binaryImageData},
                  @"features":@[
                          @{@"type":@"LABEL_DETECTION",
                            @"maxResults":@10}
                          ]}]};
    
    
    NSError *error;
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:paramsDictionary options:0 error:&error];
    [request setHTTPBody: requestData];
    
    // Run the request on a background thread
    
    NSArray*dataRequest = [NSArray arrayWithObjects:request,[data objectAtIndex:1], nil];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self runRequestOnBackgroundThread: dataRequest];
    });
    
    
}

- (void)runRequestOnBackgroundThread: (NSArray*) dataRequest {
    if (isStoped) return;
    NSMutableURLRequest*request = [dataRequest objectAtIndex:0];
    float time = [[dataRequest objectAtIndex:1] floatValue];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^ (NSData *data, NSURLResponse *response, NSError *error) {
        if (data == NULL || error) {
            [self errorMessage:@"error in google API" code:101];
        }else {
            [self analyzeResults:data time:time];
        }
    }];
    [task resume];
}


- (void)analyzeResults: (NSData*)dataToParse time:(float)time {
    if (isStoped) return;
    // Update UI on the main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSError *e = nil;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:dataToParse options:kNilOptions error:&e];
        
        NSArray *responses = [json objectForKey:@"responses"];
        NSLog(@"%@", responses);
        NSDictionary *responseData = [responses objectAtIndex: 0];
        NSDictionary *errorObj = [json objectForKey:@"error"];
        
        
        // Check for errors
        if (errorObj) {
            NSString *errorString1 = @"Error code ";
            NSString *errorCode = [errorObj[@"code"] stringValue];
            NSString *errorString2 = @": ";
            NSString *errorMsg = errorObj[@"message"];
            NSLog(@"error %@",[NSString stringWithFormat:@"%@%@%@%@", errorString1, errorCode, errorString2, errorMsg]);
            [self errorMessage:[NSString stringWithFormat:@"%@%@%@%@", errorString1, errorCode, errorString2, errorMsg] code:101];
        } else {
           
            // Get label annotations
            NSDictionary *labelAnnotations = [responseData objectForKey:@"labelAnnotations"];
            NSInteger numLabels = [labelAnnotations count];
            NSMutableArray *labels = [[NSMutableArray alloc] init];
            if (numLabels > 0) {
                NSString *labelResultsText = @"";
                for (NSDictionary *label in labelAnnotations) {
                    NSString *labelString = [label objectForKey:@"description"];
                    //labelString = [labelString stringByAppendingFormat:@"&&%@",[label objectForKey:@"score"]];
                    [labels addObject:labelString];
                }
                for (NSString *label in labels) {
                    // if it's not the last item add a comma
                    if (labels[labels.count - 1] != label) {
                        NSString *commaString = [label stringByAppendingString:@","];
                        labelResultsText = [labelResultsText stringByAppendingString:commaString];
                    } else {
                        labelResultsText = [labelResultsText stringByAppendingString:label];
                    }
                }
                
                //labelResultsText = [NSString stringWithFormat:@"%@||%d,%d,%d",labelResultsText,colorA,colorB,colorC];
                labelMessage.text = labelResultsText;
                [self sendMessageToBase:labelResultsText time:time];
                
                
                
                return;
            } else {
                
                [self errorMessage:@"No labels found" code:102 ];
                NSLog(@"No labels found");
            }
        }
    });
    
}

-(NSData *)dataForPOSTWithDictionary:(NSDictionary *)aDictionary boundary:(NSString *)aBoundary {
    NSArray *myDictKeys = [aDictionary allKeys];
    NSMutableData *myData = [NSMutableData dataWithCapacity:1];
    NSString *myBoundary = [NSString stringWithFormat:@"--%@\r\n", aBoundary];
    
    for(int i = 0;i < [myDictKeys count];i++) {
        id myValue = [aDictionary valueForKey:[myDictKeys objectAtIndex:i]];
        [myData appendData:[myBoundary dataUsingEncoding:NSUTF8StringEncoding]];
        //if ([myValue class] == [[[NSString]] class]) {
        if ([myValue isKindOfClass:[NSString class]]) {
            [myData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", [myDictKeys objectAtIndex:i]] dataUsingEncoding:NSUTF8StringEncoding]];
            [myData appendData:[[NSString stringWithFormat:@"%@", myValue] dataUsingEncoding:NSUTF8StringEncoding]];
        } else if(([myValue isKindOfClass:[NSData class]])) {
            [myData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", [myDictKeys objectAtIndex:i], [myDictKeys objectAtIndex:i]] dataUsingEncoding:NSUTF8StringEncoding]];
            [myData appendData:[[NSString stringWithFormat:@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
            [myData appendData:myValue];
        } // eof if()
        [myData appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    } // eof for()
    [myData appendData:[[NSString stringWithFormat:@"--%@--\r\n", aBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    return myData;
}

-(void)sendMessageToBase:(NSString*)responsedLabels time:(float)time {
    if (isStoped) return;
    currentIndexRequest++;
    NSString *urlString = [serverPath stringByAppendingString:@"videoSearch.php"];//
    
    
    NSURL *url = [NSURL URLWithString: urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod: @"POST"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[[NSBundle mainBundle] bundleIdentifier] forHTTPHeaderField:@"X-Ios-Bundle-Identifier"];
    
    
    // Build our API request
    NSDictionary *paramsDictionary =
    @{
         @"request":@"sendToBaseLabels",
         @"name":fileName,
         @"labels":responsedLabels,
         @"indexFrame":[NSNumber numberWithInt:currentIndexRequest],
         @"time":[NSNumber numberWithFloat:time]
    };
    
    
    NSError *error;
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:paramsDictionary options:0 error:&error];
    [request setHTTPBody:requestData];
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self runRequestOnBackgroundThreadTobase: request];
    });
    
    
    
}

-(void)runRequestOnBackgroundThreadTobase:(NSMutableURLRequest*)request {
    if (isStoped) return;
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^ (NSData *data, NSURLResponse *response, NSError *error) {
        if (data == NULL || error) {
            [self errorMessage:@"error in google API" code:101];
        }else {
            [self analyzeResultsFrombase:data];
        }
    }];
    [task resume];
}

-(void)analyzeResultsFrombase:(NSData*)data {
    if (isStoped) return;
    dispatch_async(dispatch_get_main_queue(), ^{
  
        
        NSError *e = nil;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&e];
        
        NSNumber *responses = [json objectForKey:@"result"];
        
        if ([responses boolValue]) {
            // next image
            [self successAddToBase];
            
        }else {
            // error here
            [self errorMessage:[json objectForKey:@"data"] code:113];
        }
        
        
        
        
        
    });
}


-(IBAction)showTag:(id)sender {
    [self stopAll:nil];
    
    
    NSString *urlString =[serverPath stringByAppendingString:@"videoSearch.php"];
    
    
    NSURL *url = [NSURL URLWithString: urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod: @"POST"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[[NSBundle mainBundle] bundleIdentifier] forHTTPHeaderField:@"X-Ios-Bundle-Identifier"];
    
    NSDictionary *paramsDictionary =
    @{
      @"request":@"searchTag",
      @"label":tagToShow.text
    };
    
    NSError *error;
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:paramsDictionary options:0 error:&error];
    [request setHTTPBody:requestData];
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self runRequestOnBackgroundThreadShowTag: request];
    });
    
    
    
}
-(void)runRequestOnBackgroundThreadShowTag:(NSMutableURLRequest*)request {

    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^ (NSData *data, NSURLResponse *response, NSError *error) {
        if (data == NULL || error) {
            [self errorMessage:@"error in google API" code:101];
        }else {
            [self analyzeResultsShowTag:data];
        }
    }];
    [task resume];
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






-(void)successAddToBase {
    if (isStoped) return;
    
    if (currentIndexFrame < currentDurationVideo) {
        currentIndexFrame++;
        [self generateImage:currentIndexFrame];
    }
}

-(void)errorMessage:(NSString*)message code:(int)code {
    if (isStoped) return;
    
    labelMessage.text = message;
    if (currentIndexFrame < currentDurationVideo) {
        currentIndexFrame++;
        [self generateImage:currentIndexFrame];
    }
    
}

-(void)generateImage:(int)index
{
    if (isStoped) return;
    //labelMessage.text = @"";
    
    
    float scale    = naturalSize.width/200.0;
    CGSize maxSize = CGSizeMake(naturalSize.width/scale, naturalSize.height/scale);
    generator.maximumSize = maxSize;
    [generator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:CMTimeMake(index, FPS)]] completionHandler:^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){
        if (result != AVAssetImageGeneratorSucceeded) {
            labelMessage.text = @"couldn't generate thumbnail, error";
            NSLog(@"couldn't generate thumbnail, error:%@", error);
            return;
        }
        if (isStoped) return;
        //float second = CMTimeGetSeconds(actualTime);
        //CMTime timeRecovery = CMTimeMakeWithSeconds(second, FPS);
        
        
        NSArray*data = [NSArray arrayWithObjects:[UIImage imageWithCGImage:im],[NSNumber numberWithFloat:CMTimeGetSeconds(actualTime)],nil];
        [self performSelectorOnMainThread:@selector(imageDoneCreateRequest:) withObject:data waitUntilDone:NO];
    }];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
