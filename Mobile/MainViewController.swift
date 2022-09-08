//
//  ViewController.swift
//  Mobile
//
//  Created by Nadia on 06.09.2022.
//

import CoreData
import UIKit

var mobiles = [Mobile]()

final class MainViewController: UIViewController {
    
    
    private var collectionView: UICollectionView!
    var reuseIdentifier = "cell"
    lazy var data = DataStorage()

    lazy var titlelabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.black
        label.text = "Mobile Storage"
        label.font = .boldSystemFont(ofSize: 45)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        
        return label
    }()
    
    lazy var buttonAdd: UIButton = {
        let button = UIButton(type: .system)
        
        button.setTitle("Add", for: .normal)
        button.tintColor = UIColor.white
        button.backgroundColor = UIColor.black
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(newModel), for: .touchUpInside)
        return button
    }()
    
    lazy var buttonFindByIMEI: UIButton = {
        let button = UIButton(type: .system)
        
        button.setTitle("Find", for: .normal)
        button.tintColor = UIColor.white
        button.backgroundColor = UIColor.black
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(findByIMEI), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.gray
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(MainCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        data.getAll()
        view.addSubview(titlelabel)
        view.addSubview(buttonAdd)
        view.addSubview(buttonFindByIMEI)
        view.addSubview(collectionView)
    }
    
    override func viewWillLayoutSubviews() {
        self.collectionViewConstraints()
        self.titleLabelConstraints()
        self.buttonAddConstraints()
        self.buttonFindConstraints()
    }
    
    @objc func findByIMEI() {
        let alertController = UIAlertController(title: "Enter device IMEI", message: "Try to find", preferredStyle: .alert)
        alertController.addTextField()
        alertController.textFields?[0].placeholder = "IMEI"
        
        let addAction = UIAlertAction(title: "Find", style: .default) { [weak self] _ in
            guard let tf1 = alertController.textFields?[0] else { return }
            
            if tf1.text == "" {
                let errorAlert = UIAlertController(
                    title: "Add all fields",
                    message: "Please", preferredStyle: .alert
                )
                errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(errorAlert, animated: true)
            } else {
                if let device = self?.data.findByImei(tf1.text ?? "") {
                    let alertControllerResult = UIAlertController(
                        title: "Found device",
                        message: "Model - \(device.model ?? "")\nIMEI - \(device.imei ?? "") ",
                        preferredStyle: .alert
                    )
                    
                    alertControllerResult.addAction(UIAlertAction(title: "Ok", style: .default))
                    self?.present(alertControllerResult, animated: true)
                } else {
                    let alertControllerResult = UIAlertController(
                        title: "No device with that IMEI",
                        message: nil, preferredStyle:
                                .alert
                    )
                    
                    alertControllerResult.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(alertControllerResult, animated: true)
                }
            }
        }
        
        alertController.addAction(addAction)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .destructive))
        present(alertController, animated: true)
    }
    
    
    @objc func newModel() {
        
        let alertController = UIAlertController(title: "Create new mobile", message: "Write model", preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "Model"
        }
        
        alertController.addTextField { textField in
            textField.placeholder = "IMEI"
        }
        
        let createModel = UIAlertAction(title: "Create", style: .default) {
            action in
            guard let firstTextField = alertController.textFields?[0], let secondTextField = alertController.textFields?[1] else { return }
            
            if firstTextField.text == "" || secondTextField.text == "" {
                let errorAlert = UIAlertController(title: "Add all fields", message: "Please", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(errorAlert, animated: true)
            } else {
                do {
                    try self.data.createDevice(model: firstTextField.text ?? "", imei: secondTextField.text ?? "") { device in
                        let successAlert = UIAlertController(title: "Device added", message: "Model - \(firstTextField.text ?? "")\nIMEI - \(secondTextField.text ?? "")", preferredStyle: .alert)
                        successAlert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.data.getAll()
                        self.collectionView.reloadData()
                        self.present(successAlert, animated: true)
                    }
                } catch {
                    let error = UIAlertController(title: "Device already exist", message: nil, preferredStyle: .alert)
                    error.addAction(UIAlertAction(title: "Ok", style: .default))
                    self.present(error, animated: true)
                }
            }
        }
        alertController.addAction(createModel)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .destructive))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func buttonAddConstraints() {
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: buttonAdd, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 50),
            NSLayoutConstraint(item: buttonAdd, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: -20),
            NSLayoutConstraint(item: buttonAdd, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 30),
            NSLayoutConstraint(item: buttonAdd, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 60)])
    }
    
    func buttonFindConstraints() {
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: buttonFindByIMEI, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 50),
            NSLayoutConstraint(item: buttonFindByIMEI, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 20),
            NSLayoutConstraint(item: buttonFindByIMEI, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 30),
            NSLayoutConstraint(item: buttonFindByIMEI, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 60)])
    }
    
    func titleLabelConstraints() {
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: titlelabel, attribute: .top, relatedBy: .equal, toItem: buttonAdd, attribute: .top, multiplier: 1, constant: 50),
            NSLayoutConstraint(item: titlelabel, attribute: .bottom, relatedBy: .equal, toItem: collectionView, attribute: .top, multiplier: 1, constant: 10),
            NSLayoutConstraint(item: titlelabel, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: titlelabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50),
            NSLayoutConstraint(item: titlelabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 360)])
    }
    
    func collectionViewConstraints() {
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            collectionView.topAnchor.constraint(equalTo: titlelabel.lastBaselineAnchor, constant: 10),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)])
    }
}


extension MainViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        mobiles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? MainCollectionViewCell else { return MainCollectionViewCell()}
        
        let mobile = mobiles[indexPath.row]
        cell.textLabel.text = "Model - \(mobile.model ?? " ") \nIMEI - \(mobile.imei ?? " ")"
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let item = mobiles[indexPath.row]
        
        let alert = UIAlertController(title: "Edit", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive , handler:{ _ in
            do {
                try self.data.delete(item)
                let successAlert = UIAlertController(title: "Deleted", message: "Success", preferredStyle: .alert)
                successAlert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(successAlert, animated: true)
            } catch {
                let faultAlert = UIAlertController(title: "Nothing to delete", message: nil, preferredStyle: .alert)
                faultAlert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(faultAlert, animated: true)
            }
        }))
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        self.present(alert, animated: true)
        self.collectionView.reloadData()
    }
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.bounds.size.width - 20, height: 120)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets.init(top: 30, left: 0, bottom: 0, right: 0)
    }
}


