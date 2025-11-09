import SwiftUI

struct CalendarView: View {
    let highlightedDates: Set<Date>

    @State private var month: Date
    @State private var selectedDate: Date?

    private let calendar = Calendar.current

    private var daysOfWeek: [String] {
        let formatter = DateFormatter()
        formatter.locale = calendar.locale

        let weekdaySymbols = formatter.shortWeekdaySymbols!
        let firstWeekday = calendar.firstWeekday

        let orderedSymbols =
            Array(weekdaySymbols[firstWeekday - 1..<weekdaySymbols.count])
            + Array(weekdaySymbols[0..<firstWeekday - 1])

        return orderedSymbols
    }

    init(
        month: Date = Date(),
        highlightedDates: Set<Date> = []
    ) {
        self.highlightedDates = highlightedDates
        
        _month = State(initialValue: month)
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(month, format: .dateTime.month(.wide).year())
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                HStack(spacing: 16) {
                    Button(action: { changeMonth(by: -1) }) {
                        Image(systemName: "chevron.left")
                            .foregroundStyle(.tint)
                    }
                    .accessibilityLabel("Previous Month")
                    
                    Button(action: { changeMonth(by: 1) }) {
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.tint)
                    }
                    .accessibilityLabel("Next Month")
                }
                .buttonStyle(.plain)
            }
            .padding(.bottom, 20)
            .padding(.horizontal, 4)

            HStack(spacing: 0) {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.bottom, 8)

            LazyVGrid(
                columns: Array(
                    repeating: GridItem(.flexible(), spacing: 0),
                    count: 7
                ),
                spacing: 8
            ) {
                ForEach(generateDates(), id: \.self) { date in
                    if let date = date {
                        CalendarDayCell(
                            date: date,
                            isHighlighted: isDateHighlighted(date),
                            isToday: calendar.isDateInToday(date)
                        )
                    } else {
                        Color.clear
                            .frame(height: 40)
                    }
                }
            }
        }
    }

    private func changeMonth(by value: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: value, to: month) {
            month = newMonth
        }
    }

    private func generateDates() -> [Date?] {
        guard
            let monthStart = calendar.date(
                from: calendar.dateComponents([.year, .month], from: month)
            ),
            let monthRange = calendar.range(
                of: .day,
                in: .month,
                for: monthStart
            )
        else {
            return []
        }

        let firstWeekday = calendar.component(.weekday, from: monthStart)

        let calendarFirstWeekday = calendar.firstWeekday
        var leadingEmptyDays = firstWeekday - calendarFirstWeekday

        if leadingEmptyDays < 0 {
            leadingEmptyDays += 7
        }

        var dates: [Date?] = Array(repeating: nil, count: leadingEmptyDays)

        for day in monthRange {
            if let date = calendar.date(
                byAdding: .day,
                value: day - 1,
                to: monthStart
            ) {
                dates.append(date)
            }
        }

        while dates.count % 7 != 0 {
            dates.append(nil)
        }

        return dates
    }

    private func isDateHighlighted(_ date: Date) -> Bool {
        highlightedDates.contains { calendar.isDate($0, inSameDayAs: date) }
    }
}
