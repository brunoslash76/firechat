import UIKit

protocol CustomInputAccessoryViewDelegate: AnyObject {
    func inputView(_ inputView: CustomInputAccessoryView, wantsToSend message: String)
}
