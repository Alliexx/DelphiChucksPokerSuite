unit caaPSDck;

(*
 * unit caaPSDck for Delphi 4 through 2005 (32-Bit Native)
 * Version 1.0.0
 * Copyright 2005, Charles A. Appel Jr.
 *
 * Chuck's Poker Suite:
 *   This is a poker library, supporting 3-Card, 4-Card, and 5-Card poker
 *   variations. This library is not Object Oriented. Instead it uses
 *   traditional Pascal constructs such as records.
 *
 * Overview: (see caaPSCrd.pas )
 *
 * Purpose of this unit:
 *   Defines the deck type and it's support types and functions.
 *
 * History:
 *   01-30-2005 - This unit created.
 *                Performed initial testing.
 *                Barring further bug fixes or unexpected needs, this unit
 *                  is complete.
 *   02-02-2005 - This unit was ported from the experimental 3-Card library.
 *                The base types were renamed to match the new format.
 *                The prefix used throughout this library is "caaPS_"
 *   03-09-2005 - Redefined the card position constants.
 *   03-23-2005 - Changed prefix to caa.
 *                (Version 1.0.0)
 *)

interface

uses
  caaPSCrd;

const
  caaStdDeckSize = 52;

  { positions for cards in an standard ordered deck }
  caaClubAce   = 0;
  caaClubTwo   = caaClubAce + 1;
  caaClubThree = caaClubTwo + 1;
  caaClubFour  = caaClubThree + 1;
  caaClubFive  = caaClubFour + 1;
  caaClubSix   = caaClubFive + 1;
  caaClubSeven = caaClubSix + 1;
  caaClubEight = caaClubSeven + 1;
  caaClubNine  = caaClubEight + 1;
  caaClubTen   = caaClubNine + 1;
  caaClubJack  = caaClubTen + 1;
  caaClubQueen = caaClubJack + 1;
  caaClubKing  = caaClubQueen + 1;

  caaDiamondAce   = caaClubKing + 1;
  caaDiamondTwo   = caaDiamondAce + 1;
  caaDiamondThree = caaDiamondTwo + 1;
  caaDiamondFour  = caaDiamondThree + 1;
  caaDiamondFive  = caaDiamondFour + 1;
  caaDiamondSix   = caaDiamondFive + 1;
  caaDiamondSeven = caaDiamondSix + 1;
  caaDiamondEight = caaDiamondSeven + 1;
  caaDiamondNine  = caaDiamondEight + 1;
  caaDiamondTen   = caaDiamondNine + 1;
  caaDiamondJack  = caaDiamondTen + 1;
  caaDiamondQueen = caaDiamondJack + 1;
  caaDiamondKing  = caaDiamondQueen + 1;

  caaHeartAce   = caaDiamondKing + 1;
  caaHeartTwo   = caaHeartAce + 1;
  caaHeartThree = caaHeartTwo + 1;
  caaHeartFour  = caaHeartThree + 1;
  caaHeartFive  = caaHeartFour + 1;
  caaHeartSix   = caaHeartFive + 1;
  caaHeartSeven = caaHeartSix + 1;
  caaHeartEight = caaHeartSeven + 1;
  caaHeartNine  = caaHeartEight + 1;
  caaHeartTen   = caaHeartNine + 1;
  caaHeartJack  = caaHeartTen + 1;
  caaHeartQueen = caaHeartJack + 1;
  caaHeartKing  = caaHeartQueen + 1;

  caaSpadeAce   = caaHeartKing + 1;
  caaSpadeTwo   = caaSpadeAce + 1;
  caaSpadeThree = caaSpadeTwo + 1;
  caaSpadeFour  = caaSpadeThree + 1;
  caaSpadeFive  = caaSpadeFour + 1;
  caaSpadeSix   = caaSpadeFive + 1;
  caaSpadeSeven = caaSpadeSix + 1;
  caaSpadeEight = caaSpadeSeven + 1;
  caaSpadeNine  = caaSpadeEight + 1;
  caaSpadeTen   = caaSpadeNine + 1;
  caaSpadeJack  = caaSpadeTen + 1;
  caaSpadeQueen = caaSpadeJack + 1;
  caaSpadeKing  = caaSpadeQueen + 1;

type
  { range of card positions in deck types (0..51) }
  TcaaDeckRange  = caaClubAce..caaSpadeKing;

  { the poker deck type is a simple array of cards }
  TcaaCardDeck =
    array[TcaaDeckRange] of TcaaCard;

{ support procedures for card decks }
procedure caaBuildCardDeck( var Deck: TcaaCardDeck );
procedure caaShuffleCardDeck( var Deck: TcaaCardDeck );

implementation

{ procedure caaBuildCardDeck
  Expects: A valid deck of cards. This deck may or may not have had values
             previously assigned to it.
  Returns: An ordered deck of cards - from the Ace of Clubs through the
             King of Spades.
  NOTE:    The aces in this ordered deck will have ranks of caaAceHigh. }
procedure caaBuildCardDeck( var Deck: TcaaCardDeck );
var
  deckPos : TcaaDeckRange; { current position in the deck }
begin
  for deckPos := caaClubAce to caaSpadeKing do
  begin
    { (deckPos mod 13) results in a value of 0..12. thus, by using the
      typecast, we are assigning initial ranks of caaAceLow.. caaKing. }
    Deck[deckPos].CardRank :=
      TcaaCardRank( deckPos mod 13 );

    { set any aces to the default high rank. }
    if Deck[deckPos].CardRank = caaAceLow then
      Deck[deckPos].CardRank := caaAceHigh;

    { (deckPos mod 13) results in a value of 0..3. by typecasting,
      we derive caaClubs..caaSpades. }
    Deck[deckPos].CardSuit := TcaaCardSuit( deckPos div 13 );
  end;
end;

{ procedure caaShuffleCardDeck
  Expects: A valid deck of cards, which has already had values assigned to
             the cards.
  Returns: A shuffled deck of cards. }
procedure caaShuffleCardDeck( var Deck: TcaaCardDeck );
var
  ShuffleCount: integer;
  deckPos1, deckPos2 : TcaaDeckRange;
  tempCard : TcaaCard;
begin
  { shuffle the cards four times. to do this, move through the deck. at each
      position, select a card at another (random) position and swap the two
      cards. }
  for ShuffleCount := 1 to 4 do
    for deckPos1 := caaClubAce to caaSpadeKing do
    begin
      deckPos2 := Random(caaStdDeckSize);
      tempCard := Deck[deckPos1];
      Deck[deckPos1] := Deck[deckPos2];
      Deck[deckPos2] := tempCard;
    end;
end;

initialization
  Randomize;
end.
