import XCERequirement

//===

public
struct MandatoryValue<T>: MandatoryValidatable
{
    public
    typealias Value = T
 
    public
    static
    var requirements: [Requirement<Value>]
    {
        return []
    }
    
    public
    var draft: Draft
    
    public
    init() { }
}

public
protocol MandatoryValidatable: ValidatableValue { }

// MARK: - Custom members

public
extension MandatoryValidatable
{
    public
    var value: Value!
    {
        return try? valueIfValid()
    }
    
    public
    func valueIfValid() throws -> Value
    {
        if
            let result = draft
        {
            // non-'nil' draft value must be checked againts requirements
            
            try type(of: self).requirements.forEach {
                
                try $0.check(with: result) }
            
            //===
            
            return result
        }
        else
        {
            // 'draft' is 'nil', which is NOT allowed
            
            throw ValueNotSet()
        }
    }
}

// MARK: - Validatable support

public
extension MandatoryValidatable
{
    public
    var isValid: Bool
    {
        do
        {
            _ = try valueIfValid()
            
            return true
        }
        catch
        {
            return false
        }
    }
    
    public
    func validate() throws
    {
        _ = try valueIfValid()
    }
}

// MARK: - Extra helpers

public
extension MandatoryValidatable
{
    /**
 
     Executes 'transform' with 'value' if it's available/valid
     
     */
    @discardableResult
    func map<U>(_ transform: (Value) throws -> U) rethrows -> U?
    {
        if
            let result = try? valueIfValid()
        {
            return try transform(result)
        }
        else
        {
            return nil
        }
    }
}
