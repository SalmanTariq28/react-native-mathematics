@objc(Mathematics)
class Mathematics: NSObject {
 
    @objc(calculate:withResolver:withRejecter:)
    func calculate(
        formulae: [String: [String: Any]],
        resolve: RCTPromiseResolveBlock,
        reject: RCTPromiseRejectBlock
    ) -> Void {
        let output: NSMutableDictionary = [:]

        for (key, data) in formulae {
            guard let rawFormula = data["formula"] as? String,
                  let constants = data["values"] as? [String: Double] else {
                NSLog("Error: Missing or invalid formula/constants for key %@", key)
                continue
            }

            // Use third-party evaluation for the formula
            var expression = rawFormula // formula with ^ intact

            // Replace ^ with ** for exponentiation
            expression = expression.replacingOccurrences(of: "^", with: "**")

            // Replace constant names with their actual values
            for (constantKey, constantValue) in constants {
                expression = expression.replacingOccurrences(of: constantKey, with: String(constantValue))
            }

            do {
                let evaluator = DoubleEvalConfiguration()
                let compiled = try Evaluator.compile(expression: expression, configuration: evaluator)

                // create map for constants to setConstants
                constants.forEach { (key, value) in
                    compiled.setConstant(name: key, value: value)
                }
                let result = try compiled.execute() as? Double
                output.setValue(result, forKey: key)
            } catch let error {
                NSLog("Error evaluating formula for key %@: %@", key, error.localizedDescription)
            }
        }

        resolve(output)
    }
}
