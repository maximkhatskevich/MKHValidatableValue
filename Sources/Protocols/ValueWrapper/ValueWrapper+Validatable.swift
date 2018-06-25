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

public
extension ValueWrapper
    where
    Self: Validatable
{
    /**
     Returns whatever is stored in 'value', if it is 'valid',
     or throws a validation error.
     */
    func validValue() throws -> Value
    {
        try validate()

        //---

        return value
    }

    /**
     USE THIS CAREFULLY!
     This is a special getter that allows to get non-optional valid value
     OR collect an error, if stored value is invalid,
     while still returning a non-optional value. Notice, that result is
     implicitly unwrapped, but may be actually 'nil'. If stored 'value'
     is invalid - the function adds validation error into the
     'collectError' array and returns implicitly unwrapped 'nil'.
     This helper function allows to collect issues from multiple
     validateable values wihtout throwing an error immediately,
     but received value should ONLY be used/read if the 'collectError'
     is empty in the end.
     */
    func validValue(
        _ collectError: inout [ValidationError]
        ) throws -> Value!
    {
        let result: Value?

        //---

        do
        {
            result = try validValue()
        }
        catch let error as ValidationError
        {
            collectError.append(error)
            result = nil
        }
        catch
        {
            // an unexpected error should be thrown to the upper level
            throw error
        }

        //---
        
        return result
    }
}
