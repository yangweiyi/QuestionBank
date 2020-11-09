//
//  ViewController.swift
//  QuestionBank
//
//  Created by ZR on 2020/11/9.
//  Copyright © 2020 wely. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    lazy var lastButton: UIButton = {
        let lastBtn = UIButton(frame: CGRect(x: 10, y: self.view.center.y - 15, width: 100, height: 30))
        lastBtn.setTitle("上一页", for: .normal)
        lastBtn.setTitleColor(.red, for: .normal)
        lastBtn.addTarget(self, action: #selector(lastFunc), for: .touchUpInside)
        return lastBtn
    }()
    lazy var nextButton: UIButton = {
        let nextBtn = UIButton(frame: CGRect(x: self.view.frame.width - 110, y: self.view.center.y - 15, width: 100, height: 30))
        nextBtn.setTitle("下一页", for: .normal)
        nextBtn.setTitleColor(.red, for: .normal)
        nextBtn.addTarget(self, action: #selector(nextFunc), for: .touchUpInside)
        return nextBtn
    }()
    lazy var centerButton: UIButton = {
        let centerBtn = UIButton(frame: CGRect(x: self.view.center.x, y: self.view.center.y - 15, width: 100, height: 30))
        centerBtn.setTitle("跳转指定页面", for: .normal)
        centerBtn.setTitleColor(.red, for: .normal)
        centerBtn.addTarget(self, action: #selector(specifiedPageFunc), for: .touchUpInside)
        return centerBtn
    }()
    lazy var pageBaseVC: SwitchCoverController = {
        let baseVC = SwitchCoverController()
        baseVC.controllerEnabled = true
        baseVC.switchDataDelagte = self
        baseVC.switchDelegate = self
        baseVC.switchPanEnabled = true
        baseVC.switchTapEnabled = true
        return baseVC
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.view.addSubview(pageBaseVC.view)
        self.addChild(pageBaseVC)
        pageBaseVC.reloadData()
        self.view.addSubview(lastButton)
        self.view.addSubview(nextButton)
        self.view.addSubview(centerButton)
    }
    @objc func lastFunc() {

        pageBaseVC.switchToLastAnimated(true)
    }
    @objc func nextFunc() {

        pageBaseVC.switchToNextAnimated(true)
    }

    @objc func specifiedPageFunc() {
        pageBaseVC.switchToIndex(5, true)
    }

}

extension ViewController: SwitchDataDelegate {
    func totalNumInPageController() -> Int {
        return 10
    }

    func tempViewControllerForIndex(_ index: Int) -> UIViewController {
        let vc = TempVC()
        vc.currentIndex = index
        return vc
    }

    func tempViewForIndex(_ index: Int) -> UIView {
        debugPrint("打印view")
        return UIView()
    }
}
extension ViewController: SwitchUIDelegate {
    func switchToLastDisAbled() {
        debugPrint("无法向上滑动")
    }

    func switchToNextDisAbled() {
        debugPrint("无法向下滑动")
    }

    func switchToFirstFunc() {
        debugPrint("当前是第一个")
    }

    func switchToLastFunc() {
        debugPrint("当前是第最后一个")
    }

    func currentViewController(_ viewController: UIViewController, _ currentIndex: Int) {
        debugPrint("获取当前滑动的VC:\(viewController) *&***  当前下标:\(currentIndex)")
    }


}

