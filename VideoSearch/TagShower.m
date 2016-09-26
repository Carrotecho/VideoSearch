//
//  TagShower.m
//  VideoSearch
//
//  Created by Easy Proger on 25.07.16.
//  Copyright © 2016 Easy Proger. All rights reserved.
//

#import "TagShower.h"
#import "TagViewCell.h"
#import "GMImagePickerController.h"

@interface TagShower ()

@end

@implementation TagShower



-(void)setDataToShow:(NSArray*)dataToShow {
    _dataToShow = dataToShow;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //[self.navigationItem setHidesBackButton:NO];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    [self.view setFrame:CGRectMake(0,0,screenWidth,screenHeight)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return [_dataToShow count];
}
static NSString *CellIdentifier = @"TagViewCell";

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TagViewCell *cell = (TagViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[TagViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [cell setDataToShow:[_dataToShow objectAtIndex:indexPath.row]];
    
    
    // Configure the cell...
    
    return cell;
}



-(void)playMovie:(NSURL*)url isLocalIdentifer:(int)isLocalIdentifer frameStart:(float)frameStart numFrames:(float)numFrames {
    
    CMTime timeRecovery = CMTimeMakeWithSeconds(frameStart/5.0, FPS);
    
    AVPlayer *player = [AVPlayer playerWithURL:url];
    AVPlayerViewController *playerViewController = [AVPlayerViewController new];
    
    playerViewController.player = player;
    [self presentViewController:playerViewController animated:YES completion:^{
        [player seekToTime:timeRecovery completionHandler:^(BOOL finished) {
            
            /* Start playback */
            [player play];
            
            /* Pause player in 3 seconds */
            [player performSelector:@selector(pause) withObject:nil afterDelay:numFrames/5.0];
            
        }];
    }];
    

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    NSDictionary*dataToShow = [_dataToShow objectAtIndex:indexPath.row];
    
    if ([[dataToShow objectForKey:@"typeMedia"] intValue] == 2) { // 2 is video
        // need show movie ;
        
        int isLocalIdentifer = [[dataToShow objectForKey:@"isLocalIdentifer"] intValue];
        
        
        
        float frameStart =[[dataToShow objectForKey:@"framesStart"] floatValue];
        float numFrames =[[dataToShow objectForKey:@"numFrames"] floatValue];
        
        
        
        if (isLocalIdentifer) {
            PHFetchResult* fetchResult = [PHAsset fetchAssetsWithLocalIdentifiers:@[[dataToShow objectForKey:@"nameFile"]] options:nil];
            
            if (fetchResult.count) {
                PHAsset*phasset = [fetchResult objectAtIndex:0];
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
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self playMovie:localVideoUrl isLocalIdentifer:isLocalIdentifer frameStart:frameStart numFrames:numFrames];
                        
                    });
                }];
            }
            
        }else {
            NSURL *videoURL = [NSURL URLWithString:[dataToShow objectForKey:@"nameFile"]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self playMovie:videoURL isLocalIdentifer:isLocalIdentifer frameStart:frameStart numFrames:numFrames];
            });
            
        }
        
        
        
        
        
        
        
        
        
    }
    
    
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
