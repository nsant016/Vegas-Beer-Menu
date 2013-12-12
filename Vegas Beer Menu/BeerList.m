// Developed by: Steven Aten and Nestor Santiago
// GitHub MIT License
//

#import "BeerList.h"
#import "Beer.h"
#import <CoreData/CoreData.h>

@implementation BeerList

// Beer list
@synthesize beerList, app;

-(id) init
{
    self = [ super init];
    if (self)
    {
        app = [[UIApplication sharedApplication] delegate];
        context = [app managedObjectContext];
        
        // The managed object context can manage undo, but we don't need it
        [context setUndoManager:nil];
        
        // Create all of the beers
        [self awakeFromInsert];
        
        // Load all of the beers into the beer list
        [self loadAllItems];
    }
    
    return self;
}

- (NSString *)itemArchivePath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    // Get one and only document directory from that list
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    
    return [documentDirectory stringByAppendingPathComponent:@"store.data"];
}

- (void)loadAllItems
{
    if (!beerList)
    {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *e = [NSEntityDescription entityForName:@"Beer" inManagedObjectContext:context];
        [request setEntity:e];
        
        NSError *error;
        NSMutableArray *result = [[context executeFetchRequest:request error:&error] mutableCopy];
        
        if (!result)
        {
            [NSException raise:@"Fetch failed"
                         format:@"Reason: %@", [error localizedDescription]];
        }
        
        beerList = [[NSMutableArray alloc] initWithArray:result];
    }
}

- (void) deleteall
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Beer" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *arr = [context executeFetchRequest:fetchRequest error:&error];
    for (NSManagedObject *managedObject in arr)
    {
        [context deleteObject:managedObject];
    }
    if (![context save:&error])
    {
        NSLog(@"could not delete");
    }
}

-(void) awakeFromInsert
{
    // Delete everything in Core Data
    [self deleteall];
    
    Beer *b1 = [NSEntityDescription insertNewObjectForEntityForName:@"Beer" inManagedObjectContext:context];
    
    b1.beerName = @"Abita Amber";
    b1.brewerName = @"sdfas";
    b1.alcoholVolume = @"10%";
    b1.logoImageURL = @"http://i1373.photobucket.com/albums/ag398/iOSFinalProject/BudLightLogo_zpsc689fe8a.jpg";
    b1.beerImageURL = @"http://i1373.photobucket.com/albums/ag398/iOSFinalProject/AbitaAmber_zps95902607.jpg";
//    [b1 setBeerName:@"Abita Amber"];
//    [b1 setBrewerName:@"Abita Brewing Company"];
//    [b1 setAlcoholVolume:@"4.5%"];
//    [b1 setLogoImageURL:@"http://i1373.photobucket.com/albums/ag398/iOSFinalProject/BudLightLogo_zpsc689fe8a.jpg"];
//    [b1 setBeerImageURL:@"http://i1373.photobucket.com/albums/ag398/iOSFinalProject/AbitaAmber_zps95902607.jpg"];
//    [b1 setBeerDescription:@"Amber is a Munich style lager brewed with crystal malt and Perle hops. It has a smooth, malty, slightly caramel flavor and a rich amber color. Abita Amber was the first beer offered by the brewery and continues to be our leading seller. Amber is Abita’s most versatile beer for pairing with food. It has been voted 'best beer' in numerous New Orleans reader polls and is used frequently in recipes of great Louisiana chefs. Because of its smooth, malty flavor, try it with smoked sausages, Louisiana boudin, or even with caviar. It’s great with crawfish and Cajun food. You might also enjoy it paired with a spicy gumbo or tomato-based pasta sauce. It also goes well also with fried catfish dipped in a tart, lemony tartar sauce. Parmesan, Pecorino and Romano cheeses are good pairings with Abita Amber."];
    
    NSError *error;
    if (![context save:&error])
    {
        NSLog(@"Failed to save - error %@", [error localizedDescription]);
    }
    else
    {
        NSLog(@"Beers successfully added to Beer list");
    }
}

@end
