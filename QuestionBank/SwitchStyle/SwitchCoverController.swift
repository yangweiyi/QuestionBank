//
//  SwitchCoverController.swift
//  QuestionBank
//
//  Created by ZR on 2020/11/9.
//  Copyright © 2020 wely. All rights reserved.
//

import UIKit

// 数据协议方法
public protocol SwitchDataDelegate: NSObjectProtocol {
    // 总页数
    func totalNumInPageController() -> Int
    // 将要展示的VC的下标
    func tempViewControllerForIndex(_ index: Int) -> UIViewController
    // 将要展示的view的下标
    func tempViewForIndex(_ index: Int) -> UIView
}
// 交互协议方法
public protocol SwitchUIDelegate: NSObjectProtocol {
    func switchToLastDisAbled() //无法切换上一页
    func switchToNextDisAbled() // 无法切换到下一页
    func switchToFirstFunc() // 滑动到第一个页面了
    func switchToLastFunc() // 滑动到最后一页了
    func currentViewController(_ viewController: UIViewController, _ currentIndex: Int) // 当前VC
}

public class SwitchCoverController: UIViewController {
    weak var switchDataDelagte: SwitchDataDelegate?
    weak var switchDelegate: SwitchUIDelegate?
    var currentViewContoller: UIViewController? // 当前VC
    var currentView: UIView? // 当前View
    var tempViewController: UIViewController? // 临时VC
    var tempView: UIView? //临时view
    var currentIndex: Int = 0 { // 当前vc||View的下标
        didSet {
            switchScrollerNextEnabled = true
            switchScrollerLastEnabled = true
            if currentIndex == 0 {
                switchScrollerLastEnabled = false
                switchDelegate?.switchToFirstFunc()
            } else if currentIndex == totalNums - 1 {
                switchScrollerNextEnabled = false
                switchDelegate?.switchToLastFunc()
            }
        }
    }
    var lastIndex: Int { //上一页面下标
        get {
            let index = self.currentIndex - 1
            return index
        }
    }
    var nextIndex: Int {
        get {
            let index = self.currentIndex + 1
            return index
        }
    }
    var controllerEnabled: Bool = true //  true 子控件是vc  false  子控件是view
    var switchAnimated: Bool = true // 动画开启状态
    var switchScrollerLastEnabled: Bool = true // 向上滑动
    var switchScrollerNextEnabled: Bool = true // 向下滑动
    var isAnimating: Bool = false // 是否动画
    var isPan: Bool = false // 滑动手势
    var isPanBegan: Bool = false // 是否重新点击了手势
    var isLeft: Bool = false // 是否是左边
    var totalNums: Int = 0 // 总页数
    var switchPanEnabled: Bool = true { //手势滑动启用状态
        didSet {
            selfPanGesture.isEnabled = switchPanEnabled
        }
    }
    var switchTapEnabled: Bool = true { // 单击滑动启用状态
        didSet {
            selfTapGesture.isEnabled = switchTapEnabled
        }
    }
    //MARK: 内部使用
    lazy var selfPanGesture: UIPanGestureRecognizer = {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGestureFunc(_:)))
        return panGesture
    }()
    lazy var selfTapGesture: UITapGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGestureFunc(_:)))
        return tapGesture
    }()
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    init() {
        super.init(nibName: nil, bundle: nil)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        self.view.removeGestureRecognizer(selfTapGesture)
        self.view.removeGestureRecognizer(selfPanGesture)
        self.view.addGestureRecognizer(selfTapGesture)
        self.view.addGestureRecognizer(selfPanGesture)
    }
    deinit {
        //移除手势
        self.view.removeGestureRecognizer(selfTapGesture)
        self.view.removeGestureRecognizer(selfPanGesture)
        if currentViewContoller != nil {
            currentViewContoller?.view.removeFromSuperview()
            currentViewContoller?.removeFromParent()
            currentViewContoller = nil
        }
        if tempViewController != nil {
            tempViewController?.view.removeFromSuperview()
            tempViewController?.removeFromParent()
            tempViewController = nil
        }
        if currentView != nil {
            currentView?.removeFromSuperview()
            currentView = nil
        }
        if tempView != nil {
            tempView?.removeFromSuperview()
            tempView = nil
        }
    }
}
extension SwitchCoverController {
    public func reloadData() {
        totalNums = switchDataDelagte?.totalNumInPageController() ?? 0
        guard totalNums > 0 else { return }
        currentIndex = 0
        if controllerEnabled { // VC
            tempViewController = switchDataDelagte?.tempViewControllerForIndex(currentIndex)
            // 初始化
            initBaseViewControllerFunc()
        } else { // View

        }

    }
    // 滑动手势
    @objc func handlePanGestureFunc(_ pan: UIPanGestureRecognizer) {
        let tempPoint = pan.location(in: self.view)
        switch(pan.state) {
        case .began:
            guard isAnimating == false else { return }
            isAnimating = true
            isPan = true
            isPanBegan = true
        case .changed:
            if isPanBegan {
                isPanBegan = false
                isLeft = tempPoint.x < self.view.center.x ? true : false
                guard isCanHandlePanOrTapFunc() == true else {
                    isPan = false
                    return
                }
                if controllerEnabled { // VC
                    tempViewController = getTempViewControllerFunc()
                    addSubViewControllerFunc(tempViewController ?? UIViewController())
                } else {
                    // 视图

                }
            }
            guard isPan == true else { return }
            // 滑动改变VC ||View 的位置
            if controllerEnabled { // VC
                guard tempViewController != nil else { return }
                if isLeft {
                    self.tempViewController?.view.frame = CGRect(x: tempPoint.x - self.view.frame.width, y: 0, width: self.view.frame.width, height: self.view.frame.height)
                } else {
                    self.currentViewContoller?.view.frame = CGRect(x: tempPoint.x - self.view.frame.width, y: 0, width: self.view.frame.width, height: self.view.frame.height)
                }
            } else {
                //View
            }
        default:
            // 结束等事件
            guard isPan else { return }
            isPan = false
            if controllerEnabled { //VC
                guard tempViewController != nil else {
                    isAnimating = false
                    return
                }
                var isSuccess: Bool = true
                if isLeft {
                    if (self.tempViewController?.view.frame.origin.x ?? 0) <= -self.view.frame.width * 0.5 {
                        isSuccess = false
                    }
                } else {
                    if (self.currentViewContoller?.view.frame.origin.x ?? 0) >= -self.view.frame.width * 0.5 {
                        isSuccess = false
                    }
                }
                gestureSuccessFunc(isSuccess, switchAnimated)
            } else { // View

            }
        }
    }
    // 点击手势
    @objc func handleTapGestureFunc(_ pan: UITapGestureRecognizer) {
        guard isAnimating == false else { return }
        isAnimating = true
        let touchPoint = pan.location(in: self.view)
        isLeft = touchPoint.x < self.view.center.x ? true : false
        guard isCanHandlePanOrTapFunc() == true else { return }
        if controllerEnabled == true {
            tempViewController = getTempViewControllerFunc()
            if let tempVC = tempViewController {
                addSubViewControllerFunc(tempVC)
            }
        } else {
            //

        }
        //成功
        gestureSuccessFunc(true, self.switchAnimated)
    }
    /// 手势成功(滑动 || 点击)
    /// - Parameters:
    ///   - isSuccess: 成功
    ///   - isAnimated: 是否动画
    fileprivate func gestureSuccessFunc(_ isSuccess: Bool, _ isAnimated: Bool) {

        if controllerEnabled {
            if self.tempViewController != nil {
                if isAnimated {
                    gestureSuccessFromDirectionOfViewControllerByAnimate(isSuccess)
                } else {
                    gestureSuccessFormDirectionOfViewConrollerByNone(isSuccess)
                }
            } else {
                // View的切换

            }
        }
    }
    /// VC动画切换
    /// - Parameter isSuccess: 手势是否结束
    fileprivate func gestureSuccessFromDirectionOfViewControllerByAnimate(_ isSuccess: Bool) {

        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            guard let weakSelf = self else { return }
            if isSuccess {
                if weakSelf.isLeft {
                    weakSelf.tempViewController?.view.frame = CGRect(x: 0, y: 0, width: weakSelf.view.frame.width, height: weakSelf.view.frame.height)
                } else {
                    weakSelf.currentViewContoller?.view.frame = CGRect(x: -weakSelf.view.frame.width, y: 0, width: weakSelf.view.frame.width, height: weakSelf.view.frame.height)
                }
            } else {
                if weakSelf.isLeft {
                    weakSelf.tempViewController?.view.frame = CGRect(x: -weakSelf.view.frame.width, y: 0, width: weakSelf.view.frame.width, height: weakSelf.view.frame.height)
                } else {
                    weakSelf.currentViewContoller?.view.frame = CGRect(x: 0, y: 0, width: weakSelf.view.frame.width, height: weakSelf.view.frame.height)
                }
            }
        }) { [weak self](finished) in
            guard let weakSelf = self else { return }
            weakSelf.animatedSuccessFunc(isSuccess)
        }
    }
    /// VC非动画切换
    /// - Parameter isSuccess: 是否成功
    fileprivate func gestureSuccessFormDirectionOfViewConrollerByNone(_ isSuccess: Bool) {

        if isSuccess {
            self.tempViewController?.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        } else {
            self.tempViewController?.view.frame = CGRect(x: -self.view.frame.width, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        }
        self.animatedSuccessFunc(isSuccess)
    }
    // 动画结束 响应代理
    fileprivate func animatedSuccessFunc(_ isSuccess: Bool) {

        if controllerEnabled { // VC
            if isSuccess {
                currentViewContoller?.view.removeFromSuperview()
                currentViewContoller?.removeFromParent()
                currentViewContoller = tempViewController
                tempViewController = nil
                isAnimating = false
                if isLeft {
                    currentIndex -= 1
                } else {
                    currentIndex += 1
                }
            } else {
                tempViewController?.view.removeFromSuperview()
                tempViewController?.removeFromParent()
                tempViewController = nil
                isAnimating = false
            }
            switchDelegate?.currentViewController(currentViewContoller ?? UIViewController(), currentIndex)
        } else {
            // 视图
            // 代理
        }
    }
    /// 获取临时需要的VC ->  重新创建的VC
    fileprivate func getTempViewControllerFunc() -> UIViewController? {
        var baseVC: UIViewController?

        if isLeft {
            baseVC = switchDataDelagte?.tempViewControllerForIndex(lastIndex)
        } else {
            baseVC = switchDataDelagte?.tempViewControllerForIndex(nextIndex)
        }
        if baseVC == nil {
            isAnimating = false
        }
        return baseVC
    }
    // 添加控制器
    fileprivate func addSubViewControllerFunc(_ viewController: UIViewController) {
        if controllerEnabled {
            self.addChild(viewController)
            if isLeft { // 左边
                self.view.addSubview(viewController.view)
                viewController.view.frame = CGRect(x: -self.view.frame.width, y: 0, width: self.view.frame.width, height: self.view.frame.height)
            } else {
                if let currentVC = currentViewContoller {
                    self.view.insertSubview(viewController.view, belowSubview: currentVC.view)
                } else {
                    self.view.addSubview(viewController.view)
                }
                viewController.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
            }
            viewControllerShadowFunc(viewController)
        }

    }
}
extension SwitchCoverController {
    // 初始化VC
    fileprivate func initBaseViewControllerFunc() {
        addSubViewControllerFunc(tempViewController ?? UIViewController())
        if isAnimating {
            UIView.animate(withDuration: 0.2, animations: { [weak self] in
                guard let weakSelf = self else { return }
                if weakSelf.isLeft == true {
                    weakSelf.tempViewController?.view.frame = CGRect(x: 0, y: 0, width: weakSelf.view.frame.width, height: weakSelf.view.frame.height)
                } else {
                    weakSelf.currentViewContoller?.view.frame = CGRect(x: -weakSelf.view.frame.width, y: 0, width: weakSelf.view.frame.width, height: weakSelf.view.frame.height)
                }
            }) { [weak self] (finish) in
                guard let weakSelf = self else { return }
                weakSelf.initBaseVIewcontrollerCompletedFunc()
            }
        } else {
            tempViewController?.view.frame = self.view.bounds
            initBaseVIewcontrollerCompletedFunc()
        }
    }
    fileprivate func initBaseVIewcontrollerCompletedFunc() {
        isAnimating = false
        if currentViewContoller != nil {
            currentViewContoller?.view.removeFromSuperview()
            currentViewContoller?.removeFromParent()
            currentViewContoller = nil
        }
        currentViewContoller = tempViewController
        tempViewController = nil
        // 当前VCz代理
        switchDelegate?.currentViewController(currentViewContoller ?? UIViewController(), currentIndex)
    }
    // 是否可以滑动   点击等
    fileprivate func isCanHandlePanOrTapFunc() -> Bool {
        var isCan: Bool = true
        guard totalNums > 0 else {
            isAnimating = false
            return false
        }
        if isLeft {
            if switchScrollerLastEnabled == false {
                isCan = false
                isAnimating = false
                //执行代理方法   不能继续向上滑动了
                switchDelegate?.switchToLastDisAbled()
            }
        } else {
            if switchScrollerNextEnabled == false {
                isCan = false
                isAnimating = false
                switchDelegate?.switchToNextDisAbled()
            }
        }
        return isCan
    }
    // vc设置阴影
    fileprivate func viewControllerShadowFunc(_ baseVC: UIViewController) {
        baseVC.view.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        baseVC.view.layer.shadowOffset = CGSize(width: 0, height: 0)
        baseVC.view.layer.shadowOpacity = 0.5
        baseVC.view.layer.shadowRadius = 10.0
    }
}

extension SwitchCoverController {
    // 跳转上一页面
    public func switchToLastAnimated(_ animated: Bool) {
        switchToIndex(currentIndex - 1, animated)
    }
    // 跳转下一页面
    public func switchToNextAnimated(_ animated: Bool) {
        switchToIndex(currentIndex + 1, animated)
    }
    /// 切换VC至指定的VC
    /// - Parameters:
    ///   - index: 下标
    ///   - animated: 动画
    public func switchToIndex(_ index: Int, _ animated: Bool) {

        guard currentIndex != index else { return }
        guard currentIndex < totalNums else { return }
        guard index >= 0 else {
            switchDelegate?.switchToLastDisAbled()
            return
        }
        guard index < totalNums else {
            switchDelegate?.switchToNextDisAbled()
            return
        }
        isAnimating = animated
        isLeft = index < currentIndex ? true : false
        currentIndex = index
        if controllerEnabled { // VC
            tempViewController = switchDataDelagte?.tempViewControllerForIndex(currentIndex)
            initBaseViewControllerFunc()
        } else { // view

        }
    }
}
