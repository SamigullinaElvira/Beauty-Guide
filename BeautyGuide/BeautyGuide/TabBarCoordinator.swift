//
//  TabBarCoordinator.swift
//  BeautyGuide
//
//  Created by Эльвира Самигуллина on 14.04.2023.
//

import UIKit

class TabBarCoordinator {
    weak var tabBarController: UITabBarController?

    func start() -> UIViewController {
        let tabBarController = UITabBarController()
        self.tabBarController = tabBarController
        self.tabBarController?.tabBar.tintColor = .black
        tabBarController.viewControllers = [
            search(),
            entries(),
            profile(),
        ]
        return tabBarController
    }
    
    private func search() -> UIViewController {
        let controller = UINavigationController(rootViewController: SearchViewController())

        controller.tabBarItem.setTitleTextAttributes([.foregroundColor: UIColor.gray], for: .normal)
        controller.tabBarItem.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
        
        controller.tabBarItem = .init(
            title: "Обзор",
            image: .init(systemName: "circle.grid.cross"),
            selectedImage: .init(systemName: "circle.grid.cross.fill")
        )
        return controller
    }
    
    private func entries() -> UIViewController {
        let controller = EntriesViewController()
        controller.tabBarItem = .init(
            title: "Записи",
            image: .init(systemName: "calendar"),
            selectedImage: .init(systemName: "calendar")
        )
        return controller
    }
    
    private func profile() -> UIViewController {
        let controller = ProfileViewController()
        controller.tabBarItem = .init(
            title: "Профиль",
            image: .init(systemName: "person"),
            selectedImage: .init(systemName: "person.fill")?.withTintColor(.black, renderingMode: .alwaysOriginal)
        )
        return controller
    }
}
