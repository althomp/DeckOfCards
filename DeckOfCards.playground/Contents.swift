import UIKit
import XCTest

struct Card: CustomStringConvertible, Equatable {
    var suit: Suit
    var faceValue: FaceValue
    var color: UIColor {
        switch suit {
        case .heart, .diamond:
            return .red
        case .club, .spade:
            return .black
        }
    }
    
    var description: String {
        let faceValueString = String(describing: faceValue).capitalized
        let suitString = String(describing: suit).capitalized
        return "\(faceValueString) of \(suitString)s"
    }
    static func ==(lhs: Card, rhs: Card) -> Bool {
        return lhs.suit == rhs.suit && lhs.faceValue == rhs.faceValue
    }
}

enum Suit: String {
    case heart, spade, club, diamond
    static let allOptions = [heart, spade, club, diamond]
}

enum FaceValue: Int {
    case ace, two, three, four, five, six, seven, eight, nine, ten, jack, queen, king
    static let allOptions = [ace, two, three, four, five, six, seven, eight, nine, ten, jack, queen, king]
}

class DeckOfCards {
    private var deck: [Card]
    
    init() {
        deck = []
        getNewDeck()
    }
    
    func getNewDeck() {
        deck.removeAll()
        for suit in Suit.allOptions {
            for faceValue in FaceValue.allOptions {
                deck.append(Card(suit: suit, faceValue: faceValue))
            }
        }
        shuffle()
    }
    
    /* Fisher-Yates shuffle */
    func shuffle() {
        for i in stride(from: cardCount()-1, through: 1, by: -1) {
            let j = Int(arc4random_uniform(UInt32(i + 1)))
            let temp = deck[i]
            deck[i] = deck[j]
            deck[j] = temp
        }
    }
    
    /* Faro Shuffle provided for magicians */
    func faroShuffle() {
        if (cardCount() <= 1) { return }
        
        var tempDeck = deck
        let highestIndex = cardCount() - 1
        let midpoint = highestIndex/2 + 1
        for i in 0..<midpoint {
            let index = (2*i + 1) > highestIndex ? highestIndex : (2*i + 1)
            deck[index] = tempDeck[i]
        }
        for i in (midpoint)...highestIndex {
            let index = (2*(i - midpoint)) > highestIndex ? highestIndex : (2*(i - midpoint))
            deck[index] = tempDeck[i]
        }
    }
    
    func dealOneCard() -> Card? {
        if !deck.isEmpty {
            return deck.removeFirst()
        }
        return nil
    }
    
    func cardCount() -> Int {
        return deck.count
    }
    
    func contains(_ card: Card) -> Bool {
        for c in deck {
            if c == card {
                return true
            }
        }
        return false
    }
    
    func containsDuplicates() -> Bool {
        for (index, card) in deck.enumerated() {
            for i in index+1..<cardCount() {
                if card == deck[i] {
                    return true
                }
            }
        }
        return false
    }
    
    func printDeckDescription() {
        var deckDesc = "Deck of \(cardCount()) cards."
        if cardCount() > 0 {
            deckDesc += " Order of cards: "
            for (index, card) in deck.enumerated() {
                deckDesc += " \(index + 1): \(card)"
                if index < cardCount() - 1 {
                    deckDesc += ","
                } else {
                    deckDesc += "."
                }
            }
        }
        print(deckDesc)
    }
}

class DeckOfCardsTests: XCTestCase {
    var deck: DeckOfCards!
    
    override func setUp() {
        super.setUp()
        deck = DeckOfCards()
    }
    
    func testDeckCreation() {
        XCTAssertEqual(deck.cardCount(), 52)
        XCTAssertEqual(deck.containsDuplicates(), false)
    }
    
    func testCardCount() {
        XCTAssertEqual(deck.cardCount(), 52)
        
        deck.dealOneCard()
        XCTAssertEqual(deck.cardCount(), 51)
        
        for _ in 0..<51 {
            deck.dealOneCard()
        }
        XCTAssertEqual(deck.cardCount(), 0)
        
        deck.getNewDeck()
        XCTAssertEqual(deck.cardCount(), 52)
    }
    
    func testShuffle() {
        XCTAssertEqual(deck.containsDuplicates(), false)
        
        deck.shuffle()
        XCTAssertEqual(deck.containsDuplicates(), false)
        
        deck.dealOneCard()
        deck.shuffle()
        XCTAssertEqual(deck.containsDuplicates(), false)
        
        for _ in 0..<49 {
            deck.dealOneCard()
        }
        deck.shuffle()
        XCTAssertEqual(deck.containsDuplicates(), false)
    }
    
    func testFaroShuffle() {
        XCTAssertEqual(deck.containsDuplicates(), false)
        
        deck.faroShuffle()
        XCTAssertEqual(deck.containsDuplicates(), false)
        
        deck.dealOneCard()
        deck.faroShuffle()
        XCTAssertEqual(deck.containsDuplicates(), false)
        
        for _ in 0..<49 {
            deck.dealOneCard()
        }
        deck.faroShuffle()
        XCTAssertEqual(deck.containsDuplicates(), false)
    }
    
    func testContains() {
        XCTAssertEqual(deck.containsDuplicates(), false)
        
        let card = Card(suit: .club, faceValue: .ace)
        XCTAssertEqual(deck.contains(card), true)
        
        let drawnCard = deck.dealOneCard()!
        XCTAssertEqual(deck.contains(drawnCard), false)
        
        deck.shuffle()
        XCTAssertEqual(deck.contains(drawnCard), false)
        
        deck.faroShuffle()
        XCTAssertEqual(deck.contains(drawnCard), false)
        
        for _ in 0..<51 {
            deck.dealOneCard()
        }
        XCTAssertEqual(deck.contains(drawnCard), false)
    }
    
    func testCardDealing() {
        XCTAssertNotNil(deck.dealOneCard())
        XCTAssertEqual(deck.cardCount(), 51)
        for _ in 0..<51 {
            deck.dealOneCard()
        }
        XCTAssertNil(deck.dealOneCard())
    }
}

