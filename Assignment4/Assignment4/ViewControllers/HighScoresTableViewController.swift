//
//  HighScoresViewController.swift
//  Assignment4
//
//  Created by Justine Manikan on 11/29/18.
//  Copyright © 2018 Justine Manikan. All rights reserved.
//

import UIKit

class HighScoresTableViewController: UITableViewController {
    
    let getData = GetData()
    var timer : Timer!
    @IBOutlet var scoreTable : UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.timer = Timer.scheduledTimer(timeInterval: 0.4, target: self, selector: #selector(self.refreshTable), userInfo: nil, repeats: true);
        
        getData.jsonParser()
    }
    @objc func refreshTable(){
        if(getData.dbData != nil)
        {
            if (getData.dbData?.count)! > 0
            {
                self.scoreTable.reloadData()
                self.timer.invalidate()
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if getData.dbData != nil{
            return (getData.dbData?.count)!
        }
        
        else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let tableCell : HighScoresTableViewCell = tableView.dequeueReusableCell(withIdentifier: "myCell") as?
            HighScoresTableViewCell ?? HighScoresTableViewCell(style: .default, reuseIdentifier: "myCell")
        
        let row = indexPath.row
        
        let rowData = (getData.dbData?[row])! as NSDictionary
        tableCell.name.text = rowData["Name"] as? String
        tableCell.score.text = rowData["Score"] as? String
        
        return tableCell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //if let split = self.splitViewController
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
