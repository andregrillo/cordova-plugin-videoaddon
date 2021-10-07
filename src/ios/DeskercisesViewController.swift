//
//  ViewController.swift
//  OutsysAddon
//
//  Created by WorldIT on 11/01/2021.
//

import UIKit
import AVKit
class DeskercisesViewController: UIViewController {

    private var playerLayer:AVPlayerLayer?
    private var playerLayer2:AVPlayerLayer?
    private var playerLayer3:AVPlayerLayer?
    
    private var mainVideoLooper: AVPlayerLooper?
    private var mainVideo = AVQueuePlayer()
   
    private var secondVideoLooper: AVPlayerLooper?
    private var secondVideo  = AVQueuePlayer()
    
    private var thirdVideoLooper: AVPlayerLooper?
    private var thirdVideo  = AVQueuePlayer()
    
    private var likeBtn = UIButton()

    private var callback:((Bool)->())?

    private var currentBackgroundVideoIndex = 0
    private  var maxVideos = 0
   
    var videoTitleArray:[String]!
    
    private var controlView:UIView!
    private var labelBgView:UIView!
    private var topLabel:UILabel!
    
    private var swipeIcon:UIImageView!
    private var swipeIcon2:UIImageView!
    private var swipeIcon3:UIImageView!
    
    private var arrowTimer:Timer?
    private var animationIndex = 0
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.playerLayer?.frame = self.view.bounds
        self.playerLayer2?.frame = self.view.bounds
        self.playerLayer3?.frame = self.view.bounds
        self.labelBgView.layer.cornerRadius = self.labelBgView.frame.height/2
        self.labelBgView.clipsToBounds = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //avoids mute setting
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
        try? AVAudioSession.sharedInstance().setActive(true)
        
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.arrowTimer?.invalidate()
    }
    private func createScreen() {
        self.controlView = UIView()
        controlView?.translatesAutoresizingMaskIntoConstraints = false
        self.controlView?.backgroundColor = .clear
        self.view.addSubview(self.controlView!)
        
        NSLayoutConstraint(item: controlView!, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: controlView!, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: controlView!, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: controlView!, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0).isActive = true
        
        
        
        likeBtn.translatesAutoresizingMaskIntoConstraints = false
        likeBtn.tintColor = .black
        likeBtn.setImage(UIImage(named: "like_lighter"), for: .normal)
        likeBtn.setImage(UIImage(named: "likefilled_lighter"), for: .selected)
        likeBtn.backgroundColor = .clear
        likeBtn.setTitle("", for: .normal)
        self.controlView.addSubview(likeBtn)
        likeBtn.widthAnchor.constraint(equalToConstant: 35).isActive = true
        likeBtn.heightAnchor.constraint(equalToConstant: 35).isActive = true
        likeBtn.addTarget(self, action: #selector(setLikeClick(_:)), for: .touchUpInside)
        likeBtn.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 16).isActive = true
        likeBtn.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16).isActive = true

        
        let closeBtn = UIButton()
        closeBtn.translatesAutoresizingMaskIntoConstraints = false
        closeBtn.setImage(UIImage(named: "close_lighter"), for: .normal)
        closeBtn.backgroundColor = .clear
        closeBtn.setTitle("", for: .normal)
        self.controlView.addSubview(closeBtn)
        closeBtn.widthAnchor.constraint(equalToConstant: 35).isActive = true
        closeBtn.heightAnchor.constraint(equalToConstant: 35).isActive = true
        closeBtn.addTarget(self, action: #selector(closeClick), for: .touchUpInside)
        closeBtn.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 16).isActive = true
        closeBtn.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16).isActive = true
        
        
        labelBgView = UIView()
        labelBgView.translatesAutoresizingMaskIntoConstraints = false
        labelBgView.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        self.controlView.addSubview(labelBgView)
        
        topLabel = UILabel()
        topLabel.translatesAutoresizingMaskIntoConstraints = false
        topLabel.textColor = .white
        topLabel.text = ""
        topLabel.font = UIFont.systemFont(ofSize: 14)
        self.controlView.addSubview(topLabel)
        topLabel.centerYAnchor.constraint(equalTo: closeBtn.centerYAnchor, constant: 0).isActive = true
        topLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        topLabel.leadingAnchor.constraint(greaterThanOrEqualTo: likeBtn.trailingAnchor, constant: 8).isActive = true
        topLabel.trailingAnchor.constraint(lessThanOrEqualTo: closeBtn.leadingAnchor, constant: -8).isActive = true
        
        
        //constraints to labelBgView
        topLabel.topAnchor.constraint(equalTo: labelBgView.topAnchor,constant:  4).isActive = true
        topLabel.leadingAnchor.constraint(equalTo: labelBgView.leadingAnchor,constant:  6).isActive = true
        topLabel.trailingAnchor.constraint(equalTo: labelBgView.trailingAnchor,constant:  -6).isActive = true
        topLabel.bottomAnchor.constraint(equalTo: labelBgView.bottomAnchor,constant:  -4).isActive = true
        
        
        let swipeLabel = UILabel()
        swipeLabel.translatesAutoresizingMaskIntoConstraints = false
        swipeLabel.font = UIFont.systemFont(ofSize: 18)
        swipeLabel.textColor = .white
        swipeLabel.text = "Swipe for next activity"

        self.controlView.addSubview(swipeLabel)
        swipeLabel.leadingAnchor.constraint(greaterThanOrEqualTo: self.view.leadingAnchor ,constant:  16).isActive = true
        swipeLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.view.trailingAnchor ,constant:  -16).isActive = true
        swipeLabel.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
        swipeLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: -15).isActive = true
        
        swipeIcon = UIImageView()
        swipeIcon.translatesAutoresizingMaskIntoConstraints = false
        swipeIcon.image = UIImage(named: "chevron-left-solid")
        swipeIcon.tintColor = .white
        swipeIcon.contentMode = .scaleAspectFit
        self.controlView.addSubview(swipeIcon)
        swipeIcon.centerYAnchor.constraint(equalTo: swipeLabel.centerYAnchor).isActive = true
        swipeIcon.leadingAnchor.constraint(equalTo: swipeLabel.trailingAnchor ,constant:  8).isActive = true
        swipeIcon.widthAnchor.constraint(equalToConstant: 15).isActive = true
        swipeIcon.heightAnchor.constraint(equalToConstant: 15).isActive = true
        
        swipeIcon2 = UIImageView()
        swipeIcon2.translatesAutoresizingMaskIntoConstraints = false
        swipeIcon2.image = UIImage(named: "chevron-left-solid")
        swipeIcon2.tintColor = .white
        swipeIcon2.contentMode = .scaleAspectFit
        self.controlView.addSubview(swipeIcon2)
        swipeIcon2.centerYAnchor.constraint(equalTo: swipeLabel.centerYAnchor).isActive = true
        swipeIcon2.leadingAnchor.constraint(equalTo: swipeIcon.trailingAnchor ,constant:  -8).isActive = true
        swipeIcon2.widthAnchor.constraint(equalToConstant: 15).isActive = true
        swipeIcon2.heightAnchor.constraint(equalToConstant: 15).isActive = true
        
        swipeIcon3 = UIImageView()
        swipeIcon3.translatesAutoresizingMaskIntoConstraints = false
        swipeIcon3.image = UIImage(named: "chevron-left-solid")
        swipeIcon3.tintColor = .white
        swipeIcon3.contentMode = .scaleAspectFit
        self.controlView.addSubview(swipeIcon3)
        swipeIcon3.centerYAnchor.constraint(equalTo: swipeLabel.centerYAnchor).isActive = true
        swipeIcon3.leadingAnchor.constraint(equalTo: swipeIcon2.trailingAnchor ,constant:  -8).isActive = true
        swipeIcon3.widthAnchor.constraint(equalToConstant: 15).isActive = true
        swipeIcon3.heightAnchor.constraint(equalToConstant: 15).isActive = true
        
        
        arrowTimer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true, block: { (_) in
           
           
               
            UIView.animate(withDuration: 0.3, delay: 0, options: [UIView.AnimationOptions.curveLinear]) {
                    self.animationIndex = (self.animationIndex + 1) % 4
                    switch self.animationIndex {
                        case 0:
                            self.swipeIcon.tintColor = .lightGray
                            self.swipeIcon2.tintColor = .darkGray
                            self.swipeIcon3.tintColor = .black
                            break
                        case 1:
                            self.swipeIcon.tintColor = .darkGray
                            self.swipeIcon2.tintColor = .black
                            self.swipeIcon3.tintColor = .white
                            break
                        case 2:
                            self.swipeIcon.tintColor = .black
                            self.swipeIcon2.tintColor = .white
                            self.swipeIcon3.tintColor = .lightGray
                            break
                        case 3:
                            self.swipeIcon.tintColor = .white
                            self.swipeIcon2.tintColor = .lightGray
                            self.swipeIcon3.tintColor = .darkGray
                        break
                        default:
                            break
                        
                    }
                    
                }
       })

        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipedScreenLeft))
        swipeLeft.direction = .left
        self.controlView.addGestureRecognizer(swipeLeft)
    
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipedScreenRight))
        swipeRight.direction = .right
        self.controlView.addGestureRecognizer(swipeRight)
        
    }
    
  
    
    /// Loads videos passed in params with URLs.
    ///
    /// - Warning: The number os items in video array shoud be equal to the number os items in videoTitleArray
    /// - Parameter videoArray: Array of string with background video url
    /// - Parameter videoTitleArray: Array of string with video titles
    /// - Parameter isLiked: True of False if the video was previously liked
    /// - Parameter callback: Reference to the method to be called when the close button is pressed, should receive 1 params (Bool) meaning (isLiked)
    func loadDeskercisesVideosFromURL(videoArray:[String], videoTitleArray:[String],isLiked:Bool, callback:@escaping ((Bool)->())) {
        self.callback = callback
        self.videoTitleArray = videoTitleArray
        self.createScreen()
        
        self.likeBtn.isSelected = isLiked
        
        self.maxVideos = videoArray.count
        self.topLabel.text = videoTitleArray[0] + " (1/\(videoTitleArray.count))"
        
      
        //MARK: Main player setup
        let playerItem = AVPlayerItem(url: URL(string: videoArray[0])!)
        mainVideo = AVQueuePlayer(items: [playerItem])
        mainVideoLooper = AVPlayerLooper(player: mainVideo, templateItem: playerItem)
        mainVideo.volume = 1
        
        //video player
        playerLayer = AVPlayerLayer(player: mainVideo)
        playerLayer?.videoGravity = .resizeAspectFill;
        self.view.layer.addSublayer(playerLayer!)
        
        //MARK: Second player setup
        if videoArray.count > 1 && videoTitleArray.count > 1 {
            let pi2 = AVPlayerItem(url: URL(string: videoArray[1])!)
            secondVideo = AVQueuePlayer(items: [pi2])
            secondVideoLooper = AVPlayerLooper(player: secondVideo, templateItem: pi2)
            
            secondVideo.automaticallyWaitsToMinimizeStalling = true
            secondVideo.volume = 1

            
            //second video player
            playerLayer2 = AVPlayerLayer(player: secondVideo)
            playerLayer2?.isHidden = true
            playerLayer2?.videoGravity = .resizeAspectFill;
            self.view.layer.addSublayer(playerLayer2!)
            
        }
        
        //MARK: Third player setup
        if videoArray.count > 2 && videoTitleArray.count > 2 {

            let pi3 = AVPlayerItem(url: URL(string: videoArray[2])!)
            thirdVideo = AVQueuePlayer(items: [pi3])
            thirdVideoLooper = AVPlayerLooper(player: thirdVideo, templateItem: pi3)
            thirdVideo.automaticallyWaitsToMinimizeStalling = false
            thirdVideo.volume = 0
            
            //third video player
            playerLayer3 = AVPlayerLayer(player: thirdVideo)
            playerLayer3?.isHidden = true
            playerLayer3?.videoGravity = .resizeAspectFill;
            self.view.layer.addSublayer(playerLayer3!)
        }
        mainVideo.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions(), context: nil)
        secondVideo.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions(), context: nil)
        thirdVideo.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions(), context: nil)
        self.view.bringSubviewToFront(self.controlView)
    }
    
    /// Loads videos passed in params from Data.
    /// Videos will be saved temporarily on the phone, videos will be saved as .mp4
    ///
    /// - Warning: The number os items in video array shoud be equal to the number os items in videoTitleArray
    /// - Parameter videoArray: Array of data with background video url
    /// - Parameter videoTitleArray: Array of string with video titles
    /// - Parameter isLiked: True of False if the video was previously liked
    /// - Parameter callback: Reference to the method to be called when the close button is pressed, should receive 1 params (Bool) meaning (isLiked)
    func loadDeskercisesVideosFromData(videoArray:[Data], videoTitleArray:[String], isLiked:Bool, callback:@escaping ((Bool)->())) {
        self.callback = callback
        self.videoTitleArray = videoTitleArray
        self.createScreen()
        
        self.likeBtn.isSelected = isLiked
        
        self.maxVideos = videoArray.count
        self.topLabel.text = videoTitleArray[0] + " (1/\(videoTitleArray.count))"
        
        //MARK: Main player setup
        
        try? videoArray[0].write(to: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("mainvideo.mp4"))
    
        let urlVideo = URL(fileURLWithPath: NSTemporaryDirectory() + "/mainvideo.mp4")
        let playerItem = AVPlayerItem(url: urlVideo)
        mainVideo = AVQueuePlayer(items: [playerItem])
        mainVideoLooper = AVPlayerLooper(player: mainVideo, templateItem: playerItem)
        mainVideo.volume = 0
      
        //video player
        playerLayer = AVPlayerLayer(player: mainVideo)
        playerLayer?.videoGravity = .resizeAspectFill;
        self.view.layer.addSublayer(playerLayer!)
       
        
        //MARK: Second player setup
        if videoArray.count > 1 && videoTitleArray.count > 1 {
            
            try? videoArray[1].write(to: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("secondvideo.mp4"))
    
            let urlVideo = URL(fileURLWithPath: NSTemporaryDirectory() + "/secondvideo.mp4")
            let pi2 = AVPlayerItem(url: urlVideo)
            secondVideo = AVQueuePlayer(items: [pi2])
            secondVideoLooper = AVPlayerLooper(player: secondVideo, templateItem: pi2)
            secondVideo.automaticallyWaitsToMinimizeStalling = true
            secondVideo.volume = 0
            
            //second video player
            playerLayer2 = AVPlayerLayer(player: secondVideo)
            playerLayer2?.isHidden = true
            playerLayer2?.videoGravity = .resizeAspectFill;
            self.view.layer.addSublayer(playerLayer2!)
            
            
        }
        //MARK: Third player setup
        if videoArray.count > 2 && videoTitleArray.count > 2 {
            try? videoArray[2].write(to: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("thirdvideo.mp4"))
            
            let urlVideo = URL(fileURLWithPath: NSTemporaryDirectory() + "/thirdvideo.mp4")
            let pi3 = AVPlayerItem(url: urlVideo)
            thirdVideo = AVQueuePlayer(items: [pi3])
            thirdVideoLooper = AVPlayerLooper(player: thirdVideo, templateItem: pi3)
            thirdVideo.automaticallyWaitsToMinimizeStalling = false
            thirdVideo.volume = 0
            
            //third video player
            playerLayer3 = AVPlayerLayer(player: thirdVideo)
            playerLayer3?.isHidden = true
            playerLayer3?.videoGravity = .resizeAspectFill;
            self.view.layer.addSublayer(playerLayer3!)
            
        }
        mainVideo.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions(), context: nil)
        secondVideo.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions(), context: nil)
        thirdVideo.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions(), context: nil)
        
        self.view.bringSubviewToFront(self.controlView)
    }
    
    @objc func setLikeClick(_ sender:UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @objc func closeClick() {
        self.callback?(self.likeBtn.isSelected)
        
        if self.navigationController?.topViewController == self {
            self.navigationController?.popViewController(animated: true)
        }
        else {
            self.dismiss(animated: true, completion: nil)
        }

    }
    @objc func swipedScreenLeft() {

        print("swipe left")
        self.currentBackgroundVideoIndex = (self.currentBackgroundVideoIndex  + 1) % self.maxVideos
        self.topLabel.text = videoTitleArray[self.currentBackgroundVideoIndex] + " (\(self.currentBackgroundVideoIndex + 1)/\(videoTitleArray.count))"
        
        self.playBackground()

    }
    @objc func swipedScreenRight() {
     
        print("swipe right")
       
        self.currentBackgroundVideoIndex = (self.currentBackgroundVideoIndex  - 1) % self.maxVideos
      
        if self.currentBackgroundVideoIndex < 0{
            self.currentBackgroundVideoIndex = self.maxVideos - 1
        }
        self.topLabel.text = videoTitleArray[self.currentBackgroundVideoIndex] + " (\(self.currentBackgroundVideoIndex + 1)/\(videoTitleArray.count))"
        
        self.playBackground()
    }
    
    
   
   
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        // Only handle observations for the playerItemContext
        guard (object as? AVPlayer) == self.mainVideo || (object as? AVPlayer) == self.secondVideo || (object as? AVPlayer) == self.thirdVideo else {
              super.observeValue(forKeyPath: keyPath,
                                 of: object,
                                 change: change,
                                 context: context)
              return
          }

        
        if keyPath == #keyPath(AVPlayerItem.status) {
            let player = (object as? AVPlayer)
           
              // Switch over status value
            switch player?.status {
              case .readyToPlay:
                if player == self.mainVideo {
                    print("a")
                    self.mainVideo.preroll(atRate: 1) { (mainFinished) in
                        print("m1 preroll \(mainFinished)")
                        if mainFinished {
                            self.playBackground()
                        }
                    }
                }
                else if player == self.secondVideo {
                    self.secondVideo.preroll(atRate: 1) { (main2Finished) in
                        print("m2 preroll \(main2Finished)")
                        if main2Finished {
                            self.playBackground()
                        }
                    }
                }
                
                else if player == self.thirdVideo {
                    self.thirdVideo.preroll(atRate: 1) { (main3Finished) in
                        print("m3 preroll \(main3Finished)")
                        if main3Finished {
                            self.playBackground()
                        }
                    }
                }
              case .failed:
                break
              case .unknown:
                break
            case .none:
                break
            @unknown default:
                break
              }
          }
    }
    
    func playBackground(){
        DispatchQueue.main.async {
            self.mainVideo.play()
            self.secondVideo.play()
            self.thirdVideo.play()
     
            self.switchVideo()
           
        }
      
    }
   
    func switchVideo() {
        DispatchQueue.main.async {
            switch self.currentBackgroundVideoIndex {
            case 0:
                self.playerLayer?.isHidden = false
                self.mainVideo.volume = 1
                self.playerLayer2?.isHidden = true
                self.secondVideo.volume = 0
                self.playerLayer3?.isHidden = true
                self.thirdVideo.volume = 0
                break
            case 1:
                self.playerLayer?.isHidden = true
                self.mainVideo.volume = 0
                self.playerLayer2?.isHidden = false
                self.secondVideo.volume = 1
                self.playerLayer3?.isHidden = true
                self.thirdVideo.volume = 0
                break
            case 2:
                self.playerLayer?.isHidden = true
                self.mainVideo.volume = 0
                self.playerLayer2?.isHidden = true
                self.secondVideo.volume = 0
                self.playerLayer3?.isHidden = false
                self.thirdVideo.volume = 1
                break
            default:
                break
            }
        }
       
    }
}

