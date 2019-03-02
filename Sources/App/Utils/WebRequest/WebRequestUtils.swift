import Vapor
import Leaf
import RoasterHammer_Shared

struct WebRequestUtils {

    func addRuleRequest(forRuleData ruleData: DynamicFormData) -> [AddRuleRequest] {
        var rules: [AddRuleRequest] = []
        for ruleDictionary in ruleData.values {
            if let ruleName = ruleDictionary["name"], ruleName.count > 0,
                let ruleDescription = ruleDictionary["description"], ruleDescription.count > 0 {
                let rule = AddRuleRequest(name: ruleName,
                                          description: ruleDescription)
                rules.append(rule)
            }
        }

        return rules
    }

}
