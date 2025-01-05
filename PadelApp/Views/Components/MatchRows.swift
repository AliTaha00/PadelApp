import SwiftUI

struct OpenMatchRow: View {
    let match: OpenMatch
    
    var body: some View {
        NavigationLink(destination: OpenMatchDetailView(match: match)) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(match.facilityName)
                        .font(.headline)
                    Spacer()
                    Text(match.matchType)
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
                
                HStack {
                    Image(systemName: "calendar")
                    Text(match.date.formatted(date: .long, time: .omitted))
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
                
                HStack {
                    Image(systemName: "clock")
                    Text("\(match.timeSlot.formatted(date: .omitted, time: .shortened)) (\(match.duration) min)")
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
                
                HStack {
                    Image(systemName: "person.2")
                    Text(match.genderPreference)
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
        }
    }
} 