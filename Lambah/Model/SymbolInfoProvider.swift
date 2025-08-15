//
//  SymbolInfoProvider.swift
//  Lambah
//
//  Created by Reef Saeed on 15/03/2025.
//

import UIKit

struct SymbolInfoProvider {
    
    static func getTitle(for signClass: String) -> String {
        let formattedClass = signClass.lowercased().replacingOccurrences(of: " ", with: "_")
        
        if formattedClass.contains("brake") {
            return "Brake System Issue"
        } else if formattedClass.contains("abs") || formattedClass.contains("anti") {
            return "Anti Lock Braking System"
        } else if formattedClass.contains("charg") || formattedClass.contains("battery") {
            return "Charging System Issue"
        } else if formattedClass.contains("check") || (formattedClass.contains("engine") && !formattedClass.contains("cool")) {
            return "Check Engine"
        } else if formattedClass.contains("door") {
            return "Door Open"
        } else if formattedClass.contains("steer") || formattedClass.contains("eps") {
            return "Electronic Power Steering"
        } else if formattedClass.contains("stab") || formattedClass.contains("esp") {
            return "Electronic Stability Problem"
        } else if formattedClass.contains("temp") || formattedClass.contains("cool") {
            return "High Engine Coolant Temperature"
        } else if formattedClass.contains("oil") {
            return "Low Engine Oil Warning"
        } else if formattedClass.contains("fuel") {
            return "Low Fuel"
        } else if formattedClass.contains("tire") || formattedClass.contains("tpms") {
            return "Low Tire Pressure Warning"
        } else if formattedClass.contains("master") {
            return "Master Warning"
        } else if formattedClass.contains("airbag") || formattedClass.contains("srs") {
            return "SRS-Airbag"
        } else if formattedClass.contains("seat") || formattedClass.contains("belt") {
            return "Seat Belt Warning"
        }
        return signClass.replacingOccurrences(of: "_", with: " ").capitalized
    }
    
    static func getDescription(for signClass: String) -> String {
        let formattedClass = signClass.lowercased().replacingOccurrences(of: " ", with: "_")
        
        if formattedClass.contains("brake") {
            return "Problem with the main braking system."
        } else if formattedClass.contains("abs") || formattedClass.contains("anti") {
            return "Issue with the Anti-Lock Braking System detected."
        } else if formattedClass.contains("charg") || formattedClass.contains("battery") {
            return "The battery is not charging properly while the engine is running."
        } else if formattedClass.contains("engine") || formattedClass.contains("check") {
            return "Engine or emission control system malfunction detected."
        } else if formattedClass.contains("door") {
            return "One or more doors are not completely closed."
        } else if formattedClass.contains("steer") || formattedClass.contains("eps") {
            return "Power steering system malfunction detected."
        } else if formattedClass.contains("stab") || formattedClass.contains("esp") {
            return "Issue with the vehicle stability control system."
        } else if formattedClass.contains("temp") || formattedClass.contains("cool") {
            return "The engine is overheating."
        } else if formattedClass.contains("oil") {
            return "Engine oil pressure is dangerously low."
        } else if formattedClass.contains("fuel") {
            return "Fuel level is critically low."
        } else if formattedClass.contains("tire") || formattedClass.contains("tpms") {
            return "One or more tires have pressure below the recommended level."
        } else if formattedClass.contains("master") || formattedClass.contains("general") {
            return "General vehicle system malfunction detected."
        } else if formattedClass.contains("airbag") || formattedClass.contains("srs") {
            return "Issue with the Supplemental Restraint System (airbags)."
        } else if formattedClass.contains("seat") || formattedClass.contains("belt") {
            return "Driver or passenger seat belt is not fastened."
        }
        return "Dashboard warning indicator requiring attention."
    }
    
    static func getAction(for signClass: String) -> String {
        let formattedClass = signClass.lowercased().replacingOccurrences(of: " ", with: "_")
        
        if formattedClass.contains("brake") {
            return "Action: Check brake fluid level. Have your brake system inspected immediately. Driving with brake issues is dangerous."
        } else if formattedClass.contains("abs") || formattedClass.contains("anti") {
            return "Action: Have your ABS system checked by a professional as soon as possible. Your regular brakes should still work."
        } else if formattedClass.contains("charg") || formattedClass.contains("battery") {
            return "Action: Check the alternator, battery, and electrical connections. Your vehicle may stop running soon."
        } else if formattedClass.contains("engine") || formattedClass.contains("check") {
            return "Action: Have your vehicle diagnosed by a professional. Continue driving only if the light is steady (not flashing)."
        } else if formattedClass.contains("door") {
            return "Action: Stop the vehicle and ensure all doors, hood, and trunk are properly closed before driving."
        } else if formattedClass.contains("steer") || formattedClass.contains("eps") {
            return "Action: Have the power steering system checked by a professional. Steering may become more difficult."
        } else if formattedClass.contains("stab") || formattedClass.contains("esp") {
            return "Action: Have the stability control system checked. Drive cautiously, especially on slippery surfaces."
        } else if formattedClass.contains("temp") || formattedClass.contains("cool") {
            return "Action: Pull over safely, turn off the engine, and allow it to cool down. Check coolant levels when safe."
        } else if formattedClass.contains("oil") {
            return "Action: Stop driving immediately and check oil level. Continuing to drive may cause severe engine damage."
        } else if formattedClass.contains("fuel") {
            return "Action: Refuel your vehicle as soon as possible to avoid running out of fuel and damaging the fuel pump."
        } else if formattedClass.contains("tire") || formattedClass.contains("tpms") {
            return "Action: Check tire pressure in all tires and inflate to the recommended PSI as soon as possible."
        } else if formattedClass.contains("master") || formattedClass.contains("warn") {
            return "Action: Check your vehicle's information display for specific warnings and have your vehicle inspected."
        } else if formattedClass.contains("airbag") || formattedClass.contains("srs") {
            return "Action: Have the airbag system checked immediately by an authorized service center."
        } else if formattedClass.contains("seat") || formattedClass.contains("belt") {
            return "Action: Ensure all passengers fasten their seat belts before the vehicle is in motion."
        }
        return "Action: Consult your vehicle's manual or have a professional inspect your vehicle."
    }
    
    static func getIconName(for signClass: String) -> String {
        let formattedClassName = signClass.lowercased().replacingOccurrences(of: " ", with: "_")
        let iconMapping = [
            "brake": "brake_icon",
            "abs": "abs_icon",
            "airbag": "airbag_icon",
            "battery": "battery_icon",
            "door": "door_icon",
            "engine": "engine_icon",
            "fuel": "fuel_icon",
            "oil": "oil_icon",
            "seat": "seatbelt_icon",
            "steer": "steering_icon",
            "stabil": "stability_icon",
            "temp": "temperature_icon",
            "tire": "tire_icon",
            "check": "engine_icon"
        ]
        
        for (keyword, iconName) in iconMapping {
            if formattedClassName.contains(keyword) {
                return iconName
            }
        }
        return "exclamationmark.triangle"
    }
    
    static func getIconColor(for signClass: String) -> UIColor {
        let formattedClassName = signClass.lowercased().replacingOccurrences(of: " ", with: "_")
        
        switch formattedClassName {
        case _ where formattedClassName.contains("brake"),
             _ where formattedClassName.contains("oil"),
             _ where formattedClassName.contains("temperature"),
             _ where formattedClassName.contains("airbag"),
             _ where formattedClassName.contains("door"):
            return .systemRed
            
        case _ where formattedClassName.contains("check"),
             _ where formattedClassName.contains("fuel"),
             _ where formattedClassName.contains("master"),
             _ where formattedClassName.contains("charging"):
            return .systemOrange
            
        default:
            return .systemYellow
        }
    }
}
