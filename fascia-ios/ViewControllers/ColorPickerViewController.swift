//
//  ColorPickerViewController.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/05/21.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import UIKit
import Color_Picker_for_iOS
import Colours

class ColorPickerViewController: UIViewController {
    private let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: nil, action: nil)

    override func viewDidLoad() {
        super.viewDidLoad()

        let navBarHeight = self.navigationController!.navigationBar.frame.height + UIApplication.sharedApplication().statusBarFrame.height
        let rect = CGRect(x: self.view.bounds.origin.x, y: self.view.bounds.origin.y + navBarHeight, width: self.view.bounds.width, height: self.view.bounds.height - navBarHeight)
        let view = HRColorPickerView(frame: rect)
        view.color = UIColor.pastelBlueColor()
        view.addTarget(self, action: #selector(ColorPickerViewController.colorChanged(_:)), forControlEvents: .ValueChanged)
        self.view.addSubview(view)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func colorChanged(sender: HRColorPickerView) {

    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
