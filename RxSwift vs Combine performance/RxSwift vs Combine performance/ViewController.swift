//
//  ViewController.swift
//  RxSwift vs Combine performance
//
//  Created by Laura Bejan on 06.09.2021.
//

import UIKit
import Combine
import RxSwift

class ViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let interval = 0...10000000
        
        let secondsRxSwift = measure {
            Observable.from(interval)
                .map { $0 * 2 }
                .filter { $0.isMultiple(of: 2) }
                .flatMap { Observable.just($0) }
                .toArray()
                .map { $0.count }
                .subscribe(onSuccess: { print($0) } )
                .disposed(by: disposeBag)
        }
        print("Result RxSwift: \(secondsRxSwift) seconds")
        
        let secondsCombine = measure {
            _ = Publishers.Sequence(sequence: interval)
                .map { $0 * 2 }
                .filter { $0.isMultiple(of: 2) }
                .flatMap { Result.Publisher($0) }
                .count()
                .sink(receiveValue: { print($0) } )
        }
        print("Result Combine: \(secondsCombine) seconds")
    }
    
    func measure(task: () -> Void) -> Double {
        let startTime = CFAbsoluteTimeGetCurrent()
        task()
        let endTime = CFAbsoluteTimeGetCurrent()
        let result = endTime - startTime
        return result
    }
}

