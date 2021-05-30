

import Foundation
import UIKit

class CustomButton: UIButton  {
    
    private let lbl:  UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .right
        lbl.font = UIFont.systemFont(ofSize: 9)
        lbl.textColor = .white
        return lbl
    }()
    
    init(label: String) {
        super.init(frame: .zero)
        lbl.text = label
        addSubview(lbl)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        lbl.frame = CGRect(x: -5, y: 0, width: self.frame.width, height: 20)
    }
    
}

