// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import XCTest

@testable import Client

final class SettingsCoordinatorTests: XCTestCase {
    private var mockRouter: MockRouter!
    private var wallpaperManager: WallpaperManagerMock!
    private var delegate: MockSettingsCoordinatorDelegate!

    override func setUp() {
        super.setUp()
        DependencyHelperMock().bootstrapDependencies()
        LegacyFeatureFlagsManager.shared.initializeDeveloperFeatures(with: MockProfile())
        self.mockRouter = MockRouter(navigationController: MockNavigationController())
        self.wallpaperManager = WallpaperManagerMock()
        self.delegate = MockSettingsCoordinatorDelegate()
    }

    override func tearDown() {
        super.tearDown()
        self.mockRouter = nil
        self.wallpaperManager = nil
        self.delegate = nil
        DependencyHelperMock().reset()
    }

    func testEmptyChilds_whenCreated() {
        let subject = createSubject()
        XCTAssertEqual(subject.childCoordinators.count, 0)
    }

    func testGeneralSettingsRoute_showsGeneralSettingsPage() throws {
        let subject = createSubject()

        subject.start(with: .general)

        XCTAssertEqual(mockRouter.pushCalled, 0)
        XCTAssertNil(mockRouter.pushedViewController)
    }

    func testNewTabSettingsRoute_showsNewTabSettingsPage() throws {
        let subject = createSubject()

        subject.start(with: .newTab)

        XCTAssertEqual(mockRouter.pushCalled, 1)
        XCTAssertTrue(mockRouter.pushedViewController is NewTabContentSettingsViewController)
    }

    func testHomepageSettingsRoute_showsHomepageSettingsPage() throws {
        let subject = createSubject()

        subject.start(with: .homePage)

        XCTAssertEqual(mockRouter.pushCalled, 1)
        XCTAssertTrue(mockRouter.pushedViewController is HomePageSettingViewController)
    }

    func testMailtoSettingsRoute_showsMailtoSettingsPage() throws {
        let subject = createSubject()

        subject.start(with: .mailto)

        XCTAssertEqual(mockRouter.pushCalled, 1)
        XCTAssertTrue(mockRouter.pushedViewController is OpenWithSettingsViewController)
    }

    func testSearchSettingsRoute_showsSearchSettingsPage() throws {
        let subject = createSubject()

        subject.start(with: .search)

        XCTAssertEqual(mockRouter.pushCalled, 1)
        XCTAssertTrue(mockRouter.pushedViewController is SearchSettingsTableViewController)
    }

    func testClearPrivateDataSettingsRoute_showsClearPrivateDataSettingsPage() throws {
        let subject = createSubject()

        subject.start(with: .clearPrivateData)

        XCTAssertEqual(mockRouter.pushCalled, 1)
        XCTAssertTrue(mockRouter.pushedViewController is ClearPrivateDataTableViewController)
    }

    func testFxaSettingsRoute_showsFxaSettingsPage() throws {
        let subject = createSubject()

        subject.start(with: .fxa)

        XCTAssertEqual(mockRouter.pushCalled, 1)
        XCTAssertTrue(mockRouter.pushedViewController is FirefoxAccountSignInViewController)
    }

    func testThemeSettingsRoute_showsThemeSettingsPage() throws {
        let subject = createSubject()

        subject.start(with: .theme)

        XCTAssertEqual(mockRouter.pushCalled, 1)
        XCTAssertTrue(mockRouter.pushedViewController is ThemeSettingsController)
    }

    func testWallpaperSettingsRoute_cannotBeShown_showsWallpaperSettingsPage() throws {
        wallpaperManager.canSettingsBeShown = false
        let subject = createSubject()

        subject.start(with: .wallpaper)

        XCTAssertEqual(mockRouter.pushCalled, 0)
        XCTAssertNil(mockRouter.pushedViewController)
    }

    func testWallpaperSettingsRoute_canBeShown_showsWallpaperSettingsPage() throws {
        wallpaperManager.canSettingsBeShown = true
        let subject = createSubject()

        subject.start(with: .wallpaper)

        XCTAssertEqual(mockRouter.pushCalled, 1)
        XCTAssertTrue(mockRouter.pushedViewController is WallpaperSettingsViewController)
    }

    // MARK: - Delegate
    func testParentCoordinatorDelegate_calledWithURL() {
        let subject = createSubject()
        subject.parentCoordinator = delegate

        let expectedURL = URL(string: "www.mozilla.com")!
        subject.settingsOpenURLInNewTab(expectedURL)

        XCTAssertEqual(delegate.openURLinNewTabCalled, 1)
        XCTAssertEqual(delegate.savedURL, expectedURL)
    }

    func testParentCoordinatorDelegate_calledDidFinish() {
        let subject = createSubject()
        subject.parentCoordinator = delegate

        subject.didFinish()

        XCTAssertEqual(delegate.didFinishSettingsCalled, 1)
    }

    // MARK: - Helper
    func createSubject() -> SettingsCoordinator {
        let subject = SettingsCoordinator(router: mockRouter,
                                          wallpaperManager: wallpaperManager)
        trackForMemoryLeaks(subject)
        return subject
    }
}

// MARK: - MockSettingsCoordinatorDelegate
class MockSettingsCoordinatorDelegate: SettingsCoordinatorDelegate {
    var savedURL: URL?
    var openURLinNewTabCalled = 0
    var didFinishSettingsCalled = 0

    func openURLinNewTab(_ url: URL) {
        savedURL = url
        openURLinNewTabCalled += 1
    }

    func didFinishSettings(from coordinator: SettingsCoordinator) {
        didFinishSettingsCalled += 1
    }
}
