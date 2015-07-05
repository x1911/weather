//
//  ViewController.swift
//  Swift Weather
//
//  Created by apple on 15/5/14.
//  Copyright (c) 2015年 zz. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

//添加location manager 协议
class ViewController: UIViewController,CLLocationManagerDelegate {
    //定义常量为地理位置的控制
    let locationManager:CLLocationManager = CLLocationManager()
    
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var temperature: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingText: UILabel!
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //locationManger的类回调给本函数，表示可以使用下面的函数
        locationManager.delegate = self

        // 初始化，定义经纬度的精度，使用最好的精确度
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // 如果是ios则额外进行一个确认
        if(ios()){
        locationManager.requestAlwaysAuthorization()
        }
        //ios8 后台程序的情况下运行update信息
        locationManager.startUpdatingLocation()
        
        //背景图片调用
        let background = UIImage(named: "background")
        // UIColor 的用法可以让这个图片产生 repeat-X repeat-Y 的效果
        self.view.backgroundColor = UIColor(patternImage: background!)
        
        //到StoryBoard里删除默认值，加入spinner，用startAnimating 来启动动画，一旦取得值后就隐藏这两个loading数据
        self.loadingIndicator.startAnimating()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // ->表示返回一个bool值，判断ios版本
    func ios() -> Bool{

        //判断版本号
        var ver:NSString = UIDevice.currentDevice().systemVersion
        // 对比版本号，注意这里返回结果是 NSComparisonResult
        return ver.substringWithRange(NSMakeRange(0, 1)) >= "8"

        //return UIDevice.currentDevice().systemVersion >= "8.0"
    }

    //一旦地理信息发生变更则回传，回传的是个数组，可空，AnyObject指所有可控ID类型
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!){
        
        //local等于这个数组，并且只要最后一个值，并将AnyObject类型的数组转换成CLLcation类型
        var location:CLLocation = locations[locations.count-1] as! CLLocation
      
        //判断location是否有值
        if(location.horizontalAccuracy > 0){
            println(location.coordinate.latitude,"维度：",location.coordinate.longitude,"    另外一个",location.horizontalAccuracy)
            //因为做了bridging到obc的头文件，就可以直接调用，不用info，因为是内部函数，所以用self前缀，可不用，第一个参数可以不用参数名
            self.updateWeatherInfo(location.coordinate.latitude,longitude:location.coordinate.longitude)
            self.updateBorrowList()
            //只要得到一次location信息就可以停止读取
            locationManager.stopUpdatingLocation()
        }
    }
    
    //判断如果出错的情况
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
            println(error)
        self.loadingText.text = "Location service not turn on?"
    }
    
    /*
    //ctrl点location.coordinate.latitude获取到latitude的值是CLLocationDegrees类型，使用 AFNetworking获取信息
    func updateWeatherInfo(latitude:CLLocationDegrees,longitude:CLLocationDegrees){
        //用一个常量表示 afnetworking的 manager
        let manager = AFHTTPRequestOperationManager()
        let url = "http://api.openweathermap.org/data/2.5/weather"
        let params = ["lat":latitude, "lon":longitude, "cnt":0]
        
        //manager 常用获取json代码，GET操作，参数使用 params 字典
        manager.GET(url, parameters: params,
            success: {
            (operation:AFHTTPRequestOperation!,respondsObject: AnyObject!) in println("JSON: " + respondsObject.description!)
                
                //将返回数据由 JSON 转型成字典 并显示
                self.updateUISucces(respondsObject as! NSDictionary!)
            
            }, failure: {
                (operation:AFHTTPRequestOperation!, error:NSError!) in println("Error: " + error.localizedDescription)
        
        })//end of manager.GET
        
    }// end of updateWeatherInfo
*/
    
    //ctrl点location.coordinate.latitude获取到latitude的值是CLLocationDegrees类型
    func updateWeatherInfo(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let url = "http://api.openweathermap.org/data/2.5/weather"
        let params = ["lat":latitude, "lon":longitude]
        //println(params)  
        //http://api.openweathermap.org/data/2.5/weather?lat=37.785834&lon=-122.406417
        
        Alamofire.request(.GET, url, parameters: params)
            .responseJSON { (request, response, json, error) in
                if(error != nil) {
                    //println("Error: \(error)")
                    //println(request)
                    println(response)
                    self.loadingText.text = "Internet appears down! \n \(error)"
                }
                else {
                    //println("Success: \(url)")
                    //println(request)
                    var jsonResult = JSON(json!)
                    self.updateUISuccess(jsonResult)
                }
        }
    }

    
    func updateBorrowList() {
        let url = "http://123.xieshoud.com/modules/moblie-api.php"
//        let params = ["dykey":"123123ASD564654ASDJHHOIZ654","module":"borrow","p":"getborrowlist","amount":"30","epage":"5","page":"1","order":"indexs","status_nid":"repay"] //借款列表页 loan正在借款，无"status_nid"参数则首页5个项目
//        let params = ["dykey":"123123ASD564654ASDJHHOIZ654","module":"borrow","q":"borrowlist","epage":"5","page":"1","order":"indexs","status_nid":"repay"] //get借款列表页
//        let params = ["dykey":"0000","module":"article","q":"articlelist","type_id":"11","amount":"10","status":1]//文章列表页
        let params = ["dykey":"123123ASD564654ASDJHHOIZ654","module":"article","q":"getarticleone","article_id":300]//页面内容
//        let params = ["dykey":"123123ASD564654ASDJHHOIZ654","module":"borrow","q":"getborrowone","borrow_nid":"20141000001"]//标内容
      
        Alamofire.request(.GET, url, parameters: params)//, encoding:.JSON //get方式无问题，post不对
//        Alamofire.request(.POST, url, parameters: params)
            .responseJSON { (request, response, json, error) in
                if(error != nil) {
                    //println("Error: \(error)")
                    //println(request)
                    println(response)
                    self.loadingText.text = "\(error)"
                }
                else {
//                    println("Success: \(url)")
//                    println(request)
                    
                    var jsonResult = JSON(json!)
                    
                    
                        //本段可以将json返回加密过的base64_encode信息
                        let data = jsonResult["contents"].string
                        let decodedData = NSData(base64EncodedString: data!, options: NSDataBase64DecodingOptions(0))
                        let decodedString = NSString(data: decodedData!, encoding: NSUTF8StringEncoding)!
                    //用UIwebView显示html格式
                    self.webView.loadHTMLString(decodedString as String,baseURL:nil)
                    println(decodedString)
                    

                    println(jsonResult)
                    self.updateUISuccess(jsonResult)
                }
        }
    }
    
    //!表示不为optional，不能为空，要求这个函数必须要传入值
    func updateUISuccess(jsonResult: JSON) {
        
        //json加载成功后停止 indicator 的动画并隐藏loadingtext
        self.loadingIndicator.stopAnimating()
        self.loadingIndicator.hidden = true
        self.loadingText.text = nil
        
        //判断json数据是否有可能为空的情况，jsonResult这个字典里main键值下的temp键值如果有值，就转换成double。如果任何一步值为空就返回到else里
        if let tempResult = jsonResult["main"]["temp"].double {
            var temperature: Double //温度保留两位小数
            //判断json里国家信息，如果是米国则转换成华氏
            if (jsonResult["sys"]["country"].string == "US"){
                temperature = round(((tempResult - 273.15) * 1.8) + 32)
                //本view里面的temperature label的字
                self.temperature.text = "F \(temperature)°"
            }else{
                temperature = round(tempResult - 273.15)
                //本view里面的temperature label的字
                self.temperature.text = "C \(temperature)°"
            }
           

            //self.temperature.font = UIFont.boldSystemFontOfSize(80)  //设置字体大小
            self.location.text = jsonResult["name"].string  //["city"]
            
            //取出天气ID和太阳起落时间
            var condition = jsonResult["weather"][0]["id"].int!
            var sunrise = jsonResult["sys"]["sunrise"].double  //要和now现在时间对比一定要转换成 double 型
            var sunset = jsonResult["sys"]["sunset"].double
            
            //判断是否晚上，默认值是白天
            var nightTime = false
            //需要把拿到的数据比对好才能算出是白天还是晚上
            var now = NSDate().timeIntervalSince1970
//            println("now 的值是 \(now)，sunrise 的值是 \(sunrise),condition 的 id 是 \(condition)")
 
            if (now < sunrise || now > sunset){ //在日出之前或日落之后则为晚上
                nightTime = true
            }
            
            self.updateWeatherIcon(condition, nightTime:nightTime)
            
        }else{
            self.loadingText.text = "Cant catch the information!"
        }//end of if let tempResult
        
    }//end updateUISucces
    
    //把天气ID转换成图标
    func updateWeatherIcon(condition:Int, nightTime:Bool){
        switch condition{
        case 100..<300:
            if nightTime {
                self.icon.image = UIImage(named: "tstorm1_night")
            }else{
                self.icon.image = UIImage(named: "tstorm1")
            }//end if (condition < 300)
            
        case 300..<500:
            self.icon.image = UIImage(named: "light_rain")
        case 500..<600:
            self.icon.image = UIImage(named: "shower3")
        case 600..<700:
            self.icon.image = UIImage(named: "snow4")
        case 700..<771:
            if nightTime {  //fog
                self.icon.image = UIImage(named: "fog_night")
            }else{
                self.icon.image = UIImage(named: "fog")
            }//end if
        case 771..<800:
            self.icon.image = UIImage(named: "tstorm3")
        case 800:
            if nightTime {  //fog
                self.icon.image = UIImage(named: "sunny_night")
            }else{
                self.icon.image = UIImage(named: "sunny")
            }//end if
        case 801..<804:
            if nightTime {  //fog
                self.icon.image = UIImage(named: "cloudy2_night")
            }else{
                self.icon.image = UIImage(named: "cloudy2")
            }//end if
        case 804:
            self.icon.image = UIImage(named: "overcast")
        case 900..<903:
            self.icon.image = UIImage(named: "tstorm3")
        case 903:
            self.icon.image = UIImage(named: "snow5")
        case 904:
            self.icon.image = UIImage(named: "sunny")
            
        default:
            self.icon.image = UIImage(named: "dunno")

        }
        
        
    }//updateWeatherIcon

}

