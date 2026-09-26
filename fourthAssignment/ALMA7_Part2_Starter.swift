// =============================================================
//  Station ALMA-7, Part II: The Teleporter Incident
//  iOS Mobile Development · Module 4 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Part2_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER DATA section.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • Default to struct. Use class only where the task says so.
// =============================================================


// MARK: - =================== STARTER DATA ===================
// MARK: - Do not modify anything in this section

/// Splits a line into fields.
/// fields("crate:101:120")            -> ["crate", "101", "120"]
/// fields("livestock:lab mice:12:2")  -> ["livestock", "lab mice", "12", "2"]
/// fields("junk")                     -> ["junk"]
func fields(_ line: String, separatedBy separator: Character = ":") -> [String] {
    var result: [String] = []
    var current = ""
    for character in line {
        if character == separator {
            result.append(current)
            current = ""
        } else {
            current.append(character)
        }
    }
    result.append(current)
    return result
}

/// Cargo manifest as recovered from the damaged recorder.
let rawManifest = [
    "crate:101:120",
    "container:KZ-ALM-7:340",
    "livestock:lab mice:12:2",
    "???-corrupted-line",
    "crate:102:75",
    "container:KZ-ALM-9:410",
    "livestock:ficus:3:5",
    "crate:103:260",
    "crate:104:abc",
    ""
]

/// Oxygen readings. One of these deck names is not a real deck.
let deckReadings: [(deck: String, oxygen: Int)] = [
    (deck: "bridge",     oxygen: 78),
    (deck: "lab",        oxygen: 64),
    (deck: "greenhouse", oxygen: 55),
    (deck: "cargo",      oxygen: 12),
    (deck: "medbay",     oxygen: 90),
    (deck: "engine",     oxygen: 41)
]

/// Crew records, straight from the personnel file.
let crewData: [(name: String, deck: String, oxygen: Int)] = [
    (name: "Timur",   deck: "engine", oxygen: 62),
    (name: "Dana",    deck: "lab",    oxygen: 48),
    (name: "Aigerim", deck: "bridge", oxygen: 91),
    (name: "Nurlan",  deck: "cargo",  oxygen: 17)
]

print("ALMA-7 recorder online: \(rawManifest.count) manifest lines, \(deckReadings.count) readings, \(crewData.count) crew records.")

// MARK: - ================= END OF STARTER DATA =================


// MARK: - =================== YOUR SOLUTION ===================


// MARK: Level 1 · The Deck Register

enum Deck: String, CaseIterable {
    case bridge, lab, cargo, medbay, engine

    var evacuationPriority: Int {
        switch self {
        case .bridge: return 1
        case .medbay: return 2
        case .lab: return 3
        case .engine: return 4
        case .cargo: return 5
        }
    }
}

for deck in Deck.allCases {
    print("\(deck.rawValue) priority \(deck.evacuationPriority)")
}

enum AlarmLevel: Int {
    case green = 0
    case yellow, orange, red

    static func level(forTotalMass mass: Int) -> AlarmLevel {
        let capped = min(max(mass, 0) / 500, AlarmLevel.red.rawValue)
        return AlarmLevel(rawValue: capped) ?? .green
    }
}

print(AlarmLevel.level(forTotalMass: 0))
print(AlarmLevel.level(forTotalMass: 940))
print(AlarmLevel.level(forTotalMass: 4000))


// MARK: Level 2 · The Manifest

enum ManifestEntry {
    case crate(id: Int, massKg: Int)
    case container(code: String, massKg: Int)
    case livestock(species: String, count: Int, massPerUnitKg: Int)
    case unknown(raw: String)
}

func parseEntry(_ line: String) -> ManifestEntry {
    let parts = fields(line)
    guard let tag = parts.first else {
        return .unknown(raw: line)
    }
    switch tag {
    case "crate":
        guard parts.count == 3, let id = Int(parts[1]), let massKg = Int(parts[2]) else {
            return .unknown(raw: line)
        }
        return .crate(id: id, massKg: massKg)
    case "container":
        guard parts.count == 3, let massKg = Int(parts[2]) else {
            return .unknown(raw: line)
        }
        return .container(code: parts[1], massKg: massKg)
    case "livestock":
        guard parts.count == 4,
              let count = Int(parts[2]),
              let massPerUnitKg = Int(parts[3]) else {
            return .unknown(raw: line)
        }
        return .livestock(species: parts[1], count: count, massPerUnitKg: massPerUnitKg)
    default:
        return .unknown(raw: line)
    }
}

func mass(of entry: ManifestEntry) -> Int {
    switch entry {
    case let .crate(id: _, massKg: massKg):
        return massKg
    case let .container(code: _, massKg: massKg):
        return massKg
    case let .livestock(species: _, count: count, massPerUnitKg: massPerUnitKg):
        return count * massPerUnitKg
    case .unknown:
        return 0
    }
}

print(parseEntry("crate:101:120"))
print(parseEntry("livestock:lab mice:12:2"))
print(mass(of: parseEntry("container:KZ-ALM-7:340")))
print(mass(of: parseEntry("not-a-real-line")))

var totalMass = 0
var unknownLines = 0
for line in rawManifest {
    let entry = parseEntry(line)
    let entryMass = mass(of: entry)
    totalMass += entryMass
    if case .unknown = entry {
        unknownLines += 1
    }
    print("'\(line)' mass \(entryMass)")
}
let A = totalMass
print("Unknown lines: \(unknownLines)")
print("Total mass A: \(A)")


// MARK: Level 3 · Crew Snapshots

struct CrewSnapshot {
    let name: String
    var deck: Deck
    var oxygen: Int

    mutating func breathe(_ amount: Int) {
        let next = oxygen - amount
        if next < 0 {
            oxygen = 0
        } else {
            oxygen = next
        }
    }

    mutating func move(to deck: Deck) {
        self.deck = deck
    }

    mutating func reviveInMedbay() {
        self = CrewSnapshot(name: name, deck: .medbay, oxygen: 100)
    }

    static func rookie(named name: String) -> CrewSnapshot {
        CrewSnapshot(name: name, deck: .bridge, oxygen: 100)
    }
}

func makeRoster(from data: [(name: String, deck: String, oxygen: Int)]) -> [CrewSnapshot] {
    var roster: [CrewSnapshot] = []
    for record in data {
        guard let deck = Deck(rawValue: record.deck) else {
            print("Warning: \(record.name) names unknown deck \(record.deck)")
            continue
        }
        roster.append(CrewSnapshot(name: record.name, deck: deck, oxygen: record.oxygen))
    }
    return roster
}

let crewRoster = makeRoster(from: crewData)
let rejected = makeRoster(from: [(name: "Ghost", deck: "greenhouse", oxygen: 10)])
print("Roster count: \(crewRoster.count)")
print("Rejected count: \(rejected.count)")

var trainee = CrewSnapshot.rookie(named: "Sara")
print("Rookie \(trainee.name) \(trainee.deck.rawValue) \(trainee.oxygen)")
trainee.breathe(30)
print("After breathe: \(trainee.oxygen)")
trainee.breathe(500)
print("After over-breathe: \(trainee.oxygen)")
trainee.move(to: .engine)
trainee.reviveInMedbay()
print("Revived \(trainee.deck.rawValue) \(trainee.oxygen)")

var original = crewRoster[0]
print("Copy before: original \(original.oxygen)")
var copied = original
copied.breathe(10)
print("Copy after: original \(original.oxygen), copy \(copied.oxygen)")

func drainPlain(_ member: CrewSnapshot) {
    var member = member
    member.breathe(15)
    print("Inside plain function: \(member.oxygen)")
}

print("Plain before: \(original.oxygen)")
drainPlain(original)
print("Plain after: \(original.oxygen)")

func drainInout(_ member: inout CrewSnapshot) {
    member.breathe(15)
}

print("Inout before: \(original.oxygen)")
drainInout(&original)
print("Inout after: \(original.oxygen)")


// MARK: Level 4 · The Teleport Pod

final class TeleportPod {
    let id: String
    var chargeLevel: Int
    var occupant: CrewSnapshot?

    // CrewSnapshot is a struct, so the memberwise init(name:deck:oxygen:) appears on its own.
    // A class never receives a memberwise init. This one has to set every stored property, including occupant.
    init(id: String, chargeLevel: Int) {
        self.id = id
        self.chargeLevel = chargeLevel
        self.occupant = nil
    }

    func load(_ crew: CrewSnapshot) -> Bool {
        guard occupant == nil, chargeLevel >= 20 else { return false }
        occupant = crew
        return true
    }

    func fire() -> CrewSnapshot? {
        guard let current = occupant else { return nil }
        occupant = nil
        chargeLevel -= 20
        return current
    }

    deinit {
        print("deinit \(id)")
    }
}

func findCrew(_ name: String) -> CrewSnapshot? {
    for member in crewRoster {
        if member.name == name {
            return member
        }
    }
    return nil
}

let pod = TeleportPod(id: "P-1", chargeLevel: 100)
let boarding = ["Timur", "Dana", "Nurlan"]
for name in boarding {
    guard let member = findCrew(name) else {
        print("Missing \(name)")
        continue
    }
    let loaded = pod.load(member)
    print("Load \(name): \(loaded), charge \(pod.chargeLevel)")
    if let arrived = pod.fire() {
        print("Fire \(arrived.name), charge \(pod.chargeLevel)")
    } else {
        print("Fire empty, charge \(pod.chargeLevel)")
    }
}
if let extra = pod.fire() {
    print("Empty-pod fire returned \(extra.name), charge \(pod.chargeLevel)")
} else {
    print("Empty-pod fire returned nil, charge \(pod.chargeLevel)")
}
let C = pod.chargeLevel
print("Charge C: \(C)")

if let dana = findCrew("Dana"), let timur = findCrew("Timur") {
    let weak = TeleportPod(id: "LOW", chargeLevel: 19)
    print("Low-charge load: \(weak.load(dana))")
    let busy = TeleportPod(id: "BUSY", chargeLevel: 50)
    print("First load: \(busy.load(dana))")
    print("Occupied load: \(busy.load(timur))")
}

let shared = TeleportPod(id: "P-shared", chargeLevel: 80)
let alias = shared
print("Class before: shared \(shared.chargeLevel), alias \(alias.chargeLevel)")
alias.chargeLevel = 5
print("Class after: shared \(shared.chargeLevel), alias \(alias.chargeLevel)")

var snap = CrewSnapshot.rookie(named: "Erik")
var snapCopy = snap
print("Struct before: snap \(snap.oxygen), copy \(snapCopy.oxygen)")
snapCopy.oxygen = 1
print("Struct after: snap \(snap.oxygen), copy \(snapCopy.oxygen)")
// A class assignment copies the reference, so both names see one object; a struct assignment copies the value, so each name keeps its own.


// MARK: Level 5 · Station Systems

final class Station {
    let callSign: String
    var oxygenByDeck: [Deck: Int]

    var hullIntegrity: Int {
        willSet {
            print("Hull \(hullIntegrity) -> \(newValue)")
        }
        didSet {
            // Writing the property inside its own didSet does not call the observers again, so this clamp cannot loop.
            if hullIntegrity > 100 {
                hullIntegrity = 100
            } else if hullIntegrity < 0 {
                hullIntegrity = 0
            }
        }
    }

    lazy var fullDiagnostics: String = {
        print("Running full scan...")
        return "\(self.callSign): hull \(self.hullIntegrity), oxygen \(self.totalOxygen)"
    }()

    var totalOxygen: Int {
        var sum = 0
        for value in oxygenByDeck.values {
            sum += value
        }
        return sum
    }

    var averageOxygen: Int {
        get {
            let count = oxygenByDeck.count
            guard count > 0 else { return 0 }
            return totalOxygen / count
        }
        set {
            let decks = Array(oxygenByDeck.keys)
            for deck in decks {
                oxygenByDeck[deck] = newValue
            }
        }
    }

    init(callSign: String, readings: [(deck: String, oxygen: Int)]) {
        var stored: [Deck: Int] = [:]
        for reading in readings {
            guard let deck = Deck(rawValue: reading.deck) else {
                print("Warning: skipping unknown deck \(reading.deck)")
                continue
            }
            stored[deck] = reading.oxygen
        }
        self.callSign = callSign
        self.hullIntegrity = 100
        self.oxygenByDeck = stored
    }
}

let station = Station(callSign: "ALMA-7", readings: deckReadings)
let B = station.averageOxygen
print("Startup totalOxygen: \(station.totalOxygen)")
print("Startup averageOxygen B: \(B)")
print("Decks stored: \(station.oxygenByDeck.count)")

let quiet = Station(callSign: "QUIET", readings: [(deck: "bridge", oxygen: 20)])
print("Quiet station \(quiet.callSign), average \(quiet.averageOxygen)")
print("Quiet section ended; fullDiagnostics was not read")

station.hullIntegrity = 130
print("After 130: \(station.hullIntegrity)")
station.hullIntegrity = -40
print("After -40: \(station.hullIntegrity)")
station.hullIntegrity = 55
print("After 55: \(station.hullIntegrity)")

print("First diagnostics access:")
print(station.fullDiagnostics)
print("Second diagnostics access:")
print(station.fullDiagnostics)

station.averageOxygen = 50
print("After setter average: \(station.averageOxygen)")
print("After setter total: \(station.totalOxygen)")


// MARK: Level 6 · Incident Reports
// Three of these compile and are wrong. One does not compile.
// For each: expectation, actual behaviour, the language rule, the fix.

// Report 1
// Expected: roster[0].oxygen drops by 10.
// Actual: it stays 62. `for var member` binds a fresh copy of each struct.
// Changing that copy does not write back into the array. Value semantics.
var roster = crewRoster
print("Report 1 before: \(roster[0].oxygen)")
for var member in roster {
    member.oxygen -= 10
}
print("Report 1 buggy: \(roster[0].oxygen)")

var fixedRoster = crewRoster
for index in fixedRoster.indices {
    fixedRoster[index].breathe(10)
}
print("Report 1 fixed: \(fixedRoster[0].oxygen)")

// Report 2
// Expected: podA.chargeLevel stays 100, because podB looks like a separate pod.
// Actual: podA.chargeLevel becomes 0. `let podB = podA` copies the reference, not the object.
// Both names point at one instance. Reference semantics.
let podA = TeleportPod(id: "A", chargeLevel: 100)
let podB = podA
print("Report 2 before: \(podA.chargeLevel)")
podB.chargeLevel = 0
print("Report 2 buggy: \(podA.chargeLevel)")

let podAFixed = TeleportPod(id: "A-fixed", chargeLevel: 100)
let podBFixed = TeleportPod(id: "B-fixed", chargeLevel: podAFixed.chargeLevel)
podBFixed.chargeLevel = 0
print("Report 2 fixed podA: \(podAFixed.chargeLevel)")
print("Report 2 fixed podB: \(podBFixed.chargeLevel)")

// Report 3
// Expected: add appends a string.
// Actual: the file does not build.
// error: cannot use mutating member on immutable value: 'self' is immutable
// A struct method receives self as a constant. append needs to replace self's storage,
// so the method must be marked mutating.
//
// struct Logbook {
//     var entries: [String] = []
//     func add(_ entry: String) {
//         entries.append(entry)
//     }
// }

struct Logbook {
    var entries: [String] = []
    mutating func add(_ entry: String) {
        entries.append(entry)
    }
}

var book = Logbook()
book.add("meteor strike")
print(book.entries)
book.add("teleporter fault")
print(book.entries)

// Report 4
// Expected: either both assignments fail, or both succeed, because both names are let.
// Actual: only the struct assignment is an error.
// error: cannot assign to property: 'snapshot' is a 'let' constant
//
// let snapshot = CrewSnapshot.rookie(named: "Dana")
// snapshot.oxygen = 40
//
// let on a struct freezes the value. oxygen is part of that value, so the assignment is illegal.
// let on a class freezes the reference only. chargeLevel is storage inside the object,
// and changing it does not make `pod` point somewhere else, so the class assignment is legal.
var snapshot = CrewSnapshot.rookie(named: "Dana")
snapshot.oxygen = 40
print("Report 4 struct: \(snapshot.oxygen)")

let reportPod = TeleportPod(id: "B", chargeLevel: 50)
reportPod.chargeLevel = 10
print("Report 4 class: \(reportPod.chargeLevel)")


// MARK: Level 7 · Sealing the Black Box

// The leaky original:
//
// class FlightRecorder {
//     var entries: [String] = []
//     var isSealed = false
// }

// internal blocks other modules from naming this type; this file still can.
internal final class FlightRecorder {
    // private blocks any code outside this type from replacing or clearing the list.
    private var entries: [String] = []

    // private(set) blocks any code outside this type from assigning isSealed, so it cannot be set back to false.
    private(set) var isSealed = false

    // internal blocks other modules from reading the count; this file still can.
    internal var count: Int {
        entries.count
    }

    // internal blocks other modules from reading the transcript; this file still can.
    internal var transcript: String {
        var text = ""
        for entry in entries {
            if text.isEmpty {
                text = entry
            } else {
                text += "\n" + entry
            }
        }
        return text
    }

    // internal blocks other modules from calling add; this file still can.
    internal func add(_ entry: String) {
        guard isSealed == false else {
            print("Rejected after seal: \(entry)")
            return
        }
        entries.append(entry)
    }

    // internal blocks other modules from calling seal; this file still can.
    internal func seal() {
        isSealed = true
    }

    // fileprivate blocks other files from reading the raw lines. A free function in this file still can.
    fileprivate func storedLines() -> [String] {
        entries
    }
}

func auditTranscript(of recorder: FlightRecorder) -> String {
    var text = ""
    for line in recorder.storedLines() {
        if text.isEmpty {
            text = line
        } else {
            text += "\n" + line
        }
    }
    return text
}

let recorder = FlightRecorder()
recorder.add("crew transfer")
recorder.add("oxygen stable")
print("Entries: \(recorder.count)")
print(recorder.transcript)
print(auditTranscript(of: recorder))
print("Sealed: \(recorder.isSealed)")
recorder.seal()
print("Sealed: \(recorder.isSealed)")
recorder.add("rewrite history")
print("Entries after rejected add: \(recorder.count)")

// Break attempts, left commented with the compiler errors they produce:
// recorder.entries = []
// error: 'entries' is inaccessible due to 'private' protection level
// recorder.entries.append("tamper")
// error: 'entries' is inaccessible due to 'private' protection level
// error: cannot use mutating member on immutable value: 'entries' setter is inaccessible
// recorder.isSealed = false
// error: cannot assign to property: 'isSealed' setter is inaccessible
// If storedLines() were private, auditTranscript could not call it:
// error: 'storedLines' is inaccessible due to 'private' protection level


// MARK: Finale · Integrity Code

let D = AlarmLevel.level(forTotalMass: A).rawValue
let integrityCode = "\(A)-\(B)-\(C)-\(D)"
print("INTEGRITY CODE: \(integrityCode)")


// MARK: Bonus

print("Lifetime: entering block")
var survivor: TeleportPod?
do {
    let born = TeleportPod(id: "DOOM", chargeLevel: 30)
    survivor = born
    print("Lifetime: inside block, two references")
}
print("Lifetime: block ended, deinit has not run")
survivor = nil
print("Lifetime: last reference cleared on the line above")

func podRelationship(_ first: TeleportPod, _ second: TeleportPod) -> String {
    if first === second {
        return "same pod"
    }
    let occupantsMatch: Bool
    if let left = first.occupant, let right = second.occupant {
        occupantsMatch = left.name == right.name && left.deck == right.deck && left.oxygen == right.oxygen
    } else {
        occupantsMatch = first.occupant == nil && second.occupant == nil
    }
    if first.id == second.id && first.chargeLevel == second.chargeLevel && occupantsMatch {
        return "equal contents, different pods"
    }
    return "different pods"
}

let leftPod = TeleportPod(id: "SAME", chargeLevel: 10)
let rightAlias = leftPod
let rightCopy = TeleportPod(id: "SAME", chargeLevel: 10)
print(podRelationship(leftPod, rightAlias))
print(podRelationship(leftPod, rightCopy))

// CrewSnapshot is a struct, so this does not compile:
// print(snap === snapCopy)
// error: argument type 'CrewSnapshot' expected to be an instance of a class or class-constrained type
// === compares object identity. A struct has no identity separate from its value.

print("End of script")


// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. Why did CrewSnapshot get an initializer for free and TeleportPod did not?
    CrewSnapshot is a struct and it declares no init of its own, so Swift
    synthesizes init(name:deck:oxygen:) from the stored properties.
    TeleportPod is a class. Classes do not get a memberwise initializer;
    the one written in Level 4 has to assign id, chargeLevel, and occupant.

 2. What does `mutating` do to self, and why do classes never need it?
    mutating lets the method replace self, which is how reviveInMedbay assigns
    a whole new CrewSnapshot. Under the hood self is passed inout.
    A class method already holds a reference to one shared object, so changing
    a property updates that object. The reference in the caller's variable
    stays the same, and there is nothing to reassign.

 3. In Report 4 both values are `let`. What exactly does `let` freeze for a
    struct, and what does it freeze for a class?
    On a struct, let freezes the value. snapshot.oxygen = 40 would build a
    different value in that binding, and the compiler rejects it:
    "cannot assign to property: 'snapshot' is a 'let' constant".
    On a class, let freezes the reference. reportPod.chargeLevel = 10 changes
    storage inside the object. The name reportPod still points at the same
    object, so the assignment is legal. let reportPod = someOtherPod would
    be the illegal one.

 4. Why must a lazy property be var? When does lazy change behaviour, not
    just performance?
    The first read writes the finished string into the property. A let
    cannot be written after init, so lazy storage has to be var.
    fullDiagnostics prints "Running full scan..." on that first read.
    QUIET never reads the property, and the scan line never appears for it.
    A stored property computed in init would run the scan even if nobody
    asked for the report. That is a change in when the side effect happens.

 5. private vs fileprivate: where in your FlightRecorder would private be
    too strict?
    storedLines() is fileprivate so auditTranscript, a free function in this
    same file, can read the raw lines. If that helper were private, the call
    would fail with "'storedLines' is inaccessible due to 'private'
    protection level". private is the right level for entries itself:
    outside code must not replace the array. fileprivate is the right level
    for the one helper this file's audit function needs.

 Bonus. On which line does deinit fire, and why can't === be used on
 CrewSnapshot?
    deinit of DOOM fires on `survivor = nil`, after the do block has already
    ended. The output prints "block ended, deinit has not run", then
    "deinit DOOM", then "last reference cleared on the line above".
    The second reference kept the retain count above zero until that
    assignment. === cannot be used on CrewSnapshot because the operator
    requires a class instance. The compiler says: argument type
    'CrewSnapshot' expected to be an instance of a class or class-constrained
    type. A struct value has no separate object identity to compare.

*/
