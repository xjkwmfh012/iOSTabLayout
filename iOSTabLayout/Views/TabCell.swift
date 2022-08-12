//
//  TabCell.swift
//  iOSTabLayout
//
//  Created by HJ Kang on 2022/08/09.
//

import UIKit

class TabCell: UICollectionViewCell {
    static let reuseIdentifier = "TabCell"

    let imageView = UIImageView()
    let cellMargin: CGFloat = 16
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layoutView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func layoutView() {
        imageView.contentMode = .scaleAspectFit
        
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(cellMargin)
        }
    }
}
