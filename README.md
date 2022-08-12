# iOS에서 TabLayout+ViewPage 구현하기

종류: UIKit, iOS

Android에서는 TabLayout과 ViewPager를 사용하여 탭과 연결된 스와이프뷰를 만들 수 있습니다. 전체적인 모양은 상단의 선택 가능한 탭이 위치하고 해당 탭과 연결된 화면이 나머지 부분에 나타나는 형식입니다.

![https://developer.android.com/images/topic/libraries/architecture/navigation-tab-layout.png?hl=ko](https://developer.android.com/images/topic/libraries/architecture/navigation-tab-layout.png?hl=ko)

iOS에서 이를 구현하기위해 커스텀 뷰로 상단 탭을 만든 후 UIPageViewController와 연결하여 동일한 모양이 나오도록 구성하였습니다. (PagingKit이라는 라이브러리로도 구현 가능)

## 결과 화면

![iosTabLayout](https://user-images.githubusercontent.com/93614510/184404612-88d7f675-eab2-4ef4-ab5f-659d5396b800.gif)

---

사용한 뷰는 다음과 같습니다.

- 상단에 위치할 탭뷰 : UICollectionView(탭) + UIView(탭 인디케이터)
- 탭뷰 하단에 위치하여 페이지를 보여줄 페이지뷰컨트롤러 : UIPageViewController
- 탭뷰와 페이지뷰컨트롤러를 담을 컨테이너뷰컨트롤러: ViewController(화면)

---

## 페이지뷰컨트롤러의 페이지 설정

1. setViewControllers로 맨 처음에 보여줄 뷰 컨트롤러을 지정합니다.
    1. (첫번째 파라미터에 (첫 페이지가 될) 하나의 뷰컨트롤러가 원소로 있는 배열을 넘겨줍니다.)
2. UIPageViewControllerDataSource로 페이지를 넘길 때 나타낼 뷰 컨트롤러를 지정합니다.
3. 페이지를 넘기는 모양이나 방향을 변경하고 싶다면 convenience init을 통해 초기화 시 설정합니다.

```swift
// transitionStyle와 navigationOrientation는 get-only이므로 초기화 때 설정한다.
convenience init() {
    //페이지 넘기는 모양과 넘기는 방향 설정
    self.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
}

override func viewDidLoad() {
    super.viewDidLoad()
            
    delegate = self
    dataSource = self
        
    if let firstVC = pages.first {
        setViewControllers([firstVC], direction: .forward, animated: true)
    }
}

// 주어진 뷰 컨트롤러의 이전 뷰 컨트롤러를 반환: 뒤로 이동
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

// 주어진 뷰 컨트롤러의 다음 뷰 컨트롤러를 반환: 앞으로 이동
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
```

## 탭 뷰 생성

1. 상단의 탭 뷰는 탭들을 보여줄 UICollectionView와 바 인디케이케이터로 사용할 UIView로 구성합니다.
2. 탭 인디케이터가 UICollectionView의 선택된 탭 밑에 위치하도록 제약사항을 설정합니다.
    - 탭인디케이터의 수평위치는 leadingAnchor의 constant으로 설정하며 이 값을 변경하여 탭인디케이터를 이동시킵니다.
    - 이 때 snapKit을 사용하면 updateConstraints로, 미사용시에는 NSLayoutConstraint를 변수로 미리 생성해두고 변수의 constant를 변경하여 leadingAnchor의 constant값을 변경합니다.
3. TabViewDelegate 프로토콜을 만들어서 탭을 누를 때 부모 뷰 컨트롤러에서 처리할 수 있도록 합니다.

```swift
// 커스텀 셀
class TabCell: UICollectionViewCell {
    let imageView = UIImageView()
    let cellMargin: CGFloat = 16
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layoutView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func layoutView() {
        imageView.contentMode = .scaleAspectFit
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(cellMargin)
        }
    }
}

/*-----------------------------------------------------------------------------*/

protocol TabViewDelegate {
    func tabView(didSelectTabAt index: Int)
}

/*-----------------------------------------------------------------------------*/

// TabView내의 뷰 생성 메서드
private func makeTabView() {
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
        let tabIndicator = UIView()
        tabIndicator.backgroundColor = .systemBlue     

   
        addSubview(tabCollectionView)
        addSubview(barIndicator)
        
     
				tabCollectionView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview()
        }
        
        tabIndicator.snp.makeConstraints { make in
            make.top.equalTo(tabCollectionView.snp.bottom)
            make.leading.equalTo(0)
            make.width.equalTo(UIScreen.main.bounds.width / CGFloat(tabs.count))
            make.height.equalTo(tabIndicatorHeight)
        }
    }

extension TabView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        tabImages.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Tab", for: indexPath) as? TabCell else { fatalError() }
        cell.imageView.image = tabImages[indexPath.row]
                
        return cell
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
```

## 탭 뷰와 페이지뷰컨트롤러의 연결

이 과정에서는 위에서 만들어둔 탭 뷰와 페이지뷰컨트롤러를 연결하여 탭을 클릭하거나 페이지를 드래그하여 넘길 때 뷰 인디케이터가 함께 넘어가도록 설정합니다.

1. 페이지뷰컨트롤러에 페이지 이동 시 사용할 movePage 메서드를 생성합니다. 현재 페이지의 인덱스와 이동할 페이지의 인덱스의 차이로 페이지를 앞으로 넘길지, 뒤로 넘길지를 결정하고 for를 통해 인덱스를 하나씩 움직여 페이지를 한장씩 넘기도록 합니다. (한 장씩 넘기지 않고 2페이지 이상씩 움직이는 경우에는 중간 페이지는 생략되므로 인디케이터가 쑥 하고 부자연스럽게 움직입니다. 이걸 방지하기 위해 반복문을 사용하여 한 장씩 넘깁니다.) 또한 페이지가 넘어가는 애니메이션을 나타내기위해서 setViewControllers의 animated를 true로 설정합니다.
2. 탭을 클릭할 때 페이지가 움직여햐하므로 탭 뷰인 UICollectionView의 didSelectItemAt에 TabViewDelegate의 tabView(didSelectTabAt)를 호출하고, 부모 뷰에서 TabViewDelegate를 채택하여 tabView(didSelectTabAt)를 구현할 때 페이지뷰컨트롤러의 movePage를 호출하여 탭 클릭 시 페이지도 함께 이동하도록 합니다.
3. 이제 탭을 클릭하거나 손으로 드래깅하여 페이지를 넘길 수 있으며 이 때 페이지가 넘어갈 때 UIScrollViewDelegate의 scrollViewDidScroll이 호출되므로 여기에서 바 인디케이터를 움직이는 것을 구현합니다.

```swift
private func setViewController(startAt from: Int, endAt to: Int, direction: UIPageViewController.NavigationDirection) {
    // 방향에 따라 for문에서 index를 증가시킬지, 감소시킬지가 정해지므로
    // forward는 1, reverse 는 -1을 사용하도록 한다.
    let by = direction == .forward ? 1 : -1
    
    // 시작점(현재 페이지)로는 이동할 필요가 없으므로 from + by을 통해 현재 페이지는 제외시키고 다음 페이지부터 시작하게 한다.
    // forward는 +1, reverse는 -1을 하여 다음 페이지를 가르키는 인덱스가 올바르게 지정되도록 한다.
    for index in stride(from: from + by, through: to, by: by) {
        setViewControllers([pages[index]], direction: direction, animated: true) { [weak self] bool in
            self?.currentPageIndex = index
        }
    }
}

func movePage(moveTo index: Int) {      
    let direction: UIPageViewController.NavigationDirection
    if index >= currentPageIndex {
        direction = .forward
    } else {
        direction = .reverse
    }

    setViewController(startAt: currentPageIndex, endAt: index, direction: direction)
}

/*-----------------------------------------------------------------------------------*/

    
func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    tapDelegate?.tabView(didSelectTabAt: indexPath.row)
}

/*-----------------------------------------------------------------------------------*/

extension MediaViewController: TabViewDelegate, UIScrollViewDelegate {
    func tabView(didSelectTabAt index: Int) {
        pageController.movePage(moveTo: index)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x / 3
        let move = tabView.cellWidth - offsetX
        let currentConstant = (tabView.cellWidth * CGFloat(pageController.currentPageIndex)) - move
        
        tabView.barIndicatorLeadingConstraint.constant = currentConstant
                
        UIView.animate(withDuration: 0, delay: 0) { [weak self] in
            self?.loadViewIfNeeded()
        }
    }
}
```

## 컨테이너 뷰 컨트롤러

1. 탭뷰와 페이지 뷰 컨트롤러가 담길 뷰 컨트롤러(화면)입니다.
    1. 탭뷰는 일반 뷰와 같으므로 view.addSubViews()를 사용합니다.
    2. 페이지 뷰 컨트롤러는 뷰 컨트롤러이므로 컨테이너뷰컨트롤러의 자식으로 추가하는 메서드인 addChild()를 함께 사용합니다.
    
    ![https://docs-assets.developer.apple.com/published/1082c276be/VCPG-container-acting-as-root-view-controller@2x.png](https://docs-assets.developer.apple.com/published/1082c276be/VCPG-container-acting-as-root-view-controller@2x.png)
    

```swift
// 현재 뷰 컨트롤러에 자식으로 들어갈 뷰 컨트롤러
let pageViewController = PageViewController()

// 1. 뷰컨트롤러를 자식으로 추가
addChild(pageViewController)
// 2. 현재 뷰에 자식 뷰컨트롤러의 뷰 추가
view.addSubview(pageViewController.view)
// 3. 자식 뷰컨트롤러의 뷰의 제약조건 추가
pageViewController.view.snp.makeConstraints { make in
    make.edges.equalToSuperview()
}
// 4. 자식 뷰컨트롤러가 현재 뷰컨트롤러의 자식으로 전환 되었음을 알리는 메서드 호출
pageViewController.didMove(toParent: self)
```


---

참고 자료

[https://baked-corn.tistory.com/111](https://baked-corn.tistory.com/111)

[https://developer.apple.com/documentation/uikit/view_controllers/creating_a_custom_container_view_controller](https://developer.apple.com/documentation/uikit/view_controllers/creating_a_custom_container_view_controller)
