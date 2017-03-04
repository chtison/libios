//
//  GradientView.swift
//  Swifty Protein
//
//  Copyright © 2017 chtison. All rights reserved.
//

import UIKit

@IBDesignable
open class GradientView: UIView {
    @IBInspectable
    public var startColor: UIColor = UIColor.green {
        didSet {
            setColors()
        }
    }
    @IBInspectable
    public var endColor: UIColor = UIColor.blue {
        didSet {
            setColors()
        }
    }
    
    private func setColors() {
        gradientLayer.colors = [endColor.cgColor, startColor.cgColor]
        setNeedsDisplay()
    }
    
    private lazy var gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.colors = [self.startColor.cgColor, self.endColor.cgColor]
        gradientLayer.transform = CATransform3DMakeRotation(CGFloat.pi / 2, 0, 0, 1)
        return gradientLayer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    open override func layoutSubviews() {
        gradientLayer.frame = bounds
    }
}
