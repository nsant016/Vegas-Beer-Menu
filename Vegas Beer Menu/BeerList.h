// Developed by: Steven Aten and Nestor Santiago
// GitHub MIT License
//

#import <Foundation/Foundation.h>
#import "BeerAppDelegate.h"

@interface BeerList : NSObject
{
    NSManagedObjectContext *context;
}

@property (nonatomic, strong) NSMutableArray *beerList;
@property (nonatomic, retain) BeerAppDelegate *app;

- (void)loadAllItems;
- (void) awakeFromInsert;

@end
