//
//  OnboardingPageController.swift
//  BubbleChat
//
//  Created by Aleks on 9/4/17.
//  Copyright © 2017 Aleks. All rights reserved.
//

import UIKit

class OnboardingPageController: UIPageViewController, UIScrollViewDelegate {
    
    // MARK: FilePrivate Properties
    
    fileprivate lazy var stepControllers: [OnboardingStepController] = {
        return [self.newStepController("One"),
                self.newStepController("Two"),
                self.newStepController("Three"),
                self.newStepController("Four")]
    }()
    
    // MARK: Delegates
    
    weak var onboardingDelegate: OnboardingPageControllerDelegate?
    
    // MARK: LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for view in self.view.subviews {
            if let scrollView = view as? UIScrollView {
                scrollView.delegate = self
            }
        }
        
        dataSource = self
        delegate = self
        
        if let firstController = stepControllers.first {
            scrollToViewController(firstController)
        }
        
        onboardingDelegate?.onboardingPageController(self, didUpdatePageCount: stepControllers.count)
    }
    
    // MARK: UIScrollViewDelegate - Percent Helper
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let point = scrollView.contentOffset
        var completionPercentage: CGFloat
        completionPercentage = fabs(point.x - view.frame.size.width)/view.frame.size.width
        NSLog("completion percentage: %f", completionPercentage)
    }
    
    // MARK: Scroll to Next View Controllerv
    
    func scrollToNextViewController() {
        if let visibleViewController = viewControllers?.first,
            let nextViewController = pageViewController(self, viewControllerAfter: visibleViewController) {
            scrollToViewController(nextViewController)
        }
    }
    
    // MARK: Scroll to Index
    
    func scrollToViewController(index newIndex: Int) {
        if let firstViewController = viewControllers?.first as? OnboardingStepController,
            let currentIndex = stepControllers.index(of: firstViewController) {
            let direction: UIPageViewControllerNavigationDirection = newIndex >= currentIndex ? .forward : .reverse
            let nextViewController = stepControllers[newIndex]
            scrollToViewController(nextViewController, direction: direction)
        }
    }
    
    // MARK: Step Controller Helper
    
    fileprivate func newStepController(_ stepName: String) -> OnboardingStepController {
        return UIStoryboard(name: "Onboarding", bundle: nil).instantiateViewController(withIdentifier: "OnboardingStep\(stepName)Controller") as! OnboardingStepController
    }
    
    // MARK: Scroll to View Controller
    
    fileprivate func scrollToViewController(_ viewController: UIViewController, direction: UIPageViewControllerNavigationDirection = .forward) {
        setViewControllers([viewController], direction: direction, animated: true, completion: { [weak self] (finished) in
            self?.notifyOnIndexUpdate()
        })
    }
    
    // MARK: Index Update
    
    fileprivate func notifyOnIndexUpdate() {
        if let firstViewController = viewControllers?.first as? OnboardingStepController,
            let index = stepControllers.index(of: firstViewController) {
            onboardingDelegate?.onboardingPageController(self, didUpdatePageIndex: index)
        }
    }
    
}

extension OnboardingPageController: UIPageViewControllerDataSource {
    
    // MARK: UIPageViewControllerDataSource
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let coloredViewController = viewController as? OnboardingStepController,
            let viewControllerIndex = stepControllers.index(of: coloredViewController) else {
                return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard stepControllers.count > previousIndex else {
            return nil
        }
        
        return stepControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let stepController = viewController as? OnboardingStepController,
            let viewControllerIndex = stepControllers.index(of: stepController) else {
                return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let stepControllersCount = stepControllers.count
        
        guard stepControllersCount != nextIndex else {
            return nil
        }
        
        guard stepControllersCount > nextIndex else {
            return nil
        }
        
        return stepControllers[nextIndex]
    }
    
}

extension OnboardingPageController: UIPageViewControllerDelegate {
    
    // MARK: UIPageViewControllerDelegate
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        notifyOnIndexUpdate()
    }
    
}


