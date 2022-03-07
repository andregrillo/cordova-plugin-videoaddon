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
    private var mainVideo:AVQueuePlayer?
   
    private var secondVideoLooper: AVPlayerLooper?
    private var secondVideo:AVQueuePlayer?
    
    private var thirdVideoLooper: AVPlayerLooper?
    private var thirdVideo:AVQueuePlayer?
    
    private var likeBtn = UIButton()

    private var callback:((Bool)->())?

    private var videoArray:[String]?
    private var localVideoArray:[Data]?
    
    private var currentBackgroundVideoIndex = 0
    private  var maxVideos = 0
   
    var videoTitleArray:[String]!
    
    private var videoView:UIView!
    private var controlView:UIView!
    private var loadingView :UIView!
    private var gifView:UIImageView?
    private var gifTimer:Timer?
    private var currentGifIndex = 0
    private var maxGifIndex = 40
    private var splashImage = [UIImage]()
    private var splashView:UIImageView?
    
    private var labelBgView:UIView!
    private var topLabel:UILabel!
    
    private var swipeIcon:UIImageView!
    private var swipeIcon2:UIImageView!
    private var swipeIcon3:UIImageView!
    
    private var arrowTimer:Timer?
    private var animationIndex = 0
    
    private var isStreaming:Bool = true
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.playerLayer?.frame = self.view.bounds
        self.playerLayer2?.frame = self.view.bounds
        self.playerLayer3?.frame = self.view.bounds
        self.labelBgView.layer.cornerRadius = self.labelBgView.frame.height/2
        self.labelBgView.clipsToBounds = true
    }
    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return UIInterfaceOrientation.portrait
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        
        if #available(iOS 13.0, *) {
            NotificationCenter.default.addObserver(self, selector: #selector(self.appDidEnterForeground), name: UIScene.didActivateNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.appDidEnterBackground), name: UIScene.didEnterBackgroundNotification, object: nil)
            
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(self.appDidEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        }
        //avoids mute setting
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
        try? AVAudioSession.sharedInstance().setActive(true)
        
//        gifTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true, block: { (_) in
//            self.currentGifIndex = (self.currentGifIndex + 1) % self.maxGifIndex
//            DispatchQueue.main.async {
//                self.gifView?.image = UIImage(named: "Loader\(self.currentGifIndex)")
//            }
//
//        })
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.arrowTimer?.invalidate()
        self.gifTimer?.invalidate()
        if #available(iOS 13.0, *) {
            NotificationCenter.default.removeObserver(self, name: UIScene.didActivateNotification, object: nil)
        } else {
            NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        }
    }
    private func createScreen() {
        self.loadingView = UIView()
        loadingView?.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.loadingView!)
        
        NSLayoutConstraint(item: loadingView!, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: loadingView!, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: loadingView!, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: loadingView!, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0).isActive = true
        
        if splashImage.count > self.currentBackgroundVideoIndex {
            splashView = UIImageView(image: splashImage[self.currentBackgroundVideoIndex])
        }
       
        splashView?.translatesAutoresizingMaskIntoConstraints = false
        splashView?.contentMode = .scaleAspectFill
        self.loadingView.addSubview(splashView!)

        splashView?.topAnchor.constraint(equalTo: self.loadingView.topAnchor, constant: 0).isActive = true
        splashView?.leftAnchor.constraint(equalTo: self.loadingView.leftAnchor, constant: 0).isActive = true
        splashView?.rightAnchor.constraint(equalTo: self.loadingView.rightAnchor, constant: 0).isActive = true
        splashView?.bottomAnchor.constraint(equalTo: self.loadingView.bottomAnchor, constant: 0).isActive = true
  
//        gifView = UIImageView(image: UIImage(named: "Loader0"))
//        gifView?.translatesAutoresizingMaskIntoConstraints = false
//        gifView?.contentMode = .scaleAspectFit
//        loadingView.addSubview(gifView!)
//        gifView?.centerXAnchor.constraint(equalTo: self.loadingView.centerXAnchor, constant: 0).isActive = true
//        gifView?.centerYAnchor.constraint(equalTo: self.loadingView.centerYAnchor, constant: 0).isActive = true
//        gifView?.widthAnchor.constraint(equalToConstant: 150).isActive = true
//        gifView?.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        self.videoView = UIView()
        videoView?.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.videoView!)
        
        NSLayoutConstraint(item: videoView!, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: videoView!, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: videoView!, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: videoView!, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0).isActive = true
        
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
        likeBtn.topAnchor.constraint(equalTo: self.controlView.safeAreaLayoutGuide.topAnchor, constant: 13).isActive = true
        likeBtn.leadingAnchor.constraint(equalTo: self.controlView.leadingAnchor, constant: 26).isActive = true
        
        let closeBtn = UIButton()
        closeBtn.translatesAutoresizingMaskIntoConstraints = false
        closeBtn.setImage(UIImage(named: "close_lighter"), for: .normal)
        closeBtn.backgroundColor = .clear
        closeBtn.setTitle("", for: .normal)
        self.controlView.addSubview(closeBtn)
        closeBtn.widthAnchor.constraint(equalToConstant: 35).isActive = true
        closeBtn.heightAnchor.constraint(equalToConstant: 35).isActive = true
        closeBtn.addTarget(self, action: #selector(closeClick), for: .touchUpInside)
        closeBtn.topAnchor.constraint(equalTo: self.controlView.safeAreaLayoutGuide.topAnchor, constant: 13).isActive = true
        closeBtn.trailingAnchor.constraint(equalTo: self.controlView.trailingAnchor, constant: -26).isActive = true
        
        labelBgView = UIView()
        labelBgView.translatesAutoresizingMaskIntoConstraints = false
        labelBgView.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        self.controlView.addSubview(labelBgView)
        
        topLabel = UILabel()
        topLabel.translatesAutoresizingMaskIntoConstraints = false
        topLabel.textColor = .white
        topLabel.text = ""
        topLabel.font = UIFont(name: "Biryani-SemiBold", size: 12)
        topLabel.minimumScaleFactor = 0.1
        topLabel.adjustsFontSizeToFitWidth = true
        topLabel.textAlignment = .center
        self.controlView.addSubview(topLabel)
        topLabel.centerYAnchor.constraint(equalTo: closeBtn.centerYAnchor, constant: 2).isActive = true
        topLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        topLabel.leadingAnchor.constraint(greaterThanOrEqualTo: likeBtn.trailingAnchor, constant: 8).isActive = true
        topLabel.trailingAnchor.constraint(lessThanOrEqualTo: closeBtn.leadingAnchor, constant: -8).isActive = true

        //constraints to labelBgView
        topLabel.topAnchor.constraint(equalTo: labelBgView.topAnchor,constant:  3).isActive = true
        topLabel.leadingAnchor.constraint(equalTo: labelBgView.leadingAnchor,constant:  6).isActive = true
        topLabel.trailingAnchor.constraint(equalTo: labelBgView.trailingAnchor,constant:  -6).isActive = true
        topLabel.bottomAnchor.constraint(equalTo: labelBgView.bottomAnchor,constant:  0).isActive = true
//        topLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
//        let v = UIView()
//        v.backgroundColor = .green
//        v.translatesAutoresizingMaskIntoConstraints = false
//        self.controlView.addSubview(v)
//        v.heightAnchor.constraint(equalToConstant: 1).isActive = true
//        v.centerYAnchor.constraint(equalTo: closeBtn.centerYAnchor, constant: 0).isActive = true
//        v.trailingAnchor.constraint(equalTo: closeBtn.leadingAnchor,constant:  0).isActive = true
//        v.leadingAnchor.constraint(equalTo: likeBtn.trailingAnchor,constant:  0).isActive = true
//
        let swipeLabel = UILabel()
        swipeLabel.translatesAutoresizingMaskIntoConstraints = false
        swipeLabel.font = UIFont(name: "Biryani-SemiBold", size: 16)
        swipeLabel.textColor = .white
        swipeLabel.text = "Swipe for next activity"

        self.controlView.addSubview(swipeLabel)
        swipeLabel.leadingAnchor.constraint(greaterThanOrEqualTo: self.view.leadingAnchor ,constant:  16).isActive = true
        swipeLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.view.trailingAnchor ,constant:  -16).isActive = true
        swipeLabel.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -5).isActive = true
        swipeLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: -6).isActive = true
        
        swipeIcon = UIImageView()
        swipeIcon.translatesAutoresizingMaskIntoConstraints = false
        swipeIcon.image = UIImage(named: "chevron-left-solid")?.withRenderingMode(.alwaysTemplate)
        swipeIcon.tintColor = .white
        swipeIcon.contentMode = .scaleAspectFit
        self.controlView.addSubview(swipeIcon)
        swipeIcon.centerYAnchor.constraint(equalTo: swipeLabel.centerYAnchor,constant: -2).isActive = true
        swipeIcon.leadingAnchor.constraint(equalTo: swipeLabel.trailingAnchor ,constant:  8).isActive = true
        swipeIcon.widthAnchor.constraint(equalToConstant: 10).isActive = true
        swipeIcon.heightAnchor.constraint(equalToConstant: 10).isActive = true
        
        swipeIcon2 = UIImageView()
        swipeIcon2.translatesAutoresizingMaskIntoConstraints = false
        swipeIcon2.image = UIImage(named: "chevron-left-solid")?.withRenderingMode(.alwaysTemplate)
        swipeIcon2.tintColor = .white
        swipeIcon2.contentMode = .scaleAspectFit
        self.controlView.addSubview(swipeIcon2)
        swipeIcon2.centerYAnchor.constraint(equalTo: swipeLabel.centerYAnchor, constant: -2).isActive = true
        swipeIcon2.leadingAnchor.constraint(equalTo: swipeIcon.trailingAnchor ,constant:  -4).isActive = true
        swipeIcon2.widthAnchor.constraint(equalToConstant: 10).isActive = true
        swipeIcon2.heightAnchor.constraint(equalToConstant: 10).isActive = true
        
        swipeIcon3 = UIImageView()
        swipeIcon3.translatesAutoresizingMaskIntoConstraints = false
        swipeIcon3.image = UIImage(named: "chevron-left-solid")?.withRenderingMode(.alwaysTemplate)
        swipeIcon3.tintColor = .white
        swipeIcon3.contentMode = .scaleAspectFit
        self.controlView.addSubview(swipeIcon3)
        swipeIcon3.centerYAnchor.constraint(equalTo: swipeLabel.centerYAnchor, constant: -2).isActive = true
        swipeIcon3.leadingAnchor.constraint(equalTo: swipeIcon2.trailingAnchor ,constant:  -4).isActive = true
        swipeIcon3.widthAnchor.constraint(equalToConstant: 10).isActive = true
        swipeIcon3.heightAnchor.constraint(equalToConstant: 10).isActive = true
        
        
        arrowTimer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true, block: { [weak self] (_) in
           
           
               
            UIView.animate(withDuration: 0.3, delay: 0, options: [UIView.AnimationOptions.curveLinear]) {
                    self?.animationIndex = ((self?.animationIndex ?? 0) + 1) % 5
                    switch self?.animationIndex {

                        case 0:
                            self?.swipeIcon.tintColor = self?.colorFromHexString("808080")
                            self?.swipeIcon2.tintColor = self?.colorFromHexString("a0a0a0")
                            self?.swipeIcon3.tintColor = self?.colorFromHexString("c0c0c0")
                            break
                        case 1:
                            self?.swipeIcon.tintColor = self?.colorFromHexString("a0a0a0")
                            self?.swipeIcon2.tintColor = self?.colorFromHexString("c0c0c0")
                            self?.swipeIcon3.tintColor = self?.colorFromHexString("e0e0e0")
                            break
                        case 2:
                            self?.swipeIcon.tintColor = self?.colorFromHexString("c0c0c0")
                            self?.swipeIcon2.tintColor = self?.colorFromHexString("e0e0e0")
                            self?.swipeIcon3.tintColor = self?.colorFromHexString("ffffff")
                            break
                        case 3:
                            self?.swipeIcon.tintColor = self?.colorFromHexString("e0e0e0")
                            self?.swipeIcon2.tintColor = self?.colorFromHexString("ffffff")
                            self?.swipeIcon3.tintColor = self?.colorFromHexString("808080")
                        case 4:
                            self?.swipeIcon.tintColor = self?.colorFromHexString("ffffff")
                            self?.swipeIcon2.tintColor = self?.colorFromHexString("808080")
                            self?.swipeIcon3.tintColor = self?.colorFromHexString("a0a0a0")
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
    func loadDeskercisesVideosFromURL(videoArray:[String], videoTitleArray:[String], splashImageArr:[Data?], isLiked:Bool, callback:@escaping ((Bool)->())) {
        self.callback = callback
        self.videoArray = videoArray
        self.videoTitleArray = videoTitleArray
        
        for splash in splashImageArr {
            if let d = splash {
                self.splashImage.append(UIImage(data: d) ?? UIImage())
            }
            else {
                self.splashImage.append(UIImage())
            }
           
        }
        
        self.createScreen()
        
        self.likeBtn.isSelected = isLiked
        
        self.maxVideos = videoArray.count
        self.topLabel.text = videoTitleArray[0] + " (1/\(videoTitleArray.count))"
        
        self.loadRemoteBackgroundPlayers()
        self.switchVideo()
      
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
    func loadDeskercisesVideosFromData(videoArray:[Data], videoTitleArray:[String], splashImageArr:[Data?], isLiked:Bool, callback:@escaping ((Bool)->())) {
        self.callback = callback
        self.videoTitleArray = videoTitleArray
        self.localVideoArray = videoArray
        self.isStreaming = false
       
        for splash in splashImageArr {
            if let d = splash {
                self.splashImage.append(UIImage(data: d) ?? UIImage())
            }
            else {
                self.splashImage.append(UIImage())
            }
           
        }
        
        self.createScreen()
        
        self.likeBtn.isSelected = isLiked
        
        self.maxVideos = videoArray.count
        self.topLabel.text = videoTitleArray[0] + " (1/\(videoTitleArray.count))"
        
        self.loadLocalBackgroundPlayers()
        self.switchVideo()
        self.view.bringSubviewToFront(self.controlView)
    }
    
    private func loadRemoteBackgroundPlayers() {
        //MARK: Main player setup
        let playerItem = AVPlayerItem(url: URL(string: videoArray![0])!)
        playerItem.preferredForwardBufferDuration = TimeInterval(30)

        mainVideo = AVQueuePlayer(items: [playerItem])
        mainVideoLooper = AVPlayerLooper(player: mainVideo!, templateItem: playerItem)
        mainVideo?.volume = 0
        mainVideo?.automaticallyWaitsToMinimizeStalling = true
        //video player
        playerLayer = AVPlayerLayer(player: mainVideo)
        playerLayer?.videoGravity = .resizeAspectFill;
        playerLayer?.isHidden = false
       // self.videoView?.layer.addSublayer(playerLayer!)
        mainVideo?.play()
//        let timeScale = CMTimeScale(NSEC_PER_SEC)
//        let time = CMTime(seconds: 1, preferredTimescale: timeScale)
//        mainVideo?.addPeriodicTimeObserver(forInterval: time, queue: .main) { (time) in
//
//            print("1 - \(self.mainVideo?.rate) | \(time) | \(self.playerLayer?.isHidden)")
//        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            //MARK: Second player setup
            if self.videoArray!.count > 1 && self.videoTitleArray.count > 1 {
                let pi2 = AVPlayerItem(url: URL(string: self.videoArray![1])!)
                pi2.preferredForwardBufferDuration = TimeInterval(30)
                self.secondVideo = AVQueuePlayer(items: [pi2])
                self.secondVideoLooper = AVPlayerLooper(player: self.secondVideo!, templateItem: pi2)

                self.secondVideo?.automaticallyWaitsToMinimizeStalling = true
                self.secondVideo?.volume = 0

                //second video player
                self.playerLayer2 = AVPlayerLayer(player: self.secondVideo)
                self.playerLayer2?.isHidden = false
                self.playerLayer2?.videoGravity = .resizeAspectFill;
               // self.videoView?.layer.addSublayer(playerLayer2!)
                self.secondVideo?.play()
              
    //            secondVideo?.addPeriodicTimeObserver(forInterval: time, queue: .main) { (time) in
    //                print("2 - \(self.secondVideo?.rate) | \(time) | \(self.playerLayer2?.isHidden)")
    //            }
               
            }

        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            //MARK: Third player setup
            if self.videoArray!.count > 2 && self.videoTitleArray.count > 2 {

                let pi3 = AVPlayerItem(url: URL(string: self.videoArray![2])!)
                pi3.preferredForwardBufferDuration = TimeInterval(30)
                self.thirdVideo = AVQueuePlayer(items: [pi3])
                self.thirdVideoLooper = AVPlayerLooper(player: self.thirdVideo!, templateItem: pi3)
                self.thirdVideo?.automaticallyWaitsToMinimizeStalling = true
                self.thirdVideo?.volume = 0

                //third video player
                self.playerLayer3 = AVPlayerLayer(player: self.thirdVideo)
                self.playerLayer3?.isHidden = false
                self.playerLayer3?.videoGravity = .resizeAspectFill;
               // self.videoView?.layer.addSublayer(playerLayer3!)
                self.thirdVideo?.play()
               
             
    //            thirdVideo?.addPeriodicTimeObserver(forInterval: time, queue: .main) { (time) in
    //
    //                print("3 - \(self.thirdVideo?.rate) | \(time) | \(self.playerLayer3?.isHidden)")
    //            }
            }
            self.switchVideo()
            self.viewDidLayoutSubviews()
        }

    }
    
    private func loadLocalBackgroundPlayers() {
        //MARK: Main player setup
        
        try? self.localVideoArray![0].write(to: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("mainvideo.mp4"))
    
        let urlVideo = URL(fileURLWithPath: NSTemporaryDirectory() + "/mainvideo.mp4")
        let playerItem = AVPlayerItem(url: urlVideo)
        mainVideo = AVQueuePlayer(items: [playerItem])
        mainVideoLooper = AVPlayerLooper(player: mainVideo!, templateItem: playerItem)
        mainVideo?.volume = 0
        mainVideo?.automaticallyWaitsToMinimizeStalling = true
        //video player
        playerLayer = AVPlayerLayer(player: mainVideo)
        playerLayer?.isHidden = false
        playerLayer?.videoGravity = .resizeAspectFill;
        //self.videoView?.layer.addSublayer(playerLayer!)
        mainVideo?.play()
        
       
        //MARK: Second player setup
        if self.localVideoArray!.count > 1 && self.videoTitleArray.count > 1 {
            
            try? self.localVideoArray![1].write(to: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("secondvideo.mp4"))
    
            let urlVideo = URL(fileURLWithPath: NSTemporaryDirectory() + "/secondvideo.mp4")
            let pi2 = AVPlayerItem(url: urlVideo)
            self.secondVideo = AVQueuePlayer(items: [pi2])
            self.secondVideoLooper = AVPlayerLooper(player: self.secondVideo!, templateItem: pi2)
            self.secondVideo?.automaticallyWaitsToMinimizeStalling = true
           
            self.secondVideo?.volume = 0
            
            //second video player
            self.playerLayer2 = AVPlayerLayer(player: self.secondVideo)
            self.playerLayer2?.isHidden = false
            self.playerLayer2?.videoGravity = .resizeAspectFill;
            //self.videoView?.layer.addSublayer(playerLayer2!)
            
            self.secondVideo?.play()
            
            
        }
   
        if self.localVideoArray!.count > 2 && self.videoTitleArray.count > 2 {
            try? self.localVideoArray![2].write(to: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("thirdvideo.mp4"))
            
            let urlVideo = URL(fileURLWithPath: NSTemporaryDirectory() + "/thirdvideo.mp4")
            let pi3 = AVPlayerItem(url: urlVideo)
            self.thirdVideo = AVQueuePlayer(items: [pi3])
            self.thirdVideoLooper = AVPlayerLooper(player: self.thirdVideo!, templateItem: pi3)
            self.thirdVideo?.automaticallyWaitsToMinimizeStalling = true
            self.thirdVideo?.volume = 0
            
            //third video player
            self.playerLayer3 = AVPlayerLayer(player: self.thirdVideo)
            self.playerLayer3?.isHidden = false
            self.playerLayer3?.videoGravity = .resizeAspectFill;
           // self.videoView?.layer.addSublayer(playerLayer3!)
            self.thirdVideo?.play()
            
        
        }

    }
    
    @objc func setLikeClick(_ sender:UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @objc func closeClick() {
        self.pause()
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
        
        if splashImage.count > self.currentBackgroundVideoIndex {
            self.splashView?.image = splashImage[self.currentBackgroundVideoIndex]
        }
       
        
        self.switchVideo()

    }
    @objc func swipedScreenRight() {
     
        print("swipe right")
       
        self.currentBackgroundVideoIndex = (self.currentBackgroundVideoIndex  - 1) % self.maxVideos
      
        if self.currentBackgroundVideoIndex < 0{
            self.currentBackgroundVideoIndex = self.maxVideos - 1
        }
        self.topLabel.text = videoTitleArray[self.currentBackgroundVideoIndex] + " (\(self.currentBackgroundVideoIndex + 1)/\(videoTitleArray.count))"
       
        if splashImage.count > self.currentBackgroundVideoIndex {
            self.splashView?.image = splashImage[self.currentBackgroundVideoIndex]
        }
        
        self.switchVideo()
      //  self.playBackground()
    }
   
    
    @objc func appDidEnterBackground() {
       // self.pause()
        self.mainVideo?.pause()
        self.secondVideo?.pause()
        self.thirdVideo?.pause()

        playerLayer?.removeFromSuperlayer()
        playerLayer2?.removeFromSuperlayer()
        playerLayer3?.removeFromSuperlayer()

        self.playerLayer = nil
        self.playerLayer2 = nil
        self.playerLayer3 = nil
    }
    @objc func appDidEnterForeground() {
        DispatchQueue.main.async {
            if self.isStreaming {
//                self.mainVideo.play()
//                self.secondVideo?.play()
//                self.thirdVideo?.play()
               
//                self.videoView?.layer.addSublayer(self.playerLayer!)
//                self.videoView?.layer.addSublayer(self.playerLayer2!)
//                self.videoView?.layer.addSublayer(self.playerLayer3!)
       
                self.loadRemoteBackgroundPlayers()
                
               
            }
            else {
                self.mainVideo?.pause()
                self.secondVideo?.pause()
                self.thirdVideo?.pause()
              
                self.loadLocalBackgroundPlayers()
               
            }
           
            self.viewDidLayoutSubviews()

            self.switchVideo()
            
           // self.playBackground()
            
        }

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("appear")
    }
    @objc func playBackground(){
        DispatchQueue.main.async {
            self.mainVideo?.play()
            self.secondVideo?.play()
            self.thirdVideo?.play()
     
            self.switchVideo()
           
        }
      
    }
    
 //   override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        // Only handle observations for the playerItemContext
//        guard (object as? AVPlayer) == self.mainVideo || (object as? AVPlayer) == self.secondVideo || (object as? AVPlayer) == self.thirdVideo  else {
//              super.observeValue(forKeyPath: keyPath,
//                                 of: object,
//                                 change: change,
//                                 context: context)
//              return
//          }
//
//
//        if keyPath == #keyPath(AVPlayerItem.status), let player = (object as? AVPlayer) {
//              // Switch over status value
//            switch player.status {
//              case .readyToPlay:
//                super.observeValue(forKeyPath: keyPath,
//                                   of: object,
//                                   change: change,
//                                   context: context)
//               break
//              case .failed:
//                print("failed-")
//                break
//              case .unknown:
//                break
//            @unknown default:
//                break
//              }
//        }
//        else {
//            super.observeValue(forKeyPath: keyPath,
//                               of: object,
//                               change: change,
//                               context: context)
//        }
      
//    }
    
    func continuePlaying(player:AVPlayer) {
        if !(player.currentItem!.isPlaybackLikelyToKeepUp) {
            player.play()
        }
    }
    func pause(){
        print("pause")
        self.mainVideo?.pause()
        self.secondVideo?.pause()
        self.thirdVideo?.pause()
    }
   
    func switchVideo() {
        DispatchQueue.main.async {
            switch self.currentBackgroundVideoIndex {
            case 0:
                self.playerLayer2?.removeFromSuperlayer()
                self.playerLayer3?.removeFromSuperlayer()
                if self.playerLayer != nil {
                    self.videoView?.layer.addSublayer(self.playerLayer!)
                }
//                self.playerLayer?.isHidden = false
//                self.mainVideo.volume = 0
//                self.playerLayer2?.isHidden = true
//                self.secondVideo?.volume = 0
//                self.playerLayer3?.isHidden = true
//                self.thirdVideo?.volume = 0
                break
            case 1:
                self.playerLayer?.removeFromSuperlayer()
                self.playerLayer3?.removeFromSuperlayer()
                if self.playerLayer2 != nil {
                    self.videoView?.layer.addSublayer(self.playerLayer2!)
                }
//                self.playerLayer?.isHidden = true
//                self.mainVideo.volume = 0
//                self.playerLayer2?.isHidden = false
//                self.secondVideo?.volume = 0
//                self.playerLayer3?.isHidden = true
//                self.thirdVideo?.volume = 0
                break
            case 2:
                self.playerLayer?.removeFromSuperlayer()
                self.playerLayer2?.removeFromSuperlayer()
                if self.playerLayer3 != nil {
                    self.videoView?.layer.addSublayer(self.playerLayer3!)
                }
                
//                self.playerLayer?.isHidden = true
//                self.mainVideo.volume = 0
//                self.playerLayer2?.isHidden = true
//                self.secondVideo?.volume = 0
//                self.playerLayer3?.isHidden = false
//                self.thirdVideo?.volume = 0
                break
            default:
                break
            }
        }
       
    }
    
    func colorFromHexString(_ hexString:String) -> UIColor{
        
        var hexStr = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
       
        var rgbColor:UInt64 = 0
        
        if hexStr.hasPrefix("#"){
            hexStr.removeFirst()
        }
        if hexStr.count == 8 {
            hexStr.removeFirst(2)
        }
        let scanner = Scanner(string: hexStr)
        scanner.scanHexInt64(&rgbColor)
        
        return UIColor.init(red: CGFloat(((rgbColor & 0xFF0000) >> 16))/CGFloat(255.0), green: CGFloat(((rgbColor & 0x00FF00) >> 8))/CGFloat(255.0), blue: CGFloat((rgbColor & 0x0000FF))/CGFloat(255.0), alpha: 1.0)
        
        
    }
}

