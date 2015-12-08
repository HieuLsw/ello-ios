//
//  NotificationBanner.swift
//  Ello
//
//  Created by Gordon Fontenot on 5/21/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import CRToast

public struct NotificationBanner {
    public static func displayAlertForPayload(payload: PushPayload) {
        configureDefaultsWithPayload(payload)
        CRToastManager.showNotificationWithMessage(payload.message) { }
    }
}

private extension NotificationBanner {
    static func configureDefaultsWithPayload(payload: PushPayload) {
        let interactionResponder = CRToastInteractionResponder(interactionType: CRToastInteractionType.Tap, automaticallyDismiss: true) { _ in
            postNotification(PushNotificationNotifications.interactedWithPushNotification, value: payload)
        }

        let dismissResponder = CRToastInteractionResponder(interactionType: CRToastInteractionType.Swipe, automaticallyDismiss: true) { _ in
        }

        CRToastManager.setDefaultOptions(
            [
                kCRToastInteractionRespondersKey: [interactionResponder, dismissResponder],
                kCRToastTimeIntervalKey: 4,
                kCRToastNotificationTypeKey: CRToastType.NavigationBar.rawValue,
                kCRToastNotificationPresentationTypeKey: CRToastPresentationType.Cover.rawValue,

                kCRToastTextColorKey: UIColor.whiteColor(),
                kCRToastBackgroundColorKey: UIColor.blackColor(),

                kCRToastAnimationOutDirectionKey: CRToastAnimationDirection.Top.rawValue,

                kCRToastAnimationInTimeIntervalKey: DefaultAnimationDuration,
                kCRToastAnimationOutTimeIntervalKey: DefaultAnimationDuration,

                kCRToastFontKey: UIFont.defaultFont(),
                kCRToastTextAlignmentKey: NSTextAlignment.Left.rawValue,
                kCRToastTextMaxNumberOfLinesKey: 2,
            ]
        )
    }
}
