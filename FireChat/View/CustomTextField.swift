import UIKit

class CustomTextField: UITextField {
    init(placeholder: String, shouldCaptalize wordCaptalized: Bool? = false, shouldAutoCorrect autoCorrect: Bool = false) {
        super.init(frame: .zero)
        
        borderStyle = .none
        font = UIFont.systemFont(ofSize: 16)
        textColor = .white
        keyboardAppearance = .dark
        autocapitalizationType = wordCaptalized! ? .words : .none
        autocorrectionType = autoCorrect ? .yes : .no
        attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: UIColor.white]
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
