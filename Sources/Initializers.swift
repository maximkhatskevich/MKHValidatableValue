/*

 MIT License

 Copyright (c) 2016 Maxim Khatskevich (maxim@khatskevi.ch)

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.

 */

// MARK: - Mandatory + Validator

public
extension ValueValidator
    where
    Self: DisplayNamed,
    Self.Input: Codable & Equatable
{
    typealias Wrapper =
        MandatoryCustom<Self>

    //---

    static
    func wrapped(
        ) -> Wrapper
    {
        return Wrapper()
    }

    static
    func wrapped(
        initialValue value: Self.Input
        ) -> Wrapper
    {
        return Wrapper(initialValue: value)
    }

    static
    func wrapped(
        const value: Self.Input
        ) throws -> Wrapper
    {
        return try Wrapper(const: value)
    }
}

// MARK: - Mandatory

public
extension Equatable
    where
    Self: Codable
{
    typealias Wrapper = MandatoryBasic<Self>

    //---

    static
    func wrapped(
        ) -> Wrapper
    {
        return Wrapper()
    }

    static
    func wrapped(
        initialValue value: Self
        ) -> Wrapper
    {
        return Wrapper(initialValue: value)
    }

    static
    func wrapped(
        const value: Self
        ) throws -> Wrapper
    {
        return try Wrapper(const: value)
    }

    //---

    func wrapped(
        ) -> Wrapper
    {
        return Wrapper(initialValue: self)
    }

    func wrappedConst(
        ) throws -> Wrapper
    {
        return try Wrapper(const: self)
    }
}

// MARK: - Optional + Validator

public
extension Swift.Optional
    where
    Wrapped: ValueValidator,
    Wrapped: DisplayNamed,
    Wrapped.Input: Codable & Equatable
{
    typealias CustomValidatableWrapper =
        CustomValidatableOptionalValue<Wrapped>

    //---

    static
    func wrapped(
        ) -> CustomValidatableWrapper
    {
        return CustomValidatableWrapper()
    }

    static
    func wrapped(
        initialValue value: Wrapped.Input
        ) -> CustomValidatableWrapper
    {
        return CustomValidatableWrapper(initialValue: value)
    }

    static
    func wrapped(
        const value: Wrapped.Input
        ) throws -> CustomValidatableWrapper
    {
        return try CustomValidatableWrapper(const: value)
    }
}

// MARK: - Optional + Context

public
extension Swift.Optional
    where
    Wrapped: Codable & Equatable
{
    typealias ContextualWrapper<NP: DisplayNamed> =
        ContextualOptionalValue<NP, Wrapped>

    //---

    //swiftlint:disable identifier_name

    static
    func wrapped<NP: DisplayNamed>(
        as: NP.Type
        ) -> ContextualWrapper<NP>
    {
        return ContextualWrapper<NP>()
    }

    static
    func wrapped<NP: DisplayNamed>(
        as: NP.Type,
        initialValue value: Wrapped
        ) -> ContextualWrapper<NP>
    {
        return ContextualWrapper<NP>(initialValue: value)
    }

    //---

    func wrapped<NP: DisplayNamed>(
        as: NP.Type
        ) -> ContextualWrapper<NP>
    {
        switch self
        {
            case .none:
                return ContextualWrapper<NP>()

            case .some(let value):
                return ContextualWrapper<NP>(initialValue: value)
        }
    }

    //swiftlint:enable identifier_name
}

// MARK: - Optional

public
extension Swift.Optional
    where
    Wrapped: Codable & Equatable,
    Wrapped: DisplayNamed
{
    typealias Wrapper = OptionalValue<Wrapped>

    //---

    static
    func wrapped(
        ) -> Wrapper
    {
        return Wrapper()
    }

    static
    func wrapped(
        initialValue value: Wrapped
        ) -> Wrapper
    {
        return Wrapper(initialValue: value)
    }

    //---

    func wrapped(
        ) -> Wrapper
    {
        switch self
        {
            case .none:
                return Wrapper()

            case .some(let value):
                return Wrapper(initialValue: value)
        }
    }
}
