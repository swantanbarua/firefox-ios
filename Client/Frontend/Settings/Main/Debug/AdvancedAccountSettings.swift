// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

class AdvancedAccountSetting: HiddenSetting {
    let profile: Profile
    private let isHidden: Bool

    override var accessoryView: UIImageView? { return SettingDisclosureUtility.buildDisclosureIndicator(theme: theme) }

    override var accessibilityIdentifier: String? { return "AdvancedAccount.Setting" }

    override var title: NSAttributedString? {
        return NSAttributedString(string: .SettingsAdvancedAccountTitle, attributes: [NSAttributedString.Key.foregroundColor: theme.colors.textPrimary])
    }

    init(settings: SettingsTableViewController, isHidden: Bool) {
        self.profile = settings.profile
        self.isHidden = isHidden
        super.init(settings: settings)
    }

    override func onClick(_ navigationController: UINavigationController?) {
        let viewController = AdvancedAccountSettingViewController()
        viewController.profile = profile
        navigationController?.pushViewController(viewController, animated: true)
    }

    override var hidden: Bool {
        return !isHidden || profile.hasAccount()
    }
}
