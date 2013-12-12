// Developed by: Steven Aten and Nestor Santiago
// GitHub MIT License
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Beer : NSManagedObject

@property (nonatomic, retain) NSString * alcoholVolume;
@property (nonatomic, retain) NSString * beerDescription;
@property (nonatomic, retain) NSString * beerImageURL;
@property (nonatomic, retain) NSString * beerName;
@property (nonatomic, retain) NSString * brewerName;
@property (nonatomic, retain) NSString * logoImageURL;

@end
