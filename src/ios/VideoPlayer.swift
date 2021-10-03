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
        
        if let backgroundVideoURL = command.arguments[0] as? String, let audioArray = command.arguments[1] as? [String], let audioVoiceURL = command.arguments[2] as? String, let subtitleURL = command.arguments[3] as? String, let secondsToSkip = command.arguments[4] as? Int, let isLiked = command.arguments[5] as? Bool {
            
            //MARK: LOAD BREATHWORK VIDEOS FORM URL
            let playerViewController = MindfulnessViewController()
            playerViewController.loadBreathworkVideosFromURL(backgroundVideoURL:  backgroundVideoURL,
                                                             audioArray: audioArray,
                                                             audioVoiceURL: audioVoiceURL,
                                                             subtitleURL: subtitleURL,
                                                             secondsToSkip: secondsToSkip,
                                                             isLiked: isLiked)
                                                             { watchedTime, isLiked in
                                                                 print(watchedTime)
                                                                 print(isLiked)
                                                             }
            
            playerViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            self.viewController.present(playerViewController, animated: true, completion: nil)
            
            pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
            self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            
        } else {
            pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Missing input parameters")
            self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
        }
    }

    @objc(loadDeskercises:)
    func loadDeskercises(command: CDVInvokedUrlCommand) {
        var pluginResult = CDVPluginResult()

        if let videoArrayURL = command.arguments[0] as? [String], let videoArrayTitle = command.arguments[1] as? [String], let liked = command.arguments[2] as? Bool {
            
            //MARK: LOAD DESKERCISES VIDEOS FORM URL
            let playerViewController = DeskercisesViewController()
            playerViewController.loadDeskercisesVideosFromURL(videoArray: videoArrayURL, videoTitleArray: videoArrayTitle, isLiked: liked, callback: { (isLiked) in
                print(isLiked)
            })
            playerViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
                        self.viewController.present(playerViewController, animated: true, completion: nil)

            pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
            self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                        
        } else {
            pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Missing input parameters")
            self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
        }
    }
}
