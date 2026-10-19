import Testing
@testable import VitralTokens

@Suite struct ValueScaleTests {
    @Test func linearFractionsAndValuesRoundTrip() {
        let scale = ValueScale(0 ... 10, step: 1, precision: 0)
        #expect(scale.fraction(of: 5) == 0.5)
        #expect(scale.value(at: 0.5) == 5)
        #expect(scale.value(at: 0.54) == 5)
    }

    @Test func valuesLandOnStepsAndStayInRange() {
        let scale = ValueScale(1 ... 11, step: 0.5, precision: 1)
        #expect(scale.snapped(3.3) == 3.5)
        #expect(scale.snapped(42) == 11)
        #expect(scale.snapped(-3) == 1)
    }

    @Test func precisionRounds() {
        let scale = ValueScale(0 ... 1, precision: 2)
        #expect(scale.snapped(0.123_456) == 0.12)
    }

    @Test func logarithmicSpreadsByRatio() {
        let scale = ValueScale(20 ... 20000, precision: 0, taper: .logarithmic)
        #expect(scale.value(at: 0.5) == 632)
        #expect(abs(scale.fraction(of: 632.456) - 0.5) < 0.000_1)
    }

    @Test func dragMovesByTheFractionOfTheLength() {
        let scale = ValueScale(0 ... 10, step: 1, precision: 0)
        #expect(scale.dragged(from: 2, by: 100, over: 200) == 7)
        #expect(scale.dragged(from: 2, by: -1000, over: 200) == 0)
    }

    @Test func steppingUsesTheStep() {
        let scale = ValueScale(0 ... 10, step: 2, precision: 0)
        #expect(scale.stepped(4, by: 1) == 6)
        #expect(scale.stepped(10, by: 1) == 10)
    }

    @Test func marksEveryIntervalStandApartFromTheValuesPrecision() {
        let scale = ValueScale(1 ... 10, precision: 2)
        #expect(scale.marks(every: 1) == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
        #expect(scale.snapped(7.354) == 7.35)
        #expect(ValueScale.decimals(of: 1) == 0)
        #expect(ValueScale.decimals(of: 0.5) == 1)
        #expect(ValueScale.decimals(of: 0.25) == 2)
    }

    @Test func marksAreTheStepsWhenFew() {
        #expect(ValueScale(0 ... 10, step: 1, precision: 0).marks() == [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
        #expect(ValueScale(0 ... 100, precision: 0).marks(limit: 5) == [0, 25, 50, 75, 100])
    }
}

@Suite struct DialGeometryTests {
    @Test func touchAnglesAreClockwiseFromTwelve() {
        #expect(DialGeometry.angle(dx: 0, dy: -1) == 0)
        #expect(DialGeometry.angle(dx: 1, dy: 0) == 90)
        #expect(DialGeometry.angle(dx: -1, dy: 0) == -90)
    }

    @Test func fractionsBetweenTheEnds() {
        #expect(DialGeometry.fraction(forAngle: -135, start: -135, end: 135) == 0)
        #expect(DialGeometry.fraction(forAngle: 0, start: -135, end: 135) == 0.5)
        #expect(DialGeometry.fraction(forAngle: 135, start: -135, end: 135) == 1)
    }

    @Test func theGapGoesToTheNearerEnd() {
        #expect(DialGeometry.fraction(forAngle: 170, start: -135, end: 135) == 1)
        #expect(DialGeometry.fraction(forAngle: -170, start: -135, end: 135) == 0)
    }

    @Test func endlessTurnsGoTheShortWay() {
        #expect(DialGeometry.turn(from: 170, to: -170) == 20)
        #expect(DialGeometry.turn(from: -170, to: 170) == -20)
    }
}

@Suite struct TrackGeometryTests {
    @Test func positionsAndFractionsRoundTrip() {
        #expect(TrackGeometry.position(of: 0.5, length: 220, thumb: 20, reversed: false) == 110)
        #expect(TrackGeometry.fraction(at: 110, length: 220, thumb: 20, reversed: false) == 0.5)
        #expect(TrackGeometry.fraction(at: 10, length: 220, thumb: 20, reversed: true) == 1)
        #expect(TrackGeometry.fraction(at: -50, length: 220, thumb: 20, reversed: false) == 0)
    }

    @Test("a finger's wobble is still a tap; past the slop it is a drag")
    func touchSlop() {
        #expect(!TrackGeometry.isDragging(dx: 0, dy: 0))
        #expect(!TrackGeometry.isDragging(dx: 0.4, dy: -0.3))
        #expect(!TrackGeometry.isDragging(dx: 4, dy: 4))
        #expect(TrackGeometry.isDragging(dx: 0, dy: -7))
        #expect(TrackGeometry.isDragging(dx: 5, dy: 5))
    }

    @Test func detentsPullWhenClose() {
        #expect(TrackGeometry.snapped(0.51, to: [0.5]) == 0.5)
        #expect(TrackGeometry.snapped(0.6, to: [0.5]) == 0.6)
    }
}

@Suite struct BreakpointTaperTests {
    let scale = ValueScale(0 ... 10, precision: 3, taper: .breakpoints([.init(0, 0), .init(0.5, 2), .init(1, 10)]))

    @Test func valuesFollowTheLinesBetweenBreakpoints() {
        #expect(scale.value(at: 0.25) == 1)
        #expect(scale.value(at: 0.75) == 6)
        #expect(scale.fraction(of: 1) == 0.25)
        #expect(scale.fraction(of: 6) == 0.75)
    }

    @Test func pastTheEndsTheEndsHold() {
        let short = ValueScale(0 ... 10, taper: .breakpoints([.init(0.2, 2), .init(0.8, 8)]))
        #expect(short.value(at: 0.1) == 2)
        #expect(short.value(at: 0.9) == 8)
        #expect(short.fraction(of: 1) == 0.2)
        #expect(short.fraction(of: 9) == 0.8)
    }

    @Test func consoleGainPutsUnityTwoThirdsUp() {
        let gain = ValueScale.consoleGain()
        #expect(abs(gain.fraction(of: 1) - 2.0 / 3.0) < 0.000_1)
        #expect(gain.value(at: 2.0 / 3.0) == 1)
        #expect(abs(gain.fraction(of: ValueScale.gain(decibels: -12)) - 1.0 / 3.0) < 0.000_1)
        #expect(gain.value(at: 1) == 2)
    }

    @Test func consoleGainIsSilentAtTheBottomAndBelowTheFloor() {
        let gain = ValueScale.consoleGain()
        #expect(gain.value(at: 0) == 0)
        #expect(gain.fraction(of: 0) == 0)
        #expect(gain.fraction(of: ValueScale.gain(decibels: -80)) == 0)
    }

    @Test func decibelsAreTheGainsInverse() {
        #expect(ValueScale.decibels(gain: 1) == 0)
        #expect(abs(ValueScale.decibels(gain: 2) - 6.0206) < 0.0001)
        #expect(abs(ValueScale.decibels(gain: ValueScale.gain(decibels: -12)) + 12) < 1e-9)
        #expect(ValueScale.decibels(gain: 0) == -.infinity)
    }
}
