//
//  InputViews.swift
//  found
//
//  Created by Ellen Li on 5/1/22.
//

import UIKit

extension UITextField {
    static func fieldLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .Theme.text
        label.font = .systemFont(ofSize: 15)
        return label
    }
}

class InputField: UITextField {
    var decodeType: DecodeType
    
    let title: String
    var validPlacerHolder: NSAttributedString {
        NSAttributedString(string: "Insert \(title)", attributes: [.foregroundColor: UIColor.Theme.subText])
    }
    var inValidplacerHolder: NSAttributedString {
        NSAttributedString(string: validPlacerHolder.string, attributes: [.foregroundColor: UIColor.red])
    }
    
    init(title: String, decodeType: DecodeType = .text) {
        self.title = title
        self.decodeType = decodeType
        
        super.init(frame: .zero)
        
        attributedPlaceholder = validPlacerHolder
        font = .systemFont(ofSize: 20)
        textColor = .Theme.text
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension InputField {
    enum DecodeType {
        case text
    }
    
    func validate() -> Bool {
        let setValidStyle: () -> Void = { self.attributedPlaceholder = self.validPlacerHolder }
        let setInvalidStyle: () -> Void = { self.attributedPlaceholder = self.inValidplacerHolder }
        
        if let _ = decodeText() {
            setValidStyle()
            return true
        } else {
            setInvalidStyle()
            return false
        }
        }
    
    func decodeText() -> String? {
        guard let text = text, !text.isEmpty else { return nil }
        return text
    }
}


extension Array where Element == Optional<Int> {
    func chainOptional() -> [Int]? {
        var result = [Int]()
        for i in self {
            guard let i = i else { return nil }
            result.append(i)
        }
        return result
    }
}

