//
//  imageProcessor.m
//  photoTest
//
//  Created by 周强 on 16/2/3.
//  Copyright © 2016年 com.jointsky.www. All rights reserved.
//

#import "imageProcessor.h"

@implementation imageProcessor

+ (instancetype)sharedImageProcessor{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (sharedInstance == nil) {
            sharedInstance = [[self alloc]init];
        }
    });
    return sharedInstance;
}


- (void)imageProcess:(UIImage *)inputImage{
    UIImage *outputImage = [self processUsingPixels:inputImage];
    UIImage *secondImage = [self secondImage:inputImage];
    NSArray *array = [self getPM25ByCA:_CA];
    if (self.delegate && [self.delegate respondsToSelector:@selector(imageProcessorWithImage:AndSecondImage:AndPM25:)]) {
        //[self.delegate imageProcessorWithImage:outputImage];
        [self.delegate imageProcessorWithImage:outputImage AndSecondImage:secondImage AndPM25:array];
        
    }
}


#define Mask8(x) ( (x) & 0xFF)
#define R(x) ( Mask8(x) )
#define G(x) ( Mask8(x >> 8 ) )
#define B(x) ( Mask8(x >> 16) )
#define A(x) ( Mask8(x >> 24) )
#define RGBAMake(r, g, b, a) ( Mask8(r) | Mask8(g) << 8 | Mask8(b) << 16 | Mask8(a) << 24 )

- (UIImage *)processUsingPixels:(UIImage *)image{
    
   //1.获得图片的像素 以及上下文
    UInt32 *inputPixels;
    CGImageRef inputCGImage = [image CGImage];
    size_t w = CGImageGetWidth(inputCGImage);
    size_t h = CGImageGetHeight(inputCGImage);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    NSInteger bytesPerPixel = 4;//每个像素的字节数
    NSInteger bitsPerComponent = 8;//每个组成像素的 位深
    NSInteger bitmapBytesPerRow = w * bytesPerPixel;//每行字节数
    
    inputPixels = (UInt32 *)calloc(w * h , sizeof(UInt32));//通过calloc开辟一段连续的内存空间
    
    CGContextRef context = CGBitmapContextCreate(inputPixels, w, h, bitsPerComponent, bitmapBytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(context, CGRectMake(0, 0, w, h), inputCGImage);
    
    //大气光A值
    int count = w * h * 0.001;
    int red[w * h];
    
    //2取具体某一个像素点的值
    for (NSInteger j = 0; j < h; j ++) {
        for (NSInteger i = 0 ; i < w; i ++) {
            UInt32 *currentPixel = inputPixels + (w * j) + i;
            UInt32 color = *currentPixel;
            
            //灰度图
            UInt32 max = MAX(MAX(R(color), G(color)), B(color));
            
            *currentPixel = RGBAMake(max, max, max, A(color));
            
            
            int t = R(color);
            red[j * w + i] = t;
        }
    }
    
    //排序
    NSLog(@"%@",[NSDate dateWithTimeIntervalSinceNow:0]);
    for (int i = 0; i < w * h - 1; i ++) {
        for (int j = 0; j < w * h - 1 - i; j ++) {
            if (red[j] > red [j + 1]) {
                int temp = red[j];
                red[j] = red[j + 1];
                red[j + 1] = temp;
            }
        }
    }
    NSLog(@"%@",[NSDate dateWithTimeIntervalSinceNow:0]);
    

    //求A值
    int contValue = 0;
    for (int i =(int)(w * h - 1); i >= (w * h) - count ; i --) {
        contValue += red[i];
    }
    
    if (count == 0) {
        count = 10;
    }
    int rrrr = contValue/count;
    printf("大气光A值为：%d / %d = %d",contValue,count,rrrr);
//    if (rrrr > 220) {
//        rrrr = 220;
//    }
    self.CA = rrrr;
    
    //3从上下文中取出
    CGImageRef newImageRef = CGBitmapContextCreateImage(context);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    
    //4释放
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    free(inputPixels);
    
    return newImage;
}





- (UIImage *)secondImage:(UIImage *)image{
    
    //1.获得图片的像素 以及上下文
    UInt32 *inputPixels;
    CGImageRef inputCGImage = [image CGImage];
    size_t w = CGImageGetWidth(inputCGImage);
    size_t h = CGImageGetHeight(inputCGImage);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    NSInteger bytesPerPixel = 4;//每个像素的字节数
    NSInteger bitsPerComponent = 8;//每个组成像素的 位深
    NSInteger bitmapBytesPerRow = w * bytesPerPixel;//每行字节数
    
    inputPixels = (UInt32 *)calloc(w * h , sizeof(UInt32));//通过calloc开辟一段连续的内存空间
    
    CGContextRef context = CGBitmapContextCreate(inputPixels, w, h, bitsPerComponent, bitmapBytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(context, CGRectMake(0, 0, w, h), inputCGImage);
    
    

    //准备工作
    //int color;
    int step = 7;
    //2取具体某一个像素点的值
    for (NSInteger j = 0; j < h; j ++) {
        for (NSInteger i = 0 ; i < w; i ++) {
            UInt32 *currentPixel = inputPixels + (w * j) + i;
            UInt32 color = *currentPixel;
            
            int src_r = R(color);
            int src_g = G(color);
            int src_b = B(color);
            double red = 255;
            double green = 255;
            double blue = 255;
            
            //
            NSInteger xStart = (i - step) >= 0 ? (i - step) : 0;
            NSInteger xEnd = (i + step) < w ? (i + step) : w;
            
            NSInteger yStart = (j - step) >= 0 ? (j - step) : 0;
            NSInteger yEnd = (j + step) < h ? (j + step) : h;
            if (self.CA == 0) {
                self.CA = 1;
            }
            for (NSInteger yy = yStart; yy < yEnd; yy++) {
                for (NSInteger xx = xStart; xx < xEnd; xx ++) {
                    UInt32 *temp = inputPixels + (w * yy) + xx;
                    UInt32 tempColor = *temp;
                    int r = R(tempColor);
                    int g = G(tempColor);
                    int b = B(tempColor);
                    if (red > r*1.0/self.CA ) {
                        red = r*1.0/self.CA;
                    }
                    if (green > g*1.0/self.CA ) {
                        green = g*1.0/self.CA;
                    }
                    if (blue > b*1.0/self.CA ) {
                        blue = b*1.0/self.CA;
                    }
                }
            }
            //
            double ays = 0;
            if (red < green) {
                ays = red;
            }else{
                ays = green;
            }
            if (ays > blue) {
                ays = blue;
            }
            
            
            double toushelv = 1;
            toushelv = 1 - 0.95 *ays;
            if (toushelv < 0.1) {
                toushelv = 0.1;
            }
            
            int result_r = (src_r - self.CA)/toushelv + self.CA;
            int result_g = (src_g - self.CA)/toushelv + self.CA;
            int result_b = (src_b - self.CA)/toushelv + self.CA;
            *currentPixel = RGBAMake(result_r, result_g, result_b, A(color));
            
        }
    }
    
    
    //3从上下文中取出
    CGImageRef newImageRef = CGBitmapContextCreateImage(context);
    UIImage *secondImage = [UIImage imageWithCGImage:newImageRef];
    
    //4释放
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    free(inputPixels);
    
    return secondImage;
}



#undef A
#undef R
#undef G
#undef B
#undef Mask8
#undef RGBAMaker

#pragma mark 根据大气光A值估算PM2.5
- (NSArray *)getPM25ByCA:(double)caValue {
    int Min;
    int Max;
    /*计算最大范围范围为2元一次方程，2个点分别为（109,342），（162,178）
     方程为：y=ax+b,其中a=-164/53,b=178+162*(164/52)
     */
    Min = (int)(-164  * caValue + 36002)/53;
    
    
    /*计算最小范围为2元一次方程，2个点分别为（187,259），（227,121）
     a=-69/20,b=121+227*(69/20)
     */
    
    Max = (int)(18083-69 *caValue)/20;
    
    if (Min < 0) {
        Min = 0;
    }
    if (Max < 0)
    {
        Max = 0;
    }
    NSArray *array = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d",Min] ,[NSString stringWithFormat:@"%d",Max] ,nil];
    
    printf("\nmin = %d,max = %d",Min,Max);
    return array;
}


/**
 *  计算大气光值得出的pm2.5范围和周围环境的pm2.5拟合出合理的pm2.5值
 *
 *  @param rangeArray 大气光值计算得到pm2.5范围
 *  @param pm25Value  周围环境的pm2.5值
 *
 *  @return 合理的pm2.5的值
 */
- (NSInteger)fittingCalculationForAToPm25Range:(NSArray *)rangeArray andSurroundingPm25:(NSInteger)pm25Value {
    NSInteger realPm25Value = 0, rangeMinPm25 = [rangeArray[0] intValue], rangeMaxPm25 = [rangeArray[1] intValue];
    
    
    if (pm25Value > rangeMinPm25 && pm25Value < rangeMaxPm25) {
        if ((pm25Value-rangeMinPm25) <= 10) {
            realPm25Value = pm25Value;
        } else if ((rangeMaxPm25-pm25Value) <= 10) {
            realPm25Value = rangeMaxPm25;
        } else {
            realPm25Value = rangeMaxPm25 - (90 - ((1.03 * pm25Value) / rangeMaxPm25 * 90)) / 90 * rangeMaxPm25;
        }
    } else if (pm25Value > rangeMaxPm25) {
        if ((pm25Value-rangeMaxPm25) <= 10) {
            realPm25Value = rangeMaxPm25;
        } else {
            realPm25Value = rangeMaxPm25 - (90 - ((1.03 * pm25Value) / rangeMaxPm25 * 90)) / 90 * rangeMaxPm25;
        }
    } else if ((rangeMinPm25-pm25Value) <= 10) {
        realPm25Value = rangeMinPm25;
    } else {
        realPm25Value = rangeMaxPm25 - (90 - ((1.03 * pm25Value) / rangeMaxPm25 * 90)) / 90 * rangeMaxPm25;
    }
    
    
    return realPm25Value;
}

@end
