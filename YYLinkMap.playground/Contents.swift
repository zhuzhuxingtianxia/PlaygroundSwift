import UIKit

//YYKit中链表的使用
//链表节点node
class LinkedMapNode {
    weak var _prev: LinkedMapNode?
    weak var _next: LinkedMapNode?
    
    var _key: AnyObject?
    var _value: AnyObject?
    var _cost: UInt = 0
    var _time: TimeInterval = 0.0
    
}

protocol LinkedMapProtocol {
    //插入头节点
    func insertNodeAtHead(node:inout LinkedMapNode);
    //把节点d移动到头节点
    func moveNodeToHead(node: LinkedMapNode);
    //移除一个节点
    func removeNode(node: LinkedMapNode);
    
    //如果有尾部节点，则移除并将其返回
    func removeTailNode() -> LinkedMapNode?;
    
    //在后台线程移除所有节点
    func removeAll();
}

public class LinkedMap: NSObject {
    var _dic = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, nil, nil)
    
    var _totalCost: UInt = 0
    var _totalCount = 0
    
    var _head: LinkedMapNode? // MRU
    var _tail: LinkedMapNode? // LRU
    
    //MARK: - init
    override init(){
        super.init()
    }
    
    deinit {
        
    }
    
}

extension LinkedMap: LinkedMapProtocol {
    //插入头节点
    func insertNodeAtHead(node:inout LinkedMapNode){
        
        //        let rawKey = withUnsafePointer(to: &node._key, { UnsafeRawPointer($0)})
        //        let rawValue = withUnsafePointer(to: &node, { UnsafeRawPointer($0)})
        //        //保存自定义对象时闪退
        //        CFDictionarySetValue(_dic, rawKey, rawValue)
        //        CFDictionaryAddValue(_dic, rawKey, rawValue)
        
        let key = Unmanaged.passUnretained(node._key!).toOpaque()
        let Value = Unmanaged.passUnretained(node).toOpaque()
        
        CFDictionarySetValue(_dic, key, Value)
        
        _totalCost += node._cost
        _totalCount += 1
        
        if _head != nil {
            node._next = _head
            _head?._prev = node
            _head = node
            
        }else{
            _head = node
            _tail = node
        }
    }
    //把节点移动到头节点
    func moveNodeToHead(node: LinkedMapNode){
        guard (_head != nil) else {
            return
        }
        if _head! === node {
            return
        }
        if _tail! === node {
            _tail = node._prev
            _tail?._next = nil
        }else{
            node._next?._prev = node._prev
            node._prev?._next = node._next
        }
        
        node._next = _head
        node._prev = nil
        _head?._prev = node
        _head = node
    }
    //移除一个节点
    func removeNode(node: LinkedMapNode){
        //        let rawKey = withUnsafePointer(to: &node._key, { UnsafeRawPointer($0)})
        let rawKey = Unmanaged.passUnretained(node._key!).toOpaque()
        CFDictionaryRemoveValue(_dic, rawKey)
        _totalCost -= node._cost
        _totalCount -= 1
        if node._next != nil {
            node._next?._prev = node._prev
        }
        if node._prev != nil {
            node._prev?._next = node._next
        }
        
        if _head === node {
            _head = node._next
        }
        if _tail === node {
            _tail = node._prev
        }
    }
    
    //如果有尾部节点，则移除并将其返回
    func removeTailNode() -> LinkedMapNode?{
        if _tail == nil {
            return nil
        }
        let tail = _tail
        //        let rawKey = withUnsafePointer(to: &_tail!._key, { UnsafeRawPointer($0)})
        let rawKey = Unmanaged.passUnretained(_tail!._key!).toOpaque()
        CFDictionaryRemoveValue(_dic, rawKey)
        _totalCost -= (_tail?._cost)!
        _totalCount -= 1
        if _head === _tail {
            _head = nil
            _tail = nil
        }else {
            _tail = _tail?._prev
            _tail?._next = nil
        }
        return tail;
    }
    
    //在后台线程移除所有节点
    func removeAll(){
        _totalCost = 0;
        _totalCount = 0;
        _head = nil;
        _tail = nil;
        
        if CFDictionaryGetCount(_dic) > 0 {
            _dic = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, nil, nil)
        }
    }
}

//使用
var _lru = LinkedMap.init()

func setObject(object: AnyObject?,forKey key: AnyObject?,withCost cost: UInt){
    guard key != nil else {
        return
    }
    //    let keyPonit = withUnsafePointer(to: key) { UnsafeRawPointer($0) }
    let keyPonit = Unmanaged.passUnretained(key!).toOpaque()
    let nodePointer = CFDictionaryGetValue(_lru._dic, keyPonit)
    
    //    var node = nodePointer?.load(as: LinkedMapNode.self)
    
    var node:LinkedMapNode?
    if nodePointer != nil {
        node = Unmanaged<LinkedMapNode>.fromOpaque(nodePointer!).takeUnretainedValue()
    }
    let now = CACurrentMediaTime()
    
    if node != nil {
        _lru._totalCost = _lru._totalCost - (node?._cost)!
        _lru._totalCost = _lru._totalCost + cost
        node?._cost = cost
        node?._time = now
        node?._value = object
        _lru.moveNodeToHead(node: node!)
    }else {
        node = LinkedMapNode.init()
        node?._cost = cost
        node?._time = now
        node?._key = key
        node?._value = object
        _lru.insertNodeAtHead(node: &node!)
    }
}

setObject(object: "http:" as AnyObject, forKey: "img" as AnyObject, withCost: 0)
print("\(String(describing: _lru._dic))")
func containsObjectForKey(key: AnyObject?) -> Bool {
    guard key != nil else {
        return false
    }
    //    let keyPonit = withUnsafePointer(to: key) { UnsafeRawPointer($0) }
    let keyPonit = Unmanaged.passUnretained(key!).toOpaque()
    let contains = CFDictionaryContainsKey(_lru._dic, keyPonit)
    
    return contains
}

let con = containsObjectForKey(key: "img" as AnyObject)

func objectForKey(key:AnyObject?) -> AnyObject? {
    guard key != nil else {
        return nil
    }
    //    let keyPonit = withUnsafePointer(to: key) { UnsafeRawPointer($0) }
    let keyPonit = Unmanaged.passUnretained(key!).toOpaque()
    
    let nodePointer = CFDictionaryGetValue(_lru._dic, keyPonit)
    //    let node = nodePointer?.load(as: LinkedMapNode.self)
    var node:LinkedMapNode?
    if nodePointer != nil {
        node = Unmanaged<LinkedMapNode>.fromOpaque(nodePointer!).takeUnretainedValue()
    }
    
    if node != nil {
        node?._time = CACurrentMediaTime()
        _lru.moveNodeToHead(node: node!)
    }
    return node != nil ? node?._value : nil
}

let objc = objectForKey(key: "img" as AnyObject)

func removeObjectForKey(key: AnyObject?) {
    guard key != nil else {
        return
    }
    //    let keyPonit = withUnsafePointer(to: key) { UnsafeRawPointer($0) }
    let keyPonit = Unmanaged.passUnretained(key!).toOpaque()
    let nodePointer = CFDictionaryGetValue(_lru._dic, keyPonit)
    
    //    let node = nodePointer?.load(as: LinkedMapNode.self)
    var node:LinkedMapNode?
    if nodePointer != nil {
        node = Unmanaged<LinkedMapNode>.fromOpaque(nodePointer!).takeUnretainedValue()
    }
    if node != nil {
        _lru.removeNode(node: node!)
    }
}

removeObjectForKey(key: "img" as AnyObject)
print("\(String(describing: _lru._dic))")

func trimToAge(ageLimit: TimeInterval) {
    var finish = false
    let now = CACurrentMediaTime()
    
    if ageLimit <= 0 {
        _lru.removeAll()
        finish = true
    }else if(_lru._tail == nil || (now - (_lru._tail?._time)!) <= ageLimit) {
        finish = true
    }
    
    if finish {
        return
    }
    
    var holder = [LinkedMapNode]()
    while !finish {
        if _lru._tail != nil && (now - (_lru._tail?._time)!) > ageLimit {
            let node = _lru.removeTailNode()
            if node != nil {
                holder.append(node!)
            }else{
                finish = true
            }
        }
    }
    
    if holder.count > 0 {
        holder.removeAll()
    }
}

