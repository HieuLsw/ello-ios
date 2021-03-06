//  Copyright (c) 2014 Rob Rix. All rights reserved.

/// The type conformed to by all boxes.
protocol BoxType {
	/// The type of the wrapped value.
	associatedtype Value

	/// Initializes an intance of the type with a value.
	init(_ value: Value)

	/// The wrapped value.
	var value: Value { get }
}

/// The type conformed to by mutable boxes.
protocol MutableBoxType: BoxType {
	/// The (mutable) wrapped value.
	var value: Value { get set }
}


/// Equality of `BoxType`s of `Equatable` types.
///
/// We cannot declare that e.g. `Box<T: Equatable>` conforms to `Equatable`, so this is a relatively ad hoc definition.
func == <B: BoxType> (lhs: B, rhs: B) -> Bool where B.Value: Equatable {
	return lhs.value == rhs.value
}

/// Inequality of `BoxType`s of `Equatable` types.
///
/// We cannot declare that e.g. `Box<T: Equatable>` conforms to `Equatable`, so this is a relatively ad hoc definition.
func != <B: BoxType> (lhs: B, rhs: B) -> Bool where B.Value: Equatable {
	return lhs.value != rhs.value
}


/// Maps the value of a box into a new box.
func map<B: BoxType, C: BoxType>(_ v: B, f: (B.Value) -> C.Value) -> C {
	return C(f(v.value))
}
