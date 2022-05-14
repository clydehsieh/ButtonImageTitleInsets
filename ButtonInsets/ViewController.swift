//
//  ViewController.swift
//  ButtonInsets
//
//  Created by ClydeHsieh on 2021/10/5.
//

import UIKit

class ViewController: UIViewController {

    private var button: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let btn = makeButton()
        view.addSubview(btn)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.topAnchor.constraint(equalTo: view.topAnchor, constant: 50).isActive = true
        btn.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        btn.widthAnchor.constraint(equalToConstant: 150).isActive = true
        btn.heightAnchor.constraint(equalToConstant: 25).isActive = true
        btn.titleLabel?.backgroundColor = .blue
        btn.imageView?.backgroundColor = .red
        
        button = btn
        
        makeInsetSlider(title: "imageInset", offsetY: 150) { [weak self] newInset in
            btn.imageEdgeInsets = newInset
            self?.printValue()
        }
        
        makeInsetSlider(title: "titleInset", offsetY: 300) { [weak self] newInset in
            btn.titleEdgeInsets = newInset
            self?.printValue()
        }

        makeInsetSlider(title: "contentInset", offsetY: 450) { [weak self] newInset in
            btn.contentEdgeInsets = newInset
            self?.printValue()
        }
    }
    
    private func printValue() {
        debugPrint("titleFrame: \(button?.titleLabel?.frame)")
        debugPrint("imageFrame: \(button?.imageView?.frame)")
        
        let padding = ( (button?.titleLabel?.frame.minX ?? 0) - ( button?.imageView?.frame.maxX ?? 0))
        debugPrint("padding: \(padding)")
    }

    private func makeButton() -> UIButton {
        let btn = UIButton()
        
        btn.setTitle("Secondary", for: .normal)
        btn.setTitleColor(.lightGray, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 12, weight: .semibold)
        
        let width: CGFloat = 150
        btn.frame = .init(x: 10, y: 10, width: width, height: 25)
        btn.backgroundColor = .yellow
        
        btn.setImage(UIImage(named: "ind")?.resizeImage(targetSize: .init(width: 12, height: 12)), for: .normal)
        
        return btn
    }
    
    private func makeInsetSlider(title: String, offsetY: CGFloat, didChange:@escaping (UIEdgeInsets)->Void ) {
        let slider = InsetSliderView()
        slider.setup(title: title)
        
        self.view.addSubview(slider)
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.topAnchor.constraint(equalTo: view.topAnchor, constant: offsetY).isActive = true
        slider.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30).isActive = true
        slider.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7).isActive = true
        
        slider.valueDidChanged = didChange
        
        return
    }
}

class InsetSliderView: UIView {
    
    enum Inset: String, CaseIterable {
        case top
        case bottom
        case left
        case right
    }
    
    private let titleLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = .black
        lb.font = .systemFont(ofSize: 12, weight: .regular)
        return lb
    }()
    
    var unitViews: [Inset: SliderUnitView] = [:]
    var insets: UIEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 0)
    
    var valueDidChanged: ((UIEdgeInsets) -> ())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        var views: [SliderUnitView] = []
        for (_, type) in Inset.allCases.enumerated() {

            let unitView = makeUnitView(type: type)

            unitView.valueDidChanged = { [weak self] newValue in
                self?.updateInsets(type: type, value: CGFloat(newValue))
            }

            unitViews[type] = unitView
            views.append(unitViews[type]!)
        }

        let sv = UIStackView.init(arrangedSubviews: views)
        sv.axis = .vertical
        sv.spacing = 10
        
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 12).isActive = true
        
        addSubview(sv)
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.topAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
        sv.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        sv.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        sv.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(title: String) {
        titleLabel.text = title
    }
    
    private func makeUnitView(type: Inset) -> SliderUnitView {
        let unit = SliderUnitView()
        unit.setup(title: type.rawValue)
        return unit
    }
    
    private func updateInsets(type: Inset, value: CGFloat) {
        switch type {
        case .top:
            insets.top = value
        case .bottom:
            insets.bottom = value
        case .left:
            insets.left = value
        case .right:
            insets.right = value
        }
        
        valueDidChanged?(insets)
    }
}

class SliderUnitView: UIView {
    
    private let titleLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = .black
        lb.font = .systemFont(ofSize: 12, weight: .regular)
        return lb
    }()
    
    private let slider: UISlider = {
        let s = UISlider()
        s.addTarget(self, action: #selector(valueDidChanged(sender:)), for: .valueChanged)
        s.setThumbImage(UIImage(named: "search"), for: .normal)
        return s
    }()
    
    private let valueLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = .black
        lb.font = .systemFont(ofSize: 12, weight: .regular)
        return lb
    }()
    
    var valueDidChanged: ((Int) -> ())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        addSubview(slider)
        addSubview(valueLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        titleLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.leftAnchor.constraint(equalTo: titleLabel.rightAnchor, constant: 5).isActive = true
        slider.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
     
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        valueLabel.leftAnchor.constraint(equalTo: slider.rightAnchor, constant: 5).isActive = true
        valueLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        valueLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
        valueLabel.widthAnchor.constraint(equalToConstant: 30).isActive = true
        
        slider.value = 0.5
        valueDidChanged(sender: slider)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(title: String) {
        titleLabel.text = title
    }
    
    @objc func valueDidChanged(sender: UISlider) {
        
        let offsetValue = sender.value - 0.5
        
        let value = Int((offsetValue) * 100)
        valueDidChanged?(value)
        valueLabel.text = "\(value)"
    }
}

extension UIImage {
    func resizeImage(targetSize: CGSize) -> UIImage? {
        let size = self.size
        
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
