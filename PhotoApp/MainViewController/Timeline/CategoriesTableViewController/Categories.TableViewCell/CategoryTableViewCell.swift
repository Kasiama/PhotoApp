//
//  CategoryTableViewCell.swift
//  PhotoApp
//
//  Created by Ivan Zhurauski on 9/12/19.
//  Copyright © 2019 Ivan Zhurauski. All rights reserved.
//

import UIKit







class CirkleView : UIView {
    
    var circlePath: UIBezierPath?
    var color: UIColor?
    
    init(frame: CGRect, color:UIColor){
        super.init(frame: frame)
        self.color = color
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
  override  func draw(_ rect: CGRect) {
    let halfSize:CGFloat = min( bounds.size.width/2, bounds.size.height/2)
    let desiredLineWidth:CGFloat = 1    // your desired value
    
     circlePath = UIBezierPath(
        arcCenter: CGPoint(x:halfSize,y:halfSize),
        radius: CGFloat( halfSize - (desiredLineWidth/2) ),
        startAngle: CGFloat(0),
        endAngle:CGFloat(Double.pi * 2),
        clockwise: true)
    
    let shapeLayer = CAShapeLayer()
    shapeLayer.path = circlePath?.cgPath
    
    shapeLayer.fillColor = UIColor.clear.cgColor
    shapeLayer.strokeColor = color?.cgColor
    shapeLayer.lineWidth = desiredLineWidth
    
    layer.addSublayer(shapeLayer)
    
    }
    
}

class CircleFillView : CirkleView{
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = self.circlePath?.cgPath
        
        shapeLayer.fillColor = color?.cgColor
        shapeLayer.strokeColor = color?.cgColor
        shapeLayer.lineWidth = 1
        
        layer.addSublayer(shapeLayer)
        }
    
}


class CategoryTableViewCell: UITableViewCell {

    @IBOutlet  var cellView: UIView!
    @IBOutlet weak var cellTextLabel: UILabel!
    
    var fillCircle : UIView?
    var cirkleView : UIView?
    var color: UIColor?
    var normalIsSelect  = false
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //let a = CirkleView.init(frame: self.cellView.bounds, color: color ?? UIColor.clear)
         //self.cellView.addSubview(a)
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        
   //    if (self.isSelected == selected) {return}
       
        super.setSelected(selected, animated: animated)
        
        
//        if(selected == false){
//            fillCircle?.isHidden = true
//             self.accessoryType = selected ? .checkmark : .none
//            return
//        }
      //  self.accessoryType = selected ? .checkmark : .none
       // fillCircle = CircleFillView.init(frame: self.cellView.bounds, color: color ?? UIColor.clear)
        //self.cellView.addSubview(fillCircle!)
       // fillCircle?.isHidden = false
        
        
        
        // Configure the view for the selected state
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if self.normalIsSelect{
//            self.normalIsSelect = false
//            self.fillCircle?.isHidden = true
//        }
//        else{
//            self.normalIsSelect = true
//            self.fillCircle?.isHidden = false
//        }

       // setSelected(!isSelected, animated: true)
        super.touchesEnded(touches, with: event)
    }
   
}
