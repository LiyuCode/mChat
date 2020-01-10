//
//  ChatCell.swift
//  mChat
//
//  Created by Vitaliy Paliy on 11/22/19.
//  Copyright © 2019 PALIY. All rights reserved.
//
import UIKit
import AVFoundation

class ChatCell: UICollectionViewCell {
    
    var msg: Messages?
    var message = UILabel()
    var messageBackground = UIView()
    var mediaMessage = UIImageView()
    var chatVC: ChatVC!
    var msgTopAnchor: NSLayoutConstraint!
    var replyMsgTopAnchor: NSLayoutConstraint!
    var backgroundWidthAnchor: NSLayoutConstraint!
    var outcomingMessage: NSLayoutConstraint!
    var incomingMessage: NSLayoutConstraint!
    
    var audioPlayButton = UIButton(type: .system)
    var durationLabel = UILabel()
    var audioPlayer: AVAudioPlayer!
    var timer: Timer!
    
    var isIncoming: Bool! {
        didSet{
            messageBackground.backgroundColor = isIncoming ?  .white  : UIColor(displayP3Red: 71/255, green: 171/255, blue: 232/255, alpha: 1)
            message.textColor = isIncoming ? .black : .white
            let userColor = isIncoming ? UIColor(displayP3Red: 71/255, green: 171/255, blue: 232/255, alpha: 1) : .white
            responseLine.backgroundColor = userColor
            responseNameLabel.textColor = userColor
            responseTextMessage.textColor = userColor
            audioPlayButton.tintColor = userColor
            durationLabel.textColor = userColor
        }
    }
    
    // Reply Outlets
    let responseView = UIView()
    let responseLine = UIView()
    let responseNameLabel = UILabel()
    let responseTextMessage = UILabel()
    let responseMediaMessage = UIImageView()
    let responseAudioMessage = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(messageBackground)
        setupBackgroundView()
        setupMessage()
        setupMediaMessage()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupBackgroundView(){
        messageBackground.translatesAutoresizingMaskIntoConstraints = false
        messageBackground.layer.cornerRadius = 12
        messageBackground.layer.masksToBounds = true
        backgroundWidthAnchor = messageBackground.widthAnchor.constraint(equalToConstant: 200)
        let constraints = [
            messageBackground.topAnchor.constraint(equalTo: topAnchor),
            backgroundWidthAnchor!,
            messageBackground.bottomAnchor.constraint(equalTo: bottomAnchor)
        ]
        outcomingMessage = messageBackground.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8)
        incomingMessage = messageBackground.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8)
        outcomingMessage.isActive = true
        NSLayoutConstraint.activate(constraints)
    }
    
    private func setupMessage(){
        messageBackground.addSubview(message)
        message.numberOfLines = 0
        message.backgroundColor = .clear
        message.translatesAutoresizingMaskIntoConstraints = false
        message.font = UIFont(name: "Helvetica Neue", size: 16)
        msgTopAnchor = message.topAnchor.constraint(equalTo: messageBackground.topAnchor)
        replyMsgTopAnchor = message.topAnchor.constraint(equalTo: messageBackground.topAnchor, constant: 50)
        let constraints = [
            message.leadingAnchor.constraint(equalTo: messageBackground.leadingAnchor, constant: 16),
            message.bottomAnchor.constraint(equalTo: messageBackground.bottomAnchor),
            message.trailingAnchor.constraint(equalTo: messageBackground.trailingAnchor, constant: -8),
            msgTopAnchor!,
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    private func setupMediaMessage(){
        messageBackground.addSubview(mediaMessage)
        mediaMessage.translatesAutoresizingMaskIntoConstraints = false
        mediaMessage.layer.cornerRadius = 16
        mediaMessage.layer.masksToBounds = true
        mediaMessage.contentMode = .scaleAspectFill
        let imageTapped = UITapGestureRecognizer(target: self, action: #selector(imageTappedHandler(tap:)))
        mediaMessage.addGestureRecognizer(imageTapped)
        mediaMessage.isUserInteractionEnabled = true
        let constraints = [
            mediaMessage.topAnchor.constraint(equalTo: topAnchor),
            mediaMessage.centerYAnchor.constraint(equalTo: messageBackground.centerYAnchor),
            mediaMessage.widthAnchor.constraint(equalTo: messageBackground.widthAnchor),
            mediaMessage.heightAnchor.constraint(equalTo: messageBackground.heightAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    @objc private func imageTappedHandler(tap: UITapGestureRecognizer){
        let imageView = tap.view as? UIImageView
        chatVC.zoomImageHandler(image: imageView!)
    }
       
    func setupRepMessageView(_ friendName: String){
        self.handleRepMessageSetup(friendName)
    }
    
    private func handleRepMessageSetup(_ name: String){
        self.msgTopAnchor.isActive = false
        self.replyMsgTopAnchor.isActive = true
        if self.backgroundWidthAnchor.constant < 140 { self.backgroundWidthAnchor.constant = 140 }
        self.setupReplyLine()
        self.setupReplyName(name: name)
        if msg?.repMessage != nil {
            self.responseMediaMessage.removeFromSuperview()
            self.responseAudioMessage.removeFromSuperview()
            self.setupReplyTextMessage(text: msg!.repMessage)
        }else if msg?.repMediaMessage != nil {
            self.responseTextMessage.removeFromSuperview()
            self.responseAudioMessage.removeFromSuperview()
            self.setupReplyMediaMessage(msg!.repMediaMessage)
        }else{
            self.responseMediaMessage.removeFromSuperview()
            self.responseTextMessage.removeFromSuperview()
            setupResponseAudioMessage()
        }
    }
    
    private func setupReplyLine(){
        messageBackground.addSubview(responseLine)
        responseLine.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            responseLine.leadingAnchor.constraint(equalTo: messageBackground.leadingAnchor, constant: 16),
            responseLine.topAnchor.constraint(equalTo: messageBackground.topAnchor, constant: 8),
            responseLine.bottomAnchor.constraint(equalTo: message.topAnchor, constant: -2),
            responseLine.widthAnchor.constraint(equalToConstant: 2)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    private func setupReplyName(name: String){
        responseNameLabel.text = name
        responseNameLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
    }
    
    private func setupReplyTextMessage(text: String){
        responseTextMessage.text = text
        responseTextMessage.font = UIFont(name: "Helvetica Neue", size: 15)
        messageBackground.addSubview(responseTextMessage)
        responseTextMessage.translatesAutoresizingMaskIntoConstraints = false
        responseTextMessage.addSubview(responseNameLabel)
        responseNameLabel.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            responseTextMessage.leadingAnchor.constraint(equalTo: responseLine.leadingAnchor, constant: 8),
            responseTextMessage.bottomAnchor.constraint(equalTo: responseLine.bottomAnchor, constant: -4),
            responseTextMessage.trailingAnchor.constraint(equalTo: messageBackground.trailingAnchor, constant: -8),
            responseNameLabel.leadingAnchor.constraint(equalTo: responseLine.leadingAnchor, constant: 8),
            responseNameLabel.topAnchor.constraint(equalTo: responseLine.topAnchor, constant: 2),
            responseNameLabel.trailingAnchor.constraint(equalTo: messageBackground.trailingAnchor, constant: 8),
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    private func setupReplyMediaMessage(_ url: String){
        let replyMediaLabel = UILabel()
        replyMediaLabel.text = "Image"
        replyMediaLabel.font = UIFont(name: "Helvetica Neue", size: 15)
        replyMediaLabel.textColor = isIncoming ? .lightGray : .lightText
        messageBackground.addSubview(responseMediaMessage)
        responseMediaMessage.translatesAutoresizingMaskIntoConstraints = false
        responseMediaMessage.addSubview(responseNameLabel)
        responseNameLabel.translatesAutoresizingMaskIntoConstraints = false
        responseMediaMessage.addSubview(replyMediaLabel)
        replyMediaLabel.translatesAutoresizingMaskIntoConstraints = false
        responseMediaMessage.loadImage(url: url)
        let constraints = [
            responseMediaMessage.topAnchor.constraint(equalTo: responseLine.topAnchor, constant: 2),
            responseMediaMessage.bottomAnchor.constraint(equalTo: responseLine.bottomAnchor, constant: -2),
            responseMediaMessage.widthAnchor.constraint(equalToConstant: 30),
            responseMediaMessage.leadingAnchor.constraint(equalTo: responseLine.trailingAnchor, constant: 4),
            replyMediaLabel.centerYAnchor.constraint(equalTo: responseMediaMessage.centerYAnchor, constant: 8),
            replyMediaLabel.leadingAnchor.constraint(equalTo: responseMediaMessage.trailingAnchor, constant: 4),
            responseNameLabel.leadingAnchor.constraint(equalTo: responseMediaMessage.trailingAnchor, constant: 4),
            responseNameLabel.centerYAnchor.constraint(equalTo: responseMediaMessage.centerYAnchor, constant: -8),
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    private func setupResponseAudioMessage(){
        messageBackground.addSubview(responseAudioMessage)
        responseAudioMessage.translatesAutoresizingMaskIntoConstraints = false
        responseAudioMessage.addSubview(responseNameLabel)
        responseNameLabel.translatesAutoresizingMaskIntoConstraints = false
        responseAudioMessage.text = "Audio Message"
        responseAudioMessage.textColor = isIncoming ? .lightGray : .lightText
        responseAudioMessage.font = UIFont(name: "Helvetica Neue", size: 15)
        let constraints = [
            responseNameLabel.leadingAnchor.constraint(equalTo: responseLine.leadingAnchor, constant: 8),
            responseNameLabel.topAnchor.constraint(equalTo: responseLine.topAnchor, constant: 2),
            responseNameLabel.trailingAnchor.constraint(equalTo: messageBackground.trailingAnchor, constant: 8),
            responseAudioMessage.topAnchor.constraint(equalTo: responseNameLabel.bottomAnchor, constant: -2),
            responseAudioMessage.leadingAnchor.constraint(equalTo: responseLine.leadingAnchor, constant: 8)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    func removeReplyOutlets(){
        replyMsgTopAnchor.isActive = false
        responseLine.removeFromSuperview()
        responseNameLabel.removeFromSuperview()
        responseAudioMessage.removeFromSuperview()
        responseTextMessage.removeFromSuperview()
        responseMediaMessage.removeFromSuperview()
        responseView.removeFromSuperview()
        msgTopAnchor.isActive = true
    }

    func setupAudioPlayButton(){
        audioPlayButton.isEnabled = false
        messageBackground.addSubview(audioPlayButton)
        audioPlayButton.addTarget(self, action: #selector(playAudioButtonPressed), for: .touchUpInside)
        audioPlayButton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
        audioPlayButton.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            audioPlayButton.leadingAnchor.constraint(equalTo: messageBackground.leadingAnchor, constant: 8),
            audioPlayButton.topAnchor.constraint(equalTo: messageBackground.topAnchor, constant: 8),
            audioPlayButton.heightAnchor.constraint(equalToConstant: 25),
            audioPlayButton.widthAnchor.constraint(equalToConstant: 25),
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    func setupAudioDurationLabel(){
        messageBackground.addSubview(durationLabel)
        durationLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 14)
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            durationLabel.trailingAnchor.constraint(equalTo: messageBackground.trailingAnchor, constant: -8),
            durationLabel.centerYAnchor.constraint(equalTo: messageBackground.centerYAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
        
    @objc func playAudioButtonPressed(){
        chatVC.handleUserPressedAudioButton(for: self)
    }
    
    @objc func timerHandler(){
        if !audioPlayer.isPlaying {
            audioPlayButton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
            timer.invalidate()
            chatVC.chatAudio.audioPlayer = nil
        }
        let (m,s) = timeFrom(seconds: Int(audioPlayer.duration - audioPlayer.currentTime))
        let minutes = m < 10 ? "0\(m)" : "\(m)"
        let seconds = s < 10 ? "0\(s)" : "\(s)"
        durationLabel.text = "\(minutes):\(seconds)"
    }
    
    func timeFrom(seconds : Int) -> (Int, Int) {
        return ((seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    
}