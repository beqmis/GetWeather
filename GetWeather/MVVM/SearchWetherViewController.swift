//
//  SearchWetherViewController.swift
//  GetWeather
//
//  Created by Яков Демиденко on 10/28/25.
//

import Foundation
import UIKit
import SnapKit
import Combine

extension UITextField{
    var textPublisher:AnyPublisher<String,Never>{
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: self)
            .compactMap { $0.object as? UITextField }
            .map { $0.text ?? "" }
            .eraseToAnyPublisher()
    }
}


class SearchWetherViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell") ?? UITableViewCell(style: .default, reuseIdentifier: "cell")
        let location = viewModel.locations[indexPath.row]
        cell.textLabel?.text = location.currentAddress
        
        return cell
    }
    
    
    let searchTextField:UITextField = UITextField()
    let outputsTableView:UITableView = UITableView()
    
    private var cancellables = Set<AnyCancellable>()
    
    var viewModel = WeatherViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        searchTextField.text? = "Moscow"
        searchTextField.backgroundColor = .green
        
        outputsTableView.backgroundColor = .red
        
        
        setupUI()
        
        searchTextField.textPublisher
            .removeDuplicates()
            .sink { [weak self] text in
                // Handle text changes here, e.g., forward to view model
                // self?.viewModel.search(query: text)
                print("Search text:", text)
            }
            .store(in: &cancellables)
        
        viewModel.$locations
            .receive(on: DispatchQueue.main)
            .sink { [weak self] locations in
                print("Locations:", locations)
                self?.outputsTableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    
    
    func setupUI()
    {

        
        view.addSubview(searchTextField)
        searchTextField.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(100)
            make.left.equalToSuperview().inset(10)
            make.right.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }
        
        view.addSubview(outputsTableView)
        outputsTableView.snp.makeConstraints { make in
            make.top.equalTo(searchTextField.snp.bottom).offset(10)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
}
