//
//  TabView.swift
//  iOSTabLayout
//
//  Created by HJ Kang on 2022/08/09.
//

import UIKit

protocol TabViewDelegate {
    func tabView(didSelectTabAt index: Int)
}

class TabView: UIView {
    
    let tabIndicator = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layoutViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    var delegate: TabViewDelegate?
    
    var tabs: [String] = ["scribble.variable", "paperplane.fill", "doc.text.magnifyingglass"]
    
    var cellWidth = UIScreen.main.bounds.width
    var cellHeight: CGFloat = 64
    var tabIndicatorHeight: CGFloat = 4
    var tabBarHeight: CGFloat {
        cellHeight + tabIndicatorHeight
    }

    func layoutViews() {
        cellWidth = UIScreen.main.bounds.width / CGFloat(tabs.count)
        
        // CollectionView
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        let tabCollectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        
        tabCollectionView.delegate = self
        tabCollectionView.dataSource = self
        tabCollectionView.register(TabCell.self, forCellWithReuseIdentifier: TabCell.reuseIdentifier)
        
        tabCollectionView.isScrollEnabled = false
        tabCollectionView.showsHorizontalScrollIndicator = false
        
        // Tab Indicator
        tabIndicator.backgroundColor = .systemPurple
        
        
        // Layout
        addSubview(tabCollectionView)
        addSubview(tabIndicator)
        
        tabCollectionView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(cellHeight)
        }
        
        tabIndicator.snp.makeConstraints { make in
            make.top.equalTo(tabCollectionView.snp.bottom)
            make.leading.equalToSuperview()
            make.width.equalTo(cellWidth)
            make.height.equalTo(tabIndicatorHeight)
        }
        
    }
}

extension TabView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tabs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TabCell.reuseIdentifier, for: indexPath) as? TabCell else { return UICollectionViewCell() }
        
        cell.imageView.image = UIImage(systemName: tabs[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.tabView(didSelectTabAt: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
