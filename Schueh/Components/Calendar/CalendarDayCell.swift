import SwiftUI

struct CalendarDayCell: View {
    let date: Date
    let isHighlighted: Bool
    let isToday: Bool
    
    private var textColor: Color {
        if isToday {
            return .blue
        }
        
        return .primary
    }
    
    var body: some View {
        ZStack {
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.body)
                .foregroundStyle(textColor)
            
            if isHighlighted {
                VStack {
                    Spacer()
                    
                    Circle()
                        .fill(.blue)
                        .frame(width: 5, height: 5)
                        .offset(y: -5)
                }
            }
        }
        .frame(height: 40)
        .contentShape(Rectangle())
    }
}
