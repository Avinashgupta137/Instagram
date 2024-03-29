//
//  ImageLoader+Extensions.swift
//  InstaUiKit
//
//  Created by IPS-161 on 11/08/23.
//
import UIKit
import Kingfisher

class ImageLoader {
    static func loadImage(for url: URL?, into imageView: UIImageView, withPlaceholder placeholder: UIImage? = nil) {
        guard let url = url, !url.absoluteString.isEmpty else {
            imageView.image = applyTintAndScale(to: placeholder)
            return
        }
        
        let processor = DownsamplingImageProcessor(size: imageView.bounds.size)
        |> RoundCornerImageProcessor(cornerRadius: 0)
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(
            with: url,
            placeholder: applyTintAndScale(to: placeholder), // Apply white background and black tint
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1)),
                .cacheOriginalImage
            ])
        {
            result in
            switch result {
            case .success(let value):
                print("Image loaded successfully from: \(value.source.url?.absoluteString ?? "")")
            case .failure(let error):
                print("Image loading failed: \(error.localizedDescription)")
            }
        }
    }
    
    static func applyTintAndScale(to image: UIImage?) -> UIImage? {
        guard let image = image else { return nil }
        let renderer = UIGraphicsImageRenderer(size: image.size)
        return renderer.image { context in
            UIColor.white.setFill()
            UIRectFill(CGRect(origin: .zero, size: image.size))
            image.draw(in: CGRect(origin: .zero, size: image.size))
        }
    }
}
