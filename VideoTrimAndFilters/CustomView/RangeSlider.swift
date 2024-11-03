//
//  RangeSlider.swift
//  VideoTrimAndFilters
//
//  Created by Aamir on 03/11/2024.
//

import UIKit

final class RangeSlider: UIView {
    var minimumValue: CGFloat = 0
    var maximumValue: CGFloat = 1
    
    var startValue: CGFloat = 0 {
        didSet { updateLayerFrames() }
    }
    
    var endValue: CGFloat = 1 {
        didSet { updateLayerFrames() }
    }
    
    private let trackLayer = CALayer()
    private let startThumbLayer = CALayer()
    private let endThumbLayer = CALayer()
    private var isTouchingStartThumb = false
    private var isTouchingEndThumb = false
    
    private let trackHeight: CGFloat = 4
    private let thumbSize: CGFloat = 28
    
    var valueChangedCallback: ((CGFloat, CGFloat) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
    }
    
    private func setupLayers() {
        trackLayer.backgroundColor = UIColor.systemGray.cgColor
        layer.addSublayer(trackLayer)
        
        startThumbLayer.backgroundColor = UIColor.systemBlue.cgColor
        startThumbLayer.cornerRadius = thumbSize / 2
        layer.addSublayer(startThumbLayer)
        
        endThumbLayer.backgroundColor = UIColor.systemBlue.cgColor
        endThumbLayer.cornerRadius = thumbSize / 2
        layer.addSublayer(endThumbLayer)
        
        updateLayerFrames()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayerFrames()
    }
    
    private func updateLayerFrames() {
        let trackY = (bounds.height - trackHeight) / 2
        trackLayer.frame = CGRect(x: 0, y: trackY, width: bounds.width, height: trackHeight)
        
        let startThumbCenter = positionForValue(startValue)
        startThumbLayer.frame = CGRect(x: startThumbCenter - thumbSize / 2, y: trackY - thumbSize / 2 + trackHeight / 2, width: thumbSize, height: thumbSize)
        
        let endThumbCenter = positionForValue(endValue)
        endThumbLayer.frame = CGRect(x: endThumbCenter - thumbSize / 2, y: trackY - thumbSize / 2 + trackHeight / 2, width: thumbSize, height: thumbSize)
    }
    
    private func positionForValue(_ value: CGFloat) -> CGFloat {
        return bounds.width * (value - minimumValue) / (maximumValue - minimumValue)
    }
    
    private func valueForPosition(_ position: CGFloat) -> CGFloat {
        return minimumValue + (maximumValue - minimumValue) * position / bounds.width
    }
}

// MARK: Override
extension RangeSlider {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        
        if startThumbLayer.frame.contains(touchLocation) {
            isTouchingStartThumb = true
        } else if endThumbLayer.frame.contains(touchLocation) {
            isTouchingEndThumb = true
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        
        if isTouchingStartThumb {
            let newValue = valueForPosition(touchLocation.x)
            // Ensure start is always less than end
            startValue = min(newValue, endValue)
        } else if isTouchingEndThumb {
            let newValue = valueForPosition(touchLocation.x)
            // Ensure end is always greater than start
            endValue = max(newValue, startValue)
        }
        
        valueChangedCallback?(startValue, endValue)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isTouchingStartThumb = false
        isTouchingEndThumb = false
        
        print("startValue: \(startValue)")
        print("endValue: \(endValue)")
    }
}
