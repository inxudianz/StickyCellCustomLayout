//
//  ViewController.swift
//  CollectionLayout
//
//  Created by William Inx on 02/04/22.
//

import UIKit

final class ViewController: UIViewController {
    
    private lazy var button: UIButton = {
        let button: UIButton = UIButton()
        
        button.setTitle("open", for: .normal)
        button.backgroundColor = .brown
        button.addAction(.init(handler: { _ in
            self.buttonTapped()
        }), for: .touchUpInside)
        return button
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(button)
        view.addConstraints([
            .init(item: button, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0),
            .init(item: button, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0)
        ])
        button.translatesAutoresizingMaskIntoConstraints = false
        // Do any additional setup after loading the view.
    }
    
    func buttonTapped() {
        let vc = TestCollectionVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

