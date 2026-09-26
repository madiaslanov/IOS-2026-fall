// =============================================================
//  Station ALMA-7: Rescue Protocol
//  iOS Mobile Development · Module 3 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER CODE section.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • Use the exact function names from the assignment PDF.
// =============================================================


// MARK: - =================== STARTER CODE ===================
// MARK: - Do not modify anything in this section

typealias Reading = (sensor: String, value: Int)

/// Splits a string at the first occurrence of the separator.
/// splitOnce("O2:87", by: ":") -> ("O2", "87")
/// splitOnce("hello", by: ":") -> nil
func splitOnce(_ line: String, by separator: Character) -> (String, String)? {
    guard let index = line.firstIndex(of: separator) else { return nil }
    let left = String(line[..<index])
    let right = String(line[line.index(after: index)...])
    return (left, right)
}

let rawLog = [
    "O2:87", "TEMP:-12", "O2:9x", "PRESS:101", "TEMP:abc", "O2:",
    "RAD:3", "O2:64", ":55", "TEMP:31", "PRESS:98", "O2:71",
    "RAD:-1", "TEMP:4", "PRESS:1o2", "O2:90"
]

class Tank {
    var level: Int
    init(level: Int) { self.level = level }
}

class Module {
    let name: String
    var oxygenTank: Tank?
    init(name: String, oxygenTank: Tank?) {
        self.name = name
        self.oxygenTank = oxygenTank
    }
}

class CrewMember {
    let name: String
    let role: String
    let priority: Int      // 1 = evacuated first
    var module: Module?    // nil = in open space
    init(name: String, role: String, priority: Int, module: Module?) {
        self.name = name
        self.role = role
        self.priority = priority
        self.module = module
    }
}

let lab  = Module(name: "Lab",  oxygenTank: Tank(level: 40))
let hab  = Module(name: "Hab",  oxygenTank: Tank(level: 12))
let dock = Module(name: "Dock", oxygenTank: nil)

let crew = [
    CrewMember(name: "Timur",   role: "Engineer",  priority: 3, module: lab),
    CrewMember(name: "Dana",    role: "Scientist", priority: 4, module: dock),
    CrewMember(name: "Aigerim", role: "Commander", priority: 1, module: hab),
    CrewMember(name: "Nurlan",  role: "Pilot",     priority: 2, module: nil)
]

var roster: [String: CrewMember] = [:]
for member in crew { roster[member.name] = member }

print("ALMA-7 systems online: \(rawLog.count) log lines, \(crew.count) crew members.")

// MARK: - ================= END OF STARTER CODE =================


// MARK: - =================== YOUR SOLUTION ===================


// MARK: Level 1 · Decoding Telemetry

func parseReading(_ raw: String) -> Reading? {
    guard let parts = splitOnce(raw, by: ":"),
          !parts.0.isEmpty,
          let value = Int(parts.1),
          parts.0 == "TEMP" || value >= 0 else {
        return nil
    }
    return (sensor: parts.0, value: value)
}

func parseLog(_ lines: [String]) -> (valid: [Reading], invalidCount: Int) {
    var valid: [Reading] = []
    var invalidCount = 0
    for line in lines {
        if let reading = parseReading(line) {
            valid.append(reading)
        } else {
            invalidCount += 1
        }
    }
    return (valid: valid, invalidCount: invalidCount)
}

func showReading(_ reading: Reading?) {
    if let reading {
        print("\(reading.sensor):\(reading.value)")
    } else {
        print("nil")
    }
}

showReading(parseReading("O2:87"))
showReading(parseReading("TEMP:-12"))
showReading(parseReading("RAD:-1"))
showReading(parseReading(":55"))

let parsedLog = parseLog(rawLog)
print("valid: \(parsedLog.valid.count), invalid: \(parsedLog.invalidCount)")
print(parseLog(["O2:1", "NOPE", "TEMP:-3"]))

let A = parsedLog.invalidCount


// MARK: Level 2 · Analysis

func select(_ readings: [Reading], where isIncluded: (Reading) -> Bool) -> [Reading] {
    var chosen: [Reading] = []
    for reading in readings {
        if isIncluded(reading) {
            chosen.append(reading)
        }
    }
    return chosen
}

func values(of readings: [Reading]) -> [Int] {
    var result: [Int] = []
    for reading in readings {
        result.append(reading.value)
    }
    return result
}

let oxygenReadings = select(parsedLog.valid) { $0.sensor == "O2" }
let tempReadings = select(parsedLog.valid) { $0.sensor == "TEMP" }
print(values(of: oxygenReadings))
print(values(of: tempReadings))

func stats(of values: [Int]) -> (min: Int, max: Int, average: Double)? {
    guard let first = values.first else { return nil }
    var lowest = first
    var highest = first
    var sum = 0
    for value in values {
        if value < lowest { lowest = value }
        if value > highest { highest = value }
        sum += value
    }
    return (min: lowest, max: highest, average: Double(sum) / Double(values.count))
}

func stats(_ values: Int...) -> (min: Int, max: Int, average: Double)? {
    stats(of: values)
}

func showStats(_ result: (min: Int, max: Int, average: Double)?) {
    if let result {
        print("min: \(result.min), max: \(result.max), average: \(result.average)")
    } else {
        print("nil")
    }
}

showStats(stats(3, 8, 1))
showStats(stats())
showStats(stats(of: values(of: oxygenReadings)))
showStats(stats(of: []))

let B = Int(stats(of: values(of: oxygenReadings))?.average ?? 0)

func sameReadings(_ lhs: [Reading], _ rhs: [Reading]) -> Bool {
    guard lhs.count == rhs.count else { return false }
    for index in lhs.indices {
        if lhs[index].sensor != rhs[index].sensor || lhs[index].value != rhs[index].value {
            return false
        }
    }
    return true
}

let sorted1 = parsedLog.valid.sorted(by: { (a: Reading, b: Reading) -> Bool in
    return a.value > b.value
})
let sorted2 = parsedLog.valid.sorted(by: { (a, b) in
    return a.value > b.value
})
let sorted3 = parsedLog.valid.sorted(by: { (a, b) in a.value > b.value })
let sorted4 = parsedLog.valid.sorted(by: { $0.value > $1.value })
let sorted5 = parsedLog.valid.sorted { $0.value > $1.value }

let sortsMatch = sameReadings(sorted1, sorted2)
    && sameReadings(sorted2, sorted3)
    && sameReadings(sorted3, sorted4)
    && sameReadings(sorted4, sorted5)
print("All five sorts match: \(sortsMatch)")
print(values(of: sorted5))


// MARK: Level 3 · Temperature Stabilization

func heatUp(_ t: Int) -> Int { t + 5 }
func coolDown(_ t: Int) -> Int { t - 3 }
func hold(_ t: Int) -> Int { t }

print(heatUp(10), heatUp(18))
print(coolDown(30), coolDown(24))
print(hold(20), hold(22))

func chooseProtocol(for temp: Int) -> (Int) -> Int {
    if temp < 18 {
        return heatUp
    } else if temp > 24 {
        return coolDown
    } else {
        return hold
    }
}

print(chooseProtocol(for: 10)(10))
print(chooseProtocol(for: 30)(30))
print(chooseProtocol(for: 20)(20))

func runUntilStable(from start: Int, maxSteps: Int = 10) -> (finalTemp: Int, steps: Int, isStable: Bool) {
    var temp = start
    var steps = 0
    while (temp < 18 || temp > 24) && steps < maxSteps {
        let adjust = chooseProtocol(for: temp)
        temp = adjust(temp)
        steps += 1
    }
    let isStable = temp >= 18 && temp <= 24
    return (finalTemp: temp, steps: steps, isStable: isStable)
}

print(runUntilStable(from: 31))
print(runUntilStable(from: -100, maxSteps: 5))

let lowestTemp = stats(of: values(of: tempReadings))?.min ?? 0
let C = runUntilStable(from: lowestTemp).steps
print("Lowest TEMP \(lowestTemp), steps \(C)")


// MARK: Level 4 · The Crew

func oxygenLevel(of member: CrewMember) -> Int? {
    member.module?.oxygenTank?.level
}

func showLevel(_ level: Int?) {
    if let level {
        print(level)
    } else {
        print("nil")
    }
}

showLevel(oxygenLevel(of: crew[0]))
showLevel(oxygenLevel(of: crew[1]))

func status(of member: CrewMember) -> String {
    guard let level = oxygenLevel(of: member) else {
        let place = member.module?.name ?? "open space"
        return "\(member.name): no data (\(place))"
    }
    let mark = level < 20 ? "CRITICAL" : "OK"
    return "\(member.name): \(level)% \(mark)"
}

for member in crew {
    print(status(of: member))
}

@discardableResult
func transferOxygen(from source: inout Int, to target: inout Int, amount: Int) -> Int {
    guard amount > 0 else { return 0 }
    let room = 100 - target
    guard room > 0, source > 0 else { return 0 }
    let moved = min(amount, source, room)
    source -= moved
    target += moved
    return moved
}

var sampleSource = 10
var sampleTarget = 95
print(transferOxygen(from: &sampleSource, to: &sampleTarget, amount: 20))
print("source \(sampleSource), target \(sampleTarget)")

var negativeSource = 40
var negativeTarget = 12
print(transferOxygen(from: &negativeSource, to: &negativeTarget, amount: -5))

if let labTank = lab.oxygenTank, let habTank = hab.oxygenTank {
    let moved = transferOxygen(from: &labTank.level, to: &habTank.level, amount: 30)
    print("Lab -> Hab moved \(moved)")
}

let D = hab.oxygenTank?.level ?? 0
print("Hab oxygen after transfer: \(D)")

func evacuationOrder(_ names: String..., roster: [String: CrewMember]) -> [String] {
    var found: [CrewMember] = []
    for name in names {
        guard let member = roster[name] else {
            print("Unknown crew member: \(name)")
            continue
        }
        found.append(member)
    }
    let ordered = found.sorted { $0.priority < $1.priority }
    var namesInOrder: [String] = []
    for member in ordered {
        namesInOrder.append(member.name)
    }
    return namesInOrder
}

print(evacuationOrder("Dana", "Ghost", "Aigerim", "Timur", roster: roster))
print(evacuationOrder("Nurlan", "Nobody", "Aigerim", roster: roster))


// MARK: Level 5 · The Saboteur's Logbook
// The saboteur's code is below, commented out (it needs your
// oxygenLevel(of:) to compile). Comment on every problem, then
// write fixed versions and a test that proves the logic bug is gone.

/*
func reportOxygen(for member: CrewMember) -> String {
    // module! crashes on Nurlan: his module is nil (open space).
    // The program stops with "Unexpectedly found nil".
    // oxygenTank! crashes on Dana: she has a module (Dock), but Dock has no tank.
    let tank = member.module!.oxygenTank!
    return "\(member.name): \(tank.level)%"
}

func firstCritical(in crew: [CrewMember]) -> String {
    var result: String?
    for member in crew {
        // oxygenLevel is nil for Dana and Nurlan, so ! crashes before any name is chosen.
        // The loop also never stops: every critical member overwrites result,
        // so the function returns the LAST critical name, not the first.
        // Starter data hides this: only Aigerim is below 20%.
        if oxygenLevel(of: member)! < 20 {
            result = member.name
        }
    }
    // If nobody is critical, result stays nil and ! crashes.
    return result!
}
*/

func reportOxygen(for member: CrewMember) -> String {
    guard let level = oxygenLevel(of: member) else {
        return "\(member.name): no data"
    }
    return "\(member.name): \(level)%"
}

func firstCritical(in crew: [CrewMember]) -> String? {
    for member in crew {
        guard let level = oxygenLevel(of: member) else { continue }
        if level < 20 {
            return member.name
        }
    }
    return nil
}

print(reportOxygen(for: crew[0]))
print(reportOxygen(for: crew[1]))
print(reportOxygen(for: crew[3]))

let podA = Module(name: "PodA", oxygenTank: Tank(level: 5))
let podB = Module(name: "PodB", oxygenTank: Tank(level: 8))
let podC = Module(name: "PodC", oxygenTank: Tank(level: 80))
let alpha = CrewMember(name: "Alpha", role: "Test", priority: 1, module: podA)
let beta = CrewMember(name: "Beta", role: "Test", priority: 2, module: podB)
let gamma = CrewMember(name: "Gamma", role: "Test", priority: 3, module: podC)
let firstHit = firstCritical(in: [alpha, beta, gamma])
print(firstHit ?? "nil")
print(firstHit == "Alpha" ? "Logic bug fixed: first critical is Alpha" : "Logic bug still returns the last name")
print(firstCritical(in: [gamma]) ?? "none")


// MARK: Finale · Launch Code

let launchCode = "\(A)-\(B)-\(C)-\(D)"
print("LAUNCH CODE: \(launchCode)")


// MARK: Bonus

func makeAlarm(threshold: Int) -> (Int) -> Bool {
    var count = 0
    return { level in
        guard level < threshold else { return false }
        count += 1
        print("Alarm #\(count)")
        return true
    }
}

let alarm = makeAlarm(threshold: 20)
print(alarm(12))
print(alarm(40))
print(alarm(5))


// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. guard let vs if let beyond syntax:

 2. Why can't you pass [Int] to stats(_ values: Int...)?

 3. Why doesn't transferOxygen(from: &x, to: &x, amount: 5) compile?

 4. Why doesn't oxygenLevel(of: dana) ?? "no data" compile?

 5. Full type of chooseProtocol and how to read it:

 Bonus. Where does the alarm counter live after makeAlarm returns?

*/
