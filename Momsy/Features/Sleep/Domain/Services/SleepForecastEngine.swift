import Foundation

protocol SleepForecastEngine {
    /// Чистая, детерминированная. nil ⇒ прогноз невозможен (нет birthDate)
    /// или onset попадает в ночь (нечего предлагать до утра).
    /// entries ≈ 14 дней, порядок не важен. «Спит сейчас» = последний entry с endDate == nil.
    func predict(birthDate: Date, entries: [SleepEntry], now: Date) -> SleepPrediction?
}
