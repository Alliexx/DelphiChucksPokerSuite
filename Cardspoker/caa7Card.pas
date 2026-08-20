unit caa7Card;

(*
  Unit caa7Card for Delphi 1 through Delphi 2005
  Version 1.0.0
  Copyright 2005, Charles A. Appel Jr.

  Purpose:
    This is a helper/utility unit designed to make programming 7-Card poker
      games and simulations easier.
     1) Exports 7-Card hand type.
     2) Exports procedures to set the high and low ratings of 7-Card hands.
     3) Exports functions to return the five card hand name in an 7-Card hand.

  History:
    10-10-2005 -
      Unit created. Preliminary testing.

    10-12-2005 -
      Additional testing.
 *)

interface

uses
  caaPSCrd, caaPS5CH;

type
  { Card Arrays }
  Tcaa7CardArray = array[1..7] of TcaaCard;

  { 7 Card Hand record }
  Tcaa7CardHand = record
    Cards  : Tcaa7CardArray;
    HighRating : Tcaa5CardHandRating;
    LowRating: Tcaa5CardHandRating;
  end;
  
{ 7-Card Stud and Texas Hold-em: Helper routines ----------------------------- }
{ Hand rating procedures for 7-Card Hands }
procedure caa7CardSetHighValue( var Hand: Tcaa7CardHand );
procedure caa7CardSetLowValue( var Hand: Tcaa7CardHand );

{ Hand name functions for 7-Card Hands }
function caa7CardGetHighHandName( const Hand:Tcaa7CardHand ): Tcaa5CardHandName;
function caa7CardGetLowHandName( const Hand:Tcaa7CardHand ): Tcaa5CardHandName;

implementation

{ 7-Card Stud and Texas Hold-em: Helper routines ----------------------------- }
{ procedure caa7CardSetHighValue
  Expects: Hand: A valid hand of 7 cards.
           UsesWC: True if the hand uses wild cards or False if does not.
  Returns: The same hand with the high rating set. }
procedure caa7CardSetHighValue( var Hand: Tcaa7CardHand );
var
  c1, c2, c3, c4, c5: integer; { card positions }
  tmpHand: Tcaa5CardHand;
begin
  { we need to create all 21 possible five card hands and evaluate each of
      them, while retaining to high and low ratings.
    initialize the high ratings with value that is lower than possible. }
  Hand.HighRating := 0;

  { loop through the seven cards, creating all possible five card hands }
  for c1 := 1 to 3 do
    for c2 := c1 + 1 to 4 do
      for c3 := c2 + 1 to 5 do
        for c4 := c3 + 1 to 6 do
          for c5 := c4 + 1 to 7 do
          begin
            { set the temporary 5-card evaluation hand equal to the
                five chosen cards }
            tmpHand.Cards[1] := Hand.Cards[c1];
            tmpHand.Cards[2] := Hand.Cards[c2];
            tmpHand.Cards[3] := Hand.Cards[c3];
            tmpHand.Cards[4] := Hand.Cards[c4];
            tmpHand.Cards[5] := Hand.Cards[c5];

            { get a high rating }
            caa5CardSetHighValue( tmpHand );

            { keep highest value }
            if tmpHand.Rating > Hand.HighRating then
              Hand.HighRating := tmpHand.Rating;

          end; { for c5 }
end;


{ procedure caa7CardSetLowValue
  Expects: A valid hand of 7 cards.
  Returns: The same hand with the low rating set. }
procedure caa7CardSetLowValue( var Hand: Tcaa7CardHand );
var
  c1, c2, c3, c4, c5: integer; { card positions }
  tmpHand: Tcaa5CardHand;
begin
  { we need to create all 21 possible five card hands and evaluate each of
      them, while retaining to high and low ratings.
    initialize the low rating with value that is lower than possible. }
  Hand.LowRating := caa5CardRoyalFlush;

  { loop through the seven cards, creating all possible five card hands }
  for c1 := 1 to 3 do
    for c2 := c1 + 1 to 4 do
      for c3 := c2 + 1 to 5 do
        for c4 := c3 + 1 to 6 do
          for c5 := c4 + 1 to 7 do
          begin
            { set the temporary 5-card evaluation hand equal to the
                five chosen cards }
            tmpHand.Cards[1] := Hand.Cards[c1];
            tmpHand.Cards[2] := Hand.Cards[c2];
            tmpHand.Cards[3] := Hand.Cards[c3];
            tmpHand.Cards[4] := Hand.Cards[c4];
            tmpHand.Cards[5] := Hand.Cards[c5];

            { get a low rating }
            caa5CardSetLowValue( tmpHand );

            { keep lowest value }
            if tmpHand.Rating < Hand.LowRating then
              Hand.LowRating := tmpHand.Rating;
          end; { for c5 }
end;


{ function caa7CardGetHighHandName
  Expects: A valid 7-Card hand with the high rating set. It is the high rating
           that is used to build the hand name - not the card array.
  Returns: The name of the hand based on the HighRating. }
function caa7CardGetHighHandName( const Hand:Tcaa7CardHand ): Tcaa5CardHandName;
var
  tmpHand: Tcaa5CardHand;
begin
  tmpHand.Rating := Hand.HighRating;
  result := caa5CardGetHandName( tmpHand );
end;


{ function caa7CardGetLowHandName
  Expects: A valid 7-Card hand with the low rating set. It is the low rating
           that is used to build the hand name - not the card array.
  Returns: The name of the hand based on the LowRating. }
function caa7CardGetLowHandName( const Hand:Tcaa7CardHand ): Tcaa5CardHandName;
var
  tmpHand: Tcaa5CardHand;
begin
  tmpHand.Rating := Hand.LowRating;
  result := caa5CardGetHandName( tmpHand );
end;

end.
