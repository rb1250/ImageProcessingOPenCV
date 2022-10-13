//
//  OpenCVWrapper.m
//  TestOpenCVSwift
//
//  Created by Ruchika Bokadia on 25/01/20.
//  Copyright © 2020 RBRB. All rights reserved.
//

#import "OpenCVWrapper.h"
#import <opencv2/videoio/cap_ios.h>
#import <opencv2/imgcodecs/ios.h>
#import <opencv2/opencv.hpp>


using namespace cv;
using namespace std;

//@interface OpenCVWrapper () <CvVideoCameraDelegate>
//@end

@implementation OpenCVWrapper

//{
//    UIViewController<NostalgiaCameraDelegate> * delegate;
//    UIImageView * imageView;
//    CvVideoCamera * videoCamera;
//    cv::Mat gtpl;
//}

//- (id)initWithController:(UIViewController<NostalgiaCameraDelegate>*)c andImageView:(UIImageView*)iv
//{
//    delegate = c;
//    imageView = iv;
//    
//    videoCamera = [[CvVideoCamera alloc] initWithParentView:imageView]; // Init with the UIImageView from the ViewController
////    videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack; // Use the back camera
////    videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait; // Ensure proper orientation
//    videoCamera.rotateVideo = YES; // Ensure proper orientation
//    videoCamera.defaultFPS = 30; // How often 'processImage' is called, adjust based on the amount/complexity of images
//    videoCamera.delegate = self;
//    
//    // Convert UIImage to Mat and store greyscale version
//    UIImage *tplImg = [UIImage imageNamed:@"item1"];
//    cv::Mat tpl;
//    UIImageToMat(tplImg, tpl);
//    cv::cvtColor(tpl, gtpl, COLOR_BGR2GRAY);
//    
//    return self;
//}
//
//- (void)processImage:(cv::Mat &)img {
//    cv::Mat gimg;
//    
//    // Convert incoming img to greyscale to match template
//    cv::cvtColor(img, gimg, COLOR_BGR2GRAY);
//    
//    // Check for matches with a certain threshold to help with scaling and angles
//    cv::Mat res(img.rows-gtpl.rows+1, gtpl.cols-gtpl.cols+1, CV_32FC1);
//    cv::matchTemplate(gimg, gtpl, res, TM_CCOEFF_NORMED);
//    cv::threshold(res, res, 0.5, 1., THRESH_TOZERO);
//    
//    double minval, maxval, threshold = 0.9;
//    cv::Point minloc, maxloc;
//    cv::minMaxLoc(res, &minval, &maxval, &minloc, &maxloc);
//    
//    // If it's a good enough match
//    if (maxval >= threshold)
//    {
//        // Draw a rectangle for confirmation
//        cv::rectangle(img, maxloc, cv::Point(maxloc.x + gtpl.cols, maxloc.y + gtpl.rows), CV_RGB(0,255,0), 2);
//        cv::floodFill(res, maxloc, cv::Scalar(0), 0, cv::Scalar(.1), cv::Scalar(1.));
//        
//        // Call our delegates callback method
//        [delegate matchedItem];
//    }
//}
//
//- (void)start
//{
//    [videoCamera start];
//}
//
//- (void)stop
//{
//    [videoCamera stop];
//}



+ (NSString *)openCVVersionString {
    return [NSString stringWithFormat:@"OpenCV Version %s",  CV_VERSION];
}

+(UIImage *) makeGrayFromImage:(UIImage *)image{
    
    //Transfer UIImage to cv::Mat
    cv::Mat imageMat;
    UIImageToMat(image, imageMat);
    
    //If image is already grayscale return
    if(imageMat.channels() == 1) return image;
    
    //Transform the cv:Mat color image to gray
    cv::Mat grayMat;
    cv::cvtColor(imageMat, grayMat, COLOR_BGR2GRAY);
    
    //Transform mat to UIIMage
    return MatToUIImage(grayMat);
    
}

///My app

+ (UIImage *)applyImageProcessing:(UIImage *)aImage pathForRes:(NSString *)path
{
//    cv::Mat originalMat = [self cvMatFromUIImage2:aImage];
    cv::Mat originalMat = [self cvMatFromUIImage2:aImage pathRes:path];
    cv::Mat dest_mat(aImage.size.width, aImage.size.height, CV_8UC4);
    cv::Mat intermediate_mat(aImage.size.width, aImage.size.height, CV_8UC4);
    
    cv::multiply(originalMat, 0.5, intermediate_mat);
    cv::add(originalMat, intermediate_mat, dest_mat);
    
    return [self UIImageFromCVMat:dest_mat];
}

+ (cv::Mat)cvMatFromUIImage:(UIImage*)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,     // Pointer to data
                                                    cols,           // Width of bitmap
                                                    rows,           // Height of bitmap
                                                    8,              // Bits per component
                                                    cvMat.step[0],  // Bytes per row
                                                    colorSpace,     // Color space
                                                    kCGImageAlphaNoneSkipLast
                                                    | kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    return cvMat;
}

+ (UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    
    CGColorSpaceRef colorspace;
    
    if (cvMat.elemSize() == 1)
    {
        colorspace = CGColorSpaceCreateDeviceGray();
    }
    else
    {
        colorspace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Create CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols, cvMat.rows, 8, 8 * cvMat.elemSize(), cvMat.step[0], colorspace, kCGImageAlphaNone | kCGBitmapByteOrderDefault, provider, NULL, false, kCGRenderingIntentDefault);
    
    // get uiimage from cgimage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorspace);
    return finalImage;
}

//+ (UIImage *)UIImageFromCVMat2:(cv::Mat)cvMat

+ (cv::Mat)cvMatFromUIImage2:(UIImage*)image pathRes:(NSString *)path
{
    NSString *foo = path;
    std::string bar = std::string([foo UTF8String]);
    cv::Mat src = cv::imread(bar); // input image
    
    if( src.type()!=CV_8UC3 )
        CV_Error(CV_HAL_ERROR_UNKNOWN,"not impl");
    cv::Mat median;
    // remove highlight pixels e.g., those from debayer-artefacts and noise
    cv::medianBlur(src,median,5);
    cv::Mat localmax;
    // find local maximum
    cv::morphologyEx( median,localmax,
                     cv::MORPH_CLOSE,cv::getStructuringElement(cv::MORPH_RECT,cv::Size(15,15) ),
                     cv::Point(-1,-1),1,cv::BORDER_REFLECT101 );
    
    // compute the per pixel gain such that the localmax goes to monochromatic 255
    cv::Mat dst = cv::Mat(src.size(),src.type() );
//    for ( int y=0;y<src.rows;++y){
//        for ( int x=0;x<src.cols;++x){
//            const cv::Vec3b & v1=src.at<cv::Vec3b>(y,x);
//            const cv::Vec3b & v2=localmax.at<cv::Vec3b>(y,x);
//            cv::Vec3b & v3=dst.at<cv::Vec3b>(y,x);
//            for ( int i=0;i<3;++i )
//            {
//                double gain = 255.0/(double)v2[i];
//                v3[i] = cv::saturate_cast<unsigned char>( gain * v1[i] );
//            }
//        }
//    }
    // and dst is the result
    return dst;
}


+ (cv::Mat)cvMatFromUIImage3:(UIImage*)image pathRes:(NSString *)path
{
    NSString *foo = path;
    std::string bar = std::string([foo UTF8String]);
    cv::Mat src = cv::imread(bar); // input image
    
    if( src.type()!=CV_8UC3 )
        CV_Error(CV_HAL_ERROR_UNKNOWN,"not impl");
    cv::Mat median;
    // remove highlight pixels e.g., those from debayer-artefacts and noise
    cv::medianBlur(src,median,5);
    cv::Mat localmax;
    // find local maximum
    cv::morphologyEx( median,localmax,
                     cv::MORPH_CLOSE,cv::getStructuringElement(cv::MORPH_RECT,cv::Size(15,15) ),
                     cv::Point(-1,-1),1,cv::BORDER_REFLECT101 );
    
    // compute the per pixel gain such that the localmax goes to monochromatic 255
    cv::Mat dst = cv::Mat(src.size(),src.type() );
    for ( int y=0;y<src.rows;++y){
        for ( int x=0;x<src.cols;++x){
            const cv::Vec3b & v1=src.at<cv::Vec3b>(y,x);
            const cv::Vec3b & v2=localmax.at<cv::Vec3b>(y,x);
            cv::Vec3b & v3=dst.at<cv::Vec3b>(y,x);
            for ( int i=0;i<3;++i )
            {
                double gain = 255.0/(double)v2[i];
                v3[i] = cv::saturate_cast<unsigned char>( gain * v1[i] );
            }
        }
    }
    // and dst is the result
    return dst;
}

@end
