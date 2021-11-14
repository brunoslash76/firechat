protocol NewMessageControllerDelegate: AnyObject {
    func controller(_ controller: NewMessageController, wantToStartChatWith user: User)
}
