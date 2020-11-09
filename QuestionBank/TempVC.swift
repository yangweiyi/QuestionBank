//
//  TempVC.swift
//  QuestionBank
//
//  Created by ZR on 2020/11/9.
//  Copyright © 2020 wely. All rights reserved.
//

import UIKit

class TempVC: UIViewController {
    var currentIndex: Int = 0
//    let backViewColor =
    lazy var currentLabel: UILabel = {
        let currentLabel = UILabel(frame: CGRect(x: 100, y: 100, width: 100, height: 100))
        currentLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        currentLabel.textColor = .black
        return currentLabel
    }()
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white
        self.view.addSubview(currentLabel)
        currentLabel.text = "\(currentIndex)"
    }
    deinit {
        debugPrint("tempVC 释放了  + +++ ")
    }
}
