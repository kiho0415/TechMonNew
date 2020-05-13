//
//  BattleViewController.swift
//  TechMonNew
//
//  Created by 森田貴帆 on 2020/05/13.
//  Copyright © 2020 森田貴帆. All rights reserved.
//

import UIKit

class BattleViewController: UIViewController {
    
    @IBOutlet var playerNameLabel:UILabel!
    @IBOutlet var playerImageView:UIImageView!
    @IBOutlet var playerHPLabel:UILabel!
    @IBOutlet var playerMPLabel:UILabel!
    @IBOutlet var playerTPLabel:UILabel!
    
    @IBOutlet var enemyNameLabel:UILabel!
    @IBOutlet var enemyImageView:UIImageView!
    @IBOutlet var enemyHPLabel:UILabel!
    @IBOutlet var enemyMPLabel:UILabel!
    
    let techMonManager = TechMonManager.shared
    
//    var playerHP = 100
//    var playerMP = 0
//    var enemyHP = 200
//    var enemyMP = 0
    
    var player: Character!
    var enemy: Character!
    
    var gameTimer: Timer!
    var isPlayerAttackAvailable: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        player = techMonManager.player
        enemy  = techMonManager.enemy
        playerNameLabel.text = "勇者"
        playerImageView.image = UIImage(named: "yusya.png")
        
        enemyNameLabel.text = "鍵"
        enemyImageView.image = UIImage(named: "monster.png")

        updateUI()
        
        gameTimer = Timer.scheduledTimer(timeInterval: 0.1,target: self,selector: #selector(updateGame),
                                         userInfo: nil, repeats: true)
        gameTimer.fire()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
           techMonManager.playBGM(fileName: "BGM_battle001")
    }
       
    override func viewWillDisappear(_ animated: Bool) {
           super.viewWillDisappear(animated)
           techMonManager.stopBGM()
    }

    @objc func updateGame(){
        player.currentMP += 1
        if player.currentMP >= player.maxMP{
            isPlayerAttackAvailable = true
            player.currentMP = player.maxMP //MPはmaxMP以上にならないようにしなきゃだから、currentMPがmaxMPを超えてもmaxMPをキーぷ
        }else{
            isPlayerAttackAvailable = false
        }
        
        enemy.currentMP += 1
        if enemy.currentMP >= enemy.maxMP{
            enemyAttack()
            enemy.currentMP = 0 //敵は自動で攻撃するから、攻撃のたびにcurrentMPを０に
        }

        updateUI()
    }
    
    func enemyAttack(){
        techMonManager.damageAnimation(imageView: playerImageView)
        techMonManager.playSE(fileName: "SE_attack")
        
        player.currentHP -= enemy.attackPoint
        updateUI()
        
        judgeBattle()
    }
    func finishBattle(vanishImageView: UIImageView, isPlayerwin: Bool){
        techMonManager.vanishAnimation(imageView: vanishImageView)
        techMonManager.stopBGM()
        gameTimer.invalidate()
        isPlayerAttackAvailable = false
        
        var finishingMessage: String = ""
        if isPlayerwin{
            techMonManager.playSE(fileName: "SE_fanfare")
            finishingMessage = "勇者の勝利！！"
        }else{
            techMonManager.playSE(fileName: "SE_gameover")
            finishingMessage = "勇者の敗北..."
        }
        
       let alert = UIAlertController(title: "バトル終了",message: finishingMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in self.dismiss(animated: true, completion: nil)
        }))
       present(alert, animated: true, completion: nil)
    }
    
    @IBAction func attackAction(){
        if isPlayerAttackAvailable{
            techMonManager.damageAnimation(imageView: enemyImageView)
            techMonManager.playSE(fileName: "SE_attack")
            
            enemy.currentHP -= player.attackPoint
            player.currentMP = 0
            
            updateUI()
            
            judgeBattle()
        }
    }
    //ステータスの反映メソッド
    func updateUI(){
        playerHPLabel.text = "\(player.currentHP) / \(player.maxHP) /"
        playerMPLabel.text = "\(player.currentMP) / \(player.maxMP) /"
        
        enemyHPLabel.text = "\(enemy.currentHP) / \(enemy.maxHP) /"
        enemyMPLabel.text = "\(enemy.currentMP) / \(enemy.maxMP) /"
    }
    
    //勝敗判定
    func judgeBattle(){
        if player.currentHP <= 0{
            finishBattle(vanishImageView: playerImageView, isPlayerwin: false)
        }else if enemy.currentHP <= 0{
            finishBattle(vanishImageView: enemyImageView, isPlayerwin: true)
        }
    }

}
