// =============================================================
//  Station ALMA-7, Part III: The Repair Fleet
//  iOS Mobile Development · Module 5 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Part3_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER DATA section. LegacyBeacon in
//     particular must be reached with an extension, not edited.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • The Health Rule must exist in exactly ONE place in this file.
// =============================================================


// MARK: - =================== STARTER DATA ===================
// MARK: - Do not modify anything in this section

/// Drone records recovered from the fleet registry.
/// One `kind` does not correspond to any drone type you will build.
let fleetData: [(kind: String, id: String, charge: Int)] = [
    (kind: "welder",  id: "W-1", charge: 80),
    (kind: "scanner", id: "S-1", charge: 45),
    (kind: "cargo",   id: "C-1", charge: 100),
    (kind: "welder",  id: "W-2", charge: 15),
    (kind: "scanner", id: "S-2", charge: 60),
    (kind: "tug",     id: "T-1", charge: 50)
]

/// Hull sensors. These are NOT drones — they never move and never work a shift.
let sensorData: [(id: String, charge: Int)] = [
    (id: "hull-cam", charge: 12),
    (id: "thermal",  charge: 77)
]

/// Hardware from the original station. You may not add anything to this
/// declaration — no methods, no protocols, no properties.
struct LegacyBeacon {
    let name: String
    let signalStrength: Int
}

let beacon = LegacyBeacon(name: "ALMA-BEACON", signalStrength: 8)

print("Fleet registry online: \(fleetData.count) drone records, \(sensorData.count) sensors, beacon \(beacon.name).")

// MARK: - ================= END OF STARTER DATA =================


// MARK: - =================== YOUR SOLUTION ===================


// MARK: Level 1 · The Power Cell

// A class is a reference type, so a `let` PowerCell still shares one battery that spend and recharge can change in place; a struct stored in `let` would be copied and could not be updated.
final class PowerCell {
    private var charge: Int

    init(charge: Int) {
        self.charge = clampedUnit(charge)
    }

    func level() -> Int {
        charge
    }

    func spend(_ amount: Int) -> Bool {
        if amount <= 0 {
            return false
        }
        if charge < amount {
            return false
        }
        charge -= amount
        return true
    }

    func recharge(by amount: Int) {
        charge = recharged(charge, by: amount)
    }
}

func clampedUnit(_ value: Int) -> Int {
    if value < 0 {
        return 0
    }
    if value > 100 {
        return 100
    }
    return value
}

func recharged(_ charge: Int, by amount: Int) -> Int {
    if amount <= 0 {
        return charge
    }
    return clampedUnit(charge + amount)
}

// Encapsulation proof (leave this commented, with the compiler error):
// let cell = PowerCell(charge: 40)
// cell.charge = 100
// error: 'charge' is inaccessible due to 'private' protection level


// MARK: Level 2 · The Fleet

// `final` on runOnce() forbids an override, so a subclass cannot skip the battery check or invent its own shift ritual.
class Drone {
    let id: String
    let cell: PowerCell

    init(id: String, cell: PowerCell) {
        self.id = id
        self.cell = cell
    }

    var powerCost: Int { 10 }

    var statusLine: String {
        "\(id): \(cell.level())% \(cell.level().powerBar)"
    }

    func performTask() -> Int { 0 }

    final func runOnce() -> Int {
        if cell.spend(powerCost) == false {
            return 0
        }
        return performTask()
    }
}

final class WelderDrone: Drone {
    override var powerCost: Int { 25 }

    override func performTask() -> Int { 40 }

    func weldSeam() -> String {
        "\(id) welded a seam"
    }
}

class ScannerDrone: Drone {
    override var powerCost: Int { 10 }

    override func performTask() -> Int { 15 }

    override var statusLine: String {
        super.statusLine + " [scanner]"
    }
}

final class CargoDrone: Drone {
    override var powerCost: Int { 20 }

    override func performTask() -> Int { 25 }
}

func makeDrone(kind: String, id: String, charge: Int) -> Drone? {
    let cell = PowerCell(charge: charge)
    switch kind {
    case "welder":
        return WelderDrone(id: id, cell: cell)
    case "scanner":
        return ScannerDrone(id: id, cell: cell)
    case "cargo":
        return CargoDrone(id: id, cell: cell)
    default:
        return nil
    }
}

let fleet: [Drone] = {
    var built: [Drone] = []
    for record in fleetData {
        if let drone = makeDrone(kind: record.kind, id: record.id, charge: record.charge) {
            built.append(drone)
        } else {
            print("Warning: skipped \(record.id), unknown kind \"\(record.kind)\".")
        }
    }
    return built
}()


// MARK: Level 3 · The Shift

func runShift(_ fleet: [Drone], rounds: Int) -> Int {
    var total = 0
    var round = 0
    while round < rounds {
        for drone in fleet {
            total += drone.runOnce()
        }
        round += 1
    }
    return total
}

let A = runShift(fleet, rounds: 3)

var B = 0
var C = 0
print("Shift complete:")
for drone in fleet {
    print(drone.statusLine)
    B += drone.cell.level()
    if drone.cell.level() >= drone.powerCost {
        C += 1
    }
}
print("Drones that can still run one more task: \(C)")


// MARK: Level 4 · Diagnostics

protocol Diagnosable {
    var componentID: String { get }
    var statusCode: Int { get }
    func diagnose() -> String
}

protocol Rechargeable {
    mutating func recharge(by amount: Int)
}

// Drone is a class, so recharge(by:) mutates the shared instance through its reference and does not need `mutating`; that keyword exists for value types.
extension Drone: Diagnosable, Rechargeable {
    var componentID: String { id }

    var statusCode: Int {
        healthCode(forCharge: cell.level())
    }

    func recharge(by amount: Int) {
        cell.recharge(by: amount)
    }
}

struct SensorModule: Diagnosable, Rechargeable {
    let componentID: String
    var chargeLevel: Int

    var statusCode: Int {
        healthCode(forCharge: chargeLevel)
    }

    mutating func recharge(by amount: Int) {
        chargeLevel = recharged(chargeLevel, by: amount)
    }
}

var sensors: [SensorModule] = []
for record in sensorData {
    sensors.append(SensorModule(componentID: record.id, chargeLevel: record.charge))
}

// [Drone] can hold only Drone and its subclasses, and SensorModule is a struct that is not a Drone; a protocol-typed array can hold every adopter, class or struct.
func diagnosticsReport(_ components: [Diagnosable]) -> String {
    var report = ""
    for component in components {
        if report.isEmpty == false {
            report += "\n"
        }
        report += component.diagnose()
    }
    return report
}

var stationComponents: [Diagnosable] = []
for drone in fleet {
    stationComponents.append(drone)
}
for sensor in sensors {
    stationComponents.append(sensor)
}

print("Diagnostics:")
print(diagnosticsReport(stationComponents))


// MARK: Level 5 · Shared Behaviour

extension Diagnosable {
    func healthCode(forCharge charge: Int) -> Int {
        if charge < 20 {
            return 2
        }
        if charge < 50 {
            return 1
        }
        return 0
    }

    func diagnose() -> String {
        "\(componentID): code \(statusCode)"
    }
}

extension LegacyBeacon: Diagnosable {
    var componentID: String { name }

    var statusCode: Int {
        healthCode(forCharge: signalStrength)
    }

    func diagnose() -> String {
        "LEGACY \(componentID): signal \(signalStrength), code \(statusCode)"
    }
}

stationComponents.append(beacon)
print("Diagnostics with beacon:")
print(diagnosticsReport(stationComponents))

var D = 0
for component in stationComponents {
    D += component.statusCode
}

extension Int {
    var powerBar: String {
        var filled = self / 10
        if filled < 0 {
            filled = 0
        }
        if filled > 10 {
            filled = 10
        }
        var bar = ""
        var index = 0
        while index < 10 {
            if index < filled {
                bar += "#"
            } else {
                bar += "."
            }
            index += 1
        }
        return bar
    }
}


// MARK: Level 6 · Incident Reports
// Checked against this fleet: Reports 1, 2, and 3 do not compile.
// Report 4 compiles and prints "generic component" instead of "thruster T-1".

/*
// Report 1
class PatchDrone: Drone {
    func performTask() -> Int {
        return 30
    }
}
// Expected: PatchDrone replaces performTask and produces 30 work units.
// Actual: does not compile — overriding declaration requires an 'override' keyword.
// Rule: a subclass method that replaces a superclass method must be marked override, so a same-name method cannot silently hide the original.
// Fix: override func performTask() -> Int { 30 }

// Report 2
final class HeavyWelder: WelderDrone {
    override func runOnce() -> Int {
        return 999
    }
}
// Expected: HeavyWelder skips the battery ritual and always returns 999.
// Actual: does not compile — inheritance from a final class 'WelderDrone', and runOnce() is itself final so it cannot be overridden.
// Rule: final on a class forbids subclassing; final on a method forbids override.
// Fix: drop the subclass. Change cost or performTask() on a non-final drone, and leave runOnce() alone.

// Report 3
let reportFleet: [Drone] = [WelderDrone(id: "W-9", cell: PowerCell(charge: 100))]
let first = reportFleet[0]
print(first.weldSeam())
// Expected: the welder in the array prints its seam.
// Actual: does not compile — value of type 'Drone' has no member 'weldSeam'.
// Rule: the compiler only sees the static type. fleet's element type is Drone, and weldSeam exists only on WelderDrone.
// Fix: conditional cast, used below. as? returns an optional because the runtime value might be some other Drone, and nil is the failed cast.

// Report 4
protocol Labelled {
    var componentID: String { get }
}

extension Labelled {
    func label() -> String { "generic component" }
}

struct Thruster: Labelled {
    let componentID: String
    func label() -> String { "thruster \(componentID)" }
}

let parts: [Labelled] = [Thruster(componentID: "T-1")]
print(parts[0].label())
// Expected: "thruster T-1".
// Actual: compiles and prints "generic component".
// Rule: a method that the protocol requires is dispatched dynamically to the conforming type. A method that exists only in a protocol extension is dispatched statically, using the compile-time type — here Labelled, not Thruster.
// Fix: add one line to the protocol, `func label() -> String`. Then parts[0].label() calls Thruster's method. The extension can stay as the default.
*/

let reportFleet: [Drone] = [WelderDrone(id: "W-9", cell: PowerCell(charge: 100))]
let first = reportFleet[0]
if let welder = first as? WelderDrone {
    print(welder.weldSeam())
}


// MARK: Finale · Mission Code

let missionCode = "\(A)-\(B)-\(C)-\(D)"
print("MISSION CODE: \(missionCode)")


// MARK: Bonus

// 1. Runtime failure: in Drone.init, if type(of: self) == Drone.self { fatalError("Drone cannot be used directly") }.
//    Subclass init does not trip it, because the dynamic type is WelderDrone, ScannerDrone, or CargoDrone.
//    Compile-time failure: Swift has no abstract keyword. Give init a second parameter of a protocol only the
//    subclasses adopt (protocol DroneSubtype {}), and have each subclass pass Self.self. A plain Drone(id:cell:)
//    then has no matching initializer and the call fails at compile time. The graded fleet keeps init(id:cell:),
//    because Level 2 requires a usable base class whose performTask returns 0.

// 2. Protocol redesign (sketch — the graded fleet above stays a class hierarchy):
//    protocol Drone: Diagnosable, Rechargeable {
//        var id: String { get }
//        var cell: PowerCell { get }
//        var powerCost: Int { get }
//        func performTask() -> Int
//    }
//    extension Drone {
//        var powerCost: Int { 10 }
//        var statusLine: String { "\(id): \(cell.level())% \(cell.level().powerBar)" }
//        func performTask() -> Int { 0 }
//        func runOnce() -> Int {
//            if cell.spend(powerCost) == false { return 0 }
//            return performTask()
//        }
//    }
//    struct WelderDrone: Drone { ... powerCost 25, performTask 40, weldSeam() ... }
//    A protocol extension cannot be `final`, and a struct has no super, so ScannerDrone would build its
//    status line from the extension helper rather than override a class property.

// 3. I would keep the class fleet for this station. Inheritance gives one stored PowerCell and one final
//    runOnce() that subclasses actually share, and super lets ScannerDrone extend statusLine.
//    The protocol version can adopt structs and types we do not own, which is why the beacon could join
//    diagnostics, but each value would carry its own copy of any state declared only on the concrete type.
//    If drones had to share mutable state, the class (or a class cell held inside a struct) is the design
//    that keeps one battery; a pure struct fleet would copy it on assignment.


// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. Why does a class satisfy a `mutating` protocol requirement without the
    keyword, while a struct must write it?
    A class is a reference type: the method changes the object the reference
    already points at, so the caller's variable still holds the same reference.
    A struct is a value: changing a property replaces that value, and `mutating`
    is what allows the method to write back to the caller's variable. A `let`
    struct cannot call it. SensorModule therefore writes `mutating`; Drone does not.

 2. One thing inheritance does that protocols cannot, and one thing
    protocols do that inheritance cannot:
    Inheritance shares stored properties and a single overridable implementation,
    with super and final, and a class can have only one superclass.
    A protocol can be adopted by a class and a struct at the same time, by many
    types you did not write (LegacyBeacon), and one type can conform to several.

 3. What does `final` prevent, and what did it protect in runOnce()?
    `final` on a method prevents override; `final` on a class prevents subclassing.
    final runOnce() protects the ritual: spend powerCost, and only then performTask().
    Report 2 is the attempt that this blocks.

 4. In Report 4, why did the protocol extension's method win?
    label() is not a protocol requirement, only an extension method, so the call
    uses the static type of parts[0], which is Labelled. Thruster.label is never
    consulted. A requirement would have been dispatched to Thruster.
*/
