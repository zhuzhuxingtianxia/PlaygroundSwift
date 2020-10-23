//
//  ViewController.swift
//  SwiftPonter
//
//  Created by ZZJ on 2019/5/27.
//  Copyright © 2019 Jion. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        numberPoint()
        
//        objcPoint()
        arrayPonit()
        
        
    }

    func typeofsize() {
        struct sample {
            let temp: Int
            let pb: Bool
        }
        
       _ = MemoryLayout<Int>.size      // returns 8 on 64-bit
        _ = MemoryLayout<Bool>.size     // returns 1
       _ = MemoryLayout<sample>.size      // returns 9
       _ = MemoryLayout<sample>.stride    // returns 16 because of alignment requirements
       _ = MemoryLayout<sample>.alignment // returns 8, addresses must be multiples of 8
        
        struct StructValue {
            let a: Int8 = 4
            let b: Int16 = 6
            let c: Int32 = 8
        }
        //获取占据字节数
        _ = MemoryLayout<Int8>.size          // returns 1
        _ = MemoryLayout<Int16>.size      // returns 2 on 64-bit
        _ = MemoryLayout<Int32>.size     // returns 4
        _ = MemoryLayout<StructValue>.size      // returns 8
        _ = MemoryLayout<StructValue>.stride    // returns 8
        _ = MemoryLayout<StructValue>.alignment // returns 4
        
        var structValue = StructValue()
        
        //一个实例对象的内存大小
        let instanceSize = MemoryLayout<StructValue>.size(ofValue: structValue)
        print(instanceSize)// returns 8
        
        let structValuePointer = withUnsafePointer(to: &structValue) { (pointer) -> UnsafeMutableRawPointer in
            UnsafeMutableRawPointer(OpaquePointer(pointer))
        }
        structValuePointer.advanced(by: 2).assumingMemoryBound(to: Int16.self).initialize(to: 99)
        
        print(structValue)//StructValue(a: 4, b: 99, c: 8)
    }

    func numberPoint() {
        //32513 = 0111 1111 0000 0001
        // let number:Int16 = 32513
        var number: Int16 = 32513
        
        //withUnsafePointer这类函数的闭包中获取的指针都是临时指针，不能在闭包外使用，这Int值我们可以继续处理成指针
        let raw_number = withUnsafePointer(to: &number) { (bb) -> Int in
            return Int(bitPattern: bb)
        }
        let number_pointer = UnsafePointer<Int16>.init(bitPattern: raw_number)
        if number_pointer?.pointee == number {
            print("true")
        }
        //对于直接寻址的number来说，使用unsafeBitCast方法获取到的就是number局部变量对应指针的内存中的值，
        //因为是直接寻址，所以就是数值 32513
        let number_bitCast = unsafeBitCast(number, to: Int16.self)
    }
    
    func objcPoint() {
        var label = UILabel()
        label.text = "aHaha"
        label.font = UIFont.systemFont(ofSize: 17)
        
        //使用passUnretained 方法， Unmanaged 保持了一个给定的对象，不增加它的引用计数
        //toOpaque()获取转化成可变原指针
        let label_UnsafeMutableRawPointer = Unmanaged.passUnretained(label).toOpaque()
        let label_unsafeBitCast_Int = unsafeBitCast(label, to: Int.self)
        let with_raw_label = withUnsafePointer(to: &label) { (wp) -> Int in
            return Int(bitPattern: wp)
        }
        
        let stack_labelPointer = UnsafeMutablePointer<UILabel>.init(bitPattern: with_raw_label)
        let heap_labelPointer = UnsafeMutablePointer<UILabel>.init(bitPattern: label_unsafeBitCast_Int)
        
        if stack_labelPointer?.pointee == label {
            print("true")
        } //true
        if heap_labelPointer?.pointee == label {
            print("true")
        }//false
        
        let what = heap_labelPointer!.pointee
        //这里正常输出，label不是一个类对象,而是一个实例对象
        let label_notClassObject = label as? AnyClass == .none
        
        //下面两句都是true，第一句证明what是UILabel的类对象，
        //第二句证明what可以调用UILabel的类方法areAnimationsEnabled,
        //综上what确实是UILabel类对象
        let what_isUILabelClass = what as? AnyClass == Optional.some(UILabel.self)
        let what_hadUILabelClassMethod:String = what.responds(to: #selector(getter: UILabel.areAnimationsEnabled)) ? "true":"false"
    }
    
    func pointToObjc() {
        //指针和对象的相互转换
        var key = String("Substring")
        var value = String("xxxxxxx")
        
        @discardableResult
        func insert(key:inout String, value:inout String) -> String?{
            let _dic = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, nil, nil)
            
            let rawKey = withUnsafePointer(to: &key, { UnsafeRawPointer($0)})
            let rawValue = withUnsafePointer(to: &value, { UnsafeRawPointer($0)})
            CFDictionarySetValue(_dic, rawKey, rawValue)
            
            let rawPointer = CFDictionaryGetValue(_dic, rawKey)
            print("\(String(describing: rawPointer))")
            
            let xx = rawPointer?.load(as: String.self)
            
            return xx
        }
        
         insert(key: &key, value: &value)
        
        @discardableResult
        func insertObc(key: AnyObject, value: AnyObject) -> AnyObject?{
            let _dic = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, nil, nil)
            
            let key = Unmanaged.passUnretained(key).toOpaque()
            let Value = Unmanaged.passUnretained(value).toOpaque()
            CFDictionarySetValue(_dic, key, Value)
            
            let rawPointer = CFDictionaryGetValue(_dic, key)
            print("\(String(describing: rawPointer))")
            
            let xx = Unmanaged<AnyObject>.fromOpaque(rawPointer!).takeUnretainedValue()
            
            return xx
        }
        
        insertObc(key: key as AnyObject, value: value as AnyObject)
    }
    
    func arrayPonit() {
        var numbers:[Int] = [7,3,2,4,0]
        //获取局部变量numbers的指针(&numbers)，栈指针
        let stack_raw_numbers = withUnsafePointer(to: &numbers, { (bb) -> Int in
            return Int(bitPattern: bb)
        })
       let sum = numbers.withUnsafeBufferPointer{buffer->Int in
            var result = 0
        //跨越式遍历，<buffer.endIndex
            for i in stride(from: buffer.startIndex, to: buffer.endIndex, by: 2) {
                 result += buffer[i]
            }
            return result
        }
        print("sum==\(sum)")
        //numbers 存储在堆中地址，该存储地址不是数组元素首地址，而是以数组标识属性等开始的数组内存
        let heap_raw_numbers = unsafeBitCast(numbers, to: Int.self)
        //numbers 可以直接作为 UnsafeRawPointer 使用, 获取 数组元素存储的首地址
        let raw_numbers = Int(bitPattern: numbers)
        
        //1.取局部变量栈指针，通过该指针的pointee来指向数组
        var numbersPointer_test = UnsafeMutablePointer<[Int]>.init(bitPattern: stack_raw_numbers)
        let get_numbers = numbersPointer_test!.pointee
        
        //2.取数组元素存储区的首地址，即数组第一个元素的地址,该指针指向第一个元素
        let numbersPointer = UnsafeMutablePointer<Int>.init(bitPattern: raw_numbers)
        //之后的元素可以根据元素地址，向后推移
        let numbersPointer_1 = numbersPointer![1]
        let numbersPointer_2 = numbersPointer![2]
        //也可以直接使用元素首地址初始化bufferPointer
        var numbers_bufferPointer = UnsafeMutableBufferPointer.init(start: numbersPointer, count: 5)

        //这里的指针本身就是指向数组了，这导致调用pointee反而出错，pointee并不指向数组元素
        var what_numbers_pointer = UnsafeMutablePointer<[Int]>.init(bitPattern: heap_raw_numbers)
        //这里不是OC对象NSArray，而是swift对象Array
        let some_what_numbersPointer = what_numbers_pointer!.pointee
    }
    //指针的创建
    func createPoint() {
        struct SYPerson {
            var name: String
            var age: Int
        }
        //指针一般用allocte来创建，需要注意的是capacity参数是容量的意思，非集合指针一般设为1
        let systructPointer = UnsafeMutablePointer<SYPerson>.allocate(capacity: 1)
        
        let systruct = SYPerson(name: "xx", age: 10)
        //用initialize来初始化，如果类型是基本类型，那么可以直接assign，因为内存中保存的必定是0或1，相当于已经初始化了。
        //这里是自定义结构体SYPerson，直接写assign会崩溃，因为pointee还没有申请内存，无法拷贝内容进去
        //systructPointer.assign(repeating: systruct, count: 1)    //wrong
        systructPointer.initialize(repeating: systruct, count: 1)
        systructPointer.initialize(to: systruct)
        
        let systruct_other = systruct
        systructPointer.assign(repeating: systruct_other, count: 1)
        //等同于
        systructPointer[0] = systruct
        //等同于
        systructPointer.pointee = systruct
        
        //最后在不用的时候deallocate释放内存。
         systructPointer.deallocate()
    }
    
    //类型转换
    func typeChange() {
        var i: Int8 = 12
        
        printpointer(p: &i)
    }
    func printpointer(p: UnsafePointer<Int8>) {
        let muS2ptr = UnsafeMutablePointer<Int8>.init(mutating: p)!
        
        print(muS2ptr.pointee)
        
        //UnsafePointer<Int8> - > UnsafeRawPointer
        var constUnTypePointer = UnsafeRawPointer(p)
        //UnsafeRawPointer -> UnsafeMutableRawPointer
        var unTypePointer = UnsafeMutableRawPointer(mutating: constUnTypePointer)
        //UnsafeMutablePointer<Int8> ->  UnsafeMutableRawPointer
        var unTypePointer2 = UnsafeMutableRawPointer(muS2ptr)
    }
    
    func cusumprint<T>(address p: UnsafeRawPointer, as type: T.Type) {
        let value = p.load(as: type)
        print(value)
    }
    
    //下面的例子展示了将Uint8的指针 转换为UInt64类型
    var i: UInt8 = 125
//    printPointer(uint8Pointer: &i)
    func printPointer(uint8Pointer: UnsafePointer<UInt8>) {
        let pointer0 = UnsafeRawPointer(uint8Pointer).bindMemory(to: UInt64.self, capacity: 1)
        let pointer0Value = pointer0.pointee
        print(pointer0Value) //UInt64
        
        let pointer1 = UnsafeRawPointer(uint8Pointer).assumingMemoryBound(to: UInt64.self)
        let pointer1Value = pointer1.pointee
        print(pointer1Value)//UInt64
        
        let pointer2Value = UnsafeRawPointer(uint8Pointer).load(as: UInt64.self)
        print(pointer2Value)//UInt64
        
        let pointer3 = UnsafeMutablePointer(mutating: uint8Pointer).withMemoryRebound(to: UInt64.self, capacity: 1) {
            return $0
        }
        print(pointer3.pointee) // UInt64
    }
    
    func stringUnsafeBytes()  {
        var string = "hello" // 5个字符 'h' 'e' 'l' 'l' 'o' 每个字符占一个字节
        var strdata = string.data(using: .ascii)
        //访问字节的数据
        strdata?.withUnsafeBytes({ (ptr:UnsafePointer<Int8>) in
            print(ptr.pointee) // 104 = 'h'
        })
    }
    
    //排序
    func sorted() {
        let dic:[String:String] = ["b":"333","a":"111","c":"222"]
        print(Array(dic))
        print("-------0---------")
        Array(dic).map{ print($0) }
        
        print("-------0.0---------")
        Array(dic).map{ print($0.0) }
        
        print("--------0.1--------")
        Array(dic).map{ print($0.1) }
        
        print("--------1--------")
        Array(dic).map{ print($1) }
        
        let arr = Array(dic).sorted { $0.0.compare($1.0) == .orderedAscending }
        
        print(arr)
        let arr1 = Array(dic).sorted { $0.1.compare($1.1) == .orderedAscending }
        
        print(arr1)
        
        let result = dic.keysSortedByValue { (Value1, Value2) -> Bool in
            return Value1.compare(Value2) == .orderedAscending
        }
        print(result)
    }
}

//sorted() 对这个扩展的查看
extension Dictionary {
    func keysSortedByValue(_ isOrderedBefore:(Value,Value)->Bool) -> [Key] {
        return Array(self).sorted{isOrderedBefore($0.1,$1.1)}.map{$0.0}
    }
}
