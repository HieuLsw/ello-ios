//
//  StreamContainerViewController.swift
//  Ello
//
//  Created by Sean on 1/17/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit
import SVGKit

public class StreamContainerViewController: StreamableViewController {

    enum Notifications : String {
        case StreamDetailTapped = "StreamDetailTappedNotification"
    }

    override public var tabBarItem: UITabBarItem? {
        get { return UITabBarItem.svgItem("circbig") }
        set { self.tabBarItem = newValue }
    }

    @IBOutlet weak public var scrollView: UIScrollView!
    @IBOutlet weak public var navigationBar: ElloNavigationBar!
    @IBOutlet weak public var navigationBarTopConstraint: NSLayoutConstraint!

    public var streamsSegmentedControl: UISegmentedControl!
    public var streamControllerViews:[UIView] = []

    override public func backGestureAction() {
        hamburgerButtonTapped()
    }

    override func setupStreamController() { /* intentially left blank */ }

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupStreamsSegmentedControl()
        setupChildViewControllers()
        navigationItem.titleView = streamsSegmentedControl
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: SVGKImage(named: "burger_normal.svg").UIImage!, style: .Done, target: self, action: Selector("hamburgerButtonTapped"))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: SVGKImage(named: "search_normal.svg").UIImage!, style: .Done, target: self, action: Selector("searchButtonTapped"))
        navigationBar.items = [navigationItem]

        scrollLogic.prevOffset = (childViewControllers[0] as! StreamViewController).collectionView.contentOffset
    }

    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateInsets()
    }

    private func updateInsets() {
        for controller in self.childViewControllers as! [StreamViewController] {
            updateInsets(navBar: navigationBar, streamController: controller)
        }
    }

    override public func showNavBars(scrollToBottom : Bool) {
        super.showNavBars(scrollToBottom)
        positionNavBar(navigationBar, visible: true, withConstraint: navigationBarTopConstraint)
        updateInsets()

        if scrollToBottom {
            for controller in childViewControllers as! [StreamViewController] {
                if let scrollView = controller.collectionView {
                    let contentOffsetY : CGFloat = scrollView.contentSize.height - scrollView.frame.size.height
                    if contentOffsetY > 0 {
                        scrollView.scrollEnabled = false
                        scrollView.setContentOffset(CGPoint(x: 0, y: contentOffsetY), animated: true)
                        scrollView.scrollEnabled = true
                    }
                }
            }
        }
    }

    override public func hideNavBars() {
        super.hideNavBars()
        positionNavBar(navigationBar, visible: false, withConstraint: navigationBarTopConstraint)
        updateInsets()
    }

    public class func instantiateFromStoryboard() -> StreamContainerViewController {
        let navController = UIStoryboard.storyboardWithId(.StreamContainer) as! UINavigationController
        let streamsController = navController.topViewController
        return streamsController as! StreamContainerViewController
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let width:CGFloat = scrollView.frame.size.width
        let height:CGFloat = scrollView.frame.size.height
        var x : CGFloat = 0

        for view in streamControllerViews {
            view.frame = CGRect(x: x, y: 0, width: width, height: height)
            x += width
        }

        scrollView.contentSize = CGSize(width: width * CGFloat(count(StreamKind.streamValues)), height: height)
    }

    private func setupChildViewControllers() {
        scrollView.scrollEnabled = false
        let width:CGFloat = scrollView.frame.size.width
        let height:CGFloat = scrollView.frame.size.height

        for (index, kind) in enumerate(StreamKind.streamValues) {
            let vc = StreamViewController.instantiateFromStoryboard()
            vc.currentUser = currentUser
            vc.streamKind = kind
            vc.createCommentDelegate = self
            vc.postTappedDelegate = self
            vc.userTappedDelegate = self
            vc.streamScrollDelegate = self

            vc.willMoveToParentViewController(self)

            let x = CGFloat(index) * width
            let frame = CGRect(x: x, y: 0, width: width, height: height)
            vc.view.frame = frame
            scrollView.addSubview(vc.view)
            streamControllerViews.append(vc.view)

            self.addChildViewController(vc)
            vc.didMoveToParentViewController(self)
            ElloHUD.showLoadingHudInView(vc.view)
            vc.loadInitialPage()
        }
    }

    private func setupNavigationBar() {
        navigationBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 30)
    }

    private func setupStreamsSegmentedControl() {
        let control = UISegmentedControl(items: StreamKind.streamValues.map{ $0.name })
        control.addTarget(self, action: Selector("streamSegmentTapped:"), forControlEvents: .ValueChanged)
        var rect = control.bounds
        rect.size = CGSize(width: rect.size.width, height: 19.0)
        control.bounds = rect
        control.layer.borderColor = UIColor.blackColor().CGColor
        control.layer.borderWidth = 1.0
        control.layer.cornerRadius = 0.0
        control.selectedSegmentIndex = 0
        control.tintColor = .blackColor()
        streamsSegmentedControl = control
    }

    // MARK: - IBActions

    @IBAction func hamburgerButtonTapped() {
        let index = streamsSegmentedControl.selectedSegmentIndex
        let relationship = StreamKind.streamValues[index].relationship
        let drawer = DrawerViewController(relationship: relationship)

        self.navigationController?.pushViewController(drawer, animated: true)
    }

    @IBAction func searchButtonTapped() {
        let search = SearchViewController()
        search.currentUser = currentUser
        self.navigationController?.pushViewController(search, animated: true)
    }

    @IBAction func streamSegmentTapped(sender: UISegmentedControl) {
        let width:CGFloat = view.bounds.size.width
        let height:CGFloat = view.bounds.size.height
        let x = CGFloat(sender.selectedSegmentIndex) * width
        let rect = CGRect(x: x, y: 0, width: width, height: height)
        scrollView.scrollRectToVisible(rect, animated: true)

        let stream = StreamKind.streamValues[sender.selectedSegmentIndex]
        Tracker.sharedTracker.screenAppeared(stream.name)
    }
}
