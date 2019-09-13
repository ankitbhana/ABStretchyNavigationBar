//
//  StretchyNavigationBar.swift
//  StretchyNavigationBar
//
//  Created by Ankit Bhana on 06/09/19.
//  Copyright © 2019 Ankit Bhana. All rights reserved.
//

import UIKit

protocol StretchyNavigationBarDelegate: class {
    func scrollViewForBarStretching() -> UIScrollView
}

class StretchyNavigationBar: UIView {
    
    //MARK: - IBInspectable properties
    @IBInspectable var barStretch: Bool = true
    @IBInspectable var barMaxStretch: CGFloat = 200
    @IBInspectable var titleStretch: Bool = false
    @IBInspectable var titleMaxFontSize: CGFloat = 25
    @IBInspectable var leadingBarButttonAnim: Bool = false
    @IBInspectable var leadingBarButttonMaxRotation: CGFloat = -90
    
    //MARK: - fileprivate properties
    fileprivate var scrollView: UIScrollView?
    fileprivate var heightConstraint: NSLayoutConstraint?
    fileprivate var navBarOriginalHeight: CGFloat = 0.0
    fileprivate var lblTitle: UILabel?
    fileprivate var lblTitleOriginalFontSize: CGFloat = 0.0
    fileprivate var lblTitleFont: UIFont?
    fileprivate var leadingBarButtton: UIButton?
    
    //MARK: - Instance properties
    weak var delegate: StretchyNavigationBarDelegate? {
        didSet {
            guard let scrollView = delegate?.scrollViewForBarStretching() else { return }
            self.scrollView = scrollView
            scrollView.delegate = self
            configBarForAnimations()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //set navigation bar height
        setBarHeight()
    }
    
    
    //MARK: - Helper Methods
    private func setBarHeight() {
        guard let navBarHeight = getNavigationBarHeight() else { return }
        navBarOriginalHeight = navBarHeight
        
        if let heightConstraint = constraints.filter ({ $0.firstAttribute == .height }).first {
            self.heightConstraint = heightConstraint
            heightConstraint.constant = navBarHeight
        } else {
            heightConstraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: navBarHeight)
            heightConstraint!.isActive = true
        }
    }
    
    
    private func configBarForAnimations() {
        //execute code only when bar streching is on
        if barStretch {
            initialSetupForBarStretch()
        }
        
        //execute code only when title streching is on
        if titleStretch {
            initialSetupForTitleStretch()
        }
        
        //execute code only when leading button animation is on
        if leadingBarButttonAnim {
            initialSetupForBtnRotation()
        }
    }
    
    
    private func animateBarComponents(scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        guard offsetY <= 0 else { return }
        if barStretch { startBarStretching(offsetY: offsetY) }
        if titleStretch { startTitleStretching(offsetY: offsetY) }
        if leadingBarButttonAnim { startBarBtnRotation(offsetY: offsetY) }
    }
    
}

//MARK: - For bar configurations
extension StretchyNavigationBar {
    
    private func initialSetupForBarStretch() {
        if let superView = superview {
            
            superView.bringSubviewToFront(self)
            
            let bottomConstraints = superView.constraints.filter ({ $0.firstAttribute == .bottom ||  $0.secondAttribute == .bottom})
            
            guard let headerBottomConstraint = (bottomConstraints.filter { (($0.firstItem?.isKind(of: UIScrollView.self) ?? false) && ($0.secondItem?.isKind(of: StretchyNavigationBar.self) ?? false) ) || (($0.secondItem?.isKind(of: UIScrollView.self) ?? false) && ($0.firstItem?.isKind(of: StretchyNavigationBar.self) ?? false))}).first else { return }
            
            func setScrollTopConstraint(headerBottomConstraint: NSLayoutConstraint, scrollView: UIScrollView, superView: UIView) {
                headerBottomConstraint.isActive = false
                NSLayoutConstraint(item: scrollView, attribute: .top, relatedBy: .equal, toItem: superView, attribute: .top, multiplier: 1, constant: navBarOriginalHeight).isActive = true
            }
            
            if let scrollView = headerBottomConstraint.firstItem as? UIScrollView {
                setScrollTopConstraint(headerBottomConstraint: headerBottomConstraint, scrollView: scrollView, superView: superView)
                return
            }
            
            if let scrollView = headerBottomConstraint.secondItem as? UIScrollView {
                setScrollTopConstraint(headerBottomConstraint: headerBottomConstraint, scrollView: scrollView, superView: superView)
            }
        }
        
    }
    
    private func initialSetupForTitleStretch() {
        lblTitle = subviews.filter ({ $0.isKind(of: UILabel.self) }).first as? UILabel
        guard let lblTitle = lblTitle, let lblFont = lblTitle.font else { return }
        lblTitleOriginalFontSize = lblFont.pointSize
        lblTitleFont = lblTitle.font
    }
    
    private func initialSetupForBtnRotation() {
        leadingBarButtton = (subviews.filter { $0.isKind(of: UIButton.self) }.first) as? UIButton
    }

}

//MARK: - For animations
extension StretchyNavigationBar {
    
    private func startBarStretching(offsetY: CGFloat) {
        guard let heightConstraint = heightConstraint else { return }
        let newHeight = navBarOriginalHeight + -offsetY
        guard newHeight <= barMaxStretch else { return }
        heightConstraint.constant = newHeight
    }
    
    private func startTitleStretching(offsetY: CGFloat) {
        guard let lblTitle = lblTitle else { return }
        
//        print(lblTitle.frame)
        /*let totalHeightToStretch: CGFloat = barStretch ? barMaxStretch - navBarOriginalHeight : 130
        guard -offsetY <= totalHeightToStretch + lblTitle.bounds.height else { return }
        let degreeToRotatePerMove = totalHeightToStretch / 40
        let currentDegreeToMove = degreeToRotatePerMove * -offsetY
        print(currentDegreeToMove)
        let newY = currentDegreeToMove
        let trans = CGAffineTransform(translationX: -currentDegreeToMove , y: newY)
        lblTitle.transform = trans*/

        
        let newFontSize = lblTitleOriginalFontSize + (-offsetY * 0.1)
        if newFontSize <= titleMaxFontSize {
            lblTitle.font = lblTitleFont?.withSize(newFontSize)
        }
    }
    
    private func startBarBtnRotation(offsetY: CGFloat) {
        let totalHeightToStretch: CGFloat = barStretch ? barMaxStretch - navBarOriginalHeight : 130
        guard -offsetY <= totalHeightToStretch else { return }
        let degreeToRotatePerMove = leadingBarButttonMaxRotation / totalHeightToStretch
        let currentDegreeToMove = degreeToRotatePerMove * -offsetY
        let currentDegreeToMoveInRadian = CGFloat(deg2rad(Double(currentDegreeToMove)))
        let rotation = CGAffineTransform(rotationAngle: currentDegreeToMoveInRadian)
        self.leadingBarButtton?.transform = rotation
    }
    
}

//MARK: - Utility
extension StretchyNavigationBar {
    
    private func getNavigationBarHeight() -> CGFloat? {
        let application = UIApplication.shared
        guard let keyWindow = application.keyWindow, let navController = keyWindow.rootViewController as? UINavigationController else { return nil}
        let navBarHeight = navController.navigationBar.bounds.height
        let statusBarHeight = application.statusBarFrame.height
        let totalNavBarHeight = navBarHeight + statusBarHeight
        return totalNavBarHeight
    }

    private func deg2rad(_ number: Double) -> Double {
        return number * .pi / 180
    }

}

//MARK: - UIScrollViewDelegate
extension StretchyNavigationBar: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        animateBarComponents(scrollView: scrollView)
    }
    
}
