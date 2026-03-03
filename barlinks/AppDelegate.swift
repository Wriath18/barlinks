import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var eventMonitor: Any?
    private let viewModel = AppViewModel()

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        setupPopover()
        NSApp.servicesProvider = self
        NSUpdateDynamicServices()
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "link", accessibilityDescription: "barlinks")
            button.action = #selector(togglePopover)
            button.target = self
        }
    }

    private func setupPopover() {
        popover = NSPopover()
        popover.contentSize = NSSize(width: 320, height: 480)
        // .applicationDefined = we control closing; won't auto-dismiss on internal clicks
        popover.behavior = .applicationDefined
        popover.animates = true
        popover.contentViewController = NSHostingController(
            rootView: MainPopoverView()
                .environmentObject(viewModel)
        )
    }

    @objc func togglePopover() {
        if popover.isShown {
            closePopover()
        } else {
            openPopover()
        }
    }

    private func openPopover() {
        guard let button = statusItem.button else { return }
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        popover.contentViewController?.view.window?.makeKey()

        // Global monitor only fires for clicks in OTHER apps, not inside our own popover/sheets
        eventMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.leftMouseDown, .rightMouseDown]
        ) { [weak self] _ in
            self?.closePopover()
        }
    }

    // MARK: - NSServices handler
    // Selector: addToBarLinks:userData:error: — must match NSMessage in Info.plist
    @objc func addToBarLinks(_ pboard: NSPasteboard, userData: String?, error: AutoreleasingUnsafeMutablePointer<NSString?>?) {
        // Prefer the explicit URL type; fall back to plain text (e.g. a selected URL string)
        let urlString = pboard.string(forType: NSPasteboard.PasteboardType("public.url"))
            ?? pboard.string(forType: .string)

        guard let urlString = urlString?.trimmingCharacters(in: .whitespacesAndNewlines),
              !urlString.isEmpty else { return }

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            // If user has no lists yet, create a default one so the sheet is immediately useful
            if self.viewModel.appData.lists.isEmpty {
                self.viewModel.addList(name: "Links")
            }
            self.viewModel.pendingServiceURL = urlString
            NSApp.activate(ignoringOtherApps: true)
            if !self.popover.isShown {
                self.openPopover()
            }
        }
    }

    private func closePopover() {
        popover.performClose(nil)
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }
}
