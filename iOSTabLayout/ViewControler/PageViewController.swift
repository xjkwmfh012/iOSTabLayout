//
//  PageViewController.swift
//  iOSTabLayout
//
//  Created by HJ Kang on 2022/08/04.
//

import UIKit

class PageViewController: UIPageViewController {

    private let pageVCs = [FirstViewController(),
                           SecondViewController(),
                           ThirdViewController()]
    
    // transitionStyle와 navigationOrientation는 get-only이므로 초기화 때 따로 설정한다.
    convenience init() {
        //페이지 넘기는 모양과 넘기는 방향 설정
        self.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        dataSource = self
        
        // setViewControllers의 첫번째 인자는 사용할 뷰
        guard let firstVC = pageVCs.first else { return }
        setViewControllers([firstVC], direction: .forward, animated: true)
    }
}

// MARK: UIPageViewController의 Delegate/DataSource
extension PageViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    // 왼쪽에서 오른쪽으로 스와이프할 때 호출됨: 이전 페이지로 이동
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        // 현재 뷰컨트롤러의 인덱스
        guard let currentIndex = pageVCs.firstIndex(of: viewController) else { return nil }
        // 이동할 뷰컨트롤러의 인덱스: 뒤로 이동하려할 때 호출되므로 -1
        let moveToIndex = currentIndex - 1
        
        // moveToIndex가 0보다 작을 수는 없기 때문에 nil 반환
        // 0보다 크거나 같으면 pageVCs에서 해당 뷰컨트롤러를 pageVCs에서 찾아 반환
        if moveToIndex < 0 {
            return nil
        } else {
            return pageVCs[moveToIndex]
        }
    }
    
    // 오른쪽에서 왼쪽로 스와이프될 때 호출됨: 다음 페이지로 이동
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        // 현재 뷰컨트롤러의 인덱스
        guard let currentIndex = pageVCs.firstIndex(of: viewController) else { return nil }
        // 이동할 뷰컨트롤러의 인덱스: 앞으로 이동하려할 때 호출되므로 +1
        let moveToIndex = currentIndex + 1
        
        // moveToIndex가 pageVCs의 원소 개수보다 같거나 클 수는 없기 때문에 nil 반환
        // pageVCs의 원소 개수보다 작으면 해당 뷰컨트롤러를 pageVCs에서 찾아 반환
        if moveToIndex >= pageVCs.count {
            return nil
        } else {
            return pageVCs[moveToIndex]
        }
    }
}
