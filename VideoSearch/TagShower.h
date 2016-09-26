//
//  TagShower.h
//  VideoSearch
//
//  Created by Easy Proger on 25.07.16.
//  Copyright © 2016 Easy Proger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>

@interface TagShower : UITableViewController {
    NSArray*_dataToShow;
}
-(void)setDataToShow:(NSArray*)dataToShow;
@end
