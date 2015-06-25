#import <Cocoa/Cocoa.h>

#import "BBCoreData.h"
#import "BBDefaultManagedObjectEntityMapping.h"
#import "BBDefaultManagedObjectPropertyMapping.h"
#import "BBManagedObjectEntityMapping.h"
#import "BBManagedObjectPropertyMapping.h"
#import "NSManagedObjectContext+BBCoreDataExtensions.h"
#import "NSManagedObjectContext+BBCoreDataImportExtensions.h"
#import "BBFoundation.h"
#import "BBFoundationDebugging.h"
#import "BBFoundationFunctions.h"
#import "BBFoundationMacros.h"
#import "BBSnakeCaseToLlamaCaseValueTransformer.h"
#import "NSArray+BBFoundationExtensions.h"
#import "NSBundle+BBFoundationExtensions.h"
#import "NSData+BBFoundationExtensions.h"
#import "NSFileManager+BBFoundationExtensions.h"
#import "NSMutableArray+BBFoundationExtensions.h"
#import "NSString+BBFoundationExtensions.h"
#import "NSURL+BBFoundationExtensions.h"
#import "BBBadgeView.h"
#import "BBGradientView.h"
#import "BBKit.h"
#import "BBKitCGImageFunctions.h"
#import "BBKitColorMacros.h"
#import "NSURL+BBKitExtensions.h"
#import "NSColor+BBKitExtensions.h"
#import "NSImage+BBKitExtensions.h"
#import "BBMediaPicker.h"
#import "BBMediaPlayer.h"
#import "BBReactiveKit.h"
#import "BBReactiveThumbnail.h"
#import "BBThumbnailGenerator+BBReactiveThumbnailExtensions.h"
#import "BBThumbnail.h"
#import "BBThumbnailAsyncOperation.h"
#import "BBThumbnailDefines.h"
#import "BBThumbnailDocumentOperation.h"
#import "BBThumbnailGenerator.h"
#import "BBThumbnailHTMLOperation.h"
#import "BBThumbnailImageOperation.h"
#import "BBThumbnailMovieOperation.h"
#import "BBThumbnailOperation.h"
#import "BBThumbnailOperationWrapper.h"
#import "BBThumbnailPDFOperation.h"
#import "BBThumbnailRTFOperation.h"
#import "BBThumbnailTextOperation.h"
#import "BBThumbnailVimeoOperation.h"
#import "BBThumbnailYouTubeOperation.h"
#import "BBTooltip.h"
#import "BBWebKit.h"

FOUNDATION_EXPORT double BBFrameworksVersionNumber;
FOUNDATION_EXPORT const unsigned char BBFrameworksVersionString[];

