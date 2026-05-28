import Foundation

enum DailyTipAlgorithm {

    static func evaluate(context: DailyContext) -> DailyTip {
        if let alert = AlertRules.evaluate(context: context) { return alert }
        if let situ  = SituationalRules.evaluate(context: context) { return situ }
        return CareRules.evaluate(context: context)
    }
}
