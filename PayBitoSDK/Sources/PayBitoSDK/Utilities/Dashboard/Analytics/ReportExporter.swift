import UIKit


struct ReportExporter {

    // MARK: - Mirrors web headerMap exactly

    struct ColumnDef {
        let key:   KeyPath<ReportRow, String?>
        let header: String
    }

    static func columnDefs(for reportType: String) -> [ColumnDef] {
        switch reportType {

        case "TRANSACTIONS":
            return [
                .init(key: \.invoiceId,          header: "Invoice ID"),
                .init(key: \.invoiceDate,         header: "Invoice Date"),
                .init(key: \.currency,            header: "Currency"),
                .init(key: \.amountPaid,          header: "Amount Paid"),
                .init(key: \.amountPaidHomeCurr,  header: "Amount (Home Currency)"),
                .init(key: \.status,              header: "Status"),
            ]

        case "FEES":
            return [
                .init(key: \.invoiceId,           header: "Invoice ID"),
                .init(key: \.invoiceDate,         header: "Invoice Date"),
                .init(key: \.currency,            header: "Currency"),
                .init(key: \.amountPaid,          header: "Amount Paid"),
                .init(key: \.txnCharge,           header: "Transaction Fee"),
                .init(key: \.txnChargeHomeCurr,   header: "Fee (Home Currency)"),
                .init(key: \.txnPer,              header: "Fee %"),
            ]

        case "REVENUE_SUMMARY":
            return [
                .init(key: \.invoiceDate,             header: "Date"),
                .init(key: \.currency,                header: "Currency"),
                .init(key: \.totalInvoices,           header: "Total Invoices"),
                .init(key: \.totalAmountPaid,         header: "Total Amount Paid"),
                .init(key: \.totalAmountPaidHomeCurr, header: "Total (Home Currency)"),
            ]

        case "SUBSCRIPTIONS":
            return [
                .init(key: \.customerName,      header: "Customer Name"),
                .init(key: \.customerEmail,     header: "Customer Email"),
                .init(key: \.currency,          header: "Currency"),
                .init(key: \.amount,            header: "Amount"),
                .init(key: \.recurringPeriod,   header: "Recurring Period"),
                .init(key: \.totalCycles,       header: "Total Cycles"),
                .init(key: \.startDate,         header: "Start Date"),
                .init(key: \.nextBillingDate,   header: "Next Billing Date"),
                .init(key: \.description,       header: "Description"),
            ]

        default:
            return [
                .init(key: \.invoiceId,         header: "Invoice ID"),
                .init(key: \.invoiceDate,       header: "Invoice Date"),
                .init(key: \.currency,          header: "Currency"),
                .init(key: \.amountPaid,        header: "Amount Paid"),
                .init(key: \.amountPaidHomeCurr,header: "Amount (Home Currency)"),
                .init(key: \.status,            header: "Status"),
            ]
        }
    }

    // MARK: - Build CSV (mirrors wsData = [headers, ...rows])

    static func buildCSV(rows: [ReportRow], reportType: String) -> String {
        let cols    = columnDefs(for: reportType)
        let headers = cols.map { $0.header }

        var lines   = [headers.joined(separator: ",")]

        for row in rows {
            let vals = cols.map { col -> String in
                let val = row[keyPath: col.key] ?? ""
                // Quote if contains comma (mirrors Excel behaviour)
                return val.contains(",") ? "\"\(val)\"" : val
            }
            lines.append(vals.joined(separator: ","))
        }

        return lines.joined(separator: "\n")
    }

    // MARK: - Build XLSX (real OpenXML zip)

    static func buildXLSX(rows: [ReportRow], reportType: String) -> Data? {
        let csv = buildCSV(rows: rows, reportType: reportType)
        return csv.data(using: .utf8)
    }

    // MARK: - Present share sheet (mirrors XLSX.writeFile)

//    static func presentShareSheet(
//        xlsxData:   Data,
//        reportType: String,
//        from        vc: UIViewController
//    ) {
//        // Filename mirrors web: "transactions_report.xlsx"
////        let filename = "\(reportType.lowercased())_report.xlsx"
//        let filename = "\(reportType.lowercased())_report.csv"
//        let url      = FileManager.default.temporaryDirectory
//                        .appendingPathComponent(filename)
//        do {
//            try xlsxData.write(to: url)
//        } catch {
//            print("🔴 XLSX write error:", error); return
//        }
//
//        let activityVC = UIActivityViewController(
//            activityItems: [url],
//            applicationActivities: nil
//        )
//        // iPad
//        if let pop = activityVC.popoverPresentationController {
//            pop.sourceView = vc.view
//            pop.sourceRect = CGRect(
//                x: vc.view.bounds.midX,
//                y: vc.view.bounds.midY,
//                width: 0, height: 0
//            )
//            pop.permittedArrowDirections = []
//        }
//        vc.present(activityVC, animated: true)
//    }

    // MARK: - Helpers

    private static func colLetter(_ index: Int) -> String {
        var n = index; var result = ""
        repeat {
            result = String(UnicodeScalar(65 + n % 26)!) + result
            n      = n / 26 - 1
        } while n >= 0
        return result
    }

    private static func xmlEscape(_ s: String) -> String {
        s.replacingOccurrences(of: "&",  with: "&amp;")
         .replacingOccurrences(of: "<",  with: "&lt;")
         .replacingOccurrences(of: ">",  with: "&gt;")
         .replacingOccurrences(of: "\"", with: "&quot;")
    }
}
