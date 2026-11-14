import Foundation
import ImageIO
import CoreGraphics
let base=CommandLine.arguments[1]
let file=try String(contentsOfFile:base+"/export-path.txt",encoding:.utf8)
let src=CGImageSourceCreateWithURL(URL(fileURLWithPath:base+"/fixture.jpg") as CFURL,nil)!
let out=CGImageSourceCreateWithURL(URL(fileURLWithPath:file) as CFURL,nil)!
let original=CGImageSourceCopyPropertiesAtIndex(src,0,nil)! as NSDictionary
let props=CGImageSourceCopyPropertiesAtIndex(out,0,nil)! as NSDictionary
assert(original[kCGImagePropertyGPSDictionary] != nil)

assert(props[kCGImagePropertyGPSDictionary] == nil)
assert((props[kCGImagePropertyTIFFDictionary] as? NSDictionary)?[kCGImagePropertyTIFFMake] == nil)
let image=CGImageSourceCreateImageAtIndex(out,0,nil)!
assert(image.width == 1200 && image.height == 2400)
let expected=CGImageSourceCreateThumbnailAtIndex(src,0,[kCGImageSourceCreateThumbnailFromImageAlways:true,kCGImageSourceCreateThumbnailWithTransform:true,kCGImageSourceThumbnailMaxPixelSize:2400] as CFDictionary)!
func samples(_ im:CGImage)->[UInt8] {
 let ctx=CGContext(data:nil,width:2,height:2,bitsPerComponent:8,bytesPerRow:8,space:CGColorSpaceCreateDeviceRGB(),bitmapInfo:CGImageAlphaInfo.premultipliedLast.rawValue)!
 ctx.interpolationQuality = .none; ctx.draw(im,in:CGRect(x:0,y:0,width:2,height:2))
 return Array(UnsafeBufferPointer(start:ctx.data!.assumingMemoryBound(to:UInt8.self),count:16))
}
let a=samples(image), b=samples(expected)
assert(zip(a,b).allSatisfy { abs(Int($0.0)-Int($0.1)) < 20 })
print("PASS: native export 1200x2400, upright versus ImageIO orientation transform, GPS and camera make absent")
