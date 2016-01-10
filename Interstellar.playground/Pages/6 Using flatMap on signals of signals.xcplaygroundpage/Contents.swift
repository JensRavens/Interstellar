//: [Previous](@previous)

import Foundation
import Interstellar

/*: 
It's your first day at Space Inc, and you've been given the job to write some code
to refuel an orbiting space station.  There's already been some code written, and
at the center of this code are Signals.

Talking to the space station, takes a lot of time.  Commands need to be send via a
radio tower and then results returned to the radio tower.  These kind of operations
are perfect to be Signals- they return values... eventually.
*/

/// Get fuel levels for the space station
/// Returns an Int for the fuel level
func getFuelLevelsFromSpaceStation() -> Signal<Int> {
    // In this stub implementation we return a value right away
    return Signal(255)
}

/// Sends the command to open the fuel port
/// Returns a bool representing if the fuel port is open (true) or closed (false)
func openFuelPort() -> Signal<Bool> {
    // In this stub implementation we return a value right away
    return Signal(true)
}

/// Sends the command to refuel from a fuel pack
/// WARNING: Make sure the fuel port is open before you do this!
/// WARNING: The space station can only contain 1000 fuel units
/// Returns an Int representing the fuel level for the space station
func refuelSpaceStationFromFuelPack(fuelPackSize: Int) -> Signal<Int> {
    // In this stub implementation we return a value right away
    return Signal(255 + fuelPackSize)
}


/*:
We've been tasked with taking this library code and writing a refueling function.
This is a perfect case for `flatMap`.

flatMap is a tool that takes a function that returns a signal and returns its inner
Signals values.

Let's start by getting the fuel level and opening the opening the fuel port
*/

let fuelPackSize = 500
getFuelLevelsFromSpaceStation()
    .flatMap { fuelLevel -> Signal<Bool> in
        if (fuelLevel) < 500 {
            return openFuelPort()
        }
        return Signal(false)
    }
    .flatMap { fuelPortIsOpen -> Signal<Int> in
        if fuelPortIsOpen {
            return refuelSpaceStationFromFuelPack(fuelPackSize)
        }
        return Signal(0)
    }
    .next { spaceStationFuel in
        print("The space station now has \(spaceStationFuel) fuel units available")
    }

// The result of running the above code is:
// The space station now has 755 fuel units available

/*:
Notice how the inner blocks return a signal but the next blocks reference the value that
is returned by the innerSignal.

`flatMap` is a wonderful tool when you are dealing with multiple asynchrous operations that
need to be chained
*/

//: [Next](@next)
