import UIKit

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

extension Dictionary {
    func keysSortedByValue(_ isOrderedBefore:(Value,Value)->Bool) -> [Key] {
        return Array(self).sorted{isOrderedBefore($0.1,$1.1)}.map{$0.0}
    }
}

let result = dic.keysSortedByValue { (Value1, Value2) -> Bool in
    return Value1.compare(Value2) == .orderedAscending
}
print(result)

