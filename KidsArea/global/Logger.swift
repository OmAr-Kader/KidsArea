//
//  Logger.swift
//  TestCoreML
//
//  Created by OmAr Kader on 21/06/2025.
//

func logger(_ items: Any?...) {
#if DEBUG
    print(items)
#else
    return
#endif
}
