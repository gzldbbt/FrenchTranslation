//
//  ViewController.swift
//  test
//
//  Created by liming on 25/11/2024.
//

import UIKit
import AVKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var extractedText: String?
    
    var translationLan:String?

    let extractor = ExtractText()
    
    let synthesizer = AVSpeechSynthesizer()
    
    let dataLanguage = ["Please select a language","Anglais","Chinois","Espagnol","Persian","Portugais"]
    let flagImag = [UIImage(named:""),UIImage(named:"USA"), UIImage(named:"China"), UIImage(named:"mexico"),UIImage(named:"Iran"), UIImage(named:"Brazil"	)]
    let langArray = ["","en","zh","es","fa","pt"]

    @IBOutlet weak var frFlag: UIImageView!
    
    @IBOutlet var picker: UIPickerView!
    
    @IBOutlet weak var backgroundImage: UIImageView!
    
    @IBOutlet weak var flagImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        picker.dataSource = self
        
        MyImageView.layer.borderWidth=1
        MyImageView.layer.masksToBounds = false
        MyImageView.layer.borderColor=UIColor.lightGray.cgColor
        MyImageView.layer.cornerRadius=MyImageView.frame.height/10
        MyImageView.clipsToBounds=true
        MyImageView.layer.shadowOpacity = 0.5
        MyImageView.layer.shadowRadius = 4 
        MyImageView.layer.masksToBounds = false
        MyImageView.layer.shadowColor = UIColor.blue.cgColor
        
        
        frFlag.layer.borderWidth=1
        frFlag.layer.masksToBounds = true
        frFlag.layer.borderColor=UIColor.white.cgColor
        frFlag.layer.cornerRadius=frFlag.frame.height/2
        frFlag.clipsToBounds=true
        
        addShadowToButton(UploadButton)
        //addShadowToButton(TranslateButton)
        //addShadowToButton(ReadButton)
    }
    
    func addShadowToButton(_ button: UIButton) {
        UploadButton.layer.shadowColor = UIColor.black.cgColor
        UploadButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        UploadButton.layer.shadowOpacity = 0.3
        UploadButton.layer.shadowRadius = 4
        UploadButton.layer.masksToBounds = false
        
    }
   
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateFlagImageViewToSquare()
    }
    
    private func updateFlagImageViewToSquare() {
        
        let size = min(frFlag.frame.width, frFlag.frame.height)
        frFlag.frame = CGRect(x: frFlag.frame.origin.x, y: frFlag.frame.origin.y, width: size, height: size)
        
        frFlag.layer.cornerRadius = size / 2
        frFlag.clipsToBounds = true
    }
    
    
    
   

    @IBOutlet weak var MyImageView: UIImageView!
    	
    @IBOutlet weak var UploadButton: UIButton!
   
    @IBOutlet weak var ExtractedLabel: UILabel!
    
    @IBOutlet weak var TranslationLabel: UILabel!
    
    
    @IBAction func UploadButton(_ sender: Any) {
        let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .photoLibrary // or .camera
                self.present(imagePicker, animated: true, completion: nil)
        
        
        
    }
    
    @IBAction func TranslateButton(_ sender: UIButton) {
        //transaltion
        let translator = Translation()
        translator.translateText(text: extractedText!, sourceLang: "fr", targetLang: translationLan!) { translatedText in
            if let translatedText = translatedText {
                self.TranslationLabel.text = translatedText
            } else {
                self.TranslationLabel.text = "Translation failed."
            }
        }
    }

    
    
    
    @IBAction func ReadButton(_ sender: UIButton) {
        let speech = AVSpeechUtterance(string: extractedText!)
        
        speech.rate = 0.5
        speech.voice = AVSpeechSynthesisVoice(language: "fr-FR")
        synthesizer.speak(speech)



    }
    
    
        
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            picker.dismiss(animated: true, completion: nil)
            
            if let selectedImage = info[.originalImage] as? UIImage {
                self.MyImageView.image = selectedImage
                if let imageData = selectedImage.jpegData(compressionQuality: 0.6) {
                    // use ExtractText class, upload pic
                    self.ExtractedLabel.text = "Processing..."
                    extractor.callOCRSpace(imageData: imageData) { result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success(let text):
                                self.ExtractedLabel.text = text
                                self.extractedText = text
                            case .failure(let error):
                                self.ExtractedLabel.text = "Error: \(error.localizedDescription)"
                            }
                        }
                    }
                }
            }
        }
}
extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataLanguage.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dataLanguage[row]
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            if let selectedFlagImage = flagImag[row] {
            self.flagImage.image = selectedFlagImage
                translationLan=langArray[row]
            
            
               
        }
        
    }
}
    

