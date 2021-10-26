//
//  VideoPlayer.swift
//  VideoPlayer
//
//  Created by Andre Grillo on 28/09/2021.
//

import Foundation

@objc(VideoPlayer) class VideoPlayer: CDVPlugin {
    
    @objc(loadMindfullness:)
    func loadMindfullness(command: CDVInvokedUrlCommand) {
        var pluginResult = CDVPluginResult()
        
        if let videoArray = command.arguments[0] as? [String], let audioArray = command.arguments[1] as? [String], let audioVoiceURL = command.arguments[2] as? String, let subtitleURL = command.arguments[3] as? String, let secondsToSkip = command.arguments[4] as? Int, let isLiked = command.arguments[5] as? Bool {
            
            let playerViewController = MindfulnessViewController()
            playerViewController.loadMindfullnessVideosFromURL(videoArray:  videoArray,
                                                               audioArray: audioArray,
                                                               audioVoiceURL: audioVoiceURL,
                                                               subtitleURL: subtitleURL,
                                                               secondsToSkip: secondsToSkip,
                                                               isLiked: isLiked)
            { watchedTime, isLiked in
                playerViewController.dismiss(animated: false, completion: nil)
                let returnDictionary = ["watchedTime": watchedTime, "isLiked": isLiked]
                if let jsonData = try? JSONSerialization.data( withJSONObject: returnDictionary, options: .prettyPrinted),
                   let json = String(data: jsonData, encoding: String.Encoding.ascii) {
                    pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: json)
                    self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                }
                else {
                    pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Error trying to serialize watchedTime and isLiked")
                    self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                }
            }
            
            playerViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            self.viewController.present(playerViewController, animated: false, completion: nil)
            
            pluginResult!.setKeepCallbackAs(true)
            
        } else {
            pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Missing input parameters")
            self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
        }
        
    }
    
    @objc(loadBreathwork:)
    func loadBreathwork(command: CDVInvokedUrlCommand) {
        var pluginResult = CDVPluginResult()
        
        if let backgroundVideoURL = command.arguments[0] as? String, let audioArray = command.arguments[1] as? [String], let audioVoiceURL = command.arguments[2] as? String, let subtitleURL = command.arguments[3] as? String, let secondsToSkip = command.arguments[4] as? Int, let isLiked = command.arguments[5] as? Bool {
            
            let playerViewController = MindfulnessViewController()
            playerViewController.loadBreathworkVideosFromURL(backgroundVideoURL:  backgroundVideoURL,
                                                             audioArray: audioArray,
                                                             audioVoiceURL: audioVoiceURL,
                                                             subtitleURL: subtitleURL,
                                                             secondsToSkip: secondsToSkip,
                                                             isLiked: isLiked)
            { watchedTime, isLiked in
                playerViewController.dismiss(animated: false, completion: nil)
                let returnDictionary = ["watchedTime": watchedTime, "isLiked": isLiked]
                if let jsonData = try? JSONSerialization.data( withJSONObject: returnDictionary, options: .prettyPrinted),
                   let json = String(data: jsonData, encoding: String.Encoding.ascii) {
                    pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: json)
                    self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                }
                else {
                    pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Error trying to serialize watchedTime and isLiked")
                    self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                }
            }
            
            playerViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            self.viewController.present(playerViewController, animated: false, completion: nil)
            
            pluginResult!.setKeepCallbackAs(true)
            
        } else {
            pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Missing input parameters")
            self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
        }
    }
    
    @objc(loadDeskercises:)
    func loadDeskercises(command: CDVInvokedUrlCommand) {
        var pluginResult = CDVPluginResult()
        
        if let videoArrayURL = command.arguments[0] as? [String], let videoArrayTitle = command.arguments[1] as? [String], let liked = command.arguments[2] as? Bool {
            
            let playerViewController = DeskercisesViewController()
            playerViewController.loadDeskercisesVideosFromURL(videoArray: videoArrayURL, videoTitleArray: videoArrayTitle, isLiked: liked, callback: { (isLiked) in
                playerViewController.dismiss(animated: false, completion: nil)
                let returnDictionary = ["isLiked": isLiked]
                if let jsonData = try? JSONSerialization.data( withJSONObject: returnDictionary, options: .prettyPrinted),
                   let json = String(data: jsonData, encoding: String.Encoding.ascii) {
                    pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: json)
                    self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                }
                else {
                    pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Error trying to serialize watchedTime and isLiked")
                    self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                }
            })
            playerViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            self.viewController.present(playerViewController, animated: false, completion: nil)
            
            pluginResult!.setKeepCallbackAs(true)
            
        } else {
            pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Missing input parameters")
            self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
        }
    }
    
    @objc(loadMindfullnessVideosFromData:)
    func loadMindfullnessVideosFromData(command: CDVInvokedUrlCommand) {
        var pluginResult = CDVPluginResult()
        let libraryDirectory = try! FileManager.default.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        if let videoArray = command.arguments[0] as? [String], let audioArray = command.arguments[1] as? [String], let voice = command.arguments[2] as? String, let subtitle = command.arguments[3] as? String, let secondsToSkip = command.arguments[4] as? Int, let isLiked = command.arguments[5] as? Bool {
            
            var videoDataArray = [Data]()
            //Loads local Video files into array as Data Objects
            for video in videoArray {
                let videoURL: URL = {
                    var url: URL!
                    do {
                        let path = try FileManager.default.subpathsOfDirectory(atPath: "\(libraryDirectory.path)/NoCloud/Files/\(video)").first!
                        if let urlPath = URL(string: path) {
                            url = urlPath
                        } else {
                            pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Error creating local directory using \(video) as input")
                            self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                        }
                    } catch {
                        pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Could not locate the local Files directory")
                        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                    }
                    return url
                }()
                if FileManager.default.fileExists(atPath: videoURL.path){
                    do {
                        let videoData = try Data.init(contentsOf: videoURL)
                        videoDataArray.append(videoData)
                    } catch {
                        pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Local video file \(video) not found")
                        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                    }
                }
            }
            
            var audioDataArray = [Data]()
            //Loads local audio files into array as Data Objects
            for audio in audioArray {
                let audioURL: URL = {
                    var url: URL!
                    do {
                        let path = try FileManager.default.subpathsOfDirectory(atPath: "\(libraryDirectory.path)/NoCloud/Files/\(audio)").first!
                        if let urlPath = URL(string: path) {
                            url = urlPath
                        } else {
                            pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Error creating local directory using \(audio) as input")
                            self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                        }
                    } catch {
                        pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Could not locate the local Files directory")
                        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                    }
                    return url
                }()
                if FileManager.default.fileExists(atPath: audioURL.path){
                    do {
                        let audioData = try Data.init(contentsOf: audioURL)
                        audioDataArray.append(audioData)
                    } catch {
                        pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Local audio file \(audio) not found")
                        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                    }
                }
            }
            
            var voiceData = Data()
            let audioVoiceURL: URL = {
                var url: URL!
                do {
                    let path = try FileManager.default.subpathsOfDirectory(atPath: "\(libraryDirectory.path)/NoCloud/Files/\(voice)").first!
                    if let urlPath = URL(string: path) {
                        url = urlPath
                    } else {
                        pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Error creating local directory using \(voice) as input")
                        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                    }
                } catch {
                    pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Could not locate the local Files directory")
                    self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                }
                return url
            }()
            if FileManager.default.fileExists(atPath: audioVoiceURL.path){
                do {
                    voiceData = try Data.init(contentsOf: audioVoiceURL)
                } catch {
                    pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Local voice audio file \(voice) not found")
                    self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                }
            }
            
            var subtitleData = Data()
            let subtitleURL: URL = {
                var url: URL!
                do {
                    let path = try FileManager.default.subpathsOfDirectory(atPath: "\(libraryDirectory.path)/NoCloud/Files/\(subtitle)").first!
                    if let urlPath = URL(string: path) {
                        url = urlPath
                    } else {
                        pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Error creating local directory using \(subtitle) as input")
                        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                    }
                } catch {
                    pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Could not locate the local Files directory")
                    self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                }
                return url
            }()
            if FileManager.default.fileExists(atPath: subtitleURL.path){
                do {
                    subtitleData = try Data.init(contentsOf: subtitleURL)
                } catch {
                    pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Local subtitle file \(subtitle) not found")
                    self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                }
            }
            
            let playerViewController = MindfulnessViewController()
            playerViewController.loadMindfullnessVideosFromData(videoArray:  videoDataArray,
                                                                audioArray: audioDataArray,
                                                                audioVoiceData: voiceData,
                                                                subtitleData: subtitleData,
                                                                secondsToSkip: secondsToSkip,
                                                                isLiked: isLiked)
            { watchedTime, isLiked in
                playerViewController.dismiss(animated: false, completion: nil)
                let returnDictionary = ["watchedTime": watchedTime, "isLiked": isLiked]
                if let jsonData = try? JSONSerialization.data( withJSONObject: returnDictionary, options: .prettyPrinted),
                   let json = String(data: jsonData, encoding: String.Encoding.ascii) {
                    pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: json)
                    self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                }
                else {
                    pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Error trying to serialize watchedTime and isLiked")
                    self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                }
            }
            
            playerViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            self.viewController.present(playerViewController, animated: false, completion: nil)
            
            pluginResult!.setKeepCallbackAs(true)
        } else {
            pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Missing input parameters")
            self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
        }
    }
    
    @objc(loadBreathworkFromData:)
    func loadBreathworkFromData(command: CDVInvokedUrlCommand) {
        var pluginResult = CDVPluginResult()
        let libraryDirectory = try! FileManager.default.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        if let backgroundVideoFile = command.arguments[0] as? String, let audioArray = command.arguments[1] as? [String], let audioVoiceFile = command.arguments[2] as? String, let subtitleFile = command.arguments[3] as? String, let secondsToSkip = command.arguments[4] as? Int, let isLiked = command.arguments[5] as? Bool {
            
            var backgroundVideoData = Data()
            let backgroundVideoURL: URL = {
                var url: URL!
                do {
                    let path = try FileManager.default.subpathsOfDirectory(atPath: "\(libraryDirectory.path)/NoCloud/Files/\(backgroundVideoFile)").first!
                    if let urlPath = URL(string: path) {
                        url = urlPath
                    } else {
                        pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Error creating local directory using \(backgroundVideoFile) as input")
                        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                    }
                } catch {
                    pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Could not locate the local Files directory")
                    self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                }
                return url
            }()
            if FileManager.default.fileExists(atPath: backgroundVideoURL.path){
                do {
                    backgroundVideoData = try Data.init(contentsOf: backgroundVideoURL)
                    
                } catch {
                    pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Local video file \(backgroundVideoFile) not found")
                    self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                }
            }
            //            }
            
            var audioDataArray = [Data]()
            //Loads local audio files into array as Data Objects
            for audio in audioArray {
                let audioURL: URL = {
                    var url: URL!
                    do {
                        let path = try FileManager.default.subpathsOfDirectory(atPath: "\(libraryDirectory.path)/NoCloud/Files/\(audio)").first!
                        if let urlPath = URL(string: path) {
                            url = urlPath
                        } else {
                            pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Error creating local directory using \(audio) as input")
                            self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                        }
                    } catch {
                        pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Could not locate the local Files directory")
                        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                    }
                    return url
                }()
                if FileManager.default.fileExists(atPath: audioURL.path){
                    do {
                        let audioData = try Data.init(contentsOf: audioURL)
                        audioDataArray.append(audioData)
                    } catch {
                        pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Local audio file \(audio) not found")
                        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                    }
                }
            }
            
            var voiceData = Data()
            let audioVoiceURL: URL = {
                var url: URL!
                do {
                    let path = try FileManager.default.subpathsOfDirectory(atPath: "\(libraryDirectory.path)/NoCloud/Files/\(audioVoiceFile)").first!
                    if let urlPath = URL(string: path) {
                        url = urlPath
                    } else {
                        pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Error creating local directory using \(audioVoiceFile) as input")
                        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                    }
                } catch {
                    pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Could not locate the local Files directory")
                    self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                }
                return url
            }()
            if FileManager.default.fileExists(atPath: audioVoiceURL.path){
                do {
                    voiceData = try Data.init(contentsOf: audioVoiceURL)
                } catch {
                    pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Local voice audio file \(audioVoiceFile) not found")
                    self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                }
            }
            
            var subtitleData = Data()
            let subtitleURL: URL = {
                var url: URL!
                do {
                    let path = try FileManager.default.subpathsOfDirectory(atPath: "\(libraryDirectory.path)/NoCloud/Files/\(subtitleFile)").first!
                    if let urlPath = URL(string: path) {
                        url = urlPath
                    } else {
                        pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Error creating local directory using \(subtitleFile) as input")
                        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                    }
                } catch {
                    pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Could not locate the local Files directory")
                    self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                }
                return url
            }()
            if FileManager.default.fileExists(atPath: subtitleURL.path){
                do {
                    subtitleData = try Data.init(contentsOf: subtitleURL)
                } catch {
                    pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Local subtitle file \(subtitleFile) not found")
                    self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                }
            }
            
            let playerViewController = MindfulnessViewController()
            playerViewController.loadBreathworkVideosFromData(backgroundVideoData: backgroundVideoData,
                                                              audioArray: audioDataArray,
                                                              audioVoiceData: voiceData,
                                                              subtitleData: subtitleData,
                                                              secondsToSkip: secondsToSkip,
                                                              isLiked: isLiked)
            { watchedTime, isLiked in
                playerViewController.dismiss(animated: false, completion: nil)
                let returnDictionary = ["watchedTime": watchedTime, "isLiked": isLiked]
                if let jsonData = try? JSONSerialization.data( withJSONObject: returnDictionary, options: .prettyPrinted),
                   let json = String(data: jsonData, encoding: String.Encoding.ascii) {
                    pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: json)
                    self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                }
                else {
                    pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Error trying to serialize watchedTime and isLiked")
                    self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                }
            }
            
            playerViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            self.viewController.present(playerViewController, animated: false, completion: nil)
            
            pluginResult!.setKeepCallbackAs(true)
        } else {
            pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Missing input parameters")
            self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
        }
        
    }
    
    @objc(loadDeskercisesFromData:)
    func loadDeskercisesFromData(command: CDVInvokedUrlCommand) {
        var pluginResult = CDVPluginResult()
        let libraryDirectory = try! FileManager.default.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        if let videoFilesArray = command.arguments[0] as? [String], let videoArrayTitle = command.arguments[1] as? [String], let liked = command.arguments[2] as? Bool {
            
            var videoDataArray = [Data]()
            //Loads local Video files into array as Data Objects
            for video in videoFilesArray {
                let videoURL: URL = {
                    var url: URL!
                        let path = "file://\(libraryDirectory.path)/NoCloud/Files/\(video)"
                        if let urlPath = URL(string: path) {
                            url = urlPath
                        } else {
                            pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Error creating local directory using \(video) as input")
                            self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                        }
                    return url
                }()
                if FileManager.default.fileExists(atPath: videoURL.path){
                    do {
                        let videoData = try Data.init(contentsOf: videoURL)
                        videoDataArray.append(videoData)
                    } catch {
                        print(">>> Error: \(error.localizedDescription)")
                        pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Local video file \(video) not found")
                        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                    }
                }
            }
            
            let playerViewController = DeskercisesViewController()
            playerViewController.loadDeskercisesVideosFromData(videoArray: videoDataArray,
                                                               videoTitleArray: videoArrayTitle,
                                                               isLiked: liked)
            { isLiked in
                playerViewController.dismiss(animated: false, completion: nil)
                let returnDictionary = ["isLiked": isLiked]
                if let jsonData = try? JSONSerialization.data( withJSONObject: returnDictionary, options: .prettyPrinted),
                   let json = String(data: jsonData, encoding: String.Encoding.ascii) {
                    pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: json)
                    self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                }
                else {
                    pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Error trying to serialize watchedTime and isLiked")
                    self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                }
            }
            
            playerViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            self.viewController.present(playerViewController, animated: false, completion: nil)
            
            pluginResult!.setKeepCallbackAs(true)
        } else {
            pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Missing input parameters")
            self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
        }
    }
}
