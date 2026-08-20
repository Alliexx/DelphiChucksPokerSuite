unit caaPSCrd;

(*
 * unit caaPSCrd for Delphi 4 through 2005 (32-Bit Native)
 * Version 1.0.0
 * Copyright 2005, Charles A. Appel Jr.
 *
 * Chuck's Poker Suite:
 *   This is a poker library, supporting 3-Card, 4-Card, and 5-Card poker
 *   variations. This library is not Object Oriented. Instead it uses
 *   traditional Pascal constructs such as records and arrays.
 *
 * Limitations:
 *   This library does not support wild cards.
 *
 * Overview:
 *   This library consists of multiple units.
 *     caaPSCrd - (caa Poker Suite Card) - This unit contains the definition
 *                of the standard Card type, its support types and functions.
 *     caaPSDck - (caa Poker Suite Deck) - This unit contains the definition
 *                of the standard Deck type, its support types and functions.
 *     caaPS3CH - (caa Poker Suite 3-Card Hand) -  this unit contains the
 *                definition of the 3-Card Poker hand, the 3-Card hand-rating
 *                function, and other 3-Card support types and functions.
 *     caaPS4CH - (caa Poker Suite 4-Card Hand) -  this unit contains the
 *                definition of the 4-Card Poker hand, the 4-Card hand-rating
 *                function, and other 4-Card support types and functions.
 *     caaPS5CH - (caa Poker Suite 5-Card Hand) -  this unit contains the
 *                definition of the 5-Card Poker hand, the 5-Card hand-rating
 *                function, and other 5-Card support types and functions.
 *
 * Purpose of this unit:
 *   Defines the card type and it's support types and functions.
 *
 * History:
 *   01-29-2005 - This unit created.
 *   01-30-2005 - Performed initial testing.
 *                Fixed bug in get card name function.
 *                Barring further big fixes or unexpected needs, this unit
 *                  is complete.
 *   02-02-2005 - This unit was ported from the experimental 3-Card library.
 *                The base types were renamed to match the new format.
 *                The prefix used throughout this library is "caaPS_"
 *   03-23-2005 - Changed prefix to caa.
 *                (Version 1.0.0)
 *)

interface

type
  { string type used by getCardName Function }
  TcaaCardName = string[32];

  { the fourteen possible ranks of playing cards. fourteen ranks are needed
    because the ace can rank either low or high. }
  TcaaCardRank =
    ( caaAceLow, caaTwo, caaThree, caaFour,
      caaFive, caaSix, caaSeven, caaEight,
      caaNine, caaTen, caaJack,  caaQueen,
      caaKing, caaAceHigh );

  { The four possible suits }
  TcaaCardSuit =
    ( caaClubs, caaDiamonds, caaHearts, caaSpades );

  { The card definition is simple.  }
  TcaaCard = record
    CardRank : TcaaCardRank;
    CardSuit : TcaaCardSuit;
  end;

{ function to return name of card. this is useful for debugging. }
function caaGetCardName( Card: TcaaCard ): TcaaCardName;

{ procedures to set card ranks and suits }
procedure caaSetCardRank( var Card: TcaaCard;
                             Rank: TcaaCardRank );
procedure caaSetCardSuit( var Card: TcaaCard;
                             Suit: TcaaCardSuit );
procedure caaSetCard( var Card: TcaaCard;
                         Rank: TcaaCardRank;
                         Suit: TcaaCardSuit );


implementation

{ function caaGetCardName
  Expects: A valid playing card containing a valid suit and rank.
  Returns: A string contining the name of the card. }
function caaGetCardName( Card: TcaaCard ): TcaaCardName;
begin
  result := '';
  { first get the name for the rank }
  case Card.CardRank of
     caaAceLow    : result  := 'Ace';
     caaTwo       : result  := 'Two';
     caaThree     : result  := 'Three';
     caaFour      : result  := 'Four';
     caaFive      : result  := 'Five';
     caaSix       : result  := 'Six';
     caaSeven     : result  := 'Seven';
     caaEight     : result  := 'Eight';
     caaNine      : result  := 'Nine';
     caaTen       : result  := 'Ten';
     caaJack      : result  := 'Jack';
     caaQueen     : result  := 'Queen';
     caaKing      : result  := 'King';
     caaAceHigh   : result  := 'Ace';
  else
     result := 'caaGetCardName: Rank Error';
     exit;
  end; { case }

  { next add the suit name for the card. }
  case Card.CardSuit of
      caaClubs     : result := result + ' of Clubs';
      caaDiamonds  : result := result + ' of Diamonds';
      caaHearts    : result := result + ' of Hearts';
      caaSpades    : result := result + ' of Spades';
  else
      result := 'caaGetCardName: Suit Error';
  end; { case }
end;

{ procedure caaSetCardRank
  Expects: Card - A valid playing card.
           Rank - A valid Rank to assign to it.
  Returns: A playing card with the card rank field assigned. }
procedure caaSetCardRank( var Card: TcaaCard;
                             Rank: TcaaCardRank);
begin
  Card.CardRank := Rank;
end;

{ procedure caaSetCardSuit
  Expects: Card - A valid playing card.
           Suit - A valid Suit to assign to it.
  Returns: A playing card with the card suit field assigned. }
procedure caaSetCardSuit( var Card: TcaaCard;
                             Suit: TcaaCardSuit);
begin
  Card.CardSuit := Suit;
end;

{ procedure caaSetCard
  Expects: Card - A valid playing card.
           Rank - A valid Rank to assign to it.
           Suit - A valid Suit to assign to it.
  Returns: A playing card with the rank and suit fields assigned. }
procedure caaSetCard( var Card: TcaaCard;
                          Rank: TcaaCardRank;
                          Suit: TcaaCardSuit );
begin
  Card.CardRank := Rank;
  Card.CardSuit := Suit;
end;

end.
