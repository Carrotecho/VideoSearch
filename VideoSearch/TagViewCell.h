//
//  TagViewCell.h
//  VideoSearch
//
//  Created by Easy Proger on 25.07.16.
//  Copyright © 2016 Easy Proger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Settings.h"
@interface TagViewCell : UITableViewCell {
    AVAssetImageGenerator*generator;
    UIImageView*imgView;
    UILabel*label;
    UILabel*label2;
    UILabel*label3;
}



-(void)setDataToShow:(NSDictionary*)data ;
@end
