import Testing
import VitralTokens

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
        #expect(scale.formatted(0.5) == "0.50")
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
