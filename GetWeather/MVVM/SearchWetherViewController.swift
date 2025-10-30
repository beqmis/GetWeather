//
//  SearchWetherViewController.swift
//  GetWeather
//
//  Created by Яков Демиденко on 10/28/25.
//

import Foundation
import UIKit
import SnapKit



class SearchWetherViewController: UIViewController, UISearchBarDelegate
{
    
    let searchBar:UISearchBar = UISearchBar()
    let searchTextField:UITextField = UITextField()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        self.searchBar.placeholder = "Search"
        self.searchBar.sizeToFit()
        self.searchBar.backgroundColor = .blue
        self.searchBar.delegate = self
        
        searchTextField.text? = "Moscow"
        searchTextField.backgroundColor = .green
        
        setupUI()
    }
    
    
    
    func setupUI()
    {
        view.addSubview(searchBar)
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }
        
        view.addSubview(searchTextField)
        searchTextField.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(8)
            make.left.equalToSuperview().inset(16)
            make.right.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }
        
    }
    
}
