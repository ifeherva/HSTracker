//
//  WindowManager.swift
//  HSTracker
//
//  Created by Benjamin Michotte on 20/10/16.
//  Copyright © 2016 Benjamin Michotte. All rights reserved.
//

import Foundation
import CleanroomLogger

class WindowManager {
    static let `default` = WindowManager()

    static let cardWidth: CGFloat = {
        switch Settings.instance.cardSize {
        case .tiny: return CGFloat(kTinyFrameWidth)
        case .small: return CGFloat(kSmallFrameWidth)
        case .medium: return CGFloat(kMediumFrameWidth)
        case .big: return CGFloat(kFrameWidth)
        case .huge: return CGFloat(kHighRowFrameWidth)
        }
    }()
    static let screenFrame: NSRect = {
        return NSScreen.main()!.frame
    }()
    static let top: CGFloat = {
        return screenFrame.height - 50
    }()

    var playerTracker: Tracker = {
        $0.playerType = .player
        return $0
    }(Tracker(windowNibName: "Tracker"))

    var opponentTracker: Tracker = {
        $0.playerType = .opponent
        return $0
    }(Tracker(windowNibName: "Tracker"))

    var secretTracker: SecretTracker = {
        $0.window?.orderFront(nil)
        return $0
    }(SecretTracker(windowNibName: "SecretTracker"))
    
    var playerBoardDamage: BoardDamage = {
        $0.player = .player
        $0.window?.orderFront(nil)
        return $0
    }(BoardDamage(windowNibName: "BoardDamage"))

    var opponentBoardDamage: BoardDamage = {
        $0.player = .opponent
        $0.window?.orderFront(nil)
        return $0
    }(BoardDamage(windowNibName: "BoardDamage"))

    var timerHud: TimerHud = {
        $0.window?.orderFront(nil)
        return $0
    }(TimerHud(windowNibName: "TimerHud"))

    var floatingCard: FloatingCard = {
        $0.window?.orderFront(nil)
        return $0
    }(FloatingCard(windowNibName: "FloatingCard"))
    
    var cardHudContainer: CardHudContainer = {
        $0.window?.orderFront(nil)
        return $0
    }(CardHudContainer(windowNibName: "CardHudContainer"))
    
    var oracle: Oracle = {
        $0.window?.orderFront(nil)
        return $0
    }(Oracle(windowNibName: "Oracle"))

    private var lastCardsUpdateRequest = Date.distantPast.timeIntervalSince1970

    private init() {
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func startManager() {
        let events = [
            "show_floating_card": #selector(showFloatingCard(_:)),
            "hide_floating_card": #selector(hideFloatingCard(_:))
            ]

        for (event, selector) in events {
            NotificationCenter.default.addObserver(self,
                                                   selector: selector,
                                                   name: NSNotification.Name(rawValue: event),
                                                   object: nil)
        }

        let reload = ["window_locked", "show_player_tracker", "show_opponent_tracker",
                      "auto_position_trackers", "space_changed", "hearthstone_closed",
                      "hearthstone_running", "hearthstone_active", "hearthstone_deactived",
                      "can_join_fullscreen"]
        for event in reload {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(updateTrackersAfterEvent),
                                                   name: NSNotification.Name(rawValue: event),
                                                   object: nil)
        }

        updateTrackers()
        forceHideFloatingCard()
    }

    func isReady() -> Bool {
        return playerTracker.window != nil && opponentTracker.window != nil
    }

    func hideGameTrackers() {
        DispatchQueue.main.async { [weak self] in
            self?.secretTracker.window?.orderOut(nil)
            self?.timerHud.window?.orderOut(nil)
            self?.playerBoardDamage.window?.orderOut(nil)
            self?.opponentBoardDamage.window?.orderOut(nil)
            self?.cardHudContainer.reset()
            self?.oracle.window?.orderOut(nil)
        }
    }

    @objc private func updateTrackersAfterEvent() {
        let time = DispatchTime.now() + DispatchTimeInterval.seconds(2)
        DispatchQueue.main.asyncAfter(deadline: time) { [weak self] in
            SizeHelper.hearthstoneWindow.reload()
            self?.updateTrackers()
        }
    }

    // MARK: - Updating trackers
    func updateTrackers(reset: Bool = false) {
        lastCardsUpdateRequest = NSDate().timeIntervalSince1970
        let when = DispatchTime.now() + DispatchTimeInterval.milliseconds(110)
        DispatchQueue.main.asyncAfter(deadline: when) { [weak self] in
            guard let strongSelf = self else { return }
            guard Date().timeIntervalSince1970 - strongSelf.lastCardsUpdateRequest > 0.1 else {
                return
            }

            SizeHelper.hearthstoneWindow.reload()

            strongSelf.redrawTrackers(reset: reset)
        }
    }

    private func redrawTrackers(reset: Bool = false) {
        let settings = Settings.instance
        let game = Game.shared

        // timer
        if Settings.instance.showTimer && !game.gameEnded {
            show(controller: timerHud, show: true, frame: SizeHelper.timerHudFrame())
        } else {
            show(controller: timerHud, show: false)
        }

        // secret helper
        if settings.showSecretHelper {
            if let secrets = game.opponentSecrets, secrets.allSecrets().count > 0 {
                secretTracker.setSecrets(secrets: secrets.allSecrets())
                show(controller: secretTracker, show: true, frame: SizeHelper.secretTrackerFrame())
            } else {
                show(controller: secretTracker, show: false)
            }
        } else {
            show(controller: secretTracker, show: false)
        }

        // card hud
        if settings.showCardHuds {
            if !game.gameEnded {
                cardHudContainer.update(entities: game.opponent.hand,
                                        cardCount: game.opponent.handCount)
                show(controller: cardHudContainer, show: true,
                           frame: SizeHelper.cardHudContainerFrame())
            } else {
                show(controller: cardHudContainer, show: false)
            }
        } else {
            show(controller: cardHudContainer, show: false)
        }

        // board damage
        let board = BoardState()

        if settings.playerBoardDamage {
            if !game.gameEnded {
                playerBoardDamage.update(attack: board.player.damage)
                show(controller: playerBoardDamage, show: true,
                     frame: SizeHelper.playerBoardDamageFrame())
            } else {
                show(controller: playerBoardDamage, show: false)
            }
        } else {
            show(controller: playerBoardDamage, show: false)
        }

        if settings.opponentBoardDamage {
            if !game.gameEnded {
                opponentBoardDamage.update(attack: board.opponent.damage)
                show(controller: opponentBoardDamage, show: true,
                     frame: SizeHelper.opponentBoardDamageFrame())
            } else {
                show(controller: opponentBoardDamage, show: false)
            }
        } else {
            show(controller: opponentBoardDamage, show: false)
        }

        var rect: NSRect?

        if settings.showOpponentTracker {
            // opponent tracker
            let cards = settings.clearTrackersOnGameEnd && !game.gameEnded
                ? [] : game.opponent.opponentCardList
            opponentTracker.update(cards: cards, reset: reset)
            opponentTracker.setWindowSizes()

            if settings.autoPositionTrackers && Hearthstone.instance.isHearthstoneRunning {
                rect = SizeHelper.opponentTrackerFrame()
            } else {
                rect = Settings.instance.opponentTrackerFrame
                if rect == nil {
                    let x = WindowManager.screenFrame.origin.x + 50
                    rect = NSRect(x: x,
                                  y: WindowManager.top + WindowManager.screenFrame.origin.y,
                                  width: WindowManager.cardWidth,
                                  height: WindowManager.top)
                }
            }
            show(controller: opponentTracker, show: true, frame: rect, title: "Opponent tracker")
        } else {
            show(controller: opponentTracker, show: false)
        }

        // player tracker
        if settings.showPlayerTracker {
            playerTracker.update(cards: game.player.playerCardList, reset: reset)
            playerTracker.setWindowSizes()

            if settings.autoPositionTrackers && Hearthstone.instance.isHearthstoneRunning {
                rect = SizeHelper.playerTrackerFrame()
            } else {
                rect = settings.playerTrackerFrame
                if rect == nil {
                    let x = WindowManager.screenFrame.width - WindowManager.cardWidth
                        + WindowManager.screenFrame.origin.x
                    rect = NSRect(x: x,
                                  y: WindowManager.top + WindowManager.screenFrame.origin.y,
                                  width: WindowManager.cardWidth,
                                  height: WindowManager.top)
                }
            }
            show(controller: playerTracker, show: true, frame: rect, title: "Player tracker")
        } else {
            show(controller: playerTracker, show: false)
        }
        
        // Oracle
        show(controller: oracle, show: true)
    }

    // MARK: - Floating card
    var closeFloatingCardRequest = 0
    var closeRequestTimer: Timer?
    @objc func showFloatingCard(_ notification: Notification) {
        guard Settings.instance.showFloatingCard else { return }

        guard let card = notification.userInfo?["card"] as? Card,
            let arrayFrame = notification.userInfo?["frame"] as? [CGFloat] else {
                return
        }
        if closeRequestTimer != nil {
            closeRequestTimer?.invalidate()
            closeRequestTimer = nil
        }

        closeFloatingCardRequest += 1
        floatingCard.showWindow(self)
        let frame = NSRect(x: arrayFrame[0],
                           y: arrayFrame[1],
                           width: arrayFrame[2],
                           height: arrayFrame[3])
        
        floatingCard.window?.setFrame(frame, display: true)
        floatingCard.window?.level = Int(CGWindowLevelForKey(CGWindowLevelKey.mainMenuWindow)) - 1
        floatingCard.set(card: card)
        
        if let drawchancetop = notification.userInfo?["drawchancetop"] as? Float {
            floatingCard.setDrawChanceTop(chance: drawchancetop)
        } else {
            floatingCard.setDrawChanceTop(chance: 0)
        }
        
        if let drawchancetop = notification.userInfo?["drawchancetop2"] as? Float {
            floatingCard.setDrawChanceTop2(chance: drawchancetop)
        } else {
            floatingCard.setDrawChanceTop2(chance: 0)
        }

        closeRequestTimer = Timer.scheduledTimer(
            timeInterval: 3,
            target: self,
            selector: #selector(forceHideFloatingCard),
            userInfo: nil,
            repeats: false)
    }

    @objc func forceHideFloatingCard() {
        closeFloatingCardRequest = 0
        floatingCard.window?.orderOut(self)
        closeRequestTimer?.invalidate()
        closeRequestTimer = nil
    }

    @objc func hideFloatingCard(_ notification: Notification) {
        guard Settings.instance.showFloatingCard else { return }

        self.closeFloatingCardRequest -= 1
        let when = DispatchTime.now() + DispatchTimeInterval.milliseconds(100)
        let queue = DispatchQueue.main
        queue.asyncAfter(deadline: when) {
            if self.closeFloatingCardRequest > 0 {
                return
            }
            self.closeFloatingCardRequest = 0
            self.floatingCard.window?.orderOut(self)
            self.closeRequestTimer?.invalidate()
            self.closeRequestTimer = nil
        }
    }

    func showHideCardHuds(_ notification: Notification) {
        updateTrackers()
    }

    // MARK: - Utility functions
    private func show(controller: OverWindowController, show: Bool,
                      frame: NSRect? = nil, title: String? = nil) {
        guard let window = controller.window else { return }

        DispatchQueue.main.async {
            if show {
                // add the window in the "windows menu"
                if let title = title {
                    NSApp.addWindowsItem(window,
                                         title: NSLocalizedString(title, comment: ""),
                                         filename: false)
                    window.title = NSLocalizedString(title, comment: "")
                }

                // show window and set size
                if let frame = frame {
                    window.setFrame(frame, display: true)
                }

                // set the level of the window : over all if hearthstone is active
                // as a normal window otherwize
                let level: Int
                if Hearthstone.instance.hearthstoneActive {
                    level = Int(CGWindowLevelForKey(CGWindowLevelKey.mainMenuWindow)) - 1
                } else {
                    level = Int(CGWindowLevelForKey(CGWindowLevelKey.normalWindow))
                }
                window.level = level

                // if the setting is on, set the window behavior to join all workspaces
                if Settings.instance.canJoinFullscreen {
                    window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
                } else {
                    window.collectionBehavior = []
                }

                let locked = Settings.instance.windowsLocked
                if locked {
                    window.styleMask = [NSBorderlessWindowMask, NSNonactivatingPanelMask]
                } else {
                    window.styleMask = [NSTitledWindowMask, NSMiniaturizableWindowMask,
                                        NSResizableWindowMask, NSBorderlessWindowMask,
                                        NSNonactivatingPanelMask]
                }
                window.ignoresMouseEvents = locked

                window.orderFront(nil)
            } else {
                NSApp.removeWindowsItem(window)
                window.orderOut(nil)
            }
        }
    }
}
