//
//  BreathworkViewController.swift
//  OutsysVideoPOC
//
//  Created by WorldIT on 24/01/2022.
//

import UIKit
import AVKit
class BreathworkViewController: UIViewController {

        
    private var playerLayer:AVPlayerLayer?
    
    private var mainAudioVideo:AVQueuePlayer?
   
    private var firstAudio:AVQueuePlayer?
    private var firstAudioLooper: AVPlayerLooper?

    private var secondAudioLooper: AVPlayerLooper?
    private var secondAudio:AVQueuePlayer?
    
    private var thirdAudioLooper: AVPlayerLooper?
    private var thirdAudio:AVQueuePlayer?
       
    private var videoView:UIView!
    private var controlView:UIView!
    private var loadingView :UIView!
  
    private var splashImage = [UIImage]()
    private var splashView:UIImageView?
    
    private var audioSlider:UISlider!{
        didSet{
            audioSlider?.transform = CGAffineTransform(rotationAngle: -.pi/2)
        }
    }
    private var audioSliderView:UIView!
    
    private var seekerSlider:UISlider!
    private var subtitleSwitch = UISwitch()
    private var pageIndicator : UIPageControl!{
        didSet{
            pageIndicator?.transform = CGAffineTransform(rotationAngle: .pi/2)
        }
    }
    private var playPauseBtn = UIButton()
    private var likeBtn = UIButton()
    
    
    
    private var closeTimer:Timer?
    private var callback:((Bool, Bool)->())?
    
    private var watchedTimeTimer:Timer?
    private var watchedTime = 0

    private var videoURL:String?
    private var audioArray:[String]?
    
    private var localVideoData:Data?
    private var localAudioArray:[Data]?
    
    private var currentBackgroundVideoIndex = 0
    private  var maxVideos = 0
    private var secondsToSkip = 0
    private var skipBtn:UIButton?
    private var timeLabel:UILabel!
    
    private var seekerTouched = false
    private var isStreaming:Bool = true
   
    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return UIInterfaceOrientation.portrait
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.playerLayer?.frame = self.view.bounds
        self.subtitleSwitch.layer.borderColor = UIColor.white.cgColor
        self.subtitleSwitch.layer.borderWidth = 1
        self.subtitleSwitch.layer.cornerRadius = self.subtitleSwitch.frame.height/2
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
        
        watchedTimeTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (_) in
           
            if self.mainAudioVideo?.timeControlStatus == .playing {
                self.watchedTime += 1
            }
            
        })
        
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.watchedTimeTimer?.invalidate()
        self.closeTimer?.invalidate()
       
        if #available(iOS 13.0, *) {
            NotificationCenter.default.removeObserver(self, name: UIScene.didActivateNotification, object: nil)
        } else {
            NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        }
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
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
            splashView = UIImageView(image: splashImage[0])
        }
       
        splashView?.translatesAutoresizingMaskIntoConstraints = false
        splashView?.contentMode = .scaleAspectFill
        self.loadingView.addSubview(splashView!)

        splashView?.topAnchor.constraint(equalTo: self.loadingView.topAnchor, constant: 0).isActive = true
        splashView?.leftAnchor.constraint(equalTo: self.loadingView.leftAnchor, constant: 0).isActive = true
        splashView?.rightAnchor.constraint(equalTo: self.loadingView.rightAnchor, constant: 0).isActive = true
        splashView?.bottomAnchor.constraint(equalTo: self.loadingView.bottomAnchor, constant: 0).isActive = true
  
        self.videoView = UIView()
        videoView?.translatesAutoresizingMaskIntoConstraints = false
        videoView.backgroundColor = .clear
        self.view.addSubview(self.videoView!)
        
        NSLayoutConstraint(item: videoView!, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: videoView!, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: videoView!, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: videoView!, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0).isActive = true
        
        self.controlView = UIView()
        controlView?.translatesAutoresizingMaskIntoConstraints = false
        self.controlView?.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        self.view.addSubview(self.controlView!)
        
        NSLayoutConstraint(item: controlView!, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: controlView!, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: controlView!, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: controlView!, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0).isActive = true
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        
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
        likeBtn.topAnchor.constraint(equalTo: self.controlView.safeAreaLayoutGuide.topAnchor, constant: 14).isActive = true
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
        closeBtn.topAnchor.constraint(equalTo: self.controlView.safeAreaLayoutGuide.topAnchor, constant: 14).isActive = true
        closeBtn.trailingAnchor.constraint(equalTo: self.controlView.trailingAnchor, constant: -26).isActive = true
        
        //subtitle switch
        subtitleSwitch.setOn(true, animated: true)
        subtitleSwitch.translatesAutoresizingMaskIntoConstraints = false
        
        self.controlView.addSubview(subtitleSwitch)
        subtitleSwitch.bottomAnchor.constraint(equalTo: self.controlView.safeAreaLayoutGuide.bottomAnchor, constant: -50).isActive = true
        subtitleSwitch.trailingAnchor.constraint(equalTo: self.controlView.trailingAnchor, constant: -42).isActive = true
        subtitleSwitch.addTarget(self, action: #selector(subtitleSwitchValueDidChange(_:)), for: .valueChanged)
        subtitleSwitch.onTintColor = colorFromHexString("a3afd3")
        
        let subLabel = UILabel()
        subLabel.text = "Subtitles"
        subLabel.textColor = .white
        subLabel.translatesAutoresizingMaskIntoConstraints = false
        self.controlView.addSubview(subLabel)
        subLabel.font = UIFont(name: "Biryani-SemiBold", size: 12)
        subLabel.centerYAnchor.constraint(equalTo: self.subtitleSwitch.centerYAnchor).isActive = true
        subLabel.trailingAnchor.constraint(equalTo: self.subtitleSwitch.leadingAnchor, constant: -12).isActive = true
        
        
        //play btn
        playPauseBtn.translatesAutoresizingMaskIntoConstraints = false
        playPauseBtn.tintColor = .white
        playPauseBtn.setImage(UIImage(named: "MPlayer_Play_2x"), for: .normal)
        playPauseBtn.setImage(UIImage(named: "MPlayer_Pause_2x"), for: .selected)
        self.controlView.addSubview(playPauseBtn)
        playPauseBtn.centerYAnchor.constraint(equalTo: self.controlView.centerYAnchor, constant: -67).isActive = true
        playPauseBtn.centerXAnchor.constraint(equalTo: self.controlView.centerXAnchor).isActive = true
        playPauseBtn.addTarget(self, action: #selector(playPauseClick(_:)), for: .touchUpInside)
        playPauseBtn.widthAnchor.constraint(equalToConstant: 42).isActive = true
        playPauseBtn.heightAnchor.constraint(equalToConstant: 42).isActive = true
        playPauseBtn.imageView?.contentMode = .scaleAspectFit
        
        let moveForward = UIButton()
        moveForward.translatesAutoresizingMaskIntoConstraints = false
        moveForward.tintColor = .white
        moveForward.setImage(UIImage(named: "MPlayer_FWD_WithNum_2x"), for: .normal)
        moveForward.setTitle("", for: .normal)
        self.controlView.addSubview(moveForward)
        moveForward.widthAnchor.constraint(equalToConstant: 30).isActive = true
        moveForward.heightAnchor.constraint(equalToConstant: 30).isActive = true
        moveForward.addTarget(self, action: #selector(moveForwardClick(_:)), for: .touchUpInside)
        moveForward.centerYAnchor.constraint(equalTo: playPauseBtn.centerYAnchor, constant: 2).isActive = true
        moveForward.leadingAnchor.constraint(equalTo: playPauseBtn.trailingAnchor, constant: 38).isActive = true

        let moveBack = UIButton()
        moveBack.translatesAutoresizingMaskIntoConstraints = false
        moveBack.tintColor = .white
        moveBack.setImage(UIImage(named: "MPlayer_RWD_WithNum_2x"), for: .normal)
        moveBack.setTitle("", for: .normal)
        self.controlView.addSubview(moveBack)
        moveBack.widthAnchor.constraint(equalToConstant: 30).isActive = true
        moveBack.heightAnchor.constraint(equalToConstant: 30).isActive = true
        moveBack.addTarget(self, action: #selector(moveBackClick(_:)), for: .touchUpInside)
        moveBack.centerYAnchor.constraint(equalTo: playPauseBtn.centerYAnchor, constant: 2).isActive = true
        moveBack.trailingAnchor.constraint(equalTo: playPauseBtn.leadingAnchor, constant: -38).isActive = true
        
        pageIndicator = UIPageControl()
        pageIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.controlView.addSubview(pageIndicator!)
        pageIndicator.centerYAnchor.constraint(equalTo: self.playPauseBtn.centerYAnchor).isActive = true
        //audioSlider is rotated. center is width / 2
        pageIndicator.centerXAnchor.constraint(equalTo: closeBtn.centerXAnchor, constant: 0).isActive = true
        pageIndicator.isUserInteractionEnabled = true
        pageIndicator.addTarget(self, action: #selector(switchVideoHandle), for: .valueChanged)
        
        let pagerTopIcon = UIImageView()
        pagerTopIcon.translatesAutoresizingMaskIntoConstraints = false
        self.controlView.addSubview(pagerTopIcon)
        
        pagerTopIcon.centerXAnchor.constraint(equalTo: self.pageIndicator.centerXAnchor).isActive = true
        pagerTopIcon.bottomAnchor.constraint(equalTo: self.pageIndicator.topAnchor, constant: -15).isActive = true
      
        pagerTopIcon.contentMode = .scaleAspectFit
       
        pagerTopIcon.image = UIImage(named: "soundIcon")
        pagerTopIcon.widthAnchor.constraint(equalToConstant: 25).isActive = true
        pagerTopIcon.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        
        audioSliderView = UIView()
        audioSliderView?.translatesAutoresizingMaskIntoConstraints = false
        audioSliderView?.backgroundColor = .clear
        audioSliderView?.widthAnchor.constraint(equalToConstant: 50).isActive = true
        audioSliderView?.heightAnchor.constraint(equalToConstant: 150).isActive = true
       
        self.controlView.addSubview(audioSliderView)
        audioSliderView.centerYAnchor.constraint(equalTo: self.playPauseBtn.centerYAnchor).isActive = true
        //audioSlider is rotated. center is width / 2
        audioSliderView.centerXAnchor.constraint(equalTo: self.likeBtn.centerXAnchor, constant: 0).isActive = true
        
        //audio slider
        audioSlider = UISlider()
        audioSlider.maximumValue = 1
        audioSlider.minimumValue = 0
        audioSlider.value = 0.75
        audioSlider.addTarget(self, action: #selector(sliderValueDidChange(_:)), for: .valueChanged)
        audioSlider.translatesAutoresizingMaskIntoConstraints = false
        audioSlider.tag = 1
        audioSlider.minimumTrackTintColor = .white
        audioSlider.maximumTrackTintColor = .lightGray
        audioSlider.backgroundColor = .clear
        self.audioSliderView?.addSubview(audioSlider!)
        
        audioSlider.widthAnchor.constraint(equalToConstant: 150).isActive = true
        audioSlider.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        //constraints to middleview
        audioSlider.centerXAnchor.constraint(equalTo: audioSliderView!.centerXAnchor).isActive = true
        audioSlider.centerYAnchor.constraint(equalTo: audioSliderView!.centerYAnchor,constant:  0).isActive = true
        
        
        //seekerSlider lider
        seekerSlider = UISlider()
        seekerSlider.maximumValue = 1
        seekerSlider.minimumValue = 0
        seekerSlider.value = 0
        seekerSlider.isContinuous = true
        seekerSlider.tintColor = .blue
        seekerSlider.tag = 2
        seekerSlider.addTarget(self, action: #selector(sliderValueDidChange(_:)), for: .valueChanged)
        seekerSlider.addTarget(self, action: #selector(touchedUp), for: .touchUpInside)
        seekerSlider.translatesAutoresizingMaskIntoConstraints = false
        seekerSlider.minimumTrackTintColor = .white
        seekerSlider.maximumTrackTintColor = .lightGray
        
        self.controlView?.addSubview(seekerSlider)
        
        seekerSlider.topAnchor.constraint(equalTo: self.playPauseBtn.bottomAnchor, constant: 176).isActive = true
        seekerSlider.trailingAnchor.constraint(equalTo: self.controlView.trailingAnchor, constant: -42).isActive = true
        seekerSlider.leadingAnchor.constraint(equalTo: self.controlView.leadingAnchor, constant: 42).isActive = true
        
        seekerSlider.heightAnchor.constraint(equalToConstant: 20).isActive = true
        seekerSlider.addTarget(self, action: #selector(sliderValueDidChange(_:)), for: .valueChanged)
        
        timeLabel = UILabel()
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.textColor = .white
        timeLabel.text = "0:00/0.00"
        timeLabel.font = UIFont(name: "Biryani-SemiBold", size: 12)
        self.controlView.addSubview(timeLabel)
        timeLabel.topAnchor.constraint(equalTo: self.seekerSlider.bottomAnchor, constant: 20).isActive = true
        timeLabel.centerXAnchor.constraint(equalTo: self.seekerSlider.centerXAnchor).isActive = true
       

        let audioSliderTopIcon = UIImageView()
        audioSliderTopIcon.translatesAutoresizingMaskIntoConstraints = false
        audioSliderTopIcon.image = UIImage(named: "personIcon")
        self.controlView.addSubview(audioSliderTopIcon)
        audioSliderTopIcon.centerXAnchor.constraint(equalTo: self.audioSlider.centerXAnchor).isActive = true
        audioSliderTopIcon.bottomAnchor.constraint(equalTo: self.audioSlider.topAnchor, constant: -56).isActive = true
        audioSliderTopIcon.widthAnchor.constraint(equalToConstant: 25).isActive = true
        audioSliderTopIcon.heightAnchor.constraint(equalToConstant: 25).isActive = true
        audioSliderTopIcon.contentMode = .scaleAspectFit
        
        let audioSliderBottomIcon = UIImageView()
        audioSliderBottomIcon.translatesAutoresizingMaskIntoConstraints = false
        audioSliderBottomIcon.image = UIImage(named: "soundIcon")
        self.controlView.addSubview(audioSliderBottomIcon)
        audioSliderBottomIcon.centerXAnchor.constraint(equalTo: self.audioSlider.centerXAnchor).isActive = true
        audioSliderBottomIcon.topAnchor.constraint(equalTo: self.audioSlider.bottomAnchor, constant: 56).isActive = true
        audioSliderBottomIcon.widthAnchor.constraint(equalToConstant: 25).isActive = true
        audioSliderBottomIcon.heightAnchor.constraint(equalToConstant: 25).isActive = true
        audioSliderBottomIcon.contentMode = .scaleAspectFit
        
       
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideShowControls))
        self.controlView.addGestureRecognizer(tap)
        
        let swipeUpControl = UISwipeGestureRecognizer(target: self, action: #selector(swipedScreenUp))
        swipeUpControl.direction = .up
        self.controlView.addGestureRecognizer(swipeUpControl)
    
        let swipeDownControl = UISwipeGestureRecognizer(target: self, action: #selector(swipedScreenDown))
        swipeDownControl.direction = .down
        self.controlView.addGestureRecognizer(swipeDownControl)
        
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(hideShowControls))
        self.view.addGestureRecognizer(tap2)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(swipedScreenUp))
        swipeUp.direction = .up
        self.view.addGestureRecognizer(swipeUp)
       
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(swipedScreenDown))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
        
        let dummySwipeUp = UISwipeGestureRecognizer(target: self, action: #selector(swipedScreenUp))
        dummySwipeUp.direction = .up
        dummySwipeUp.cancelsTouchesInView = true
        audioSliderView.addGestureRecognizer(dummySwipeUp)
        let dummySwipeDown = UISwipeGestureRecognizer(target: self, action: #selector(swipedScreenDown))
        dummySwipeDown.direction = .down
        dummySwipeDown.cancelsTouchesInView = true
        audioSliderView.addGestureRecognizer(dummySwipeDown)
        
        
       
    }

    @objc func touchedUp() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if !self.seekerSlider.isHighlighted {
                self.seekerTouched = false
            }
           
        }
       
    }
    
    /// Loads videos passed in params with URLs.
    ///
    /// - Parameter backgroundVideoWithVoiceURL: String to the background video with narration
    /// - Parameter audioArray: Array of string with background audio url
    /// - Parameter audioVoiceURL:String to the narration audio
    /// - Parameter subtitleData:Data to the subtitles file (.srt)
    /// - Parameter splashImage: Data with the image shown while loading
    /// - Parameter secondsToSkip: Number of seconds that the Skip Button should skip in the narration, if less or equals to 0 the button is hidden/disabled
    /// - Parameter isLiked: True of False if the video was previously liked
    /// - Parameter callback: Reference to the method to be called when the close button is pressed, should receive 2 params (Bool, Bool) meaning (true if watched more than 80%, isLiked)
    func loadBreathworkVideosFromURL(backgroundVideoWithVoiceURL:String, audioArray:[String], subtitleData:Data, splashImage:Data?, secondsToSkip:Int, isLiked:Bool, callback:@escaping ((Bool, Bool)->())) {
        self.callback = callback
        self.videoURL = backgroundVideoWithVoiceURL
        self.audioArray = audioArray
        self.watchedTime = 0
       
        if splashImage != nil {
            self.splashImage.append(UIImage(data: splashImage!) ?? UIImage())
        }
        
        
        self.createScreen()
        self.likeBtn.isSelected = isLiked
        
        self.maxVideos = audioArray.count
        self.pageIndicator.numberOfPages = audioArray.count
        self.secondsToSkip = secondsToSkip
        
        if secondsToSkip > 0 {
            self.addSkipButton()
        }

       
        //load videos and audios
        let playerItem = AVPlayerItem(url: URL(string: videoURL!)!)
        playerItem.preferredForwardBufferDuration = TimeInterval(30)
        mainAudioVideo = AVQueuePlayer(items: [playerItem])
        mainAudioVideo?.automaticallyWaitsToMinimizeStalling = true
        mainAudioVideo?.volume = audioSlider?.value ?? 0.0
        
        //video player
        playerLayer = AVPlayerLayer(player: mainAudioVideo)
        playerLayer?.videoGravity = .resizeAspectFill;
        playerLayer?.isHidden = false
        self.videoView.layer.addSublayer(playerLayer!)
        
        self.loadRemoteBackgroundAudioPlayers()
        self.switchAudio()
        self.view.bringSubviewToFront(self.controlView)
        
      
        
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 1, preferredTimescale: timeScale)

        mainAudioVideo?.addPeriodicTimeObserver(forInterval: time, queue: .main) {[weak self] (time) in
           
            self?.timeLabel.text = "\(self?.getTime(roundedSeconds: self?.mainAudioVideo?.currentTime().seconds.rounded() ?? 0.0))/\(self?.getTime(roundedSeconds: (self?.mainAudioVideo?.currentItem?.asset.duration.seconds ?? 0.0).rounded()))"
           
            print(time.seconds)
            if Int(time.seconds) <  Int((self?.seekerSlider.maximumValue ?? 1)) && !(self?.seekerSlider.isHighlighted ?? true) && !(self?.seekerTouched ?? false) {
                self?.seekerSlider.setValue(Float(time.seconds), animated: true)
            }
            
            if Int(self?.mainAudioVideo?.currentTime().seconds.rounded() ?? 0.0) >= (self?.secondsToSkip ?? 0) {
                self?.skipBtn?.isHidden = true
            }
          
        }

        mainAudioVideo?.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions(), context: nil)
       
        //MARK: Subtitle setup
        self.addSubtitles().open(fromData: subtitleData, player: mainAudioVideo!)
    }

    /// Loads videos passed in params from Data.
    /// Videos will be saved temporarily on the phone, videos will be saved as .mp4 and audios as .mp3
    ///
    /// - Parameter backgroundVideoWithVoiceData: String to the background video with narration
    /// - Parameter audioArray: Array of data with background audio url
    /// - Parameter subtitleData:Data to the subtitles file (.srt)
    /// - Parameter splashImage: Data with the image shown while loading
    /// - Parameter secondsToSkip: Number of seconds that the Skip Button should skip in the narration, if less or equals to 0 the button is hidden/disabled
    /// - Parameter isLiked: True of False if the video was previously liked
    /// - Parameter callback: Reference to the method to be called when the close button is pressed, should receive 2 params (Bool, Bool) meaning (true if watched more than 80%, isLiked)
    func loadBreathworkVideosFromData(backgroundVideoWithVoiceData:Data, audioArray:[Data], subtitleData:Data, splashImage:Data?, secondsToSkip:Int, isLiked:Bool, callback:@escaping ((Bool, Bool)->())) {
        self.callback = callback
        self.localVideoData = backgroundVideoWithVoiceData
        self.localAudioArray = audioArray
        self.watchedTime = 0
        self.isStreaming = false
        
        
        if splashImage != nil {
            self.splashImage.append(UIImage(data: splashImage!) ?? UIImage())
        }
        
        self.createScreen()
        self.likeBtn.isSelected = isLiked
        
        self.maxVideos = audioArray.count
        self.pageIndicator.numberOfPages = audioArray.count
        self.secondsToSkip = secondsToSkip
        
        if secondsToSkip > 0 {
            self.addSkipButton()
        }
        
        try? localVideoData!.write(to: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("mainvideo.mp4"))
        let urlVideo = URL(fileURLWithPath: NSTemporaryDirectory() + "/mainvideo.mp4")
        let playerItem = AVPlayerItem(url: urlVideo)
        mainAudioVideo = AVQueuePlayer(items: [playerItem])
        mainAudioVideo?.volume = audioSlider?.value ?? 0.0
        mainAudioVideo?.automaticallyWaitsToMinimizeStalling = true
        
        //video player
        playerLayer = AVPlayerLayer(player: mainAudioVideo)
        playerLayer?.videoGravity = .resizeAspectFill;
        playerLayer?.isHidden = false
        self.videoView.layer.addSublayer(playerLayer!)
        
        self.loadLocalBackgroundPlayers()
        self.switchAudio()
        self.view.bringSubviewToFront(self.controlView)
        

        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 1, preferredTimescale: timeScale)

        mainAudioVideo?.addPeriodicTimeObserver(forInterval: time, queue: .main) {[weak self] (time) in
           
            self?.timeLabel.text = "\(self?.getTime(roundedSeconds: self?.mainAudioVideo?.currentTime().seconds.rounded() ?? 0.0))/\(self?.getTime(roundedSeconds: (self?.mainAudioVideo?.currentItem?.asset.duration.seconds ?? 0.0).rounded()))"
           
            print(time.seconds)
            if Int(time.seconds) <  Int((self?.seekerSlider.maximumValue ?? 1)) && !(self?.seekerSlider.isHighlighted ?? true) && !(self?.seekerTouched ?? false) {
                self?.seekerSlider.setValue(Float(time.seconds), animated: true)
            }
            
            if Int(self?.mainAudioVideo?.currentTime().seconds.rounded() ?? 0.0) >= (self?.secondsToSkip ?? 0) {
                self?.skipBtn?.isHidden = true
            }
          
        }

        mainAudioVideo?.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions(), context: nil)
       
//        //MARK: Subtitle setup

        self.addSubtitles().open(fromData: subtitleData, player: mainAudioVideo!)
        
    }
    
    private func loadRemoteBackgroundAudioPlayers() {
        //MARK: Main player setup
        let playerAudioItem = AVPlayerItem(url: URL(string: audioArray![0])!)
        firstAudio = AVQueuePlayer(items: [playerAudioItem])
        firstAudioLooper = AVPlayerLooper(player: firstAudio!, templateItem: playerAudioItem)
        firstAudio?.automaticallyWaitsToMinimizeStalling = true

        
        //MARK: Second player setup
        if audioArray!.count > 1 {
            //second audio player
            let pai2 = AVPlayerItem(url: URL(string: audioArray![1])!)
            secondAudio = AVQueuePlayer(items: [pai2])
            secondAudioLooper = AVPlayerLooper(player: secondAudio!, templateItem: pai2)
            secondAudio?.automaticallyWaitsToMinimizeStalling = true
        }
        
        //MARK: Third player setup
        if audioArray!.count > 2 {
            //third audio player
            let pai3 = AVPlayerItem(url: URL(string: audioArray![2])!)
            thirdAudio = AVQueuePlayer(items: [pai3])
            thirdAudioLooper = AVPlayerLooper(player: thirdAudio!, templateItem: pai3)
            thirdAudio?.automaticallyWaitsToMinimizeStalling = true
        }
    }
    
    private func loadLocalBackgroundPlayers() {
        //MARK: Main player setup
        try? localAudioArray![0].write(to: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("mainaudio.mp3"))
       
        let urlAudio = URL(fileURLWithPath: NSTemporaryDirectory() + "/mainaudio.mp3")
        let playerAudioItem = AVPlayerItem(url: urlAudio)
        firstAudio = AVQueuePlayer(items: [playerAudioItem])
        firstAudioLooper = AVPlayerLooper(player: firstAudio!, templateItem: playerAudioItem)
        firstAudio?.automaticallyWaitsToMinimizeStalling = true
    
        
        //MARK: Second player setup
        if localAudioArray!.count > 1 {
            try? localAudioArray![1].write(to: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("secondaudio.mp3"))
            let urlAudio = URL(fileURLWithPath: NSTemporaryDirectory() + "/secondaudio.mp3")
            let pai2 = AVPlayerItem(url: urlAudio)
            secondAudio = AVQueuePlayer(items: [pai2])
            secondAudioLooper = AVPlayerLooper(player: secondAudio!, templateItem: pai2)
            secondAudio?.automaticallyWaitsToMinimizeStalling = true
        }
        
        //MARK: Third player setup
        if localAudioArray!.count > 2 {
            try? localAudioArray![2].write(to: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("thirdaudio.mp3"))
            
            let urlAudio = URL(fileURLWithPath: NSTemporaryDirectory() + "/thirdaudio.mp3")
            let pai3 = AVPlayerItem(url: urlAudio)
            thirdAudio = AVQueuePlayer(items: [pai3])
            thirdAudioLooper = AVPlayerLooper(player: thirdAudio!, templateItem: pai3)
            thirdAudio?.automaticallyWaitsToMinimizeStalling = true
        }
    }
    
    private func addSkipButton() {
       
        skipBtn = UIButton()
        skipBtn?.translatesAutoresizingMaskIntoConstraints = false
        skipBtn?.setTitle("Skip intro", for: .normal)
        skipBtn?.setTitleColor(.white, for: .normal)
        skipBtn?.widthAnchor.constraint(equalToConstant: 82).isActive = true
        skipBtn?.heightAnchor.constraint(equalToConstant: 30).isActive = true
        skipBtn?.titleLabel?.font = UIFont(name: "Biryani-SemiBold", size: 12)
        skipBtn?.addTarget(self, action: #selector(skipIntro(sender:)), for: .touchUpInside)
        self.controlView.addSubview(skipBtn!)
        skipBtn?.centerYAnchor.constraint(equalTo: self.subtitleSwitch.centerYAnchor).isActive = true
        skipBtn?.leadingAnchor.constraint(equalTo: self.controlView.leadingAnchor, constant: 44).isActive = true
        skipBtn?.contentEdgeInsets = UIEdgeInsets(top: 1, left: 0, bottom: -1, right: 0)
        skipBtn?.layer.cornerRadius = 15
        skipBtn?.layer.borderWidth = 1
        skipBtn?.layer.borderColor = UIColor.white.cgColor
    
        
    }
    
    @objc func setLikeClick(_ sender:UIButton) {
        sender.isSelected = !sender.isSelected
        closeTimer?.invalidate()
        if self.playPauseBtn.isSelected {
            self.startCloseTimer()
        }
        
    }
    
    @objc func closeClick() {
        self.stopBackground()
        closeTimer?.invalidate()
        self.pause()
        let maxTime = (self.mainAudioVideo?.currentItem?.asset.duration.seconds ?? 0.0).rounded()
        
        self.callback?(self.watchedTime >= (Int(maxTime) * 80 / 100), self.likeBtn.isSelected)
        
        if self.navigationController?.topViewController == self {
            self.navigationController?.popViewController(animated: true)
        }
        else {
            self.dismiss(animated: true, completion: nil)
        }
        self.firstAudio = nil
        self.secondAudio = nil
        self.thirdAudio = nil
        self.mainAudioVideo?.removeObserver(self, forKeyPath: "status")
        self.mainAudioVideo = nil
    }
    @objc func swipedScreenUp(_ sender:UISwipeGestureRecognizer) {
        print("swipe up")
        if sender.view == self.audioSliderView {
            return
        }
        self.currentBackgroundVideoIndex = (self.currentBackgroundVideoIndex  + 1) % self.maxVideos
        self.pageIndicator.currentPage = self.currentBackgroundVideoIndex
        

        self.switchAudio()
        
        
        if self.controlView.alpha == 1 {
            self.closeTimer?.invalidate()
            self.startCloseTimer()
        }
       
    }
    @objc func swipedScreenDown(_ sender:UISwipeGestureRecognizer) {
        print("swipe down")
        if sender.view == self.audioSliderView {
            return
        }
        
        self.currentBackgroundVideoIndex = (self.currentBackgroundVideoIndex  - 1) % self.maxVideos
        if self.currentBackgroundVideoIndex < 0{
            self.currentBackgroundVideoIndex = self.maxVideos - 1
        }
        self.pageIndicator.currentPage = self.currentBackgroundVideoIndex
       
        self.switchAudio()
        
         
        if self.controlView.alpha == 1 {
            self.closeTimer?.invalidate()
            self.startCloseTimer()
        }
    }
    
    @objc func hideShowControls() {
        if self.controlView.alpha == 0 {
            self.showControls()
        }
        else {
            self.hideControls()
        }
    }
    func showControls() {
        if self.controlView.alpha == 0 {
            closeTimer?.invalidate()
            UIView.animate(withDuration: 0.2) {
                self.controlView.alpha = 1
            } completion: { (_) in
               
                self.startCloseTimer()
            }
        }
    }
    
    func hideControls() {
        if self.controlView.alpha == 1 {
            self.closeTimer?.invalidate()
            UIView.animate(withDuration: 0.2, animations: {
                self.controlView.alpha = 0
            }, completion: nil)
        }
    }
    
    func startCloseTimer(seconds:Int = 2) {
        closeTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(seconds), repeats: false, block: { (_) in
            DispatchQueue.main.async {
                self.hideShowControls()
            }
        })
    }
    
    @objc func playerDidFinishPlaying(_ notification: Notification) {
        if (self.mainAudioVideo?.currentTime().seconds.rounded() ?? 0.0) >= (self.mainAudioVideo?.currentItem?.asset.duration.seconds ?? 0.0).rounded() {
            self.closeClick()
        }
    }
    func getTime(roundedSeconds:Double) -> String {
      
        var hours:  Int { return Int(roundedSeconds / 3600) }
        var minute: Int { return Int(roundedSeconds.truncatingRemainder(dividingBy: 3600) / 60) }
        var second: Int { return Int(roundedSeconds.truncatingRemainder(dividingBy: 60)) }
        var positionalTime: String {
            return hours > 0 ?
                String(format: "%d:%02d:%02d",
                       hours, minute, second) :
                String(format: "%02d:%02d",
                       minute, second)
        }
        return positionalTime
    }
    
    @objc func playPauseClick(_ sender:UIButton){
        closeTimer?.invalidate()
        
        if sender.isSelected {
            sender.isSelected = false
            self.pause()
        }
        else {
            sender.isSelected = true
            self.play()
        }
       
    }
    @objc func moveForwardClick(_ sender:UIButton){

        let playerCurrentTime = CMTimeGetSeconds(mainAudioVideo!.currentTime() )
        let time:CMTime = CMTimeMake(value: Int64(playerCurrentTime + 15), timescale: 1)
        mainAudioVideo?.seek(to: time)
        
        closeTimer?.invalidate()
        if self.playPauseBtn.isSelected {
            self.startCloseTimer()
        }
    }
    @objc func moveBackClick(_ sender:UIButton){
        let playerCurrentTime = CMTimeGetSeconds(mainAudioVideo!.currentTime())
        let time:CMTime = CMTimeMake(value: Int64(playerCurrentTime - 15), timescale: 1)
        mainAudioVideo?.seek(to: time)
        
        closeTimer?.invalidate()
        if self.playPauseBtn.isSelected {
            self.startCloseTimer()
        }
    }
    @objc func sliderValueDidChange(_ sender:UISlider){
        if sender.tag == 1 {
            mainAudioVideo?.volume = audioSlider?.value ?? 0.0
            
            switch self.currentBackgroundVideoIndex {
            case 0:
                self.firstAudio?.volume = (1.0 - (self.audioSlider?.value ?? 0)) * 0.5
                self.secondAudio?.volume = 0
                self.thirdAudio?.volume = 0
                print(firstAudio?.volume)
                break
            case 1:
                self.firstAudio?.volume = 0
                self.secondAudio?.volume = (1.0 - (self.audioSlider?.value ?? 0)) * 0.5
                self.thirdAudio?.volume = 0
                print(secondAudio?.volume)
                break
            case 2:
                self.firstAudio?.volume = 0
                self.secondAudio?.volume = 0
                self.thirdAudio?.volume = (1.0 - (self.audioSlider?.value ?? 0)) * 0.5
                print(thirdAudio?.volume)
                break
            default:
                break
            }
            
           
            print(mainAudioVideo?.volume)
        }
        else if sender.tag == 2 {
            self.seekerTouched = true
            let seconds : Int64 = Int64(sender.value)
            let time:CMTime = CMTimeMake(value: seconds, timescale: 1)
            mainAudioVideo?.seek(to: time)
            
          
        }
        closeTimer?.invalidate()
        if self.playPauseBtn.isSelected {
            self.startCloseTimer()
        }
    }
    
    @objc func subtitleSwitchValueDidChange(_ sender:UISwitch){
        if sender.isOn {
            self.subtitleLabel?.isHidden = false
        }
        else {
            self.subtitleLabel?.isHidden = true
        }
        
        closeTimer?.invalidate()
        if self.playPauseBtn.isSelected {
            self.startCloseTimer()
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        // Only handle observations for the playerItemContext
        guard (object as? AVPlayer) == self.mainAudioVideo else {
              super.observeValue(forKeyPath: keyPath,
                                 of: object,
                                 change: change,
                                 context: context)
              return
          }

        
        if keyPath == #keyPath(AVPlayerItem.status), let player = (object as? AVPlayer) {
              // Switch over status value
            switch player.status {
              case .readyToPlay:
                if player == mainAudioVideo {
                    self.mainAudioVideo?.preroll(atRate: 1) { (audioFinished2) in
                        print("a1 preroll \(audioFinished2)")
                        if audioFinished2 {
                            self.playPauseBtn.isSelected = true
                            self.play(shoudHide5Sec: true)
                        }
                        else {
                            DispatchQueue.main.async {
                                self.showControls()
                            }
                        }
                    }
                }
              case .failed:
                break
              case .unknown:
                break
            @unknown default:
                break
              }
        }
      
    }
    
    func play(shoudHide5Sec:Bool = false) {
        print("play")
        self.playBackground()
        self.mainAudioVideo?.play()
        self.mainAudioVideo?.volume = self.audioSlider?.value ?? 0.0
        if let a = mainAudioVideo?.currentItem?.asset.duration {
            seekerSlider?.maximumValue = Float(a.seconds)
            self.timeLabel.text = "\(self.getTime(roundedSeconds: self.mainAudioVideo?.currentTime().seconds.rounded() ?? 0.0))/\(self.getTime(roundedSeconds: (self.mainAudioVideo?.currentItem?.asset.duration.seconds ?? 0.0).rounded()))"
        }
       
        if shoudHide5Sec {
            self.startCloseTimer(seconds: 5)
        }
        else {
            self.startCloseTimer()
        }
    }
  
    func pause(){
        print("pause)")
        self.stopBackground()
        self.mainAudioVideo?.pause()
        self.playPauseBtn.isSelected = false
        closeTimer?.invalidate()
        self.showControls()
    }
    
    @objc func appDidEnterBackground() {
       // self.pause()
        self.mainAudioVideo?.pause()
        self.stopBackground()
    }
    @objc func appDidEnterForeground() {
        DispatchQueue.main.async {
            if self.isStreaming {
                self.stopBackground()
                
                self.loadRemoteBackgroundAudioPlayers()
                
            }
            else {
                self.stopBackground()
               
                self.loadLocalBackgroundPlayers()
               
            }
     
      
        
            self.viewDidLayoutSubviews()
        

          
            self.playerLayer?.isHidden = false
            self.switchAudio()
        
        
            if self.playPauseBtn.isSelected {
                let seconds : Int64 = Int64(max((self.mainAudioVideo?.currentTime().seconds ?? 0) - 5, 0))
                let time:CMTime = CMTimeMake(value: seconds, timescale: 1)
                self.mainAudioVideo?.seek(to: time)
                self.mainAudioVideo?.play()
                self.playBackground()
            }
            
            if !self.isStreaming && self.mainAudioVideo?.currentTime().seconds.rounded() ?? 0.0 >= (self.mainAudioVideo?.currentItem?.asset.duration.seconds ?? 0.0).rounded(){
                self.closeClick()
            }
        }

    }
    @objc func playBackground(){
        DispatchQueue.main.async {
            self.mainAudioVideo?.play()
            self.firstAudio?.play()
            self.secondAudio?.play()
            self.thirdAudio?.play()
            
        
            self.switchAudio()
            
           
        }
      
    }
    func stopBackground(){
        self.firstAudio?.pause()
        self.secondAudio?.pause()
        self.thirdAudio?.pause()
    }
    
    @objc func switchVideoHandle(_ sender:UIPageControl){
        
        self.currentBackgroundVideoIndex = self.pageIndicator.currentPage
        
        self.switchAudio()
        
    }
    
    
    func switchAudio() {
        DispatchQueue.main.async {
            switch self.currentBackgroundVideoIndex {
            case 0:
                self.firstAudio?.volume = (1.0 - (self.audioSlider?.value ?? 0)) * 0.5
                self.secondAudio?.volume = 0
                self.thirdAudio?.volume = 0
                break
            case 1:
                self.firstAudio?.volume = 0
                self.secondAudio?.volume = (1.0 - (self.audioSlider?.value ?? 0)) * 0.5
                self.thirdAudio?.volume = 0
                break
            case 2:
                self.firstAudio?.volume = 0
                self.secondAudio?.volume = 0
                self.thirdAudio?.volume = (1.0 - (self.audioSlider?.value ?? 0)) * 0.5
                break
            default:
                break
            }
        }
       
    }
    
    @objc func skipIntro(sender:UIButton) {
        if self.secondsToSkip > 0 && self.mainAudioVideo?.status == .readyToPlay {
            let seconds : Int64 = Int64(self.secondsToSkip)
            let time:CMTime = CMTimeMake(value: seconds, timescale: 1)
            mainAudioVideo?.seek(to: time)
            self.watchedTime = self.secondsToSkip
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


