import UIKit
import Firebase

class RegistrationController: UIViewController {
    // MARK: - Properties
    
    private var viewModel = RegistrationViewModel()
    private var profileImage: UIImage?
    weak var delegate: AuthenticationDelegate?
    
    private let plusPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        let image = #imageLiteral(resourceName: "plus_photo")
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(handleSelectPhoto), for: .touchUpInside)
        button.tintColor = .white
        button.imageView?.clipsToBounds = true
        button.imageView?.contentMode = .scaleAspectFill
        button.clipsToBounds = true
        return button
    }()
    
    private let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
        button.setTitle("Sign Up", for: .normal)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)
        button.isEnabled = false
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        button.setHeight(height: 50)
        return button
    }()
    
    private let alreadyHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(
            string: "Already have an account?  ",
            attributes: [
                .font: UIFont.systemFont(ofSize: 16),
                .foregroundColor: UIColor.white
            ]
        )
        attributedTitle.append(NSAttributedString(
            string: "Log In",
            attributes: [
                .font: UIFont.boldSystemFont(ofSize: 16),
                .foregroundColor: UIColor.white
            ]
        ))
        
        button.addTarget(self, action: #selector(handleShowLogin), for: .touchUpInside)
        button.setAttributedTitle(attributedTitle, for: .normal)
        return button
    }()
    
    private lazy var emailContainerView: InputContainerView = {
        return InputContainerView(
            image: UIImage(systemName: "envelope"),
            textField: emailTextField
        )
    }()
    
    private lazy var fullnameContainerView: UIView = {
        return InputContainerView(
            image: UIImage(systemName: "person.circle"),
            textField: fullnameTextField
        )
    }()
    
    private lazy var usernameContainerView: UIView = {
        return InputContainerView(
            image: UIImage(systemName: "person"),
            textField: usernameTextField
        )
    }()
    
    private lazy var passwordContainerView: UIView = {
        return InputContainerView(
            image: UIImage(systemName: "lock"),
            textField: passwordTextField
        )
    }()
    
    private let emailTextField = CustomTextField(placeholder: "Email")
    private let fullnameTextField = CustomTextField(placeholder: "Full Name", shouldCaptalize: true)
    private let usernameTextField = CustomTextField(placeholder: "Username")
    
    private let passwordTextField: CustomTextField = {
        let field = CustomTextField(placeholder: "Password")
        field.isSecureTextEntry = true
        return field
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemPurple
        configureUI()
    }
    
    // MARK: - Selectors
    @objc func handleSelectPhoto() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @objc func handleRegister() {
        print("ViewModel: \(viewModel)")
    }
    
    @objc func handleShowLogin() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func textDidChange(sender: UITextField) {
        if sender == emailTextField {
            viewModel.email = sender.text
        } else if sender == fullnameTextField {
            viewModel.fullname = sender.text
        } else if sender == usernameTextField {
            viewModel.username = sender.text
        } else if sender == passwordTextField {
            viewModel.password = sender.text
        }
        
        checkFormStatus()
    }
    
    @objc func handleShowSignUp() {
        showLoader(true, withText: "Signing you up...")
        guard let email = emailTextField.text else {
            self.errorHandler("E-mail is required")
            return
        }
        guard let fullname = fullnameTextField.text else {
            self.errorHandler("Fullname is required")
            return
        }
        guard let username = usernameTextField.text?.lowercased() else {
            self.errorHandler("Username is required")
            return
        }
        guard let password = passwordTextField.text else {
            self.errorHandler("Password is required")
            return
        }
        guard let profileImage = self.profileImage else {
            self.errorHandler("Profile image is required")
            return
        }
                
        let credencitals = RegistrationCredentials(
            email: email,
            fullname: fullname,
            username: username,
            password: password,
            profileImage: profileImage
        )
        
        AuthService.shared.createUser(credentials: credencitals) { error in
            if let error = error {
                self.errorHandler(error.localizedDescription)
                return
            }
            self.showLoader(false)
            self.delegate?.authenticationComplete()
        }
    }
    
    @objc func keyboardWillShow() {
        if view.frame.origin.y == 0 {
            self.view.frame.origin.y -= 88
        }
    }
    
    @objc func keyboardWillHide() {
        if view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    // MARK: - Helpers
    
    func errorHandler(_ message: String) {
        self.showError(message)
        self.showLoader(false)
    }
    
    func configureUI() {
        configureGradientLayer()
        configureNotificationObservers()
        
        view.addSubview(plusPhotoButton)
        plusPhotoButton.centerX(inView: view)
        plusPhotoButton.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            paddingTop: 32
        )
        plusPhotoButton.setDimensions(height: 180, width: 180)
        
        let stack = UIStackView(arrangedSubviews: [
                emailContainerView,
                fullnameContainerView,
                usernameContainerView,
                passwordContainerView,
                signUpButton
        ])
        stack.axis = .vertical
        stack.spacing = 16
        view.addSubview(stack)
        stack.anchor(
            top: plusPhotoButton.bottomAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: 32,
            paddingLeft: 32,
            paddingRight: 32
        )
        
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.anchor(
            left: view.leftAnchor,
            bottom: view.safeAreaLayoutGuide.bottomAnchor,
            right: view.rightAnchor,
            paddingLeft: 32,
            paddingRight: 32
        )
    }
    
    func configureNotificationObservers() {
        emailTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        fullnameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        usernameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
}

// MARK: - UIImagePickerControllerDelegate

extension RegistrationController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.originalImage] as? UIImage
        profileImage = image
        plusPhotoButton.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
        plusPhotoButton.layer.borderColor = UIColor(white: 1, alpha: 0.7).cgColor
        plusPhotoButton.layer.borderWidth = 3.0
        plusPhotoButton.layer.cornerRadius = 180 / 2
        plusPhotoButton.imageView?.clipsToBounds = true
        plusPhotoButton.imageView?.contentMode = .scaleAspectFill
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - AuthenticationControllerProtocol

extension RegistrationController: AuthenticationControllerProtocol {
    func checkFormStatus() {
        if viewModel.formIsValid {
            signUpButton.isEnabled = true
            signUpButton.backgroundColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
        } else {
            signUpButton.isEnabled = false
            signUpButton.backgroundColor = #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)
        }
    }
}
