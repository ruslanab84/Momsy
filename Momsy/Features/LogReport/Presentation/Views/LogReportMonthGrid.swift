import SwiftUI

struct LogReportMonthGrid: View {
    @ObservedObject var vm: LogReportViewModel

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 6) {
            ForEach(Array(vm.monthDays.enumerated()), id: \.offset) { _, day in
                if let day {
                    dayCell(day)
                } else {
                    Color.clear.frame(height: 44)
                }
            }
        }
        .bbCard(pad: 14)
    }

    private func dayCell(_ day: Date) -> some View {
        let selected = calendar.isDate(day, inSameDayAs: vm.selectedDate)
        let kinds = vm.kinds(on: day)
        return VStack(spacing: 3) {
            Text("\(calendar.component(.day, from: day))")
                .font(.system(size: 13, weight: .heavy, design: .rounded))
                .foregroundColor(selected ? .white : .bbInk)
                .frame(width: 28, height: 28)
                .background(selected ? Color.bbCoralDeep : .clear)
                .clipShape(Circle())
            HStack(spacing: 2) {
                ForEach(kinds, id: \.self) { kind in
                    Circle()
                        .fill(kind.defaultTone)
                        .frame(width: 5, height: 5)
                }
            }
            .frame(height: 6)
        }
        .frame(height: 44)
        .contentShape(Rectangle())
        .onTapGesture { vm.selectedDate = day }
    }
}
