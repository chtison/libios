//
//  CircleView.swift
//  Swifty Protein
//
//  Copyright © 2017 chtison. All rights reserved.
//

import UIKit

@IBDesignable
class CircleView: UIView {
    
    @IBInspectable
    var layerBackgroundColor: UIColor = UIColor.clear {
        didSet {
            setLayerBackgroundColor()
        }
    }
    
    func setLayerBackgroundColor() {
        layer.backgroundColor = layerBackgroundColor.cgColor
        setNeedsDisplay()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        setLayerBackgroundColor()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.width / 2
    }
}
