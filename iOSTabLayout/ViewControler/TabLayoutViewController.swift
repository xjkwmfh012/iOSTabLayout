//
//  ViewController.swift
//  iOSTabLayout
//
//  Created by HJ Kang on 2022/08/04.
//

import UIKit
import SnapKit

class TabLayoutViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setTabView()
        addPageVC()
    }
    
    /// 탭 뷰를 배치합니다.
    func setTabView() {
        
    }
    
    /// 페이지 뷰 컨트롤러를 자식으로 추가 및 배치합니다.
    func addPageVC() {
        let pageViewController = PageViewController()

        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        pageViewController.didMove(toParent: self)
    }
}

