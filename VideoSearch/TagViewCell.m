//
//  TagViewCell.m
//  VideoSearch
//
//  Created by Easy Proger on 25.07.16.
//  Copyright © 2016 Easy Proger. All rights reserved.
//

#import "TagViewCell.h"
#import "GMImagePickerController.h"

@implementation TagViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    
    
    
    
    
}


-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    
    imgView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 50, 50)];
    [self.contentView addSubview:imgView];
    
    CGRect frame = CGRectMake(60, 5, screenWidth-60, 25);
    label = [[UILabel alloc] initWithFrame:frame];
    label.tag = 1;
    [self.contentView addSubview:label];
    
    frame = CGRectMake(60, 20, screenWidth-60, 20);
    label2 = [[UILabel alloc] initWithFrame:frame];
    label2.tag = 1;
    [label2 setFont:[UIFont systemFontOfSize:10]];
    [self.contentView addSubview:label2];
    
    frame = CGRectMake(60, 35, screenWidth-60, 20);
    label3 = [[UILabel alloc] initWithFrame:frame];
    label3.tag = 1;
    [label3 setFont:[UIFont systemFontOfSize:5]];
    [self.contentView addSubview:label3];
    
    return self;
}



-(void)imageDone:(UIImage*)image {
    [imgView setImage:image];
}



-(void)showMovie:(NSURL*)url isLocalIdentifer:(int)isLocalIdentifer frameStart:(float)frameStart {
    
    AVURLAsset *asset=[[AVURLAsset alloc] initWithURL:url  options:nil];
    generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.requestedTimeToleranceAfter =  kCMTimeZero;
    generator.requestedTimeToleranceBefore =  kCMTimeZero;
    
    CGSize size = [asset naturalSize];
    
    float delta = size.width/50.0;
    CMTime timeRecovery = CMTimeMakeWithSeconds(frameStart/5.0, FPS);
    
    CGSize maxSize = CGSizeMake(50.0, size.height/delta);
    generator.maximumSize = maxSize;
    [generator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:timeRecovery]] completionHandler:^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){
        if (result != AVAssetImageGeneratorSucceeded) {
            NSLog(@"couldn't generate thumbnail, error:%@", error);
            return;
        }
        
        [self performSelectorOnMainThread:@selector(imageDone:) withObject:[UIImage imageWithCGImage:im] waitUntilDone:NO];
    }];
    
}

-(void)setDataToShow:(NSDictionary*)data {
    
    
    NSLog(@"%@",data);
    
    float frameStart =[[data objectForKey:@"framesStart"] floatValue];
    float numFrames =[[data objectForKey:@"numFrames"] floatValue];
    
    
    
    NSString*nameFile = [data objectForKey:@"nameFile"];
    
    
    int isLocalIdentifer = [[data objectForKey:@"isLocalIdentifer"] intValue];
    int typeMedia = [[data objectForKey:@"typeMedia"] intValue];
    
    
    if (isLocalIdentifer) {
        
        label2.text = @"localFile";
        
        PHFetchResult* fetchResult = [PHAsset fetchAssetsWithLocalIdentifiers:@[nameFile] options:nil];
        
        if (fetchResult.count) {
            PHAsset*phasset = [fetchResult objectAtIndex:0];
            if (phasset.mediaType == PHAssetMediaTypeVideo) {
                
                PHVideoRequestOptions* options = [[PHVideoRequestOptions alloc] init];
                options.version = PHVideoRequestOptionsVersionOriginal;
                options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
                options.networkAccessAllowed = YES;
                options.progressHandler =  ^(double progress,NSError *error,BOOL* stop, NSDictionary* dict) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                    });
                };
                
                [[PHImageManager defaultManager] requestAVAssetForVideo:phasset options:options resultHandler:^(AVAsset * _Nullable avasset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                    
                    AVURLAsset*urlAsset = (AVURLAsset*)avasset;
                    
                    if (!urlAsset) return;
                    NSURL* localVideoUrl = urlAsset.URL;
                    if (!localVideoUrl) return;
                    
                    [self showMovie:localVideoUrl isLocalIdentifer:isLocalIdentifer frameStart:frameStart];
                }];
            }else if (phasset.mediaType == PHAssetMediaTypeImage) {
                PHContentEditingInputRequestOptions* options = [[PHContentEditingInputRequestOptions alloc] init];
                
                options.networkAccessAllowed = YES;
                options.progressHandler = ^(double progress, BOOL *stop) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                    });
                };
                
                [phasset requestContentEditingInputWithOptions:options completionHandler:^(PHContentEditingInput * _Nullable contentEditingInput, NSDictionary * _Nonnull info) {
                    UIImage* displaySizeImage = contentEditingInput.displaySizeImage;
                    CGSize originalSize = [displaySizeImage size];
                    
                    float delta = originalSize.width/50.0;
                    CGSize newSize = CGSizeMake(50.0, originalSize.height/delta);
                    
                    UIGraphicsBeginImageContext( newSize );
                    [displaySizeImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
                    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // Update the UI
                        imgView.image = newImage;
                    });
                    
                }];
            }
        }else {
            NSLog(@"not found on device");
            label2.text = @"not found on device";
        }
    }else {
        
        if (typeMedia == PHAssetMediaTypeVideo) {
            [self showMovie:[NSURL URLWithString:[data objectForKey:@"nameFile"]] isLocalIdentifer:isLocalIdentifer frameStart:frameStart];
        }else if (typeMedia == PHAssetMediaTypeImage) {
            
            
            NSURL *imageURL = [NSURL URLWithString:[data objectForKey:@"nameFile"]];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    // Update the UI
                    imgView.image = [UIImage imageWithData:imageData];
                });
            });
            
        }
        
        
        label2.text = [[data objectForKey:@"nameFile"] lastPathComponent];
    }
    
    
    label3.text =[data objectForKey:@"location"];
    
    if (typeMedia == PHAssetMediaTypeImage) {
        
    }else if (typeMedia == PHAssetMediaTypeVideo) {
        label.text = [NSString stringWithFormat:@"TimeStart:%f TimeEnd:%f",frameStart/5.0,(frameStart+numFrames)/5.0,nil];
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
