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
protocol OptionalValidatable: ValidatableValue {}

//---

public
extension OptionalValidatable
{
    func valueIfValid() throws -> RawValue?
    {
        guard
            let result = draft
        else
        {
            // 'draft' is 'nil', which is a valid 'value'
            return nil
        }

        //---

        // non-'nil' draft value must be checked againts requirements

        let currentContext = String(reflecting: type(of: self))
        var failedConditions: [String] = []

        Validator.conditions.forEach
        {
            do
            {
                try $0.validate(context: currentContext, value: result)
            }
            catch
            {
                if
                    case ValidatableValueError
                        .conditionCheckFailed(_, _, let condition) = error
                {
                    failedConditions.append(condition)
                }
            }
        }

        //---

        guard
            failedConditions.isEmpty
        else
        {
            throw ValidatableValueError.validationFailed(
                context: currentContext,
                input: result,
                failedConditions: failedConditions
            )
        }

        //---

        return result
    }
}
