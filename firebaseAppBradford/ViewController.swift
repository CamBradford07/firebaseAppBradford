//
//  ViewController.swift
//  firebaseAppBradford
//
//  Created by CAMERON BRADFORD on 2/10/25.
//

import UIKit
import FirebaseDatabase
import FirebaseCore

class Employee{
    var ref = Database.database().reference()
    var name : String
    var position : String
    var salary : Int
    var key = ""
    
    init(name: String, position: String, salary: Int) {
        self.name = name
        self.position = position
        self.salary = salary
    }
    
    init(dict: Dictionary<String, Any>){
        if let salary = dict["salary"] as? Int{
            self.salary = salary
        }
        else{
            salary = 0
        }
        if let name = dict["name"] as? String{
            self.name = name
        }
        else{
            name = "unknown"
        }
        if let position = dict["position"] as? String{
            self.position = position
        }
        else{
            position = "Not Available"
        }
    }
    
    func saveToFirebase(){
        let dict = ["name": name, "position":position, "salary":salary] as [String: Any]
        ref.child("employees").childByAutoId().setValue(dict)
        key = ref.child("employees").childByAutoId().key ?? "0"
    }
    
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    

    @IBOutlet weak var nameFieldOutlet: UITextField!
    
    @IBOutlet weak var positionFieldOutlet: UITextField!
    
    @IBOutlet weak var salaryFieldOutlet: UITextField!
    
    @IBOutlet weak var employeeTableViewOutlet: UITableView!
    
    var ref: DatabaseReference!
    
    var employees = [Employee]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
        employeeTableViewOutlet.dataSource = self
        employeeTableViewOutlet.delegate = self
        
        ref.child("employees").observe(.childAdded, with: { (snapshot) in
                   // snapshot is a dictionary with a key and a dictionary as a value
                    // this gets the dictionary from each snapshot
                    let dict = snapshot.value as! [String:Any]
                   
                    // building a Student object from the dictionary
            let employee = Employee(dict: dict)
            employee.key = snapshot.key
                    // adding the student object to the Student array
            self.employees.append(employee)
            self.employeeTableViewOutlet.reloadData()
        
                })
        // Do any additional setup after loading the view.
    }

    @IBAction func addPersonAction(_ sender: UIButton) {
        var name = nameFieldOutlet.text ?? "UNKNOWN"
        var salary = Int(salaryFieldOutlet.text ?? "0") ?? 0
        var position = positionFieldOutlet.text ?? "Unavailable"
        
        var newEmployee = Employee(name: name, position: position, salary: salary)
        newEmployee.saveToFirebase()
        nameFieldOutlet.text = ""
        positionFieldOutlet.text = ""
        salaryFieldOutlet.text = ""
        ref.child("employees").observeSingleEvent(of: .value) { snapshot in
            self.employeeTableViewOutlet.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return employees.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = employeeTableViewOutlet.dequeueReusableCell(withIdentifier: "myCell")!
        let employee = employees[indexPath.row]
        cell.textLabel?.text = "Name: \(employee.name) \t Position: \(employee.position) \n Salary: $\(employee.salary)"
        return cell
    }
    
}

