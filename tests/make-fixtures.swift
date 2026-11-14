import Foundation
import CoreGraphics
import ImageIO
let path = CommandLine.arguments[1]
let context = CGContext(data:nil,width:4000,height:2000,bitsPerComponent:8,bytesPerRow:16000,space:CGColorSpaceCreateDeviceRGB(),bitmapInfo:CGImageAlphaInfo.premultipliedLast.rawValue)!
context.setFillColor(CGColor(red:0,green:1,blue:0,alpha:1));context.fill(CGRect(x:0,y:0,width:4000,height:2000))
context.setFillColor(CGColor(red:1,green:0,blue:0,alpha:1));context.fill(CGRect(x:0,y:1000,width:2000,height:1000))
let image=context.makeImage()!
let dest=CGImageDestinationCreateWithURL(URL(fileURLWithPath:path) as CFURL,"public.jpeg" as CFString,1,nil)!
let props:[CFString:Any] = [kCGImagePropertyOrientation:6,kCGImagePropertyTIFFDictionary:[kCGImagePropertyTIFFMake:"Plant Doctor test camera"],kCGImagePropertyGPSDictionary:[kCGImagePropertyGPSLatitude:1.0,kCGImagePropertyGPSLatitudeRef:"N",kCGImagePropertyGPSLongitude:2.0,kCGImagePropertyGPSLongitudeRef:"E"]]
CGImageDestinationAddImage(dest,image,props as CFDictionary)
assert(CGImageDestinationFinalize(dest))
