//
//  UUID+Identifiable.swift
//  kivoai
//

import Foundation

extension UUID: @retroactive Identifiable {
    public var id: UUID { self }
}
