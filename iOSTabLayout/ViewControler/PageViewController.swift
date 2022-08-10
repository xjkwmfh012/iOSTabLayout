//
//  PageViewController.swift
//  iOSTabLayout
//
//  Created by HJ Kang on 2022/08/04.
//

import UIKit

class PageViewController: UIPageViewController {

    var currentPageIndex = 0
    let pageVCs = [FirstViewController(),
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
    
    func movePage(moveTo index: Int) {
        var direction: UIPageViewController.NavigationDirection
        if index >= currentPageIndex {
            direction = .forward
        } else {
            direction = .reverse
        }
        
        setCurrentPage(startAt: currentPageIndex, endAt: index, direction: direction)
    
    }
    
    /// 페이지를 넘긴다.
    /// 시작페이지와 끝 페이지의 차이/방향에 따라 자연스럽게 페이지를 넘긴다.
    private func setCurrentPage(startAt: Int, endAt: Int, direction: UIPageViewController.NavigationDirection) {
        // 페이지를 넘기는 방향에 따라 for문에서의 index를 증가시킬지, 감소시킬지가 정해지므로
        // forward는 1, reverse 는 -1을 사용하도록 한다.
        let by = direction == .forward ? 1 : -1
        
        // 시작점(현재 페이지)로는 이동할 필요가 없으므로 from + by을 통해 현재 페이지는 제외시키고 다음 페이지부터 시작하게 한다.
            // forward는 +1, reverse는 -1을 하여 다음 페이지를 가르키는 인덱스가 올바르게 지정되도록 한다.
            for index in stride(from: startAt + by, through: endAt, by: by) {
                setViewControllers([pageVCs[index]], direction: direction, animated: true) { [weak self] bool in
                    self?.currentPageIndex = index
                }
            }
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
    
    // 직접 드래깅할 때 currentPageIndex의 값을 설정한다.
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            if let currentVC = viewControllers?.first {
                currentPageIndex = pageVCs.firstIndex(of: currentVC) ?? 0
            }
        }
    }
}
