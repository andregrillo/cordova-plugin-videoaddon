//
//  PlayerViewController.swift
//  OutsysVideoPOC
//
//  Created by WorldIT on 12/08/2021.
//

import UIKit
import AVKit
class MindfulnessViewController: UIViewController {

    private var audioVoice = AVPlayer()
    
    private var playerLayer:AVPlayerLayer?
    private var playerLayer2:AVPlayerLayer?
    private var playerLayer3:AVPlayerLayer?
    
    private var mainVideoLooper: AVPlayerLooper?
    private var mainVideo = AVQueuePlayer()
    private var mainAudio = AVQueuePlayer()
    private var mainAudioLooper: AVPlayerLooper?
   
    private var secondVideoLooper: AVPlayerLooper?
    private var secondVideo  = AVQueuePlayer()
    private var secondAudioLooper: AVPlayerLooper?
    private var secondAudio = AVQueuePlayer()
    
    
    private var thirdVideoLooper: AVPlayerLooper?
    private var thirdVideo  = AVQueuePlayer()
    private var thirdAudioLooper: AVPlayerLooper?
    private var thirdAudio = AVQueuePlayer()
       
    private var controlView:UIView!
    
    private var audioSlider:UISlider!{
        didSet{
            audioSlider?.transform = CGAffineTransform(rotationAngle: -.pi/2)
        }
    }
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

    private var currentBackgroundVideoIndex = 0
    private  var maxVideos = 0
    private var secondsToSkip = 0
    private var skipBtn:UIButton?
    private var timeLabel:UILabel!
    
    private var isMindfullness:Bool = true
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.playerLayer?.frame = self.view.bounds
        self.playerLayer2?.frame = self.view.bounds
        self.playerLayer3?.frame = self.view.bounds
        self.subtitleSwitch.layer.borderColor = UIColor.white.cgColor
        self.subtitleSwitch.layer.borderWidth = 1
        self.subtitleSwitch.layer.cornerRadius = self.subtitleSwitch.frame.height/2
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //avoids mute setting
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
        try? AVAudioSession.sharedInstance().setActive(true)
        
        watchedTimeTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (_) in
           
            if self.audioVoice.timeControlStatus == .playing {
                self.watchedTime += 1
              //  print("TIME \(self.watchedTime)")
            }
            
        })
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.watchedTimeTimer?.invalidate()
        self.closeTimer?.invalidate()
    }
    private func createScreen() {
        self.controlView = UIView()
        controlView?.translatesAutoresizingMaskIntoConstraints = false
        self.controlView?.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        self.view.addSubview(self.controlView!)
        
        NSLayoutConstraint(item: controlView!, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: controlView!, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: controlView!, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: controlView!, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0).isActive = true
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        

        //subtitle switch
        subtitleSwitch.setOn(true, animated: true)
        subtitleSwitch.translatesAutoresizingMaskIntoConstraints = false
        
        self.controlView.addSubview(subtitleSwitch)
        subtitleSwitch.bottomAnchor.constraint(equalTo: self.controlView.safeAreaLayoutGuide.bottomAnchor, constant: -100).isActive = true
        subtitleSwitch.trailingAnchor.constraint(equalTo: self.controlView.trailingAnchor, constant: -32).isActive = true
        subtitleSwitch.addTarget(self, action: #selector(subtitleSwitchValueDidChange(_:)), for: .valueChanged)
        subtitleSwitch.onTintColor = .white
        
        let subLabel = UILabel()
        subLabel.text = "Subtitles"
        subLabel.textColor = .white
        subLabel.translatesAutoresizingMaskIntoConstraints = false
        self.controlView.addSubview(subLabel)
        subLabel.centerYAnchor.constraint(equalTo: self.subtitleSwitch.centerYAnchor).isActive = true
        subLabel.trailingAnchor.constraint(equalTo: self.subtitleSwitch.leadingAnchor, constant: -16).isActive = true
        
        
        //play btn
        playPauseBtn.translatesAutoresizingMaskIntoConstraints = false
        playPauseBtn.tintColor = .white
        playPauseBtn.setImage(UIImage(named: "MPlayer_Play_2x"), for: .normal)
        playPauseBtn.setImage(UIImage(named: "MPlayer_Pause_2x"), for: .selected)
        self.controlView.addSubview(playPauseBtn)
        playPauseBtn.centerYAnchor.constraint(equalTo: self.controlView.centerYAnchor, constant: -70).isActive = true
        playPauseBtn.centerXAnchor.constraint(equalTo: self.controlView.centerXAnchor).isActive = true
        playPauseBtn.addTarget(self, action: #selector(playPauseClick(_:)), for: .touchUpInside)
        playPauseBtn.widthAnchor.constraint(equalToConstant: 45).isActive = true
        playPauseBtn.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        let moveForward = UIButton()
        moveForward.translatesAutoresizingMaskIntoConstraints = false
        moveForward.tintColor = .white
        moveForward.setImage(UIImage(named: "MPlayer_FWD_WithNum_2x"), for: .normal)
        moveForward.setTitle("", for: .normal)
        self.controlView.addSubview(moveForward)
        moveForward.widthAnchor.constraint(equalToConstant: 35).isActive = true
        moveForward.heightAnchor.constraint(equalToConstant: 35).isActive = true
        moveForward.addTarget(self, action: #selector(moveForwardClick(_:)), for: .touchUpInside)
        moveForward.centerYAnchor.constraint(equalTo: playPauseBtn.centerYAnchor).isActive = true
        moveForward.leadingAnchor.constraint(equalTo: playPauseBtn.trailingAnchor, constant: 30).isActive = true

        let moveBack = UIButton()
        moveBack.translatesAutoresizingMaskIntoConstraints = false
        moveBack.tintColor = .white
        moveBack.setImage(UIImage(named: "MPlayer_RWD_WithNum_2x"), for: .normal)
        moveBack.setTitle("", for: .normal)
        self.controlView.addSubview(moveBack)
        moveBack.widthAnchor.constraint(equalToConstant: 35).isActive = true
        moveBack.heightAnchor.constraint(equalToConstant: 35).isActive = true
        moveBack.addTarget(self, action: #selector(moveBackClick(_:)), for: .touchUpInside)
        moveBack.centerYAnchor.constraint(equalTo: playPauseBtn.centerYAnchor).isActive = true
        moveBack.trailingAnchor.constraint(equalTo: playPauseBtn.leadingAnchor, constant: -30).isActive = true
        
        pageIndicator = UIPageControl()
        pageIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.controlView.addSubview(pageIndicator!)
        pageIndicator.centerYAnchor.constraint(equalTo: self.playPauseBtn.centerYAnchor).isActive = true
        //audioSlider is rotated. center is width / 2
        pageIndicator.rightAnchor.constraint(equalTo: self.controlView.safeAreaLayoutGuide.rightAnchor, constant: -0).isActive = true
        pageIndicator.isUserInteractionEnabled = false
        
        let pagerTopIcon = UIImageView()
        pagerTopIcon.translatesAutoresizingMaskIntoConstraints = false
        self.controlView.addSubview(pagerTopIcon)
        
        pagerTopIcon.centerXAnchor.constraint(equalTo: self.pageIndicator.centerXAnchor).isActive = true
        pagerTopIcon.bottomAnchor.constraint(equalTo: self.pageIndicator.topAnchor, constant: -15).isActive = true
      
        pagerTopIcon.contentMode = .scaleAspectFit
        if isMindfullness {
            pagerTopIcon.image = UIImage(named: "backAndImg")
            pagerTopIcon.widthAnchor.constraint(equalToConstant: 35).isActive = true
            pagerTopIcon.heightAnchor.constraint(equalToConstant: 35).isActive = true
        }
        else {
            pagerTopIcon.image = UIImage(named: "soundIcon")
            pagerTopIcon.widthAnchor.constraint(equalToConstant: 25).isActive = true
            pagerTopIcon.heightAnchor.constraint(equalToConstant: 25).isActive = true
        }
        
        //audio slider
        audioSlider = UISlider()
        audioSlider.maximumValue = 1
        audioSlider.minimumValue = 0
        audioSlider.value = 0.5
        audioSlider.addTarget(self, action: #selector(sliderValueDidChange(_:)), for: .valueChanged)
        audioSlider.translatesAutoresizingMaskIntoConstraints = false
        audioSlider.tag = 1
        audioSlider.minimumTrackTintColor = .white
        audioSlider.maximumTrackTintColor = .lightGray
        
        self.controlView.addSubview(audioSlider!)
        audioSlider.centerYAnchor.constraint(equalTo: self.playPauseBtn.centerYAnchor).isActive = true
        //audioSlider is rotated. center is width / 2
        audioSlider.leftAnchor.constraint(equalTo: self.controlView.safeAreaLayoutGuide.leftAnchor, constant: -30).isActive = true
        
        audioSlider.widthAnchor.constraint(equalToConstant: 150).isActive = true
        audioSlider.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        
        //seekerSlider lider
        seekerSlider = UISlider()
        seekerSlider.maximumValue = 1
        seekerSlider.minimumValue = 0
        seekerSlider.value = 0
        seekerSlider.isContinuous = true
        seekerSlider.tintColor = .blue
        seekerSlider.tag = 2
        seekerSlider.addTarget(self, action: #selector(sliderValueDidChange(_:)), for: .valueChanged)
        seekerSlider.translatesAutoresizingMaskIntoConstraints = false
        seekerSlider.minimumTrackTintColor = .white
        seekerSlider.maximumTrackTintColor = .lightGray
        
        self.controlView?.addSubview(seekerSlider)
        
        seekerSlider.topAnchor.constraint(equalTo: self.playPauseBtn.bottomAnchor, constant: 120).isActive = true
        seekerSlider.trailingAnchor.constraint(equalTo: self.controlView.trailingAnchor, constant: -64).isActive = true
        seekerSlider.leadingAnchor.constraint(equalTo: self.controlView.leadingAnchor, constant: 64).isActive = true
        
        seekerSlider.heightAnchor.constraint(equalToConstant: 20).isActive = true
        seekerSlider.addTarget(self, action: #selector(sliderValueDidChange(_:)), for: .valueChanged)
        
        timeLabel = UILabel()
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.textColor = .white
        timeLabel.text = "0:00/0.00"
        self.controlView.addSubview(timeLabel)
        timeLabel.topAnchor.constraint(equalTo: self.seekerSlider.bottomAnchor, constant: 20).isActive = true
        timeLabel.centerXAnchor.constraint(equalTo: self.seekerSlider.centerXAnchor).isActive = true
       

        let audioSliderTopIcon = UIImageView()
        audioSliderTopIcon.translatesAutoresizingMaskIntoConstraints = false
        audioSliderTopIcon.image = UIImage(named: "personIcon")
        self.controlView.addSubview(audioSliderTopIcon)
        audioSliderTopIcon.centerXAnchor.constraint(equalTo: self.audioSlider.centerXAnchor).isActive = true
        audioSliderTopIcon.bottomAnchor.constraint(equalTo: self.audioSlider.topAnchor, constant: -80).isActive = true
        audioSliderTopIcon.widthAnchor.constraint(equalToConstant: 25).isActive = true
        audioSliderTopIcon.heightAnchor.constraint(equalToConstant: 25).isActive = true
        audioSliderTopIcon.contentMode = .scaleAspectFit
        
        let audioSliderBottomIcon = UIImageView()
        audioSliderBottomIcon.translatesAutoresizingMaskIntoConstraints = false
        audioSliderBottomIcon.image = UIImage(named: "soundIcon")
        self.controlView.addSubview(audioSliderBottomIcon)
        audioSliderBottomIcon.centerXAnchor.constraint(equalTo: self.audioSlider.centerXAnchor).isActive = true
        audioSliderBottomIcon.topAnchor.constraint(equalTo: self.audioSlider.bottomAnchor, constant: 80).isActive = true
        audioSliderBottomIcon.widthAnchor.constraint(equalToConstant: 25).isActive = true
        audioSliderBottomIcon.heightAnchor.constraint(equalToConstant: 25).isActive = true
        audioSliderBottomIcon.contentMode = .scaleAspectFit
        
        
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
        likeBtn.topAnchor.constraint(equalTo: self.controlView.safeAreaLayoutGuide.topAnchor, constant: 16).isActive = true
        likeBtn.leadingAnchor.constraint(equalTo: self.controlView.leadingAnchor, constant: 16).isActive = true

        
        let closeBtn = UIButton()
        closeBtn.translatesAutoresizingMaskIntoConstraints = false
        closeBtn.setImage(UIImage(named: "close_lighter"), for: .normal)
        closeBtn.backgroundColor = .clear
        closeBtn.setTitle("", for: .normal)
        self.controlView.addSubview(closeBtn)
        closeBtn.widthAnchor.constraint(equalToConstant: 35).isActive = true
        closeBtn.heightAnchor.constraint(equalToConstant: 35).isActive = true
        closeBtn.addTarget(self, action: #selector(closeClick), for: .touchUpInside)
        closeBtn.topAnchor.constraint(equalTo: self.controlView.safeAreaLayoutGuide.topAnchor, constant: 16).isActive = true
        closeBtn.trailingAnchor.constraint(equalTo: self.controlView.trailingAnchor, constant: -16).isActive = true
        
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
        
    }
    
  
    
    /// Loads videos passed in params with URLs.
    ///
    /// - Warning: The number os items in video array shoud be equal to the number os items un audioArray
    /// - Parameter videoArray: Array of string with background video url
    /// - Parameter audioArray: Array of string with background audio url
    /// - Parameter audioVoiceURL:String to the narration audio
    /// - Parameter subtitleURL:String to the subtitles file (.srt)
    /// - Parameter secondsToSkip: Number of seconds that the Skip Button should skip in the narration, if less or equals to 0 the button is hidden/disabled
    /// - Parameter isLiked: True of False if the video was previously liked
    /// - Parameter callback: Reference to the method to be called when the close button is pressed, should receive 2 params (Bool, Bool) meaning (true if watched more than 80%, isLiked)
    func loadMindfullnessVideosFromURL(videoArray:[String], audioArray:[String], audioVoiceURL:String, subtitleURL:String, secondsToSkip:Int, isLiked:Bool, callback:@escaping ((Bool, Bool)->())) {
        self.callback = callback
        self.watchedTime = 0
        self.isMindfullness = true
        self.createScreen()
        
        self.likeBtn.isSelected = isLiked
        
        self.maxVideos = videoArray.count
        self.pageIndicator.numberOfPages = videoArray.count
        self.secondsToSkip = secondsToSkip
        
        if secondsToSkip > 0 {
            self.addSkipButton()
        }
        //MARK: Main player setup
        let playerItem = AVPlayerItem(url: URL(string: videoArray[0])!)
        mainVideo = AVQueuePlayer(items: [playerItem])
        mainVideoLooper = AVPlayerLooper(player: mainVideo, templateItem: playerItem)
        let playerAudioItem = AVPlayerItem(url: URL(string: audioArray[0])!)
        mainAudio = AVQueuePlayer(items: [playerAudioItem])
        mainAudioLooper = AVPlayerLooper(player: mainAudio, templateItem: playerAudioItem)
        mainVideo.volume = 0
        mainAudio.automaticallyWaitsToMinimizeStalling = true
        
        //video player
        playerLayer = AVPlayerLayer(player: mainVideo)
        playerLayer?.videoGravity = .resizeAspectFill;
        self.view.layer.addSublayer(playerLayer!)
        
        //MARK: Second player setup
        if videoArray.count > 1 && audioArray.count > 1 {
            let pi2 = AVPlayerItem(url: URL(string: videoArray[1])!)
            secondVideo = AVQueuePlayer(items: [pi2])
            secondVideoLooper = AVPlayerLooper(player: secondVideo, templateItem: pi2)
            let pai2 = AVPlayerItem(url: URL(string: audioArray[1])!)
            secondAudio = AVQueuePlayer(items: [pai2])
            secondAudioLooper = AVPlayerLooper(player: secondAudio, templateItem: pai2)
            
            secondVideo.automaticallyWaitsToMinimizeStalling = true
            secondVideo.volume = 0
            secondAudio.automaticallyWaitsToMinimizeStalling = true
            
            //second video player
            playerLayer2 = AVPlayerLayer(player: secondVideo)
            playerLayer2?.isHidden = true
            playerLayer2?.videoGravity = .resizeAspectFill;
            self.view.layer.addSublayer(playerLayer2!)
            
        }
        
        //MARK: Third player setup
        if videoArray.count > 2 && audioArray.count > 2 {

            let pi3 = AVPlayerItem(url: URL(string: videoArray[2])!)
            thirdVideo = AVQueuePlayer(items: [pi3])
            thirdVideoLooper = AVPlayerLooper(player: thirdVideo, templateItem: pi3)
            let pai3 = AVPlayerItem(url: URL(string: audioArray[2])!)
            thirdAudio = AVQueuePlayer(items: [pai3])
            thirdAudioLooper = AVPlayerLooper(player: thirdAudio, templateItem: pai3)

            thirdVideo.automaticallyWaitsToMinimizeStalling = false
            thirdVideo.volume = 0
            thirdAudio.automaticallyWaitsToMinimizeStalling = false
            
            //third video player
            playerLayer3 = AVPlayerLayer(player: thirdVideo)
            playerLayer3?.isHidden = true
            playerLayer3?.videoGravity = .resizeAspectFill;
            self.view.layer.addSublayer(playerLayer3!)
        }
       
        self.view.bringSubviewToFront(self.controlView)
        
        //MARK: Audio voice setup
        if let url = URL(string:audioVoiceURL) {
            audioVoice = AVPlayer(url: url)
        }
        audioVoice.automaticallyWaitsToMinimizeStalling = true
        
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 1, preferredTimescale: timeScale)

        audioVoice.addPeriodicTimeObserver(forInterval: time, queue: .main) { (time) in
           
            self.timeLabel.text = "\(self.getTime(roundedSeconds: self.audioVoice.currentTime().seconds.rounded()))/\(self.getTime(roundedSeconds: (self.audioVoice.currentItem?.asset.duration.seconds ?? 0.0).rounded()))"
           
            print(time.seconds)
            if Int(time.seconds) <  Int((self.seekerSlider.maximumValue)) && !self.seekerSlider.isHighlighted {
                self.seekerSlider.setValue(Float(time.seconds), animated: true)
            }
            
            if Int(self.audioVoice.currentTime().seconds.rounded()) >= self.secondsToSkip {
                self.skipBtn?.isHidden = true
            }
          
        }

        audioVoice.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions(), context: nil)
        
        //MARK: Subtitle setup
        if let subUrl = URL(string:subtitleURL) {
            self.addSubtitles().open(fileFromRemote: subUrl, player: audioVoice)
        }
    }
    
    /// Loads videos passed in params from Data.
    /// Videos will be saved temporarily on the phone, videos will be saved as .mp4 and audios as .mp3
    ///
    /// - Warning: The number os items in video array shoud be equal to the number os items in audioArray
    /// - Parameter videoArray: Array of data with background video url
    /// - Parameter audioArray: Array of data with background audio url
    /// - Parameter audioVoiceData:Data to the narration audio
    /// - Parameter subtitleData:Data to the subtitles file (.srt)
    /// - Parameter secondsToSkip: Number of seconds that the Skip Button should skip in the narration, if less or equals to 0 the button is hidden/disabled
    /// - Parameter isLiked: True of False if the video was previously liked
    /// - Parameter callback: Reference to the method to be called when the close button is pressed, should receive 2 params (Bool, Bool) meaning (true if watched more than 80%, isLiked)
    func loadMindfullnessVideosFromData(videoArray:[Data], audioArray:[Data], audioVoiceData:Data, subtitleData:Data, secondsToSkip:Int, isLiked:Bool, callback:@escaping ((Bool, Bool)->())) {
        self.callback = callback
        self.watchedTime = 0
        self.isMindfullness = true
        self.createScreen()
        
        self.likeBtn.isSelected = isLiked
        
        self.maxVideos = videoArray.count
        self.pageIndicator.numberOfPages = videoArray.count
        self.secondsToSkip = secondsToSkip
        
        if secondsToSkip > 0 {
            self.addSkipButton()
        }
        
        //MARK: Main player setup
        
        try? videoArray[0].write(to: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("mainvideo.mp4"))
        try? audioArray[0].write(to: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("mainaudio.mp3"))
        let urlVideo = URL(fileURLWithPath: NSTemporaryDirectory() + "/mainvideo.mp4")
        let playerItem = AVPlayerItem(url: urlVideo)
        mainVideo = AVQueuePlayer(items: [playerItem])
        mainVideoLooper = AVPlayerLooper(player: mainVideo, templateItem: playerItem)
        mainVideo.volume = 0
        let urlAudio = URL(fileURLWithPath: NSTemporaryDirectory() + "/mainaudio.mp3")
        let playerAudioItem = AVPlayerItem(url: urlAudio)
        mainAudio = AVQueuePlayer(items: [playerAudioItem])
        mainAudioLooper = AVPlayerLooper(player: mainAudio, templateItem: playerAudioItem)
        mainAudio.automaticallyWaitsToMinimizeStalling = true
           
        //video player
        playerLayer = AVPlayerLayer(player: mainVideo)
        playerLayer?.videoGravity = .resizeAspectFill;
        self.view.layer.addSublayer(playerLayer!)
       
        
        //MARK: Second player setup
        if videoArray.count > 1 && audioArray.count > 1 {
            
            try? videoArray[1].write(to: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("secondvideo.mp4"))
            try? audioArray[1].write(to: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("secondaudio.mp3"))
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
            
            let urlAudio = URL(fileURLWithPath: NSTemporaryDirectory() + "/secondaudio.mp3")
            let pai2 = AVPlayerItem(url: urlAudio)
            secondAudio = AVQueuePlayer(items: [pai2])
            secondAudioLooper = AVPlayerLooper(player: secondAudio, templateItem: pai2)
            secondAudio.automaticallyWaitsToMinimizeStalling = true
            
            
        }
        //MARK: Third player setup
        if videoArray.count > 2 && audioArray.count > 2 {
            try? videoArray[2].write(to: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("thirdvideo.mp4"))
            try? audioArray[2].write(to: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("thirdaudio.mp3"))
            
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
            
            let urlAudio = URL(fileURLWithPath: NSTemporaryDirectory() + "/thirdaudio.mp3")
            let pai3 = AVPlayerItem(url: urlAudio)
            thirdAudio = AVQueuePlayer(items: [pai3])
            thirdAudioLooper = AVPlayerLooper(player: thirdAudio, templateItem: pai3)
            thirdAudio.automaticallyWaitsToMinimizeStalling = false
            
        }

        self.view.bringSubviewToFront(self.controlView)
        
        //MARK: Audio voice setup
        try? audioVoiceData.write(to: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("audiovoice.mp3"))
        let urlAudioVoice = URL(fileURLWithPath: NSTemporaryDirectory() + "/audiovoice.mp3")
        audioVoice = AVPlayer(url: urlAudioVoice)
        
        
        audioVoice.automaticallyWaitsToMinimizeStalling = false

        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 1, preferredTimescale: timeScale)

        audioVoice.addPeriodicTimeObserver(forInterval: time, queue: .main) { (time) in

            self.timeLabel.text = "\(self.getTime(roundedSeconds: self.audioVoice.currentTime().seconds.rounded()))/\(self.getTime(roundedSeconds: (self.audioVoice.currentItem?.asset.duration.seconds ?? 0.0).rounded()))"

            print(time.seconds)
            if Int(time.seconds) <  Int((self.seekerSlider.maximumValue)) && !self.seekerSlider.isHighlighted {
                self.seekerSlider.setValue(Float(time.seconds), animated: true)
            }

            if Int(self.audioVoice.currentTime().seconds.rounded()) >= self.secondsToSkip {
                self.skipBtn?.isHidden = true
            }
            
        }

        audioVoice.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions(), context: nil)

//        //MARK: Subtitle setup

        self.addSubtitles().open(fromData: subtitleData, player: audioVoice)
        
    }
    
    /// Loads videos passed in params with URLs.
    ///
    /// - Parameter backgroundVideoURL: String to the background video
    /// - Parameter audioArray: Array of string with background audio url
    /// - Parameter audioVoiceURL:String to the narration audio
    /// - Parameter subtitleURL:String to the subtitles file (.srt)
    /// - Parameter secondsToSkip: Number of seconds that the Skip Button should skip in the narration, if less or equals to 0 the button is hidden/disabled
    /// - Parameter isLiked: True of False if the video was previously liked
    /// - Parameter callback: Reference to the method to be called when the close button is pressed, should receive 2 params (Bool, Bool) meaning (true if watched more than 80%, isLiked)
    func loadBreathworkVideosFromURL(backgroundVideoURL:String, audioArray:[String], audioVoiceURL:String, subtitleURL:String, secondsToSkip:Int, isLiked:Bool, callback:@escaping ((Bool, Bool)->())) {
        self.callback = callback
        self.watchedTime = 0
        self.isMindfullness = false
        self.createScreen()
        
        self.likeBtn.isSelected = isLiked
        
        self.maxVideos = audioArray.count
        self.pageIndicator.numberOfPages = audioArray.count
        self.secondsToSkip = secondsToSkip
        
        if secondsToSkip > 0 {
            self.addSkipButton()
        }
        //MARK: Main player setup
        let playerItem = AVPlayerItem(url: URL(string: backgroundVideoURL)!)
        mainVideo = AVQueuePlayer(items: [playerItem])
        mainVideoLooper = AVPlayerLooper(player: mainVideo, templateItem: playerItem)
        let playerAudioItem = AVPlayerItem(url: URL(string: audioArray[0])!)
        mainAudio = AVQueuePlayer(items: [playerAudioItem])
        mainAudioLooper = AVPlayerLooper(player: mainAudio, templateItem: playerAudioItem)
        mainVideo.volume = 0
        mainAudio.automaticallyWaitsToMinimizeStalling = true
        
        //video player
        playerLayer = AVPlayerLayer(player: mainVideo)
        playerLayer?.videoGravity = .resizeAspectFill;
        self.view.layer.addSublayer(playerLayer!)
        
        //MARK: Second player setup
        if audioArray.count > 1 {

            let pai2 = AVPlayerItem(url: URL(string: audioArray[1])!)
            secondAudio = AVQueuePlayer(items: [pai2])
            secondAudioLooper = AVPlayerLooper(player: secondAudio, templateItem: pai2)
            secondAudio.automaticallyWaitsToMinimizeStalling = true
            
        }
        
        //MARK: Third player setup
        if audioArray.count > 2 {

            let pai3 = AVPlayerItem(url: URL(string: audioArray[2])!)
            thirdAudio = AVQueuePlayer(items: [pai3])
            thirdAudioLooper = AVPlayerLooper(player: thirdAudio, templateItem: pai3)

            thirdAudio.automaticallyWaitsToMinimizeStalling = false
            
        }
       
        self.view.bringSubviewToFront(self.controlView)
        
        //MARK: Audio voice setup
        if let url = URL(string:audioVoiceURL) {
            audioVoice = AVPlayer(url: url)
        }
        audioVoice.automaticallyWaitsToMinimizeStalling = true
        
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 1, preferredTimescale: timeScale)

        audioVoice.addPeriodicTimeObserver(forInterval: time, queue: .main) { (time) in
           
            self.timeLabel.text = "\(self.getTime(roundedSeconds: self.audioVoice.currentTime().seconds.rounded()))/\(self.getTime(roundedSeconds: (self.audioVoice.currentItem?.asset.duration.seconds ?? 0.0).rounded()))"
           
            print(time.seconds)
            if Int(time.seconds) <  Int((self.seekerSlider.maximumValue)) && !self.seekerSlider.isHighlighted {
                self.seekerSlider.setValue(Float(time.seconds), animated: true)
            }
            
            if Int(self.audioVoice.currentTime().seconds.rounded()) >= self.secondsToSkip {
                self.skipBtn?.isHidden = true
            }
          
        }

        audioVoice.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions(), context: nil)
        
        //MARK: Subtitle setup
        if let subUrl = URL(string:subtitleURL) {
            self.addSubtitles().open(fileFromRemote: subUrl, player: audioVoice)
        }
    }

    /// Loads videos passed in params from Data.
    /// Videos will be saved temporarily on the phone, videos will be saved as .mp4 and audios as .mp3
    ///
    /// - Parameter backgroundVideoData: Data to the background video
    /// - Parameter audioArray: Array of data with background audio url
    /// - Parameter audioVoiceData:Data to the narration audio
    /// - Parameter subtitleData:Data to the subtitles file (.srt)
    /// - Parameter secondsToSkip: Number of seconds that the Skip Button should skip in the narration, if less or equals to 0 the button is hidden/disabled
    /// - Parameter isLiked: True of False if the video was previously liked
    /// - Parameter callback: Reference to the method to be called when the close button is pressed, should receive 2 params (Bool, Bool) meaning (true if watched more than 80%, isLiked)
    func loadBreathworkVideosFromData(backgroundVideoData:Data, audioArray:[Data], audioVoiceData:Data, subtitleData:Data, secondsToSkip:Int, isLiked:Bool, callback:@escaping ((Bool, Bool)->())) {
        self.callback = callback
        self.watchedTime = 0
        self.isMindfullness = true
        self.createScreen()
        self.isMindfullness = false
        self.likeBtn.isSelected = isLiked
        
        self.maxVideos = audioArray.count
        self.pageIndicator.numberOfPages = audioArray.count
        self.secondsToSkip = secondsToSkip
        
        if secondsToSkip > 0 {
            self.addSkipButton()
        }
        
        //MARK: Main player setup
        
        try? backgroundVideoData.write(to: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("mainvideo.mp4"))
        try? audioArray[0].write(to: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("mainaudio.mp3"))
        let urlVideo = URL(fileURLWithPath: NSTemporaryDirectory() + "/mainvideo.mp4")
        let playerItem = AVPlayerItem(url: urlVideo)
        mainVideo = AVQueuePlayer(items: [playerItem])
        mainVideoLooper = AVPlayerLooper(player: mainVideo, templateItem: playerItem)
        mainVideo.volume = 0
        let urlAudio = URL(fileURLWithPath: NSTemporaryDirectory() + "/mainaudio.mp3")
        let playerAudioItem = AVPlayerItem(url: urlAudio)
        mainAudio = AVQueuePlayer(items: [playerAudioItem])
        mainAudioLooper = AVPlayerLooper(player: mainAudio, templateItem: playerAudioItem)
        mainAudio.automaticallyWaitsToMinimizeStalling = true
           
        //video player
        playerLayer = AVPlayerLayer(player: mainVideo)
        playerLayer?.videoGravity = .resizeAspectFill;
        self.view.layer.addSublayer(playerLayer!)
       
        
        //MARK: Second player setup
        if audioArray.count > 1 {
            try? audioArray[1].write(to: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("secondaudio.mp3"))
            
            let urlAudio = URL(fileURLWithPath: NSTemporaryDirectory() + "/secondaudio.mp3")
            let pai2 = AVPlayerItem(url: urlAudio)
            secondAudio = AVQueuePlayer(items: [pai2])
            secondAudioLooper = AVPlayerLooper(player: secondAudio, templateItem: pai2)
            secondAudio.automaticallyWaitsToMinimizeStalling = true
            
            
        }
        //MARK: Third player setup
        if audioArray.count > 2 {
            try? audioArray[2].write(to: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("thirdaudio.mp3"))
            
            let urlAudio = URL(fileURLWithPath: NSTemporaryDirectory() + "/thirdaudio.mp3")
            let pai3 = AVPlayerItem(url: urlAudio)
            thirdAudio = AVQueuePlayer(items: [pai3])
            thirdAudioLooper = AVPlayerLooper(player: thirdAudio, templateItem: pai3)
            thirdAudio.automaticallyWaitsToMinimizeStalling = false
            
        }

        self.view.bringSubviewToFront(self.controlView)
        
        //MARK: Audio voice setup
        try? audioVoiceData.write(to: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("audiovoice.mp3"))
        let urlAudioVoice = URL(fileURLWithPath: NSTemporaryDirectory() + "/audiovoice.mp3")
        audioVoice = AVPlayer(url: urlAudioVoice)
        
        
        audioVoice.automaticallyWaitsToMinimizeStalling = false

        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 1, preferredTimescale: timeScale)

        audioVoice.addPeriodicTimeObserver(forInterval: time, queue: .main) { (time) in

            self.timeLabel.text = "\(self.getTime(roundedSeconds: self.audioVoice.currentTime().seconds.rounded()))/\(self.getTime(roundedSeconds: (self.audioVoice.currentItem?.asset.duration.seconds ?? 0.0).rounded()))"

            print(time.seconds)
            if Int(time.seconds) <  Int((self.seekerSlider.maximumValue)) && !self.seekerSlider.isHighlighted {
                self.seekerSlider.setValue(Float(time.seconds), animated: true)
            }

            if Int(self.audioVoice.currentTime().seconds.rounded()) >= self.secondsToSkip {
                self.skipBtn?.isHidden = true
            }
            
        }

        audioVoice.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions(), context: nil)

//        //MARK: Subtitle setup

        self.addSubtitles().open(fromData: subtitleData, player: audioVoice)
        
    }
    
    private func addSkipButton() {
       
        skipBtn = UIButton()
        skipBtn?.translatesAutoresizingMaskIntoConstraints = false
        skipBtn?.setTitle("Skip intro", for: .normal)
        skipBtn?.setTitleColor(.white, for: .normal)
        skipBtn?.widthAnchor.constraint(equalToConstant: 80).isActive = true
        skipBtn?.heightAnchor.constraint(equalToConstant: 40).isActive = true
        skipBtn?.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        skipBtn?.addTarget(self, action: #selector(skipIntro(sender:)), for: .touchUpInside)
        self.controlView.addSubview(skipBtn!)
        skipBtn?.centerYAnchor.constraint(equalTo: self.subtitleSwitch.centerYAnchor).isActive = true
        skipBtn?.leadingAnchor.constraint(equalTo: self.controlView.leadingAnchor, constant: 32).isActive = true
        skipBtn?.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        skipBtn?.layer.cornerRadius = 20
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
        closeTimer?.invalidate()
        let maxTime = (self.audioVoice.currentItem?.asset.duration.seconds ?? 0.0).rounded()
        
        self.callback?(self.watchedTime >= (Int(maxTime) * 80 / 100), self.likeBtn.isSelected)
        
        if self.navigationController?.topViewController == self {
            self.navigationController?.popViewController(animated: true)
        }
        else {
            self.dismiss(animated: true, completion: nil)
        }

    }
    @objc func swipedScreenUp() {

        print("swipe up")
        self.currentBackgroundVideoIndex = (self.currentBackgroundVideoIndex  + 1) % self.maxVideos
        self.pageIndicator.currentPage = self.currentBackgroundVideoIndex
        
        if isMindfullness {
            self.switchVideo()
        }
        else {
            self.switchAudio()
        }
        
        if self.controlView.alpha == 1 {
            self.closeTimer?.invalidate()
            self.startCloseTimer()
        }
       
    }
    @objc func swipedScreenDown() {
     
        print("swipe down")
        print("current down \(self.currentBackgroundVideoIndex)")
        self.currentBackgroundVideoIndex = (self.currentBackgroundVideoIndex  - 1) % self.maxVideos
        print("after down \(self.currentBackgroundVideoIndex)")
        if self.currentBackgroundVideoIndex < 0{
            self.currentBackgroundVideoIndex = self.maxVideos - 1
        }
        self.pageIndicator.currentPage = self.currentBackgroundVideoIndex
        if isMindfullness {
            self.switchVideo()
        }
        else {
            self.switchAudio()
        }
         
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
    
    func startCloseTimer() {
        closeTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: { (_) in
            DispatchQueue.main.async {
                self.hideShowControls()
            }
        })
    }
    
    @objc func playerDidFinishPlaying(_ notification: Notification) {
        if audioVoice.currentTime() == audioVoice.currentItem?.duration {
            self.pause()
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

        let playerCurrentTime = CMTimeGetSeconds(audioVoice.currentTime())
        let time:CMTime = CMTimeMake(value: Int64(playerCurrentTime + 15), timescale: 1)
        audioVoice.seek(to: time)
        
        closeTimer?.invalidate()
        if self.playPauseBtn.isSelected {
            self.startCloseTimer()
        }
    }
    @objc func moveBackClick(_ sender:UIButton){
        let playerCurrentTime = CMTimeGetSeconds(audioVoice.currentTime())
        let time:CMTime = CMTimeMake(value: Int64(playerCurrentTime - 15), timescale: 1)
        audioVoice.seek(to: time)
        
        closeTimer?.invalidate()
        if self.playPauseBtn.isSelected {
            self.startCloseTimer()
        }
    }
    @objc func sliderValueDidChange(_ sender:UISlider){
        if sender.tag == 1 {
            audioVoice.volume = 1.0 - (audioSlider?.value ?? 0.0)
            
            switch self.currentBackgroundVideoIndex {
            case 0:
                self.mainAudio.volume = self.audioSlider?.value ?? 0
                self.secondAudio.volume = 0
                self.thirdAudio.volume = 0
                print(mainAudio.volume)
                break
            case 1:
                self.mainAudio.volume = 0
                self.secondAudio.volume = self.audioSlider?.value ?? 0
                self.thirdAudio.volume = 0
                print(secondAudio.volume)
                break
            case 2:
                self.mainAudio.volume = 0
                self.secondAudio.volume = 0
                self.thirdAudio.volume = self.audioSlider?.value ?? 0
                print(thirdAudio.volume)
                break
            default:
                break
            }
            
           
            print(audioVoice.volume)
        }
        else if sender.tag == 2 {
            let seconds : Int64 = Int64(sender.value)
            let time:CMTime = CMTimeMake(value: seconds, timescale: 1)
            audioVoice.seek(to: time)
            
          
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
        guard (object as? AVPlayer) == self.mainVideo || (object as? AVPlayer) == self.mainAudio || (object as? AVPlayer) == self.audioVoice  else {
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
                if player == audioVoice {
                    print("a")
                    self.audioVoice.preroll(atRate: 1) { (audioFinished2) in
                        print("a1 preroll \(audioFinished2)")
                        if audioFinished2 {
                            self.playPauseBtn.isSelected = true
                            self.play()
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
            case .none:
                break
            @unknown default:
                break
              }
          }
    }
    
    func play() {
        print("play")
        self.playBackground()
        self.audioVoice.play()
        self.audioVoice.volume = 1.0 - (self.audioSlider?.value ?? 0.0)
        if let a = audioVoice.currentItem?.asset.duration {
            seekerSlider?.maximumValue = Float(a.seconds)
            self.timeLabel.text = "\(self.getTime(roundedSeconds: self.audioVoice.currentTime().seconds.rounded()))/\(self.getTime(roundedSeconds: (self.audioVoice.currentItem?.asset.duration.seconds ?? 0.0).rounded()))"
        }
       
        self.hideControls()
    }
  
    func pause(){
        print("pause)")
        self.stopBackground()
        self.audioVoice.pause()
        self.playPauseBtn.isSelected = false
        closeTimer?.invalidate()
        self.showControls()
    }
    
    func playBackground(){
        DispatchQueue.main.async {
            self.mainVideo.play()
            self.mainAudio.play()
            self.secondVideo.play()
            self.secondAudio.play()
            self.thirdVideo.play()
            self.thirdAudio.play()
            
            if self.isMindfullness {
                self.switchVideo()
            }
            else {
                self.switchAudio()
            }
           
        }
      
    }
    func stopBackground(){
        self.mainVideo.pause()
        self.mainAudio.pause()
        self.secondVideo.pause()
        self.secondAudio.pause()
        self.thirdVideo.pause()
        self.thirdAudio.pause()
    }
    
    func switchVideo() {
        DispatchQueue.main.async {
            switch self.currentBackgroundVideoIndex {
            case 0:
                self.playerLayer?.isHidden = false
                self.playerLayer2?.isHidden = true
                self.playerLayer3?.isHidden = true
                self.mainAudio.volume = self.audioSlider?.value ?? 0
                self.secondAudio.volume = 0
                self.thirdAudio.volume = 0
                break
            case 1:
                self.playerLayer?.isHidden = true
                self.playerLayer2?.isHidden = false
                self.playerLayer3?.isHidden = true
                self.mainAudio.volume = 0
                self.secondAudio.volume = self.audioSlider?.value ?? 0
                self.thirdAudio.volume = 0
                break
            case 2:
                self.playerLayer?.isHidden = true
                self.playerLayer2?.isHidden = true
                self.playerLayer3?.isHidden = false
                self.mainAudio.volume = 0
                self.secondAudio.volume = 0
                self.thirdAudio.volume = self.audioSlider?.value ?? 0
                break
            default:
                break
            }
        }
       
    }
    
    func switchAudio() {
        DispatchQueue.main.async {
            switch self.currentBackgroundVideoIndex {
            case 0:
                self.mainAudio.volume = self.audioSlider?.value ?? 0
                self.secondAudio.volume = 0
                self.thirdAudio.volume = 0
                break
            case 1:
                self.mainAudio.volume = 0
                self.secondAudio.volume = self.audioSlider?.value ?? 0
                self.thirdAudio.volume = 0
                break
            case 2:
                self.mainAudio.volume = 0
                self.secondAudio.volume = 0
                self.thirdAudio.volume = self.audioSlider?.value ?? 0
                break
            default:
                break
            }
        }
       
    }
    
    @objc func skipIntro(sender:UIButton) {
        if self.secondsToSkip > 0 && self.audioVoice.status == .readyToPlay {
            let seconds : Int64 = Int64(self.secondsToSkip)
            let time:CMTime = CMTimeMake(value: seconds, timescale: 1)
            audioVoice.seek(to: time)
            self.watchedTime = self.secondsToSkip
        }
    }
}

