//
//  SceneDelegate.swift
//  BeautyGuide
//
//  Created by Эльвира Самигуллина on 30.03.2023.
//

import UIKit
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: scene)
        self.window = window
        window.makeKeyAndVisible()
        
        checkAuth()
    }
    
    public func checkAuth() {
        if Auth.auth().currentUser == nil {
            self.goToController(with: LoginViewController(), inNavigation: true)
        } else {
            let tabBarCoordinator = TabBarCoordinator()
            let vc = tabBarCoordinator.start()
            self.goToController(with: vc, inNavigation: true)
        }
    }
    
    private func goToController(with viewController: UIViewController, inNavigation: Bool) {
        DispatchQueue.main.async { [weak self] in
            UIView.animate(withDuration: 0.25) {
                self?.window?.layer.opacity = 0
            
            } completion: { [weak self] _ in
                
                if inNavigation {
                    let nav = UINavigationController(rootViewController: viewController)
                    nav.modalPresentationStyle = .fullScreen
                    self?.window?.rootViewController = nav
                } else {
                    self?.window?.rootViewController = viewController
                }
                
                UIView.animate(withDuration: 0.25) { [weak self] in
                    self?.window?.layer.opacity = 1
                }
            }
        }
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}

