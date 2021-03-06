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

import XCTest

@testable
import XCEValidatableValue

//---

class EntityTests: XCTestCase {}

//---

extension EntityTests
{
    func testConditionalConformance() // only works in Swift 4.2+
    {
        enum FirstName: ValueSpecification
        {
            typealias Value = String
        }

        struct SomeWrapper: ValueWrapper
        {
            typealias Specification = FirstName

            typealias Value = Specification.Value

            var value: Value

            init(wrappedValue: Value)
            {
                self.value = wrappedValue
            }
        }

        //---

        let array: [Any] = [

            "Sam",
            SomeWrapper(wrappedValue: "John"),
            Optional.some(SomeWrapper(wrappedValue: "David")) as Any
        ]

        let valElements = array.compactMap{ $0 as? Validatable }

        print("Number of val members found: ---->>>>> \(valElements.count)")
        XCTAssert(valElements.count == 2)
    }

    func testMembersGetters()
    {
        enum FirstName: ValueSpecification
        {
            typealias Value = String
        }

        struct TheEntity: ValidatableEntity
        {
            var wrap1: NonRequired<FirstName>
            var wrap1Opt: NonRequired<FirstName>?
            var wrap2: Required<FirstName>
            var wrap2Opt: Required<FirstName>?
        }

        let entity = TheEntity(
            wrap1: .init(wrappedValue: ""),
            wrap1Opt: .init(wrappedValue: ""),
            wrap2: .init(wrappedValue: ""),
            wrap2Opt: .init(wrappedValue: "")
        )

        //---

        let allMembers = entity.allMembers
        let valMembers = entity.allValidatableMembers

        XCTAssert(valMembers.count == allMembers.count)

        let reqMembers = entity.allRequiredMembers

        XCTAssert(valMembers.count != reqMembers.count)
        XCTAssert(reqMembers.count == 2)
    }

    func testDisplayName()
    {
        struct SomeEntity: ValidatableEntity {}

        XCTAssert(SomeEntity.displayName == SomeEntity.intrinsicDisplayName)

        //---

        struct CustomNamedEntity: ValidatableEntity
        {
            static
            let someStr = "This is a custom named Entity"

            static
            let displayName = someStr
        }

        XCTAssert(CustomNamedEntity.displayName != CustomNamedEntity.intrinsicDisplayName)
        XCTAssert(CustomNamedEntity.displayName == CustomNamedEntity.someStr)
    }

    func testDefaultValueReport()
    {
        struct SomeEntity: ValidatableEntity {}

        let defaultReport = SomeEntity.defaultReport(with: [])

        let report = SomeEntity.prepareReport(with: [])

        XCTAssert(report == defaultReport)
    }

    func testCustomEntityReport()
    {
        struct SomeEntity: ValidatableEntity
        {
            static
            let customReport = ("This is", "it!")

            //---

            static
            var reviewReport: EntityReportReview
            {
                // by default, we don't adjust anything in the report
                return {

                    _, report in

                    //---

                    report = customReport
                }
            }
        }

        let defaultReport = SomeEntity.defaultReport(with: [])

        let report = SomeEntity.prepareReport(with: [])

        XCTAssert(report != defaultReport)
        XCTAssert(report == SomeEntity.customReport)
    }

    func testManualValidation()
    {
        struct ManualValidationEntity: ValidatableEntity
        {
            static
            let someStr = "Is invalid"

            func validate() throws
            {
                let issues: [ValidationError] = [
                    .valueIsNotValid(
                        origin: "Some wrapper",
                        value: "Some value",
                        failedConditions: ["Test condition"],
                        report: (title: "Some test value", message: type(of: self).someStr)
                    )
                ]

                throw issues.asValidationIssues(for: self)
            }
        }

        //---

        do
        {
            try ManualValidationEntity().validate()

            XCTFail("Should not get here ever")
        }
        catch ValidationError.entityIsNotValid(
            let origin,
            let issues,
            _
            )
        {
            XCTAssert(origin == ManualValidationEntity.displayName)
            XCTAssert(issues.count == 1) // exactly as we've sent

            let report = issues[0].report

            XCTAssert(report.message == ManualValidationEntity.someStr)
        }
        catch
        {
            print(error)
            XCTFail("Should not get here ever")
        }
    }

    func testAutoValidatable()
    {
        struct SimpleWrapper: BasicValueWrapper,
            Validatable
        {
            static
            let someStr = "Is invalid"

            typealias Value = String?

            var value: Value

            init(wrappedValue: Value) { self.value = wrappedValue }

            func validate() throws
            {
                if
                    value == nil
                {
                    throw ValidationError.mandatoryValueIsNotSet(
                        origin: type(of: self).displayName,
                        report: (
                            title: "Mandatory value is missing",
                            message: type(of: self).someStr
                        )
                    )
                }
            }
        }

        struct AutoValidationEntity: ValidatableEntity
        {
            let stringWrapper: SimpleWrapper
        }

        //---

        do
        {
            try AutoValidationEntity
                .init(stringWrapper: SimpleWrapper(wrappedValue: nil))
                .validate()

            XCTFail("Should not get here ever")
        }
        catch ValidationError.entityIsNotValid(
            let origin,
            let issues,
            _
            )
        {
            XCTAssert(origin == AutoValidationEntity.displayName)
            XCTAssert(issues.count == 1)

            let report = issues[0].report

            XCTAssert(report.message == SimpleWrapper.someStr)
        }
        catch
        {
            print(error)
            XCTFail("Should not get here ever")
        }

        //---

        do
        {
            try AutoValidationEntity
                .init(stringWrapper: SimpleWrapper(wrappedValue: "Some valid value"))
                .validate()
        }
        catch
        {
            print(error)
            XCTFail("Should not get here ever")
        }
    }
}
