//
//  AsyncImageLoader.swift
//  BubbleChat
//
//  Created by Aleks on 9/4/17.
//  Copyright © 2017 Aleks. All rights reserved.
//

import UIKit

private let singleton = AsyncImageLoadingManager()
private let maxCacheSize = 20

class AsyncImageLoadingManager: NSObject {
    
    var imageCacheDictionary = [String: UIImage]()
    
    static var shared: AsyncImageLoadingManager {
        return singleton
    }
    
    func emptyAllCache() {
        imageCacheDictionary.removeAll(keepingCapacity: false)
    }
    
    func cachedImageForURL(url: String) -> UIImage? {
        return imageCacheDictionary[url]
    }
    
    func putImageInCache(image: UIImage, forURL url: String) {
        guard imageCacheDictionary.count < maxCacheSize else {
            imageCacheDictionary.remove(at: imageCacheDictionary.startIndex)
            return
        }
        imageCacheDictionary[url] = image
    }
    
    func loadImageAsyncFromUrl(urlString: String, completion: ((_ success: Bool, _ image: UIImage?) -> Void)?) {
        
        if let cachedImage = cachedImageForURL(url: urlString) {
            
            DispatchQueue.main.async(execute: { completion?(true, cachedImage) })
            
        } else if let url = NSURL(string: urlString) {
            
            URLSession.shared.downloadTask(with: url as URL, completionHandler: { (retrievedURL, response, error) -> Void in
                
                guard let unwrappedRetrievedUrl = retrievedURL, let data = NSData(contentsOf: unwrappedRetrievedUrl), let image = UIImage(data: data as Data)
                    else {
                        DispatchQueue.main.async(execute: { completion?(false, nil) })
                        return
                }
                
                self.putImageInCache(image: image, forURL: url.absoluteString!)
                
                DispatchQueue.main.async(execute: { completion?(true, image) });
                
            }).resume()
            
        } else { completion?(false, nil) }
    }
    
    
}
