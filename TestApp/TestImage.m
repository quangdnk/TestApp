//
//  TestImage.m
//  TestApp
//
//  Created by AsianTech on 6/2/15.
//  Copyright (c) 2015 AsianTech. All rights reserved.
//

#import "TestImage.h"
#import <ImageIO/ImageIO.h>
#import <ImageIO/CGImageSource.h>
#import <CoreGraphics/CoreGraphics.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/CGImageMetadata.h>
@interface TestImage ()

@end

@implementation TestImage

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSString *path = [[NSBundle mainBundle]pathForResource:@"P_20150601_115626 2" ofType:@"jpg"];
    
    
    NSURL *url  = [NSURL fileURLWithPath:path];
    //  NSMutableDictionary *tiffMetadata = [[NSMutableDictionary alloc] init];
    
    
    // NSData *jpeg = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer] ;
    CGImageSourceRef imageSource = CGImageSourceCreateWithURL((CFURLRef)url, NULL);
    
    if (imageSource == NULL) {
        NSLog(@"Erorr");
        return;
    }
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:NO], (NSString *)kCGImageSourceShouldCache,
                             nil];
    CFDictionaryRef imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, (CFDictionaryRef)options);
    
    ///////////////////////////////////////
    //////////////////////////////    //////////////////////////////
    
    
    // NSData *jpeg = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer] ;
    
    CGImageSourceRef  source ;
    source = CGImageSourceCreateWithURL((CFURLRef)url, NULL);
    
    //get all the metadata in the image
    NSDictionary *metadata = (NSDictionary *) CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(source,0,NULL));
    
    //make the metadata dictionary mutable so we can add properties to it
    NSMutableDictionary *metadataAsMutable = [metadata mutableCopy];
    
    
    NSMutableDictionary *EXIFDictionary = [[metadataAsMutable objectForKey:(NSString *)kCGImagePropertyExifDictionary]mutableCopy];
    NSMutableDictionary *GPSDictionary = [[metadataAsMutable objectForKey:(NSString *)kCGImagePropertyGPSDictionary]mutableCopy];
    NSMutableDictionary *TiffDic  = [metadataAsMutable objectForKey:(NSString *)kCGImagePropertyTIFFDictionary];
    if(!EXIFDictionary) {
        //if the image does not have an EXIF dictionary (not all images do), then create one for us to use
        EXIFDictionary = [NSMutableDictionary dictionary];
    }
    if(!GPSDictionary) {
        GPSDictionary = [NSMutableDictionary dictionary];
    }
    
    [TiffDic setValue:@"This is new softwave" forKey:(NSString *)kCGImagePropertyTIFFSoftware];
    
    //Setup GPS dict
    
    
    [GPSDictionary setValue:[NSNumber numberWithFloat:16] forKey:(NSString*)kCGImagePropertyGPSLatitude];
    [GPSDictionary setValue:[NSNumber numberWithFloat:108] forKey:(NSString*)kCGImagePropertyGPSLongitude];
    
    
    //[EXIFDictionary setValue:xml forKey:(NSString *)kCGImagePropertyExifUserComment];
    //add our modified EXIF data back into the image’s metadata
    
    [metadataAsMutable setObject:TiffDic forKey:(NSString *)kCGImagePropertyTIFFDictionary];
    [metadataAsMutable setObject:EXIFDictionary forKey:(NSString *)kCGImagePropertyExifDictionary];
    [metadataAsMutable setObject:GPSDictionary forKey:(NSString *)kCGImagePropertyGPSDictionary];
    
    CFStringRef UTI = CGImageSourceGetType(source); //this is the type of image (e.g., public.jpeg)
    
    //this will be the data CGImageDestinationRef will write into
    NSMutableData *dest_data = [NSMutableData data];
    
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((CFMutableDataRef)dest_data,UTI,1,NULL);
    
    if(!destination) {
        NSLog(@"***Could not create image destination ***");
    }
    
    //add the image contained in the image source to the destination, overidding the old metadata with our modified metadata
    CGImageDestinationAddImageFromSource(destination,source,0, (CFDictionaryRef) metadataAsMutable);
    
    //tell the destination to write the image data and metadata into our data object.
    //It will return false if something goes wrong
    BOOL success = NO;
    success = CGImageDestinationFinalize(destination);
    
    if(!success) {
        NSLog(@"***Could not create data from image destination ***");
    }
    
    //now we have the data ready to go, so do whatever you want with it
    //here we just write it to disk at the same path we were passed
    
    [dest_data writeToURL:url atomically:YES];
    
    
    
//    UIImage *image1 = [[UIImage alloc]initWithData:dest_data];
//    UIImageWriteToSavedPhotosAlbum(image1, self, nil, nil);
    
    //cleanup
    
    //
    //    NSDictionary *metaData =(NSDictionary *)CFBridgingRelease(CGImageSourceCopyMetadataAtIndex(imageSource, 0, NULL));
    //
    //
    //    NSMutableDictionary *metadataImageProperties =[metaData mutableCopy];
    //
    //
    //    NSMutableDictionary *gpsDic =[metadataImageProperties objectForKey:(NSString*)kCGImagePropertyGPSDictionary];
    //
    //
    //
    //    if(!gpsDic) {
    //        gpsDic = [NSMutableDictionary dictionary];
    //    }
    //
    //
    //    [gpsDic setValue:[NSNumber numberWithFloat:16] forKey:(NSString*)kCGImagePropertyGPSLatitude];
    //    [gpsDic setValue:[NSNumber numberWithFloat:16] forKey:(NSString*)kCGImagePropertyGPSLatitudeRef];
    //    [gpsDic setValue:[NSNumber numberWithFloat:108] forKey:(NSString*)kCGImagePropertyGPSLongitude];
    //    [gpsDic setValue:[NSNumber numberWithFloat:108] forKey:(NSString*)kCGImagePropertyGPSLongitudeRef];
    //
    //
    //    [metadataImageProperties setObject:gpsDic forKey:(NSString*)kCGImagePropertyGPSDictionary];
    //
    //    CFStringRef UTI = CGImageSourceGetType(imageSource);
    //    NSMutableData *desData =[NSMutableData data];
    //
    //    CGImageDestinationRef destination =CGImageDestinationCreateWithData((CFMutableDataRef)desData, UTI, 1, NULL);
    //
    //    CGImageDestinationAddImageFromSource(destination, imageSource, 0, (CFDictionaryRef)metadataImageProperties);
    //
    //    BOOL success =NO;
    //    success = CGImageDestinationFinalize(destination);
    //    [desData writeToURL:url atomically:YES];
    //
    //
    //
    
    //////////////////////////////    //////////////////////////////
    
    
    if (imageProperties) {
        NSNumber *width = (NSNumber *)CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelWidth);
        NSNumber *height = (NSNumber *)CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelHeight);
        
        
        
        NSLog(@"Property %@",imageProperties);
        NSLog(@"Image dimensions: %@ x %@ px", width, height);
        
    }
    CFDictionaryRef exif = CFDictionaryGetValue(imageProperties, kCGImagePropertyExifDictionary);
    if (exif) {
        NSLog(@"Exif %@",exif);
        NSString *dateTakenString = (NSString *)CFDictionaryGetValue(exif, kCGImagePropertyExifDateTimeOriginal);
        NSLog(@"Date Taken: %@", dateTakenString);
    }
    
    
    CFDictionaryRef tiff = CFDictionaryGetValue(imageProperties, kCGImagePropertyTIFFDictionary);
    if (tiff) {
        NSLog(@"%@",tiff);
        NSString *cameraModel = (NSString *)CFDictionaryGetValue(tiff, kCGImagePropertyTIFFModel);
        
        NSString *softwave = (NSString*)CFDictionaryGetValue(tiff, kCGImagePropertyTIFFSoftware);
        NSLog(@"Camera Model: %@", cameraModel);
        
        NSLog(@"Softwave : %@",softwave);
    }
    
    CFDictionaryRef gps = CFDictionaryGetValue(imageProperties, kCGImagePropertyGPSDictionary);
    
    
    
    if (gps) {
        NSLog(@"GPS %@",gps);
        
        NSString *latitudeString = (NSString *)CFDictionaryGetValue(gps, kCGImagePropertyGPSLatitude);
        NSString *latitudeRef = (NSString *)CFDictionaryGetValue(gps, kCGImagePropertyGPSLatitudeRef);
        NSString *longitudeString = (NSString *)CFDictionaryGetValue(gps, kCGImagePropertyGPSLongitude);
        NSString *longitudeRef = (NSString *)CFDictionaryGetValue(gps, kCGImagePropertyGPSLongitudeRef);
        
        NSLog(@"GPS Coordinates: %@ %@ / %@ %@", longitudeString, longitudeRef, latitudeString, latitudeRef);
        
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
