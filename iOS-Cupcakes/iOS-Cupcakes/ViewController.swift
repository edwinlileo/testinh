//
//  ViewController.swift
//  iOS-Cupcakes
//
//  Created by Edwin Liléo on 2020-04-17.
//  Copyright © 2020 Edwin Liléo. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    private var cupcakes = [Cupcake]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        fetchData()
    }
    
    func fetchData() {
        guard let url = URL(string: "http://localhost:8080/cupcakes") else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
                guard let data = data else {
                print("NO DATA GOT BACK")
                return
            }
            let decoder = JSONDecoder()
            if let cakes = try? decoder.decode([Cupcake].self, from: data) {
                DispatchQueue.main.async {
                    self.cupcakes = cakes
                    self.tableView.reloadData()
                    print("Loaded \(cakes.count) cupcakes")
                }
            } else {
                print("Unable to parse JSON response")
            }
        }
    .resume()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cupcakes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cake = cupcakes[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = "\(cake.name) - $\(cake.price)"
        cell.detailTextLabel?.text = "\(cake.describtion)"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cake = cupcakes[indexPath.row]
        var textField: UITextField?
        
        let alert = UIAlertController(title: "Order a \(cake.name)?", message: "Please enter your name", preferredStyle: .alert)
        alert.addTextField { (textfield) in
            textField = textfield
        }
        alert.addAction(.init(title: "Order", style: .default, handler: { (action) in
            if let byerName = textField?.text {
                self.order(cake, buyerName: byerName)
            }
        }))
        alert.addAction(.init(title: "Cancel", style: .cancel))
        self.present(alert, animated: true, completion: nil)
    }
    
    func order(_ cake: Cupcake, buyerName: String) {
        let order = Order(cakeName: cake.name, buyerName: buyerName)
        guard let url = URL(string: "http://localhost:8080/order") else { return }
        
        let encoder = JSONEncoder()
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? encoder.encode(order)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                let decoder = JSONDecoder()
                if let item = try? decoder.decode(Order.self, from: data) {
                    print(item.buyerName)
                } else {
                    print("Bad JSON recived back.")
                }
            }
        }.resume()
    }
}

