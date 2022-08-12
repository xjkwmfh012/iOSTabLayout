//
//  ViewController.swift
//  iOSTabLayout
//
//  Created by HJ Kang on 2022/08/04.
//

import UIKit
import SnapKit

class MainViewController: UIViewController {
    
    let tabView = TabView()
    let pageViewController = PageViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setTabView()
        setPageVC()
    }
    
    func setTabView() {
        tabView.delegate = self
        
        view.addSubview(tabView)
        tabView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(tabView.tabBarHeight)
        }
    }
    
    func setPageVC() {
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.view.snp.makeConstraints { make in
            make.top.equalTo(tabView.snp.bottom)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalToSuperview()
        }
        pageViewController.didMove(toParent: self)
        
        for view in pageViewController.view.subviews {
            if let scrollView = view as? UIScrollView {
                scrollView.delegate = self
            }
        }
    }
}

extension MainViewController: TabViewDelegate, UIScrollViewDelegate {
    func tabView(didSelectTabAt index: Int) {
        pageViewController.movePage(moveTo: index)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x / 3
        let move = tabView.cellWidth - offsetX
        let currentConstant = (tabView.cellWidth * CGFloat(pageViewController.currentPageIndex)) - move
        
        tabView.tabIndicator.snp.updateConstraints { make in
            make.leading.equalTo(currentConstant)
        }
                                
        UIView.animate(withDuration: 0, delay: 0) { [weak self] in
            self?.loadViewIfNeeded()
        }
    }
}

