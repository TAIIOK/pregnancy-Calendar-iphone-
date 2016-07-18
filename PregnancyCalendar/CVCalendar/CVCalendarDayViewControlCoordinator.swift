//
//  CVCalendarDayViewControlCoordinator.swift
//  CVCalendar
//
//  Created by E. Mozharovsky on 12/27/14.
//  Copyright (c) 2014 GameApp. All rights reserved.
//

import UIKit

public final class CVCalendarDayViewControlCoordinator {
    // MARK: - Non public properties
    public var selectionSet = Set<DayView>()
    private unowned let calendarView: CalendarView
    public var selection = false
    // MARK: - Public properties
    public weak var selectedDayView: CVCalendarDayView?
    public var animator: CVCalendarViewAnimator! {
        get {
            return calendarView.animator
        }
    }

    // MARK: - initialization
    public init(calendarView: CalendarView  )
    {
        self.calendarView = calendarView
    }
}

// MARK: - Animator side callback

extension CVCalendarDayViewControlCoordinator {
    public func selectionPerformedOnDayView(dayView: DayView) {
        // TODO:
    }
    
    public func deselectionPerformedOnDayView(dayView: DayView) {
        if dayView != selectedDayView {
            selectionSet.remove(dayView)
            dayView.setDeselectedWithClearing(true)
        }
    }
    
    public func dequeueDayView(dayView: DayView) {
        selectionSet.remove(dayView)
    }
    
    public func flush() {
  
        selectedDayView = nil
        selectionSet.removeAll()
        
    }
}

// MARK: - Animator reference 

private extension CVCalendarDayViewControlCoordinator {
    func presentSelectionOnDayView(dayView: DayView) {
        animator.animateSelectionOnDayView(dayView)
        //animator?.animateSelection(dayView, withControlCoordinator: self)
    }
    func presentSelectionOnDayView_(dayView: DayView) {
        animator.animateSelectionOnDayView_(dayView)
        //animator?.animateSelection(dayView, withControlCoordinator: self)
    }
    
    func presentDeselectionOnDayView(dayView: DayView) {
        animator.animateDeselectionOnDayView(dayView)
        //animator?.animateDeselection(dayView, withControlCoordinator: self)
    }
}

// MARK: - Coordinator's control actions

extension CVCalendarDayViewControlCoordinator {
    
    
    public func setSelection(select:Bool)
    {
        selection = select
    }
    
    public func deselect(days: [DayView])
    {
        for i in days{
            presentDeselectionOnDayView(i)
            selectionSet.remove(i)
        }
    }
    
    public func select(days: [DayView])
    {
        for i in days{
            if !selectionSet.contains(i){
                selectionSet.insert(i)
            }
            presentSelectionOnDayView(i)
        }
    }
    
    public func performDayViewSingleSelection(dayView: DayView) {
        
        if (selectionSet.contains(dayView) && selection)
        {
            presentDeselectionOnDayView(dayView)
            selectionSet.remove(dayView)
        }else{
            selectionSet.insert(dayView)
            if selectionSet.count > 1 {
                for dayViewInQueue in selectionSet {
                    if dayView != dayViewInQueue {
                        if dayView.calendarView != nil {
                            if(!selection){
                                presentDeselectionOnDayView(dayViewInQueue)
                            }
                        }
                    }
                }
            }
        
            if let _ = animator {
                if selectedDayView != dayView {
                    selectedDayView = dayView
                    presentSelectionOnDayView(dayView)
                }
            }
        }
    }
    
    public func performDayViewSingleSelection_(dayView: DayView) {
        
        if (selectionSet.contains(dayView) && selection)
        {
            presentDeselectionOnDayView(dayView)
            selectionSet.remove(dayView)
        }else{
            selectionSet.insert(dayView)
            
            if let _ = animator {
                if selectedDayView != dayView {
                    selectedDayView = dayView
                    presentSelectionOnDayView_(dayView)
                }
            }
        }
    }

    
    public func performDayViewRangeSelection(dayView: DayView) {
        print("Day view range selection found")
    }
}
