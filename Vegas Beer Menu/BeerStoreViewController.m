// Developed by: Steven Aten
// GitHub MIT License
//

#import "BeerStoreViewController.h"
#import "Beer.h"
#import "BeerDetailViewController.h"

@interface BeerStoreViewController ()

@end

@implementation BeerStoreViewController
{
    // Context Core Data
    NSManagedObjectContext *context;
    
    // Beer containers
    NSMutableArray *beerarray;
    NSMutableArray *searchResults;
}

@synthesize tableView = _tableView;
@synthesize app;

- (id)init
{
    if (self){
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // Setup the BeerAppDelegate to start the Singleton
    app = [[UIApplication sharedApplication] delegate];
    context = [app managedObjectContext];
    
    // Clear all of the beers from core data
    [self deleteall];
    
    // Load all of the beers from core data
    [self loadBeer];
    
    // Instantiate the search list to filter beer search results
    searchResults = [NSMutableArray arrayWithCapacity:[beerarray count]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// The delete all method is responsible for cleaning out Core Data each time the app is run.
- (void) deleteall
{
    // Instantiate a fetch request for Core Data
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Let Core Data know what the table/entity is called (Beer)
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Beer" inManagedObjectContext:context];
    
    // Call the table/entity in the request
    [fetchRequest setEntity:entity];
    
    // Check if an error occurred
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

#pragma mark - Table View DataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Check if the search feature is in use
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        // Return the number of cells based on the letters entered by the user
        return [searchResults count];
    }
    else
    {
        // Return the full list of beers (the search feature is not in use)
        return [beerarray count];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return the same number that is set as the height of the beer cell in the storyboard
    return 71;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Setup the identifier for the beer cell in storyboard
    static NSString *simpleTableIdentifier = @"BeerCell";
    
    // Reuse (add/remove) cells for performance
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    // Check if there is no cell in use
    if (cell == nil)
    {
        // Create a new cell
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    //Beer *b = [beerarray objectAtIndex:indexPath.row];
    
    // Create a Beer object
    Beer *b;
    
    // Check if the search filter is being used
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        // Add the filter search result to the Beer object
        b = [searchResults objectAtIndex:indexPath.row];
    }
    else
    {
        // Add the full list of beers to the Beer object
        b = [beerarray objectAtIndex:indexPath.row];
    }
    
    // Manually create each label, image view, and other storyboard components for mutitple cell creation
    NSURL *imageURL = [NSURL URLWithString: b.logoImageURL];
    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    
    UIImageView *logoImageView = (UIImageView *)[cell viewWithTag:100];
    logoImageView.image = [UIImage imageWithData:imageData];
    
    UILabel *beerNameLabel = (UILabel *)[cell viewWithTag:101];
    beerNameLabel.text = b.beerName;
    
    UITextView *brewerNameTextView = (UITextView *)[cell viewWithTag:102];
    brewerNameTextView.text = b.brewerName;
    
    UILabel *alcoholVolumeLabel = (UILabel *)[cell viewWithTag:103];
    alcoholVolumeLabel.text = b.alcoholVolume;
    
    return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Check if the segue wants to move to the BeerDetailViewController
    if ([segue.identifier isEqualToString:@"showBeerDetails"])
    {
        // Create an instance of the BeerDetailViewController
        BeerDetailViewController *destViewController = segue.destinationViewController;
        
        // Instantiate a path for storing the specific cell
        NSIndexPath *indexPath = nil;
        
        // Check if the search filter is being used by the user
        if (self.searchDisplayController.isActive)
        {
            // Set the beer cell to the single filtered search result
            indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
            
            // Pass the beer object from the search results array (the single beer cell selected)
            destViewController.beer = [searchResults objectAtIndex:indexPath.row];
        }
        else
        {
            // Set the beer cell to the selected beer cell from the full beer list
            indexPath = [self.tableView indexPathForSelectedRow];
            
            // Pass the beer object from the full results array (the beer cell selected)
            destViewController.beer = [beerarray objectAtIndex:indexPath.row];
        }
    }
    else
    {
        // Logic for the random beer selection button
        int lowerBound = 0;
        int upperBound = beerarray.count;
        int rndValue = lowerBound + arc4random() % (upperBound - lowerBound);
        
        BeerDetailViewController *destViewController = segue.destinationViewController;
        
        destViewController.beer = [beerarray objectAtIndex:rndValue];
    }
}

-(void)filteredContentForSearchText:(NSString *)searchText  scope:(NSString*)scope
{
    [searchResults removeAllObjects];
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF.beerName Contains[cd] %@",searchText];
    
    searchResults = [NSMutableArray arrayWithArray:[beerarray filteredArrayUsingPredicate:resultPredicate]];
}

#pragma mark - UISearchDisplayController Delegate Methods

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filteredContentForSearchText:searchString
                                 scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                        objectAtIndex:[self.searchDisplayController.searchBar
                                                       selectedScopeButtonIndex]]];
    
    return YES;
}

/*
 Manually enter the beers into core data.
 This should always be at the bottom of the file due to the massive beer list.
 */
- (void) loadBeer
{
    Beer *b0 = [NSEntityDescription insertNewObjectForEntityForName:@"Beer" inManagedObjectContext:context];
    b0.beerName = @"Abita Amber";
    b0.brewerName = @"Abita Brewing Company";
    b0.alcoholVolume = @"4.5%";
    b0.logoImageURL = @"https://lh5.googleusercontent.com/-7AdT6TrbqfY/Uql0IvBxuvI/AAAAAAAAAE8/iQJzD3i-PiI/s437/Abita%2520Amber%2520Logo.png";
    b0.beerImageURL = @"https://lh4.googleusercontent.com/-1djSnz4MGC8/Uql0Ir1A20I/AAAAAAAAAFA/U1rFbitBxFs/s325/Abita%2520Amber.jpg";
    b0.beerDescription = @"Amber is a Munich style lager brewed with crystal malt and Perle hops. It has a smooth, malty, slightly caramel flavor and a rich amber color. Abita Amber was the first beer offered by the brewery and continues to be our leading seller. Amber is Abita’s most versatile beer for pairing with food. It has been voted 'best beer' in numerous New Orleans reader polls and is used frequently in recipes of great Louisiana chefs.";
    
    Beer *b1 = [NSEntityDescription insertNewObjectForEntityForName:@"Beer" inManagedObjectContext:context];
    b1.beerName = @"Affligem Blond";
    b1.brewerName = @"Brouwerij De Smedt / Brouwerij Affligem";
    b1.alcoholVolume = @"7%";
    b1.logoImageURL = @"https://lh3.googleusercontent.com/-TUEwm4NAOjw/Uql0J_iCpwI/AAAAAAAAAFw/yha7Xk6lt-I/s1024/Affligem%2520Blond%2520Logo.png";
    b1.beerImageURL = @"https://lh4.googleusercontent.com/-ZYEi87NqFss/Uql0J86b_gI/AAAAAAAAAFg/23ihVgmsFkQ/s300/Affligem%2520Blond.jpg";
    b1.beerDescription = @"Affligem Blonde, the classic clear blonde abbey ale, with a gentle roundness and 6.8% alcohol. Low on bitterness, it is eminently drinkable.";
    
    Beer *b2 = [NSEntityDescription insertNewObjectForEntityForName:@"Beer" inManagedObjectContext:context];
    b2.beerName = @"Angry Orchard Cider";
    b2.brewerName = @"Angry Orchard Cider Company";
    b2.alcoholVolume = @"5%";
    b2.logoImageURL = @"https://lh4.googleusercontent.com/-Rx1p4VzH4uI/Uql0LcqtiFI/AAAAAAAAAGY/byPXjDHeMnY/s551/Angry%2520Orchard%2520Logo.jpg";
    b2.beerImageURL = @"https://lh3.googleusercontent.com/-_vo-nqEL03U/Uql0LoXPNoI/AAAAAAAAAGc/Na7GNfXTGGk/s900/Angry%2520Orchard.jpg";
    b2.beerDescription = @"This crisp and refreshing cider mixes the sweetness of the apples with a subtle dryness for a balanced cider taste. The fresh apple aroma and slightly sweet, ripe apple flavor make this cider hard to resist.";
    
    Beer *b3 = [NSEntityDescription insertNewObjectForEntityForName:@"Beer" inManagedObjectContext:context];
    b3.beerName = @"Amstel Light";
    b3.brewerName = @"Amstel Brouwerij B. V.";
    b3.alcoholVolume = @"3.5%";
    b3.logoImageURL = @"https://lh6.googleusercontent.com/-b1NH50Sg2tA/Uql0Kad_08I/AAAAAAAAAGA/8v_LuGhcK0U/s380/Amstel%2520Light%2520Logo.jpg";
    b3.beerImageURL = @"https://lh3.googleusercontent.com/-H4IdmtFH_W4/Uql0KYiIi8I/AAAAAAAAAF4/RlFGy6U4cRI/s426/Amstel%2520Light.jpg";
    b3.beerDescription = @"A special light beer containing only 3.5% alcohol and approximately 35% fewer calories than regular lager beer. But every bit as thirst-quenching and refreshing.";
    
    Beer *b4 = [NSEntityDescription insertNewObjectForEntityForName:@"Beer" inManagedObjectContext:context];
    b4.beerName = @"Anchor Steam";
    b4.brewerName = @"Anchor Brewing Company";
    b4.alcoholVolume = @"4.9%";
    b4.logoImageURL = @"https://lh3.googleusercontent.com/-UMdLf54Bkmo/Uql0K1fSF4I/AAAAAAAAAGQ/Sviq_T0VsTQ/s720/Anchor%2520Steam%2520Logo.jpg";
    b4.beerImageURL = @"https://lh4.googleusercontent.com/-OZyRiH8lplY/Uql0LAVeryI/AAAAAAAAAGI/tkzQNapeQX4/s449/Anchor%2520Steam.jpg";
    b4.beerDescription = @"San Francisco's famous Anchor Steam®, the classic of American brewing tradition since 1896, is virtually handmade, with an exceptional respect for the ancient art of brewing. The deep amber color, thick creamy head, and rich flavor all testify to our traditional brewing methods. Anchor Steam is unique, for our brewing process has evolved over many decades and is like no other in the world. Anchor Steam derives its unusual name from the 19th century when 'steam' seems to have been a nickname for beer brewed on the West Coast of America under primitive conditions and without ice. The brewing methods of those days are a mystery and, although there are many theories, no one can say with certainty why the word 'steam' came to be associated with beer. For many decades Anchor alone has used this quaint name for its unique beer. In modern times, 'Steam' has become a trademark of Anchor Brewing.";
    
    Beer *b5 = [NSEntityDescription insertNewObjectForEntityForName:@"Beer" inManagedObjectContext:context];
    b5.beerName = @"Avery IPA";
    b5.brewerName = @"Avery Brewing Company";
    b5.alcoholVolume = @"6.5%";
    b5.logoImageURL = @"https://lh6.googleusercontent.com/-yf460KDEMWE/Uql0LnTuDAI/AAAAAAAAAGk/3jULIUDitQc/s300/Avery%2520IPA%2520Logo.jpg";
    b5.beerImageURL = @"https://lh6.googleusercontent.com/-2pyu3sQlRvw/Uql0MJSEwyI/AAAAAAAAAGs/2j94jJXkqgA/s512/Avery%2520IPA.jpg";
    b5.beerDescription = @"In the 1700’s one crafty brewer discovered that a healthy dose of hops and an increased alcohol content perserved his ales during the long voyage to India (as depicted in our label) to quench the thirst of British troops. Today, we tip our hat to that historic innovation by brewing Colorado’s hoppiest pale ale. Avery IPA demands to be poured into your favorite glass to truly appreciate the citrusy, floral bouquet and the rich, malty finish. Brewed by hopheads for hopheads!";
    
    Beer *b6 = [NSEntityDescription insertNewObjectForEntityForName:@"Beer" inManagedObjectContext:context];
    b6.beerName = @"Bass Pale Ale";
    b6.brewerName = @"Bass Brewers Limited";
    b6.alcoholVolume = @"5%";
    b6.logoImageURL = @"https://lh6.googleusercontent.com/-tapmsk4lP5w/Uql0MwyZl3I/AAAAAAAAAHE/k_zaj23HZG0/s217/Bass%2520Pale%2520Ale%2520Logo.png";
    b6.beerImageURL = @"https://lh3.googleusercontent.com/-MadlVt-QXcM/Uql0NJyBntI/AAAAAAAAAHM/DEf1dBJUPtE/s263/Bass%2520Pale%2520Ale.jpeg";
    b6.beerDescription = @"No description available at this time.";
    
    Beer *b7 = [NSEntityDescription insertNewObjectForEntityForName:@"Beer" inManagedObjectContext:context];
    b7.beerName = @"Budweiser";
    b7.brewerName = @"Anheuser-Busch";
    b7.alcoholVolume = @"5%";
    b7.logoImageURL = @"https://lh4.googleusercontent.com/-_vD07zjYg5Q/Uql0Ulco78I/AAAAAAAAALM/lDx21c5xhJk/s800/Budweiser%2520Logo.jpg";
    b7.beerImageURL = @"https://lh6.googleusercontent.com/-Jl6eJB6oDdQ/Uql0UwwdLiI/AAAAAAAAALE/fl0XudBS4Ic/s385/Budweiser.jpeg";
    b7.beerDescription = @"Brewed using a blend of imported and classic American aroma hops, and a blend of barley malts and rice. Budweiser is brewed with time-honored methods including 'kraeusening' for natural carbonation and Beechwood aging, which results in unparalleled balance and character.";
    
    Beer *b8 = [NSEntityDescription insertNewObjectForEntityForName:@"Beer" inManagedObjectContext:context];
    b8.beerName = @"Bud Light";
    b8.brewerName = @"Anheuser-Busch";
    b8.alcoholVolume = @"4.2%";
    b8.logoImageURL = @"https://lh6.googleusercontent.com/-OU9xtrMjTyk/Uql0UIrMhSI/AAAAAAAAAK8/jdYiAcSE4lc/s800/Bud%2520Light%2520Logo.jpg";
    b8.beerImageURL = @"https://lh3.googleusercontent.com/-PD76Z_jf-iw/Uql0Uv43N2I/AAAAAAAAAK4/QIns-tRMeRQ/s400/Bud%2520Light.jpg";
    b8.beerDescription = @"Bud Light is brewed using a blend of premium aroma hop varieties, both American-grown and imported, and a combination of barley malts and rice. Its superior drinkability and refreshing flavor makes it the world’s favorite light beer.";
    
    Beer *b9 = [NSEntityDescription insertNewObjectForEntityForName:@"Beer" inManagedObjectContext:context];
    b9.beerName = @"Beck’s Oktoberfest";
    b9.brewerName = @"Brauerei Beck & Co.";
    b9.alcoholVolume = @"5%";
    b9.logoImageURL = @"https://lh6.googleusercontent.com/-LKHwZIadqdw/Uql0Ni--eRI/AAAAAAAAAHk/cf_lqmtRss4/s286/Becks%2520Oktoberfest%2520Logo.jpg";
    b9.beerImageURL = @"https://lh3.googleusercontent.com/-XhMM7jKK38g/Uql0NzjWErI/AAAAAAAAAHg/TS3Lt3v-w54/s488/Becks%2520Oktoberfest.jpg";
    b9.beerDescription = @"This seasonal specialty is brewed in limited quantities. Beck’s brewmasters create the distinctive, malty-sweet, amber-colored brew so people throughout the world can celebrate the season popularly known in Germany as Oktoberfest.";
    
    Beer *b10 = [NSEntityDescription insertNewObjectForEntityForName:@"Beer" inManagedObjectContext:context];
    b10.beerName = @"Omme Gang BPA";
    b10.brewerName = @"Brewery Ommegang";
    b10.alcoholVolume = @"6.2%";
    b10.logoImageURL = @"https://lh5.googleusercontent.com/-mfKgtO5eRO4/UqnKgVSmZsI/AAAAAAAAArs/z2UkA0-A9ho/s261/Omme%2520Gang%2520Logo.jpg";
    b10.beerImageURL = @"https://lh6.googleusercontent.com/-e5LgxkRBcVs/UqnKgUkj6pI/AAAAAAAAArw/hBRS3W6mvqo/s512/Omme%2520Gang%2520BPA.jpg";
    b10.beerDescription = @"This fine pale ale has citrus and tropical fruit aromatic shared with a well-balanced – yet abundant – hop character. It uses our own Belgian yeast, five malts, two hops, and plenty of patience. Finishing touches include dry-hopping with Cascade hops and warm-cellaring.";
    
    Beer *b11 = [NSEntityDescription insertNewObjectForEntityForName:@"Beer" inManagedObjectContext:context];
    b11.beerName = @"Belzebuth";
    b11.brewerName = @"Brasserie Grain d' Orge";
    b11.alcoholVolume = @"13%";
    b11.logoImageURL = @"https://lh4.googleusercontent.com/-KweSkW30cPg/Uql0PdUpubI/AAAAAAAAAIk/s2KBjwk3SJM/s220/Belzebuth%2520Logo.gif";
    b11.beerImageURL = @"https://lh3.googleusercontent.com/-yca23QVhz-w/Uql0PkTjsWI/AAAAAAAAAIo/9yYLowtuPhU/s250/Belzebuth.jpeg";
    b11.beerDescription = @"Bottle (13% abv) and can (11.8%): Filtered. Ingredients: Water, Barley Malt, Wheat, Rice, Sugar, Hops. Alcohol content lowered in 2002 from 15% to 13% when brewery changed name from Jeanne d’Arc to Grain d’Orge. 'The dark amber coloured Belzebub offers an intense alcohol flavour with a strong supporting maltiness.' The 11.8% version is canned in Holland.";
    
    Beer *b12 = [NSEntityDescription insertNewObjectForEntityForName:@"Beer" inManagedObjectContext:context];
    b12.beerName = @"Belhaven Scottish Ale";
    b12.brewerName = @"Belhaven Brewery Company Ltd.";
    b12.alcoholVolume = @"5.2%";
    b12.logoImageURL = @"https://lh3.googleusercontent.com/-HO7jQTvduXk/Uql0OPopFaI/AAAAAAAAAH0/bfQLVyqZwNs/s153/Belhaven%2520Logo.jpeg";
    b12.beerImageURL = @"https://lh4.googleusercontent.com/-ei8KpZjtAnY/Uql0O3fLU8I/AAAAAAAAAII/WvgG9uNVikw/s360/Belhaven%2520Scottish%2520Ale.png";
    b12.beerDescription = @"No description available at this time.";
    
    Beer *b13 = [NSEntityDescription insertNewObjectForEntityForName:@"Beer" inManagedObjectContext:context];
    b13.beerName = @"Bell's Oberon Ale";
    b13.brewerName = @"Bell's Brewery, Inc.";
    b13.alcoholVolume = @"5.89%";
    b13.logoImageURL = @"https://lh5.googleusercontent.com/-I6G2O87KovQ/UqnQVF8_zcI/AAAAAAAAAsE/4hHiAppmqVE/s496/Bells%2520Oberon%2520Ale%2520Logo.jpg";
    b13.beerImageURL = @"https://lh4.googleusercontent.com/-Va3BllsaS-c/Uql0O2P_cVI/AAAAAAAAAIM/tUZ8aZ9SZmE/s350/Bells%2520Oberon%2520Ale.jpg";
    b13.beerDescription = @"An American wheat ale made with European ingredients. Belgium wheat malt and Czech Saaz hops provide a spicy, fruity balance to this seasonal ale. (Formerly known as Solsun)";
    
    Beer *b14 = [NSEntityDescription insertNewObjectForEntityForName:@"Beer" inManagedObjectContext:context];
    b14.beerName = @"Bells Two Hearted Ale";
    b14.brewerName = @"Bell's Brewery, Inc.";
    b14.alcoholVolume = @"7%";
    b14.logoImageURL = @"https://lh3.googleusercontent.com/-cgqXhBvFu7M/Uql0PZ0QkdI/AAAAAAAAAIw/gl-b8rLMib4/s288/Bells%2520Two%2520Hearted%2520Ale%2520Logo.jpg";
    b14.beerImageURL = @"https://lh5.googleusercontent.com/-1aIVE-nBgK0/Uql0PQFKZDI/AAAAAAAAAIQ/J8-o3igvFps/s300/Bells%2520Two%2520Hearted%2520Ale.jpg";
    b14.beerDescription = @"An India Pale Ale style well suited for adventurous trips to the Upper Peninsula. American malts and enormous hop additions give this beer a crisp finish and an incredibly floral aroma.";
    
    Beer *b15 = [NSEntityDescription insertNewObjectForEntityForName:@"Beer" inManagedObjectContext:context];
    b15.beerName = @"Bitburger";
    b15.brewerName = @"Bitburger Brauerei";
    b15.alcoholVolume = @"4.8%";
    b15.logoImageURL = @"https://lh3.googleusercontent.com/-SK80UxMsh_g/Uql0QCNZYXI/AAAAAAAAAIs/Ink5EDsV5aM/s277/Bitburger%2520Logo.jpeg";
    b15.beerImageURL = @"https://lh3.googleusercontent.com/-RD5iklbxEaQ/Uql0Q3wCYyI/AAAAAAAAAJA/ktO_35HyPyw/s349/Bitburger.jpg";
    b15.beerDescription = @"The classic Bitburger - a mature and most agreeable beer - is brewed with the best of ingredients in the same traditional way it has been for many, many years. The result is delicately tart and pleasantly bitter - with a strong hop taste.";
    
    Beer *b16 = [NSEntityDescription insertNewObjectForEntityForName:@"Beer" inManagedObjectContext:context];
    b16.beerName = @"Blue Moon";
    b16.brewerName = @"Coors Brewing Company (MillerCoors)";
    b16.alcoholVolume = @"5.4%";
    b16.logoImageURL = @"https://lh3.googleusercontent.com/-PBokA9YCQfw/Uql0RNQVrxI/AAAAAAAAAJU/mGERlhkU2zU/s239/Blue%2520Moon%2520Logo.jpeg";
    b16.beerImageURL = @"https://lh3.googleusercontent.com/-j61Drv0ja7E/Uql0RYe8SoI/AAAAAAAAAJg/vce74coVOiY/s391/Blue%2520Moon.jpg";
    b16.beerDescription = @"No description available at this time.";
    
    Beer *b17 = [NSEntityDescription insertNewObjectForEntityForName:@"Beer" inManagedObjectContext:context];
    b17.beerName = @"Brooklyn Brown Ale";
    b17.brewerName = @"Brooklyn Brewery";
    b17.alcoholVolume = @"5.6%";
    b17.logoImageURL = @"https://lh6.googleusercontent.com/-ZTIDpVREKTs/Uql0S_q1fSI/AAAAAAAAAKE/55ko-WWL420/s500/Brooklyn%2520Brown%2520Logo.jpg";
    b17.beerImageURL = @"https://lh5.googleusercontent.com/-NgNEZ9Pols8/Uql0S_3wKVI/AAAAAAAAAKM/13XW8deGmUQ/s400/Brooklyn%2520Brown.jpg";
    b17.beerDescription = @"Brooklyn Brown Ale, made exclusively with American ingredients, won Bronze medals at the Great American Beer Festival in the Strong Ale Category in 1991 and in the American Brown Ale Category in 1992. Brooklyn Brown uses pale, crystal, chocolate, and black malts to attain a complex creamy texture. It is more heavily hopped than its British forbears.";
    
    Beer *b18 = [NSEntityDescription insertNewObjectForEntityForName:@"Beer" inManagedObjectContext:context];
    b18.beerName = @"Brooklyn Post Road";
    b18.brewerName = @"Brooklyn Brewery";
    b18.alcoholVolume = @"5%";
    b18.logoImageURL = @"https://lh3.googleusercontent.com/-1G3Z9efyp-w/Uql0TqNzl_I/AAAAAAAAAKc/4hSPDn9ud2g/s200/Brooklyn%2520Post%2520Road%2520Logo.png";
    b18.beerImageURL = @"https://lh4.googleusercontent.com/-qS09mAolPnI/Uql0T6t7QGI/AAAAAAAAAKg/nIbZi6Yuwxs/s350/Brooklyn%2520Post%2520Road.jpg";
    b18.beerDescription = @"Early American colonialists, seeking natural ingredients for brewing ales, turned to pumpkins, which were plentiful, flavorful and nutritious. Blended with barley malt, pumpkins became a commonly used beer ingredient. Post Road Pumpkin Ale brings back this tasty tradition. Hundreds of pounds of pumpkins are blended into the mash of each batch, creating a beer with an orange amber color, warm pumpkin aroma, biscuity malt center, and crisp finish.";
    
    Beer *b19 = [NSEntityDescription insertNewObjectForEntityForName:@"Beer" inManagedObjectContext:context];
    b19.beerName = @"Blanche De Bruxelles";
    b19.brewerName = @"Brasserie Lefebvre";
    b19.alcoholVolume = @"4.5%";
    b19.logoImageURL = @"https://lh5.googleusercontent.com/-Rbb0DqERJxA/Uql0Q3zUHTI/AAAAAAAAAJI/Ejrhgx1_jEs/s345/Blanche%2520De%2520Bruxelles%2520Logo.jpg";
    b19.beerImageURL = @"https://lh4.googleusercontent.com/-6MNSWkx3IhM/Uql0QwHTLpI/AAAAAAAAAJM/hqJykB7PyQU/s400/Blanche%2520De%2520Bruxelles%2520.gif";
    b19.beerDescription = @"Ingredients: Malted barley; wheat (40%); coriander; bitter orange peel; sugar; hops; yeast. Blanche de Bruxelles owes its natural cloudiness to the large percentage (40 %) of wheat that goes into its composition. The natural spice aromas of coriander and bitter orange peels are added during the brewing process. The brewing method, which includes infusion, is very slow. The beer, which is not filtered, is bottled and refermented with yeast and brewing sugar. You need only take a sip of this delicious drink to appreciate the fresh and mellow flavour with its hint of orange. It is really not like any other beer. Always served chiled, between 3°C and 6°C.";
    
    Beer *b20 = [NSEntityDescription insertNewObjectForEntityForName:@"Beer" inManagedObjectContext:context];
    b20.beerName = @"Tommy Knocker Butt Head Bock";
    b20.brewerName = @"Tommyknocker Brewery";
    b20.alcoholVolume = @"8.2%";
    b20.logoImageURL = @"https://lh6.googleusercontent.com/-kMv2IHtViyo/Uql1QpDiFgI/AAAAAAAAAo4/XwxKiXWHHMQ/s172/Tommy%2520Knocker%2520Butt%2520Head%2520Bock%2520Logo.jpeg";
    b20.beerImageURL = @"https://lh4.googleusercontent.com/-YnLTNEP0-Ds/Uql1RWON1lI/AAAAAAAAAo8/TG3WwGWZfcw/s350/Tommy%2520Knocker%2520Butt%2520Head%2520Bock.jpg";
    b20.beerDescription = @"This award winning doppelbock (8.2% alcohol by volume) lager is brewed with a generous supply of Munich, carapils, caramel and chocolate malts and is fermented with Bavarian lager yeast. The resulting caramel sweetness and rich mouthfeel are complimented by the mild bittering of German Hallertau hops. 1997 Great American Beer Festival Silver Medal Winner";
    
    Beer *b21 = [NSEntityDescription insertNewObjectForEntityForName:@"Beer" inManagedObjectContext:context];
    b21.beerName = @"Weyerbacher Blithering Idiot";
    b21.brewerName = @"Weyerbacher Brewing Co.";
    b21.alcoholVolume = @"11%";
    b21.logoImageURL = @"https://lh4.googleusercontent.com/-rgN_V02i3W4/Uql1VnL8CmI/AAAAAAAAArA/uiob7_PySEY/s640/Weyerbacher%2520Blithering%2520Idiot.jpg";
    b21.beerImageURL = @"https://lh4.googleusercontent.com/-2ss4DqO10LY/Uql1VQUFoLI/AAAAAAAAAq0/zpZJlCpH7L4/s266/Weyerbacher%2520Blithering%2520Idiot.jpeg";
    b21.beerDescription = @"At Weyerbacher, we prefer to brew things true to European style guidelines, so our barley wine is definitely on the malty side, without being overly sweet. Notes of date or perhaps fig on the palate follow a pleasurably malty aroma to your taste buds. The finish is warm and fruity, and begs for the next sip.";
    
    Beer *b22 = [NSEntityDescription insertNewObjectForEntityForName:@"Beer" inManagedObjectContext:context];
    b22.beerName = @"Mendocino Seasonal Black IPA";
    b22.brewerName = @"Mendocino Brewing Company (United Breweries Group)";
    b22.alcoholVolume = @"6%";
    b22.logoImageURL = @"https://lh4.googleusercontent.com/-DipboiQjFWk/Uql042GreQI/AAAAAAAAAdo/iYLt3tOV9gc/s422/Mendocino%2520Seasonal%2520Black%2520IPA%2520Logo.png";
    b22.beerImageURL = @"https://lh4.googleusercontent.com/-p-N4MxBnvEM/Uql0h3IvOOI/AAAAAAAAARk/YJs9yL6wulA/s400/Goose%2520Island%2520IPA.jpg";
    b22.beerDescription = @"A tantalizing twist on a unique style! This ale has a seductive ebony hue, with an aroma that is bold, full of fresh floral and citrus hops, with just a pinch of pine. The rich aroma blends delightfully into the enigmatic body of rich roasted malts with chocolatey, nutty flavors. Then ensues the tang of refreshing orange peel and a citrus hop finish that lightly lingers and then beckons you to revisit this most enjoyable seasonal ale.";
    
    Beer *b23 = [NSEntityDescription insertNewObjectForEntityForName:@"Beer" inManagedObjectContext:context];
    b23.beerName = @"Dale's Pale Ale";
    b23.brewerName = @"Oskar Blues Brewing Company";
    b23.alcoholVolume = @"6.5%";
    b23.logoImageURL = @"https://lh3.googleusercontent.com/-J8MMZPHRLx4/Uql0XntLYhI/AAAAAAAAAMk/X-RUxABPXTU/s803/Dale%25E2%2580%2599s%2520Pale%2520Ale%2520Logo.jpg";
    b23.beerImageURL = @"https://lh6.googleusercontent.com/-MKwiaVaFFgY/Uql0X1Bt1eI/AAAAAAAAAMo/BVTCjB1WuWg/s289/Dale%25E2%2580%2599s%2520Pale%2520Ale.jpg";
    b23.beerDescription = @"Brewed with hefty amounts of European malts and four kinds of American hops, it delivers a blast of hop aromas, a rich middle of malt and hops, and a thrilling finish. It weighs in at 6.5 % alcohol by volume. Why squeeze such a big brew into a little can? Because we think fun in the great outdoors calls for great beer. Our cans go where bottled beers can't, where flavorless canned beers don't belong. And no matter where you drink Dale's Pale Ale, our can protect it from light and oxidation far better than bottles do.";
    
    Beer *b24 = [NSEntityDescription insertNewObjectForEntityForName:@"Beer" inManagedObjectContext:context];
    b24.beerName = @"Deviant Dale's";
    b24.brewerName = @"Oskar Blues Brewery";
    b24.alcoholVolume = @"8.9%";
    b24.logoImageURL = @"https://lh5.googleusercontent.com/-gRlq4DkKav0/Uql0ZElrMLI/AAAAAAAAANQ/tTCYMxX9ews/s576/Deviant%2520Dale%25E2%2580%2599s%2520Logo.jpeg";
    b24.beerImageURL = @"https://lh5.googleusercontent.com/-MxYgINqDqnY/Uql0ZKUzCAI/AAAAAAAAANY/lIwc2EskZ0o/s350/Deviant%2520Dale%25E2%2580%2599s.jpg";
    b24.beerDescription = @"This beer is intended to be a sensory assault for hop lovers. At 8.0% ABV, four hop additions during the brew process, and a final wallop of excessive Columbus dry-hopping, this beer is meant to say one thing: MORE HOPS! Perfect for these cool winter nights, The Deviant is a returning favorite from the little brewery in Lyons, Colorado that started the Canned Revolution!";
    
    Beer *b25 = [NSEntityDescription insertNewObjectForEntityForName:@"Beer" inManagedObjectContext:context];
    b25.beerName = @"Carlsberg";
    b25.brewerName = @"Carlsberg Danmark A/S";
    b25.alcoholVolume = @"4.6%";
    b25.logoImageURL = @"https://lh4.googleusercontent.com/-maZOmz_hYOc/Uql0VWmZXnI/AAAAAAAAALY/KP-KZxivmgU/s251/Carlsberg%2520Logo.jpeg";
    b25.beerImageURL = @"https://lh4.googleusercontent.com/-ai_rSbhD1rk/Uql0V4TTVhI/AAAAAAAAALw/g44dKxjFauo/s512/Carlsberg.jpg";
    b25.beerDescription = @"No description available at this time.";
    
    Beer *b26 = [NSEntityDescription insertNewObjectForEntityForName:@"Beer" inManagedObjectContext:context];
    b26.beerName = @"Cigar City Florida Cracker";
    b26.brewerName = @"Cigar City Brewing";
    b26.alcoholVolume = @"5%";
    b26.logoImageURL = @"https://lh4.googleusercontent.com/-Pzt2Qe5RsDg/Uql0VXQ1p9I/AAAAAAAAALc/KREQZmls7bo/s240/Cigar%2520City%2520Florida%2520Cracker%2520Logo.jpg";
    b26.beerImageURL = @"https://lh4.googleusercontent.com/-dIi8tHq95d8/Uql0Vy2j9vI/AAAAAAAAALs/7eAUAVSJNjk/s350/Cigar%2520City%2520Florida%2520Cracker.jpg";
    b26.beerDescription = @"No description available at this time.";
    
    Beer *b27 = [NSEntityDescription insertNewObjectForEntityForName:@"Beer" inManagedObjectContext:context];
    b27.beerName = @"Corona Extra";
    b27.brewerName = @"Grupo Modelo S.A. de C.V.";
    b27.alcoholVolume = @"4.6%";
    b27.logoImageURL = @"https://lh4.googleusercontent.com/-4mZXjCWGSnU/Uql0XDmayJI/AAAAAAAAAMM/74ASjwkeyqc/s362/Corona%2520Extra%2520Logo.png";
    b27.beerImageURL = @"https://lh4.googleusercontent.com/--Xi8wvyGxb4/Uql0XRslapI/AAAAAAAAAMg/RSkhPJ--ssU/s512/Corona%2520Extra.jpg";
    b27.beerDescription = @"Corona Extra is the number-one selling beer in Mexico and the leading export brand from Mexico. This pilsener type beer was first brewed in 1925 by Cervecería Modelo, located in Mexico City.";
    
    Beer *b28 = [NSEntityDescription insertNewObjectForEntityForName:@"Beer" inManagedObjectContext:context];
    b28.beerName = @"Coors Light";
    b28.brewerName = @"Coors Brewing Company (MillerCoors)";
    b28.alcoholVolume = @"4.2%";
    b28.logoImageURL = @"https://lh6.googleusercontent.com/-124jJJHrsuo/Uql0XCrERBI/AAAAAAAAAMw/3UPUlWRokNU/s720/Coors%2520Light%2520Logo.jpg";
    b28.beerImageURL = @"https://lh5.googleusercontent.com/-jU3GTvgK3to/Uql0XDjHqiI/AAAAAAAAAMU/1Fn5eTzkRRc/s512/Coors%2520Light.jpg";
    b28.beerDescription = @"A premium light beer with 105 calories per 12-ounce serving.";
    
    Beer *b29 = [NSEntityDescription insertNewObjectForEntityForName:@"Beer" inManagedObjectContext:context];
    b29.beerName = @"Samuel Smith Organic Chocolate Stout";
    b29.brewerName = @"Samuel Smith Old Brewery";
    b29.alcoholVolume = @"5%";
    b29.logoImageURL = @"https://lh5.googleusercontent.com/-42YZDa_l8Zc/Uql1GYjqOeI/AAAAAAAAAj0/ytRL9UZ7Nd8/s512/Samuel%2520Smith%2520Organic%2520Chocolate%2520Stout%2520Logo.png";
    b29.beerImageURL = @"https://lh5.googleusercontent.com/-B_bho7qdAKc/Uql1GyMMSxI/AAAAAAAAAkI/24fOxDvB-dA/s512/Samuel%2520Smith%2520Organic%2520Chocolate%2520Stout.png";
    b29.beerDescription = @"Ingredients: Water; Organic malted barley; Organic cane sugar; Yeast; Organic hops; Organic cocoa extract; Carbon dioxide Brewed with well water (the original well, sunk in 1758, is still in use with the hard well water being drawn from 85 feet underground), the gently roasted organic cocoa extract impart a delicious, smooth and creamy character, with inviting deep flavours and a delightful finish - this is a marriage of satisfying stout and luxurious chocolate.";
    
    Beer *b30 = [NSEntityDescription insertNewObjectForEntityForName:@"Beer" inManagedObjectContext:context];
    b30.beerName = @"Rogue Dead Guy Ale";
    b30.brewerName = @"Rogue Ales";
    b30.alcoholVolume = @"6.5%";
    b30.logoImageURL = @"https://lh5.googleusercontent.com/-WrC7J7TOuUI/Uql1D_WwLiI/AAAAAAAAAjM/kxrODau97qY/s640/Rogue%2520Dead%2520Guy%2520Ale%2520Logo.jpg";
    b30.beerImageURL = @"https://lh5.googleusercontent.com/-201dp3CUOX8/Uql1EL3votI/AAAAAAAAAi8/hmmlnIY1SCA/s512/Rogue%2520Dead%2520Guy%2520Ale.jpg";
    b30.beerDescription = @"Dead Guy is a German-style Maibock made with Rogue’s proprietary 'PacMan' ale yeast. It is deep honey in color with a malty aroma, rich hearty flavor and a well balanced finish. Dead Guy is created from Northwest Harrington, Klages, Maier Munich and Carastan malts, along with Perle and Saaz Hops.";
    
    Beer *b31 = [NSEntityDescription insertNewObjectForEntityForName:@"Beer" inManagedObjectContext:context];
    b31.beerName = @"Delirium Tremens";
    b31.brewerName = @"Brouwerij Huyghe";
    b31.alcoholVolume = @"8.5%";
    b31.logoImageURL = @"https://lh4.googleusercontent.com/-UX0M8Rh6X3I/Uql0YyR7-4I/AAAAAAAAANI/zxjkiSBm65o/s400/Delirium%2520Tremens.jpg";
    b31.beerImageURL = @"https://lh5.googleusercontent.com/-JDsil-G2JCU/Uql0YxJoSuI/AAAAAAAAANM/L5lbxm6yXkA/s512/Delirium%2520Tremens.png";
    b31.beerDescription = @"The particular character and the unique taste of 'Delirium Tremens' result from the use of three different kinds of yeast. Its very original packing, which resembles cologne ceramics, and the colourful label contribute to its success.";
    
    Beer *b32 = [NSEntityDescription insertNewObjectForEntityForName:@"Beer" inManagedObjectContext:context];
    b32.beerName = @"Delirium Nocturnum";
    b32.brewerName = @"Brouwerij Huyghe";
    b32.alcoholVolume = @"8.5%";
    b32.logoImageURL = @"https://lh4.googleusercontent.com/-b4-3Vbs8XNs/Uql0X8BjesI/AAAAAAAAAMs/HagOtKsqqKA/s225/Delirium%2520Nocturnum%2520Logo.jpeg";
    b32.beerImageURL = @"https://lh3.googleusercontent.com/-qlDwYBjrIPg/Uql0YCDJ3KI/AAAAAAAAANU/lEFI-zUsUwA/s512/Delirium%2520Nocturnum.jpg";
    b32.beerDescription = @"Colour and sight: Dark brown-red. A compact white-yellow, stable and lacing head. Scent: Touches of caramel, mocha and chocolate. Spices such as liquorice and coriander are also present. Flavour: Initially, a very good mouthfeel of alcohol and softness. This is followed by an increasing bitterness, partially from the hop, but also from the roasted malt and chocolate malt. Towards the end a nice balance between bitterness, sour and sweet.";
    
    Beer *b33 = [NSEntityDescription insertNewObjectForEntityForName:@"Beer" inManagedObjectContext:context];
    b33.beerName = @"Dos Equis XX Amber";
    b33.brewerName = @"FEMSA - Cuauhtémoc-Moctezuma (Heineken)";
    b33.alcoholVolume = @"4.7%";
    b33.logoImageURL = @"https://lh4.googleusercontent.com/-g5KkFdJv02c/Uql0anXs_aI/AAAAAAAAAOY/pg5UzPZHyhw/s640/Dos%2520Equis%2520XX%2520Amber%2520Logo.jpg";
    b33.beerImageURL = @"https://lh4.googleusercontent.com/-k7jAng-bs2c/Uql0bFT6sMI/AAAAAAAAAOU/XnzsetgwtV4/s250/Dos%2520Equis%2520XX%2520Amber.jpg";
    b33.beerDescription = @"Dos Equis Amber is a rich, full-bodied Mexican import with a reddish-gold color and is made from the finest ingredients, representing the brand’s traditional Mexican heritage. The history of Dos Equis Amber is traced to the development of the popular Oktoberfest-style of Vienna lager originally created during the mid-19th century.";
    
    Beer *b34 = [NSEntityDescription insertNewObjectForEntityForName:@"Beer" inManagedObjectContext:context];
    b34.beerName = @"Indian Brown Ale";
    b34.brewerName = @"Dogfish Head Brewery";
    b34.alcoholVolume = @"7.2%";
    b34.logoImageURL = @"https://lh3.googleusercontent.com/-PTUu07ZCSZg/Uql0akwvZfI/AAAAAAAAAOM/WNDVUK_YaqU/s500/Dogfish%2520Head%2520Indian%2520Brown%2520Ale%2520Logo.jpg";
    b34.beerImageURL = @"https://lh3.googleusercontent.com/-CRhAjS7xFqA/Uql0a57qadI/AAAAAAAAAOQ/mUnTu2Byrx4/s400/Dogfish%2520Head%2520Indian%2520Brown%2520Ale.png";
    b34.beerDescription = @"The beer has characteristics of each style that inspired it: the color of an American Brown, the caramel notes of a Scotch Ale, and the hopping regiment of an India Pale Ale. We dry-hop the Indian Brown Ale in a similar fashion to our 60 Minute IPA and 90 Minute IPA. This beer is brewed with Aromatic barley and organic brown sugar. ";
    
    Beer *b35 = [NSEntityDescription insertNewObjectForEntityForName:@"Beer" inManagedObjectContext:context];
    b35.beerName = @"60 Min IPA";
    b35.brewerName = @"Dogfish Head Brewery";
    b35.alcoholVolume = @"6%";
    b35.logoImageURL = @"https://lh6.googleusercontent.com/-zuCmbyNQlYQ/Uql0ZdRXThI/AAAAAAAAANs/HJUKFwol7fE/s506/Dogfish%2520Head%252060%2520Min%2520IPA%2520Logo.png";
    b35.beerImageURL = @"https://lh4.googleusercontent.com/-riYAuxRJ-e4/Uql0aOvO1VI/AAAAAAAAANw/3VmkQcA_1r0/s512/Dogfish%2520Head%252060%2520Min%2520IPA.jpg";
    b35.beerDescription = @"A session India Pale Ale brewed with Warrior, Amarillo & ’Mystery Hop X.’ A powerful East Coast I.P.A. with a lot of citrusy hop character. THE session beer for beer geeks like us! 6% abv 60 ibu Tasting Notes: Citrus, cedar, pine & candied-orange flavors, floral. Food Pairing recommendations: Spicy foods, pesto, grilled salmon, soy-based dishes, pizza. Glassware recommendation: Pint Wine comparable: Busty Chardonnay In case you care... the average 12 oz. serving has 209 calories.";
    
    Beer *b36 = [NSEntityDescription insertNewObjectForEntityForName:@"Beer" inManagedObjectContext:context];
    b36.beerName = @"90 Min IPA";
    b36.brewerName = @"Dogfish Head Brewery";
    b36.alcoholVolume = @"9%";
    b36.logoImageURL = @"https://lh3.googleusercontent.com/-BikePuW3Tn4/Uql0aBtdInI/AAAAAAAAAN0/VEBoAjqJq74/s225/Dogfish%2520Head%252090%2520Min%2520IPA%2520Logo.jpg";
    b36.beerImageURL = @"https://lh6.googleusercontent.com/-UISON5Ku7Kc/Uql0aTPjhII/AAAAAAAAAOE/gDmCH1ZDSy4/s512/Dogfish%2520Head%252090%2520Min%2520IPA.jpg";
    b36.beerDescription = @"Esquire Magazine calls our 90 Minute I.I.PA., 'perhaps the best I.P.A. in America.' An Imperial I.P.A. brewed to be savored from a snifter. A big beer with a great malt backbone that stands up to the extreme hopping rate. This beer is an excellent candidate for use with Randall The Enamel Animal! 90 ibu Tasting Notes: Brandied fruitcake, raisiney, citrusy.";
    
    Beer *b37 = [NSEntityDescription insertNewObjectForEntityForName:@"Beer" inManagedObjectContext:context];
    b37.beerName = @"Duvel Belgian Golden Ale";
    b37.brewerName = @"Duvel";
    b37.alcoholVolume = @"8.5%";
    b37.logoImageURL = @"https://lh4.googleusercontent.com/-DW_YZz0oXj4/Uql0bSqNEFI/AAAAAAAAAOs/kaM-e7nkCUg/s640/Duvel%2520Belgian%2520Golden%2520Ale%2520Logo.jpg";
    b37.beerImageURL = @"https://lh3.googleusercontent.com/-Dj47OToptYQ/Uql0ba0QgyI/AAAAAAAAAO0/l0Q5Gx8O7LY/s383/Duvel%2520Belgian%2520Golden%2520Ale.jpg";
    b37.beerDescription = @"No description available at this time.";
    
    Beer *b38 = [NSEntityDescription insertNewObjectForEntityForName:@"Beer" inManagedObjectContext:context];
    b38.beerName = @"Erdinger Champ Hefe-Weizen";
    b38.brewerName = @"Erdinger Weissbräu";
    b38.alcoholVolume = @"4.7%";
    b38.logoImageURL = @"https://lh6.googleusercontent.com/-ZRIFyqGTdYo/Uql0b5WpG8I/AAAAAAAAAOw/zPeCcmVduog/s532/Erdinger%2520Champ%2520Hefe-Weizen%2520Logo.jpg";
    b38.beerImageURL = @"https://lh6.googleusercontent.com/-MS1HJ0NJI7A/Uql0cITQRjI/AAAAAAAAAO4/rBgwW-ez-o0/s311/Erdinger%2520Champ%2520Hefe-Weizen.jpg";
    b38.beerDescription = @"No description available at this time.";
    
    /*
    Beer *b39 = [NSEntityDescription insertNewObjectForEntityForName:@"Beer" inManagedObjectContext:context];
    b39.beerName = @"";
    b39.brewerName = @"";
    b39.alcoholVolume = @"";
    b39.logoImageURL = @"";
    b39.beerImageURL = @"";
    b39.beerDescription = @"";
     */
    
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
    
    beerarray = [[NSMutableArray alloc] initWithArray:result];
}

@end
