import Foundation

struct RegistrationViewModel: AuthenticationProtocol {
    var photo: String?
    var email: String?
    var fullname: String?
    var username: String?
    var password: String?
    
    var formIsValid: Bool {
        return email?.isEmpty == false
        && fullname?.isEmpty == false
        && username?.isEmpty == false
        && password?.isEmpty == false
        && password!.count >= 6
    }
}
