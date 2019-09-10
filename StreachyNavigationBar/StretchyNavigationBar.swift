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

    @IBInspectable var maxStretch: CGFloat = 0
    @IBInspectable var stretchTitle: Bool = false
    @IBInspectable var titleMaxFontSize: CGFloat = 30
    
    weak var delegate: StretchyNavigationBarDelegate? {
        didSet {
            if let scrollView = delegate?.scrollViewForBarStretching() {
                scrollView.delegate = self
            }
        }
    }
    
    fileprivate var heightConstraint: NSLayoutConstraint?
    fileprivate var navBarOriginalHeight: CGFloat = 0.0
    fileprivate var lblTitle: UILabel?
    fileprivate var lblTitleOriginalFontSize: CGFloat = 0.0
    fileprivate var lblTitleFont: UIFont?
    fileprivate var leadingBarButtton: UIButton?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        guard let navBarHeight = getNavigationBarHeight() else { return }
        navBarOriginalHeight = navBarHeight
        
        if let heightConstraint = constraints.filter ({ $0.firstAttribute == .height }).first {
            self.heightConstraint = heightConstraint
            heightConstraint.constant = navBarHeight
        } else {
            heightConstraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: navBarHeight)
            heightConstraint!.isActive = true
        }
        
        if let superView = superview {
            superView.bringSubviewToFront(self)
            let bottomConstraints = superView.constraints.filter ({ $0.firstAttribute == .bottom ||  $0.secondAttribute == .bottom})
            
            guard let headerBottomConstraint = (bottomConstraints.filter { (($0.firstItem?.isKind(of: UIScrollView.self) ?? false) && ($0.secondItem?.isKind(of: StretchyNavigationBar.self) ?? false) ) || (($0.secondItem?.isKind(of: UIScrollView.self) ?? false) && ($0.firstItem?.isKind(of: StretchyNavigationBar.self) ?? false))}).first else { return }
            
            if let scrollView = headerBottomConstraint.firstItem as? UIScrollView {
                headerBottomConstraint.isActive = false
                NSLayoutConstraint(item: scrollView, attribute: .top, relatedBy: .equal, toItem: superView, attribute: .top, multiplier: 1, constant: navBarOriginalHeight).isActive = true
            }
            
            if let scrollView2 = headerBottomConstraint.secondItem as? UIScrollView {
                headerBottomConstraint.isActive = false
                NSLayoutConstraint(item: scrollView2, attribute: .top, relatedBy: .equal, toItem: superView, attribute: .top, multiplier: 1, constant: navBarOriginalHeight).isActive = true
            }
        }
        
        lblTitle = subviews.filter ({ $0.isKind(of: UILabel.self) }).first as? UILabel
        if let lblTitle = lblTitle, let lblFont = lblTitle.font {
            lblTitleOriginalFontSize = lblFont.pointSize
            lblTitleFont = lblTitle.font
        }
        
        if let leadingBarButtton = (subviews.filter { $0.isKind(of: UIButton.self) }.first) as? UIButton {
            self.leadingBarButtton = leadingBarButtton
        }
        
    }
    
    private func getNavigationBarHeight() -> CGFloat? {
        let application = UIApplication.shared
        guard let keyWindow = application.keyWindow, let navController = keyWindow.rootViewController as? UINavigationController else { return nil}
        let navBarHeight = navController.navigationBar.bounds.height
        let statusBarHeight = application.statusBarFrame.height
        let totalNavBarHeight = navBarHeight + statusBarHeight
        return totalNavBarHeight
    }
    
    func stretch(scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        guard let heightConstraint = heightConstraint, let lblTitle = lblTitle else { return }
        let newHeight = navBarOriginalHeight + -offsetY
        guard offsetY <= 0, newHeight <= maxStretch else { return }
        heightConstraint.constant = newHeight

        if stretchTitle {
            let newFontSize = lblTitleOriginalFontSize + (-offsetY * 0.1)
            if newFontSize <= titleMaxFontSize {
                lblTitle.font = lblTitleFont?.withSize(newFontSize)
            }
        }
        
        let totalHeightToStretch: CGFloat = maxStretch - navBarOriginalHeight
        let totalDegreeToRotate: CGFloat = -90
        let degreeToRotatePerMove = totalDegreeToRotate / totalHeightToStretch
        let currentDegreeToMove = degreeToRotatePerMove * -offsetY
        print(currentDegreeToMove)
        let currentDegreeToMoveInRadian = CGFloat(deg2rad(Double(currentDegreeToMove)))
        let rotation = CGAffineTransform(rotationAngle: currentDegreeToMoveInRadian)
        self.leadingBarButtton?.transform = rotation
    }
    
    func deg2rad(_ number: Double) -> Double {
        return number * .pi / 180
    }

}

extension StretchyNavigationBar: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        stretch(scrollView: scrollView)
    }
    
}
