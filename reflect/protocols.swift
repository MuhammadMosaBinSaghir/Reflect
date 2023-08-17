import Foundation
import SwiftUI

protocol Attributable: Hashable {
    static var label: String { get }
    static var icon: String { get }
    
    func formatted<S: CustomFormatStyle>(_ style: S) -> S.FormatOutput? where S.FormatInput == Self?
}

protocol Colorful: View, ShapeStyle {}

protocol CustomFormatStyle: FormatStyle {}

protocol Empty {
    static var empty: Self { get }
}
