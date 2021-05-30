import UIKit

var proxy : UITextDocumentProxy!

class KeyboardViewController: UIInputViewController {
    
    @IBOutlet var nextKeyboardButton: UIButton!
    
    var keyboardView: UIView!
    var keys: [UIButton] = []
    var paddingViews: [UIButton] = []
    var backspaceTimer: Timer?
    
    enum KeyboardState{
        case letters
        case numbers
        case symbols
    }
    
    enum ShiftButtonState {
        case normal
    }
    
    var keyboardState: KeyboardState = .letters
    var shiftButtonState:ShiftButtonState = .normal
    
    
    @IBOutlet weak var stackView1: UIStackView!
    @IBOutlet weak var stackView2: UIStackView!
    @IBOutlet weak var stackView3: UIStackView!
    @IBOutlet weak var stackView4: UIStackView!
    @IBOutlet weak var stackView5: UIStackView!
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        // Add custom view sizing constraints here
        keyboardView.frame.size = view.frame.size
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        proxy = textDocumentProxy as UITextDocumentProxy
        loadInterface()
        self.nextKeyboardButton.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillLayoutSubviews() {
        self.nextKeyboardButton.isHidden = !self.needsInputModeSwitchKey
        super.viewWillLayoutSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let heightConstraint = NSLayoutConstraint(item: view!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1.0, constant: 220)
        view.addConstraint(heightConstraint)
        
    }
    
    
    func loadInterface(){
        let keyboardNib = UINib(nibName: "Keyboard", bundle: nil)
        keyboardView = keyboardNib.instantiate(withOwner: self, options: nil)[0] as? UIView
        view.addSubview(keyboardView)
        loadKeys()
    }
    
    func addPadding(to stackView: UIStackView, width: CGFloat, key: String){
        let padding = UIButton(frame: CGRect(x: 0, y: 0, width: 5, height: 5))
        padding.setTitleColor(.clear, for: .normal)
        padding.alpha = 0.02
        padding.widthAnchor.constraint(equalToConstant: width).isActive = true
        
        //if we want to use this padding as a key, for example the a and l buttons
        let keyToDisplay = shiftButtonState == .normal ? key : key.capitalized
        padding.layer.setValue(key, forKey: "original")
        padding.layer.setValue(keyToDisplay, forKey: "keyToDisplay")
        padding.layer.setValue(false, forKey: "isSpecial")
        padding.addTarget(self, action: #selector(keyPressedTouchUp), for: .touchUpInside)
        padding.addTarget(self, action: #selector(keyTouchDown), for: .touchDown)
        padding.addTarget(self, action: #selector(keyUntouched), for: .touchDragExit)
        
        paddingViews.append(padding)
        stackView.addArrangedSubview(padding)
    }
    
    func loadKeys(){
        keys.forEach{$0.removeFromSuperview()}
        paddingViews.forEach{$0.removeFromSuperview()}
        
        let buttonWidth = (UIScreen.main.bounds.width - 6) / CGFloat(Constants.letterKeys[0].count)
        
        var keyboard: [[String]]
        var smallLetter: [[String]]
        
        
        smallLetter = Constants.smallLetterKeys
        //start padding
        switch keyboardState {
        case .letters:
            keyboard = Constants.letterKeys
        case .numbers:
            keyboard = Constants.numberKeys
        case .symbols:
            keyboard = Constants.symbolKeys
        }
        
        
        let numRows = keyboard.count
        for row in 0...numRows - 1{
            for col in 0...keyboard[row].count - 1{
//                let button = UIButton(type: .custom)
                let button: UIButton!
                let key = keyboard[row][col]
                let smallKey = smallLetter[row][col]
                let capsKey = keyboard[row][col].capitalized
                let keyToDisplay = shiftButtonState == .normal ? key : capsKey
                
                if(keyboard[0][0] == "១") {
                    button = CustomButton(label: smallKey)
                } else {
                    button = UIButton(type: .custom)
                }
                button.tag = row * 10
                button.tag += col
                button.backgroundColor = Constants.keyNormalColour
                button.setTitleColor(.white, for: .normal)
                button.layer.setValue(key, forKey: "original")
                button.layer.setValue(smallKey, forKey: "subLetter")
                button.layer.setValue(keyToDisplay, forKey: "keyToDisplay")
                button.layer.setValue(false, forKey: "isSpecial")
                button.setTitle(keyToDisplay, for: .normal)
                button.layer.borderColor =  keyboardView.backgroundColor?.cgColor
                button.layer.borderWidth = 3
                button.addTarget(self, action: #selector(keyPressedTouchUp), for: .touchUpInside)
                button.addTarget(self, action: #selector(keyTouchDown), for: .touchDown)
                button.addTarget(self, action: #selector(keyUntouched), for: .touchDragExit)
                let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
                swipeUp.direction = .up
                button.addGestureRecognizer(swipeUp)

                if key == "⌫"{
                    let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(keyLongPressed(_:)))
                    button.addGestureRecognizer(longPressRecognizer)
                }
                
                button.layer.cornerRadius = buttonWidth/4
                keys.append(button)
                switch row{
                case 0: stackView1.addArrangedSubview(button)
                case 1: stackView2.addArrangedSubview(button)
                case 2: stackView3.addArrangedSubview(button)
                case 3: stackView4.addArrangedSubview(button)
                case 4: stackView5.addArrangedSubview(button)
                default:
                    break
                }
                if key == "🌐"{
                    nextKeyboardButton = button
                }
                
                //top row is longest row so it should decide button width
//                print("button width: ", buttonWidth)
                if key == "⚙︎" || key == "#+=" || key == "ABC" || key == "123" || key == "🌐" || key == "☻"{
                    button.widthAnchor.constraint(equalToConstant: buttonWidth + buttonWidth/4).isActive = true
                    button.layer.setValue(true, forKey: "isSpecial")
                    button.backgroundColor = Constants.specialKeyNormalColour
                }else if key == "↩" {
                    button.widthAnchor.constraint(equalToConstant: buttonWidth * 2).isActive = true
                } else if key != "space"{
                    button.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
                }else{
                    button.layer.setValue(key, forKey: "original")
                    button.setTitle(key, for: .normal)
                }
            }
        }
        
        
        //end padding
        switch keyboardState {
        case .letters:
            break
        case .numbers:
            break
        case .symbols: break
        }
        
    }
        
    func changeKeyboardToNumberKeys(){
        keyboardState = .numbers
        shiftButtonState = .normal
        loadKeys()
    }
    func changeKeyboardToLetterKeys(){
        keyboardState = .letters
        loadKeys()
    }
    func changeKeyEmoji(){
        
    }
    func changeKeyboardToSymbolKeys(){
        keyboardState = .symbols
        loadKeys()
    }
    func handlDeleteButtonPressed(){
        proxy.deleteBackward()
    }
    
    @IBAction func keyPressedTouchUp(_ sender: UIButton) {
        guard let originalKey = sender.layer.value(forKey: "original") as? String, let keyToDisplay = sender.layer.value(forKey: "keyToDisplay") as? String else {return}
        
        guard let isSpecial = sender.layer.value(forKey: "isSpecial") as? Bool else {return}
        sender.backgroundColor = isSpecial ? Constants.specialKeyNormalColour : Constants.keyNormalColour

        switch originalKey {
        case "⌫":
            handlDeleteButtonPressed()
        case "space":
            proxy.insertText(" ")
        case "🌐":
            break
        case "↩":
            proxy.insertText("\n")
        case "123":
            changeKeyboardToNumberKeys()
        case "ABC":
            changeKeyboardToLetterKeys()
        case "#+=":
            changeKeyboardToSymbolKeys()
        default:
            proxy.insertText(keyToDisplay)
        }
    }
    
    @objc func handleSwipe(_ gesture: UIGestureRecognizer){
        if let btn = gesture.view as? UIButton {
            let row = btn.tag / 10
            let col = btn.tag % 10
            var subLetter = ""
            subLetter = Constants.smallLetterKeys[row][col]
            proxy.insertText(String(subLetter))
        }
        (gesture.view as! UIButton).backgroundColor = Constants.specialKeyNormalColour
    }
    
    
    @objc func keyLongPressed(_ gesture: UIGestureRecognizer){
        if gesture.state == .began {
            backspaceTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { (timer) in
                self.handlDeleteButtonPressed()
            }
        } else if gesture.state == .ended || gesture.state == .cancelled {
            backspaceTimer?.invalidate()
            backspaceTimer = nil
            (gesture.view as! UIButton).backgroundColor = Constants.specialKeyNormalColour
        }
    }
    
    @objc func keyUntouched(_ sender: UIButton){
        guard let isSpecial = sender.layer.value(forKey: "isSpecial") as? Bool else {return}
        sender.backgroundColor = isSpecial ? Constants.specialKeyNormalColour : Constants.keyNormalColour
    }
    
    @objc func keyTouchDown(_ sender: UIButton){
        sender.backgroundColor = Constants.keyPressedColour
    }
    
    override func textWillChange(_ textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.
        
        var textColor: UIColor
        let proxy = self.textDocumentProxy
        if proxy.keyboardAppearance == UIKeyboardAppearance.dark {
            textColor = UIColor.white
        } else {
            textColor = UIColor.black
        }
        self.nextKeyboardButton.setTitleColor(textColor, for: [])
    }
    
}
