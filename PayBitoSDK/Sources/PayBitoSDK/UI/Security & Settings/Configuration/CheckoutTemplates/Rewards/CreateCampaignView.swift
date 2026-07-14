////
////  CreateCampaignView.swift
////  PaymentsTerminsl
////
////  Created by Sk Jasimuddin on 29/05/26.
////
//
////import SwiftUI
////
////struct CreateCampaignView: View {
////    
////    @Environment(\.dismiss)
////    private var dismiss
////    
////    @StateObject
////    private var vm =
////    CreateCampaignViewModel()
////    
////    var body: some View {
////        
////        ZStack {
////            
////            Color(hex: "#090d18")
////                .ignoresSafeArea()
////            
////            ScrollView {
////                
////                VStack(
////                    spacing: 18
////                ) {
////                    
////                    header
////                    
////                    CampaignStatusBanner(
////                        isScheduled:
////                            vm.isScheduled
////                    )
////                    
////                    RequiredFieldsCard(
////                        canSubmit:
////                            vm.canSubmit
////                    )
////                    
////                    CampaignNameCard(
////                        text:
////                            $vm.form.campaignName
////                    )
////                    
////                    RewardTypeSection(
////                        selection:
////                            $vm.form.rewardType
////                    )
////                    
////                    RewardRateCard(
////                        rewardRate:
////                            $vm.form.rewardRate,
////                        
////                        minPurchase:
////                            $vm.form.minPurchase,
////                        
////                        maxReward:
////                            $vm.form.maxReward
////                    )
////                    
////                    DateRangeCard(
////                        form:
////                            $vm.form
////                    )
////                    
////                    ScheduleCard(
////                        form:
////                            $vm.form
////                    )
////                    
////                    CampaignPreviewCard(
////                        form:
////                            vm.form
////                    )
////                }
////                .padding()
////            }
////            
////            bottomBar
////        }
////    }
////    private var bottomBar: some View {
////        
////        VStack {
////            
////            Spacer()
////            
////            HStack {
////                
////                Button("Cancel") {
////                    dismiss()
////                }
////                
////                Spacer()
////                
////                Button {
////                    
////                    vm.saveCampaign()
////                    
////                } label: {
////                    
////                    if vm.isLoading {
////                        
////                        ProgressView()
////                        
////                    } else {
////                        
////                        Text(
////                            vm.form.campaignId == nil
////                            ? "Create Campaign"
////                            : "Update Campaign"
////                        )
////                    }
////                }
////                .disabled(!vm.canSubmit)
////            }
////            .padding()
////            .background(
////                Color(hex: "#141b2d")
////            )
////        }
////    }
////    
////    struct RequiredFieldsCard: View {
////        
////        let canSubmit: Bool
////        
////        var body: some View {
////            
////            Text(
////                canSubmit
////                ? "Ready"
////                : "Missing Required Fields"
////            )
////            .foregroundColor(.white)
////        }
////    }
////    struct CampaignNameCard: View {
////        
////        @Binding var text: String
////        
////        var body: some View {
////            
////            TextField(
////                "Campaign Name",
////                text: $text
////            )
////        }
////    }
////    private var header: some View {
////        
////        HStack {
////            Button {
////                dismiss()
////            } label: {
////                Image(systemName: "arrow.left")
////                    .foregroundColor(.white)
////            }
////            
////            VStack(alignment: .leading) {
////                Text("Create Reward Campaign")
////                    .font(.title2.bold())
////                    .foregroundColor(.white)
////                
////                Text("Set up reward campaigns")
////                    .font(.caption)
////                    .foregroundColor(.gray)
////            }
////            
////            Spacer()
////        }
////    }
////    struct CampaignStatusBanner: View {
////        
////        let isScheduled: Bool
////        
////        var body: some View {
////            
////            Text(
////                isScheduled
////                ? "Scheduled Campaign"
////                : "Active Campaign"
////            )
////            .foregroundColor(.white)
////            .frame(maxWidth: .infinity)
////            .padding()
////            .background(Color.green.opacity(0.2))
////            .cornerRadius(12)
////        }
////    }
////    struct RewardTypeSection: View {
////        
////        @Binding var selection: String
////        
////        var body: some View {
////            
////            VStack(alignment: .leading) {
////                
////                Text("Reward Type")
////                    .foregroundColor(.white)
////                
////                Picker(
////                    "Reward Type",
////                    selection: $selection
////                ) {
////                    Text("Cashback")
////                        .tag("cashback")
////                    
////                    Text("Store Credit")
////                        .tag("store_credit")
////                }
////                .pickerStyle(.segmented)
////            }
////        }
////    }
////    struct RewardRateCard: View {
////        
////        @Binding var rewardRate: String
////        @Binding var minPurchase: String
////        @Binding var maxReward: String
////        
////        var body: some View {
////            
////            VStack {
////                
////                TextField(
////                    "Reward Rate",
////                    text: $rewardRate
////                )
////                
////                TextField(
////                    "Min Purchase",
////                    text: $minPurchase
////                )
////                
////                TextField(
////                    "Max Reward",
////                    text: $maxReward
////                )
////            }
////            .padding()
////            .background(Color.white.opacity(0.05))
////            .cornerRadius(12)
////        }
////    }
////    struct DateRangeCard: View {
////        
////        @Binding var form: CampaignFormState
////        
////        var body: some View {
////            
////            Text("Date Range")
////                .foregroundColor(.white)
////                .frame(maxWidth: .infinity)
////                .padding()
////                .background(Color.white.opacity(0.05))
////                .cornerRadius(12)
////        }
////    }
////    struct ScheduleCard: View {
////        
////        @Binding var form: CampaignFormState
////        
////        var body: some View {
////            
////            Text("Schedule")
////                .foregroundColor(.white)
////                .frame(maxWidth: .infinity)
////                .padding()
////                .background(Color.white.opacity(0.05))
////                .cornerRadius(12)
////        }
////    }
////    struct CampaignPreviewCard: View {
////        
////        let form: CampaignFormState
////        
////        var body: some View {
////            
////            VStack(alignment: .leading) {
////                
////                Text("Preview")
////                    .foregroundColor(.white)
////                
////                Text(form.campaignName)
////                    .foregroundColor(.gray)
////            }
////            .frame(maxWidth: .infinity, alignment: .leading)
////            .padding()
////            .background(Color.white.opacity(0.05))
////            .cornerRadius(12)
////        }
////    }
////}
//
//import SwiftUI
//
//struct CreateCampaignView: View {
//
//    @Environment(\.dismiss) private var dismiss
//
//    @State private var campaignName = ""
//    @State private var rewardType = 0
//
//    @State private var rewardRate = ""
//    @State private var minPurchase = ""
//    @State private var maxReward = ""
//
//    @State private var startDate = Date()
//    @State private var endDate = Date()
//
//    @State private var noEndDate = false
//
//    @State private var selectedDay = "Every Day"
//
//    @State private var startTime = Date()
//    @State private var endTime = Date()
//
//    let days = [
//        "Every Day",
//        "Monday",
//        "Tuesday",
//        "Wednesday",
//        "Thursday",
//        "Friday",
//        "Saturday",
//        "Sunday"
//    ]
//
//    var body: some View {
//
//        ScrollView {
//
//            VStack(spacing: 20) {
//
//                // MARK: Status
//
//                VStack(spacing: 8) {
//
//                    Image(systemName: "gift.fill")
//                        .font(.system(size: 40))
//                        .foregroundColor(.blue)
//
//                    Text("Create Reward Campaign")
//                        .font(.title2.bold())
//
//                    Text("Configure cashback and reward campaigns")
//                        .font(.subheadline)
//                        .foregroundColor(.secondary)
//                }
//
//                // MARK: Campaign Name
//
//                GroupBox("Campaign Name") {
//
//                    TextField(
//                        "Weekend Cashback",
//                        text: $campaignName
//                    )
//                    .textFieldStyle(.roundedBorder)
//                }
//
//                // MARK: Reward Type
//
//                GroupBox("Reward Type") {
//
//                    Picker(
//                        "Reward Type",
//                        selection: $rewardType
//                    ) {
//
//                        Text("Cashback")
//                            .tag(0)
//
//                        Text("Store Credit")
//                            .tag(1)
//                    }
//                    .pickerStyle(.segmented)
//                }
//
//                // MARK: Reward Settings
//
//                GroupBox("Reward Settings") {
//
//                    VStack(spacing: 12) {
//
//                        TextField(
//                            "Reward Rate (%)",
//                            text: $rewardRate
//                        )
//                        .keyboardType(.decimalPad)
//                        .textFieldStyle(.roundedBorder)
//
//                        TextField(
//                            "Minimum Purchase",
//                            text: $minPurchase
//                        )
//                        .keyboardType(.decimalPad)
//                        .textFieldStyle(.roundedBorder)
//
//                        TextField(
//                            "Maximum Reward",
//                            text: $maxReward
//                        )
//                        .keyboardType(.decimalPad)
//                        .textFieldStyle(.roundedBorder)
//                    }
//                }
//
//                // MARK: Date Range
//
//                GroupBox("Campaign Date Range") {
//
//                    VStack(spacing: 12) {
//
//                        DatePicker(
//                            "Start Date",
//                            selection: $startDate,
//                            displayedComponents: .date
//                        )
//
//                        if !noEndDate {
//
//                            DatePicker(
//                                "End Date",
//                                selection: $endDate,
//                                displayedComponents: .date
//                            )
//                        }
//
//                        Toggle(
//                            "No End Date",
//                            isOn: $noEndDate
//                        )
//                    }
//                }
//
//                // MARK: Schedule
//
//                GroupBox("Schedule") {
//
//                    VStack(spacing: 12) {
//
//                        Picker(
//                            "Day",
//                            selection: $selectedDay
//                        ) {
//
//                            ForEach(days, id: \.self) { day in
//                                Text(day)
//                                    .tag(day)
//                            }
//                        }
//
//                        DatePicker(
//                            "Start Time",
//                            selection: $startTime,
//                            displayedComponents: .hourAndMinute
//                        )
//
//                        DatePicker(
//                            "End Time",
//                            selection: $endTime,
//                            displayedComponents: .hourAndMinute
//                        )
//                    }
//                }
//
//                // MARK: Preview
//
//                GroupBox("Preview") {
//
//                    VStack(
//                        alignment: .leading,
//                        spacing: 8
//                    ) {
//
//                        Text("Campaign")
//                            .font(.headline)
//
//                        Text(
//                            campaignName.isEmpty
//                            ? "Campaign Name"
//                            : campaignName
//                        )
//
//                        Text(
//                            rewardType == 0
//                            ? "Cashback"
//                            : "Store Credit"
//                        )
//
//                        if !rewardRate.isEmpty {
//                            Text("Reward Rate: \(rewardRate)%")
//                        }
//                    }
//                    .frame(
//                        maxWidth: .infinity,
//                        alignment: .leading
//                    )
//                }
//
//                // MARK: Buttons
//
//                HStack(spacing: 12) {
//
//                    Button("Cancel") {
//                        dismiss()
//                    }
//                    .buttonStyle(.bordered)
//
//                    Button("Create Campaign") {
//
//                    }
//                    .buttonStyle(.borderedProminent)
//                }
//            }
//            .padding()
//        }
//        .navigationTitle("Create Campaign")
//        .navigationBarTitleDisplayMode(.inline)
//    }
//}
//
//#Preview {
//    NavigationStack {
//        CreateCampaignView()
//    }
//}

import SwiftUI

struct CreateCampaignView: View {
    @StateObject private var vm = CreateCampaignViewModel()
    private let bgColor = Color(
        red: 0.08,
        green: 0.09,
        blue: 0.12
    )

    private let cardColor = Color(
        red: 0.11,
        green: 0.13,
        blue: 0.17
    )

    private let fieldColor = Color(
        red: 0.13,
        green: 0.15,
        blue: 0.20
    )

    private let borderColor = Color(
        red: 0.22,
        green: 0.25,
        blue: 0.32
    )

    private let purpleColor = Color(
        red: 0.56,
        green: 0.27,
        blue: 0.90
    )

    private let greenColor = Color(
        red: 0.20,
        green: 0.85,
        blue: 0.55
    )

    private let subtitleColor = Color(
        red: 0.55,
        green: 0.58,
        blue: 0.65
    )

    private let ruleBg = Color(
        red: 0.10,
        green: 0.12,
        blue: 0.16
    )

    @Environment(\.dismiss) private var dismiss

    @State private var campaignName = ""

    @State private var rewardType = 0

    @State private var rewardRate = ""
    @State private var minPurchase = ""
    @State private var maxReward = ""

    @State private var startDate = Date()
    @State private var endDate = Date()

    @State private var noEndDate = false

    @State private var selectedDay = "Any Day"

    @State private var startTime = Date()
    @State private var endTime = Date()

    private let days = [
        "Any Day",
        "Monday",
        "Tuesday",
        "Wednesday",
        "Thursday",
        "Friday",
        "Saturday",
        "Sunday"
    ]

    var body: some View {

        ZStack {

            bgColor
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {

                VStack(spacing: 18) {

                    headerSection

                    statusBanner

                    requiredInfoCard

                    campaignNameCard

                    rewardTypeCard

                    rewardSettingsCard

                    dateRangeCard

                    scheduleCard

                    Spacer()
                        .frame(height: 100)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }
        }
        .safeAreaInset(edge: .bottom) {
            bottomBar
        }
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - Header

extension CreateCampaignView {

    private var headerSection: some View {

        HStack(spacing: 12) {

            Button {
                dismiss()
            } label: {

                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 46, height: 46)
                    .background(cardColor)
                    .cornerRadius(14)
            }

            Circle()
                .fill(Color.accentPurple.opacity(0.15))
                .frame(width: 46, height: 46)
                .overlay {
                    Image(systemName: "plus")
                        .foregroundColor(.accentPurple)
                }

            Text("Create Reward Campaign")
                .font(.title3.bold())
                .foregroundColor(.white)

            Spacer()
        }
    }
}

// MARK: - Status Banner

extension CreateCampaignView {

    private var statusBanner: some View {

        HStack(spacing: 14) {

            RoundedRectangle(cornerRadius: 16)
                .fill(Color.green.opacity(0.15))
                .frame(width: 60, height: 60)
                .overlay {
                    Image(systemName: "gift")
                        .font(.system(size: 24))
                        .foregroundColor(.green)
                }

            VStack(alignment: .leading, spacing: 4) {

                Text("✅ Active Campaign")
                    .font(.headline)
                    .foregroundColor(.green)

                Text("This campaign will run immediately once activated")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Spacer()

            Text("ACTIVE")
                .font(.caption.bold())
                .foregroundColor(.green)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.green.opacity(0.15))
                .cornerRadius(20)
        }
        .padding()
        .background(
            LinearGradient(
                colors: [
                    Color.green.opacity(0.15),
                    Color.green.opacity(0.05)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(22)
    }
}

// MARK: - Required Info

extension CreateCampaignView {

    private var requiredInfoCard: some View {

        VStack(alignment: .leading, spacing: 12) {

            HStack {

                Image(systemName: "exclamationmark.circle")
                    .foregroundColor(.red)

                Text("Required Information")
                    .font(.headline)
                    .foregroundColor(.white)
            }

            Text("⚠ Please fill in the following required fields:")
                .foregroundColor(.red)

            VStack(alignment: .leading, spacing: 6) {

                Text("• Campaign name")
                Text("• Reward rate (1–100%)")
                Text("• Start date")
            }
            .foregroundColor(.gray)
        }
        .padding()
        .background(cardColor)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    style: StrokeStyle(
                        lineWidth: 1,
                        dash: [8]
                    )
                )
                .foregroundColor(borderColor)
        )
        .cornerRadius(20)
    }
}

// MARK: - Campaign Name

extension CreateCampaignView {

    private var campaignNameCard: some View {

        DarkCard {

            VStack(alignment: .leading, spacing: 14) {

                titleRow(
                    icon: "pencil",
                    title: "Campaign Name",
                    required: true
                )

                TextField(
                    "",
                    text: $campaignName,
                    prompt: Text("e.g. Weekend Cashback")
                        .foregroundColor(.gray)
                )
                .foregroundColor(.white)
                .padding()
                .background(fieldColor)
                .cornerRadius(14)
            }
        }
    }
}

// MARK: - Reward Type

extension CreateCampaignView {

    private var rewardTypeCard: some View {

        DarkCard {

            VStack(alignment: .leading, spacing: 14) {

                titleRow(
                    icon: "gift",
                    title: "Reward Type",
                    required: true
                )

                HStack(spacing: 12) {

                    rewardOption(
                        title: "Cashback",
                        subtitle: "Real money credited to customer wallet",
                        selected: rewardType == 0
                    ) {
                        rewardType = 0
                    }

                    rewardOption(
                        title: "Store Credit",
                        subtitle: "Merchant specific redeemable credit",
                        selected: rewardType == 1
                    ) {
                        rewardType = 1
                    }
                }
            }
        }
    }
}

// MARK: - Reward Settings

extension CreateCampaignView {

    private var rewardSettingsCard: some View {

        DarkCard {

            VStack(alignment: .leading, spacing: 16) {

                titleRow(
                    icon: "percent",
                    title: "Reward Rate & Limits",
                    required: true
                )

                darkField(
                    title: "REWARD RATE (%) *",
                    value: $rewardRate,
                    placeholder: "5"
                )

                HStack {

                    darkField(
                        title: "MIN PURCHASE",
                        value: $minPurchase,
                        placeholder: "$0.00"
                    )

                    darkField(
                        title: "MAX REWARD",
                        value: $maxReward,
                        placeholder: "$0.00"
                    )
                }
            }
        }
    }
}

// MARK: - Date Range

extension CreateCampaignView {

    private var dateRangeCard: some View {

        DarkCard {

            VStack(alignment: .leading, spacing: 16) {

                titleRow(
                    icon: "calendar",
                    title: "Campaign Date Range",
                    required: true
                )

                DatePicker(
                    "Start Date",
                    selection: $startDate,
                    displayedComponents: .date
                )
                .colorScheme(.dark)

                DatePicker(
                    "End Date",
                    selection: $endDate,
                    displayedComponents: .date
                )
                .colorScheme(.dark)

                Toggle(
                    "No end date — run indefinitely",
                    isOn: $noEndDate
                )
                .tint(.accentPurple)
                .foregroundColor(.white)
            }
        }
    }
}

// MARK: - Schedule

extension CreateCampaignView {

    private var scheduleCard: some View {

        DarkCard {

            VStack(alignment: .leading, spacing: 16) {

                titleRow(
                    icon: "clock",
                    title: "Day & Time Schedule",
                    required: false
                )

                VStack(alignment: .leading, spacing: 14) {

                    Text("TIME WINDOW (OPTIONAL)")
                        .font(.caption.bold())
                        .foregroundColor(.gray)

                    Picker(
                        "Day",
                        selection: $selectedDay
                    ) {

                        ForEach(days, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(.white)

                    DatePicker(
                        "Start Time",
                        selection: $startTime,
                        displayedComponents: .hourAndMinute
                    )
                    .colorScheme(.dark)

                    DatePicker(
                        "End Time",
                        selection: $endTime,
                        displayedComponents: .hourAndMinute
                    )
                    .colorScheme(.dark)

                    Text("ⓘ Runs every day, all hours")
                        .foregroundColor(.gray)
                }
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(
                            style: StrokeStyle(
                                lineWidth: 1,
                                dash: [8]
                            )
                        )
                        .foregroundColor(borderColor)
                )
            }
        }
    }
}

// MARK: - Bottom Bar

extension CreateCampaignView {

    private var bottomBar: some View {

        HStack(spacing: 12) {

            Button("Cancel") {

            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .foregroundColor(.white)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        Color.accentPurple,
                        lineWidth: 2
                    )
            )

            Button {

                vm.campaignName = campaignName

                vm.rewardType = rewardType

                vm.rewardRate = rewardRate

                vm.minPurchase = minPurchase

                vm.maxReward = maxReward

                vm.startDate = startDate

                vm.endDate = endDate

                vm.noEndDate = noEndDate

                vm.saveCampaign()

            } label: {

                if vm.isLoading {

                    ProgressView()

                        .tint(.white)

                } else {

                    Text("Create Campaign")

                }

            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color.accentPurple)
            .foregroundColor(.white)
            .cornerRadius(16)
        }
        .padding()
        .background(bgColor)
    }
}

// MARK: - Components

extension CreateCampaignView {

    func titleRow(
        icon: String,
        title: String,
        required: Bool
    ) -> some View {

        HStack {

            Image(systemName: icon)
                .foregroundColor(.accentPurple)

            Text(title)
                .foregroundColor(.white)
                .font(.headline)

            if required {

                Text("required")
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.red.opacity(0.15))
                    .cornerRadius(8)
            }

            Spacer()
        }
    }

    func rewardOption(
        title: String,
        subtitle: String,
        selected: Bool,
        action: @escaping () -> Void
    ) -> some View {

        Button(action: action) {

            VStack(alignment: .leading, spacing: 12) {

                HStack {

                    Image(systemName: "gift")

                    Spacer()

                    if selected {
                        Image(systemName: "checkmark.circle.fill")
                    }
                }

                Text(title)
                    .font(.headline)

                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .frame(height: 160)
            .background(fieldColor)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(
                        selected
                        ? purpleColor
                        : borderColor,
                        lineWidth: selected ? 2 : 1
                    )
            )
            .cornerRadius(18)
        }
    }

    func darkField(
        title: String,
        value: Binding<String>,
        placeholder: String
    ) -> some View {

        VStack(alignment: .leading, spacing: 8) {

            Text(title)
                .font(.caption.bold())
                .foregroundColor(.gray)

            TextField(
                "",
                text: value,
                prompt: Text(placeholder)
                    .foregroundColor(.gray)
            )
            .foregroundColor(.white)
            .padding()
            .background(fieldColor)
            .cornerRadius(14)
        }
    }
}

// MARK: - Dark Card

struct DarkCard<Content: View>: View {

    let content: Content

    init(
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
    }

    var body: some View {

        content
            .padding(16)
            .background(
                Color(
                    red: 0.11,
                    green: 0.13,
                    blue: 0.17
                )
            )
            .cornerRadius(18)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(
                        Color(
                            red: 0.22,
                            green: 0.25,
                            blue: 0.32
                        ),
                        lineWidth: 1
                    )
            )
    }
}



#Preview {
    NavigationStack {
        CreateCampaignView()
    }
}
