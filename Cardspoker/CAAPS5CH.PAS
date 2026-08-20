unit caaPS5CH;

(*
 * unit caaPS5CH for Delphi 4 through 2005 (32-Bit Native)
 * Version 1.0.0
 * Copyright 2005, Charles A. Appel Jr.
 *
 * Chuck's Poker Suite:
 *   This is a poker library, supporting 3-Card, 4-Card, and 5-Card poker
 *   variations. This library is not Object Oriented. Instead it uses
 *   traditional Pascal constructs such as records and arrays.
 *
 * Overview: (see caaPSCrd.pas )
 *
 * Purpose of this unit:
 *   Defines the 5-Card Hand type and it's support types and functions.
 *
 * History:
 *   02-04-2005 - This unit created as modified version of caaPS4CH.
 *   02-08-2005 - Low-ball support added.
 *   02-20-2005 - Added preprocessing statements to sort routine. This resulted
 *                in a 10% speed increase.
 *   03-23-2005 - Changed prefix to caa.
 *                (Version 1.0.0)
 *)

interface

uses
  caaPSCrd, caaPSDck;

type
  { Tcaa5CardHandRating - this type is the core type of the rating system.
    It is implemented as an LongInt - a 32-bit integer. Information about the
    hand is mapped as described below:

        not  used     rank     card5  card4  card3  card2  card1
        3322 2222     2222     1111   1111   1100   0000   0000
        1098 7654     3210     9876   5432   1098   7654   3210
      | HO---------------------- bits -----------------------LO |

    Only 24 bits are actually used. The upper eight bits are simply ignored.

    Bits 20..23 contain the hand rank.

      Hand           Value   Bits    Hands/Deck
      No Pair        = 0 --- 0000     1,302,540
      One Pair       = 1 --- 0001     1,098,240
      Two Pair       = 2 --- 0010       123,552
      Trips          = 3 --- 0011        54,912
      Straight       = 4 --- 0100        10,200
      Flush          = 5 --- 0101         5,108
      Full House     = 6 --- 0110         3,744
      Four of a Kind = 7 --- 0111           624
      Straight Flush = 8 --- 1000            36
      Royal Flush    = 9 --- 1001             4
      -----------------------------------------
                         Total Hands  2,598,960

    The lowest 20 bits (0..19) are divided into five nibbles which contain
    the ordinal values of the card ranks. The order the cards are in is based
    on the rules for evaluating the hands of poker and is described below:

       High Hand Evaluations:
       For all Straights, Flushes and No Pair hands, the cards will be sorted
         with the highest card in position card5 (bits 16..19) and the lowest
         in position card1 (bits 00...03). In a baby straight or baby straight
         flush, the ace will be ranked low. In all other cases, the ace will be
         ranked high. Examples: K-Q-J-10-9, A-9-5-4-2, 5-4-3-2-A etc.

       For One Pair, the pair will occupy card5 (16..19) and card4 (12..15).
         The remaining three cards will be in sorted order (high to low)
         according to rank. K-K-J-4-2 etc.

       For Two Pair, the higher ranking pair will occupy card5 (16..19) and
         card4 (12..15). The second pair will occupy card3 (08..11) and card2
         (04..07) and the odd card will be in the remaining slot.

       For Three of a Kind (Trips), the trips will be in the highest three
         positions (16..19, 12..15, 08..11). The higher odd card will be in
         card2 (04..07) and the lower in card1 (00.03).

       For a Full House, the trips will occupy the three higher positions and
         the pair will occupy the two lower.

       For Four of a Kind Hands, the odd card will occupy card 1 (00.03), with
         the quads in the four higher positions.

       Low Hand Evaluations:
       Aces are always low.

       Straights and Flushes do not count for low evaluation. They are treated
         as No Pair Hands. The cards will be sorted with the highest card in
         position card5 (bits 16..19) and the lowest in position card1
         (bits 00...03).

       For One Pair, the pair will occupy card5 (16..19) and card4 (12..15).
         The remaining three cards will be in sorted order (high to low)
         according to rank. K-K-J-4-2 etc.

       For Two Pair, the higher ranking pair will occupy card5 (16..19) and
         card4 (12..15). The second pair will occupy card3 (08..11) and card2
         (04..07) and the odd card will be in the remaining slot.

       For Three of a Kind (Trips), the trips will be in the highest three
         positions (16..19, 12..15, 08..11). The higher odd card will be in
         card2 (04..07) and the lower in card1 (00.03).

       For a Full House, the trips will occupy the three higher positions and
         the pair will occupy the two lower.

       For Four of a Kind Hands, the odd card will occupy card 1 (00.03), with
         the quads in the four higher positions.

    The value stored for the card is one higher than the ordinal value of
    the card as type TcaaCardRank. This makes the rating easier to read.
    ( A two will display as a 2 instead of a 1 for example. )  Remember this
    if you must directly access the rank nibbles. See the getCardRankName for
    an example.
  }    
  Tcaa5CardHandRating = LongInt;

  { card position in hand }
  Tcaa5CardHandPosition = 1..5;

  { Card Array }
  Tcaa5CardArray = array[Tcaa5CardHandPosition] of TcaaCard;

  { Five card poker hand }
  Tcaa5CardHand = record
    Cards  : Tcaa5CardArray;
    Rating : Tcaa5CardHandRating;
  end;

  { name for hand }
  Tcaa5CardHandName = string[32];

const
  { Rank values used to set/test the base rank of various hands }
  caa5CardNoPair        = $0;
  caa5CardOnePair       = $100000;
  caa5CardTwoPair       = $200000;
  caa5CardThreeOfAKind  = $300000;
  caa5CardStraight      = $400000;
  caa5CardFlush         = $500000;
  caa5CardFullHouse     = $600000;
  caa5CardFourOfAKind   = $700000;
  caa5CardStraightFlush = $800000;
  caa5CardRoyalFlush    = $900000;

  { mask to eliminate everything but the hand ranks above }
  caa5CardHandRanks     = $F00000;

{ set the high value of the hand in Hand.Rating }
procedure caa5CardSetHighValue( var Hand: Tcaa5CardHand );
procedure caa5CardSetLowValue( var Hand: Tcaa5CardHand );

{ get the name of the hand }
function caa5CardGetHandName( const Hand:Tcaa5CardHand ):
                                 Tcaa5CardHandName;

implementation

uses SysUtils;

{ Hand Name Routines --------------------------------------------------------- }

{ function getCardRankName
  Expects: A hand rating and card position. Card positions within a rating are
           ordered as 5,4,3,2,1.
  Returns: The card's rank as a string.
  Notes:   This function is not exported. It is a support function for
           caa5CardGetHandName. }
function getCardRankName( Rating: Tcaa5CardHandRating;
                          cardPos: Tcaa5CardHandPosition ): string;
var
  cardRank : TcaaCardRank;
  tmpRank: integer;
begin

  result := '';
  tmpRank := 0;
  { mask out all cards except the one we want and make sure it is in the
      lowest nibble. }
  case cardPos of
    1 : tmpRank := Rating and $F;
    2 : tmpRank := (Rating and $F0) shr 4;
    3 : tmpRank := (Rating and $F00) shr 8;
    4 : tmpRank := (Rating and $F000) shr 12;
    5 : tmpRank := (Rating and $F0000) shr 16;
  else
    result := 'getCardRankName: Rating Error.';
  end;

  { get the card rank. note: we must subtract one from the value
      stored in the rating. the value in the rating is set one higher
      than the ordinal value of the card rank to make it match the
      spot cards (2..9) and make the ratings easier to read in Hex. }
  cardRank := TcaaCardRank( tmpRank - 1 );
  
  { first get the name for the rank }
  case cardRank of
     caaAceLow  : result  := 'Ace';
     caaTwo     : result  := 'Two';
     caaThree   : result  := 'Three';
     caaFour    : result  := 'Four';
     caaFive    : result  := 'Five';
     caaSix     : result  := 'Six';
     caaSeven   : result  := 'Seven';
     caaEight   : result  := 'Eight';
     caaNine    : result  := 'Nine';
     caaTen     : result  := 'Ten';
     caaJack    : result  := 'Jack';
     caaQueen   : result  := 'Queen';
     caaKing    : result  := 'King';
     caaAceHigh : result  := 'Ace';
  else
     result := 'getCardRankName: Rank Error - ' +
               IntToStr(tmpRank);
     exit;
  end; { case }
end;

{ function caa5CardGetHandName
  Expects: A valid hand with the rating set.
  Returns: The name of the hand. }
function caa5CardGetHandName( const Hand:Tcaa5CardHand ):
                                 Tcaa5CardHandName;
var
  cardRankName5,
  cardRankName4,
  cardRankName3,
  cardRankName2,
  pluralStr,
  pluralStr2: string;
begin
  result := '';
  { in some cases we will wish to make the card name plural. for cards
      other than the six, we simply add 's'. for the six, we add 'es'. }
  pluralStr := 's';
  if getCardRankName( Hand.Rating, 5 ) = 'Six' then
    pluralStr := 'e' + pluralStr;
  pluralStr2 := 's';

  { use the hand rating to determine the string to be returned.
    Hand.Rating and caaHandRanks - will give us the rating of the hand
      without regard to the card values. this saves us the trouble of setting
      ranges for the cases.
    we then get the card names by using the value stored for them in the
      rating. we cannot derive the card name from the cards array, because
      the cards in the array remain in the order they were dealt. }
  case (Hand.Rating and caa5CardHandRanks) of
    caa5CardNoPair :
    begin
      cardRankName5 := getCardRankName( Hand.Rating, 5 );
      cardRankName4 := getCardRankName( Hand.Rating, 4 );
      result := 'No Pair: ' +
                cardRankName5 +
                ', ' +
                cardRankName4 +
                ' High.';
    end;

    caa5CardOnePair :
    begin
      cardRankName5 := getCardRankName( Hand.Rating, 5 );
      result := 'Pair of ' +
                cardRankName5 +
                pluralstr;
    end;

    caa5CardTwoPair :
    begin
      cardRankName5 := getCardRankName( Hand.Rating, 5 );
      cardRankName3 := getCardRankName( Hand.Rating, 3 );
      if cardRankName3 = 'Six' then pluralStr2 := 'es';
      result := 'Two Pairs: ' +
                cardRankName5 +
                pluralstr +
                ' and ' +
                cardRankName3 +
                pluralstr2;
    end;

    caa5CardThreeOfAKind :
    begin
      cardRankName5 := getCardRankName( Hand.Rating, 5 );
      result := 'Three ' +
                cardRankName5 +
                pluralstr;
    end;

    caa5CardStraight :
    begin
      cardRankName5 := getCardRankName( Hand.Rating, 5 );
      result := cardRankName5 + ' High Straight';
    end;

    caa5CardFlush :
    begin
      cardRankName5 := getCardRankName( Hand.Rating, 5 );
      result := cardRankName5 + ' High Flush';
    end;

    caa5CardFullHouse :
    begin
      cardRankName5 := getCardRankName( Hand.Rating, 5 );
      cardRankName2 := getCardRankName( Hand.Rating, 2 );
      if cardRankName2 = 'Six' then pluralStr2 := 'es';
      result := 'Full House: ' +
                cardRankName5 +
                pluralstr +
                ' over ' +
                cardRankName2 +
                pluralstr2;
    end;

    caa5CardFourOfAKind :
    begin
      cardRankName5 := getCardRankName( Hand.Rating, 5 );
      result := 'Four ' +
                cardRankName5 +
                pluralstr;
    end;

    caa5CardStraightFlush :
    begin
      cardRankName5 := getCardRankName( Hand.Rating, 5 );
      result := cardRankName5 + ' High Straight Flush';
    end;

    caa5CardRoyalFlush :
    begin
      result := 'Royal Flush';
    end;

  else
    result := 'caa5CardGetHandName: Error.';
  end;
end;

{ Hand Rating Routines - General --------------------------------------------- }

{ procedure swapCards
  Expects: Two valid cards.
  Returns: The same two cards with their contents swapped.
  Notes:   This function is not exported. It is a private function used by
           the sorting routine. }
procedure swapCards( var card1, card2: TcaaCard );
var
  tempCard: TcaaCard;
begin
  tempCard := card1;
  card1 := card2;
  card2 := tempCard;
end;

{ procedure sortCardsLowToHigh
  Expects: A valid array of five cards.
  Returns: The same array, sorted from low to high.
  Notes:   This function is not exported. It is used by the isStraight and
           caa5CardSetxxxValue routines.
           This is (sort of) an unrolled Bubble Sort with a preprocessor. }
procedure sortCardsLowToHigh( var evalHand: Tcaa5CardArray );
begin
  { pre-process - three comparisons }
  if evalHand[1].CardRank > evalHand[5].CardRank then
    swapCards( evalHand[1], evalHand[5] );
  if evalHand[2].CardRank > evalHand[5].CardRank then
    swapCards( evalHand[2], evalHand[5] );
  if evalHand[2].CardRank > evalHand[4].CardRank then
    swapCards( evalHand[2], evalHand[4] );

  { pass 1 - four comparisons }
  if evalHand[1].CardRank > evalHand[2].CardRank then
    swapCards( evalHand[1], evalHand[2] );
  if evalHand[2].CardRank > evalHand[3].CardRank then
    swapCards( evalHand[2], evalHand[3] );
  if evalHand[3].CardRank > evalHand[4].CardRank then
    swapCards( evalHand[3], evalHand[4] );
  if evalHand[4].CardRank > evalHand[5].CardRank then
    swapCards( evalHand[4], evalHand[5] );

  { pass 2 - three comparisons }
  if evalHand[1].CardRank > evalHand[2].CardRank then
    swapCards( evalHand[1], evalHand[2] );
  if evalHand[2].CardRank > evalHand[3].CardRank then
    swapCards( evalHand[2], evalHand[3] );
  if evalHand[3].CardRank > evalHand[4].CardRank then
    swapCards( evalHand[3], evalHand[4] );

  { pass 3 - two comparisons }
  if evalHand[1].CardRank > evalHand[2].CardRank then
    swapCards( evalHand[1], evalHand[2] );
  if evalHand[2].CardRank > evalHand[3].CardRank then
    swapCards( evalHand[2], evalHand[3] );

  { pass 4 - one comparison }
  if evalHand[1].CardRank > evalHand[2].CardRank then
    swapCards( evalHand[1], evalHand[2] );
end;

{ function CardsRating
  Expects: A valid array of five cards arranged according to standard poker
           rules.
  Returns: The cards rating for the cards in the hand.  This cards rating
           consists only of the card information - stored in the lower
           five nibbles of the hand rating. It does not include the rating
           for hand type.
  Note:    The rating is set up to make it easy to read. Therefore, one (1)
           is added to the value to make it match the spot values on the two
           through nine. }
function CardsRating(const evalHand: Tcaa5CardArray): Tcaa5CardHandRating;
var
  cd1, cd2, cd3, cd4, cd5 : integer;
begin
   cd1 := Ord( evalHand[1].CardRank ) + 1;
   cd2 := Ord( evalHand[2].CardRank ) + 1;
   cd3 := Ord( evalHand[3].CardRank ) + 1;
   cd4 := Ord( evalHand[4].CardRank ) + 1;
   cd5 := Ord( evalHand[5].CardRank ) + 1;
   { the card array comes in as cd1,cd2,cd3, cd4, cd5. we reverse this in the
     rating. cd1 is in bits 0..3, cd2 in 4..7, etc. }
   Result := cd1 + (cd2 shl 4) + (cd3 shl 8) + (cd4 shl 12) + (cd5 shl 16);
end;

{ Hand Rating Routines - Tests for Hand Types -------------------------------- }

{ function isFlush
  Expects: A valid array of five cards. They need not be sorted.
  Returns: True if the cards are a flush.
           False if the cards are not a flush. }
function isFlush( const evalHand: Tcaa5CardArray ): boolean;
begin
  result := false;
  if ( evalHand[1].CardSuit = evalHand[2].CardSuit ) and
     ( evalHand[1].CardSuit = evalHand[3].CardSuit ) and
     ( evalHand[1].CardSuit = evalHand[4].CardSuit ) and
     ( evalHand[1].CardSuit = evalHand[5].CardSuit ) then result := true;
end;

{ function isFourOfAKind
  Expects: A valid array of five cards sorted from low to high.
  Returns: True if the cards contain trips.
           False if the cards do not contain four of a kind. }
function isFourOfAKind( const evalHand: Tcaa5CardArray ): boolean;
begin
  result := false;
  if (evalHand[1].CardRank = evalHand[4].CardRank) or
     (evalHand[2].CardRank = evalHand[5].CardRank) then result := true;
end;

{ function isFullHouse
  Expects: A valid array of five cards sorted from low to high.
  Returns: True if the cards contain trips.
           False if the cards do not contain trips. }
function isFullHouse( const evalHand: Tcaa5CardArray ): boolean;
begin
  result := false;
  if (evalHand[1].CardRank = evalHand[3].CardRank) and
     (evalHand[4].CardRank = evalHand[5].CardRank) then
  begin
    result := true;
    exit;
  end;

  if (evalHand[1].CardRank = evalHand[2].CardRank) and
     (evalHand[3].CardRank = evalHand[5].CardRank) then  result := true;
end;

{ function isOnePair
  Expects: A valid array of five cards sorted from low to high.
  Returns: True if the cards contain a pair.
           False if the cards do not contain a pair. }
function isOnePair( const evalHand: Tcaa5CardArray ): boolean;
begin
  result := false;
  if (evalHand[1].CardRank = evalHand[2].CardRank) or
     (evalHand[2].CardRank = evalHand[3].CardRank) or
     (evalHand[3].CardRank = evalHand[4].CardRank) or
     (evalHand[4].CardRank = evalHand[5].CardRank) then result := true;
end;

{ function isStraight
  Expects: A valid array of five cards sorted from low to high.
  Returns: True if the cards are a straight.
           False if the cards are not a straight.
  Notes:   This routine can change the order of the cards. }
function isStraight( var evalHand: Tcaa5CardArray ): boolean;
begin
  result := false;

  { if the rank of card 5 and card 1 differ by four, we should have
    as straight. we are relying on the fact that straights are tested after
    pairs, trips (and other hands with multiple cards of the same rank) have
    been eliminated, therefore the four cards in the array *must* have
    different ranks. }
  if ( Ord( evalHand[5].CardRank ) - Ord( evalHand[1].CardRank ) ) = 4 then
  begin
    result := true;
    exit;
  end;

  { at this point in the evaluation, all aces are still high and
    all cards are sorted from low to high.
    we must check for the possibility that we have 2-3-4-5-A. }
  if ( evalHand[5].CardRank = caaAceHigh ) and
     ( evalHand[4].CardRank = caaFive ) then
  begin
    evalHand[5].CardRank := caaAceLow;
    sortCardsLowToHigh( evalHand );
    result := true;
    exit;
  end;
end;

{ function isThreeOfAKind
  Expects: A valid array of five cards sorted from low to high.
  Returns: True if the cards contain trips.
           False if the cards do not contain trips. }
function isThreeOfAKind( const evalHand: Tcaa5CardArray ): boolean;
begin
  result := false;
  if (evalHand[1].CardRank = evalHand[3].CardRank) or
     (evalHand[2].CardRank = evalHand[4].CardRank) or
     (evalHand[3].CardRank = evalHand[5].CardRank) then result := true;
end;

{ function isTwoPair
  Expects: A valid array of five cards sorted from low to high.
  Returns: True if the cards contain two pair.
           False if the cards do not contain two pair. }
function isTwoPair( const evalHand: Tcaa5CardArray ): boolean;
begin
  result := false;
  { we could have XXyyA, XXAyy... }
  if (evalHand[1].CardRank = evalHand[2].CardRank) then
    if (evalHand[3].CardRank = evalHand[4].CardRank) or
       (evalHand[4].CardRank = evalHand[5].CardRank) then
    begin
      result := true;
      Exit;
    end;

  { ... or AXXyy }
  if (evalHand[2].CardRank = evalHand[3].CardRank) and
     (evalHand[4].CardRank = evalHand[5].CardRank) then result := true;
end;

{ Main Hand Rating Routine --------------------------------------------------- }
{ procedure caa5CardSetHighValue
  Expects: A valid hand of 5 cards.
  Returns: The same hand with the rating set.
  Notes:   This routine preserves the original card order. The actual
           processing is done on a copy of the card array. }
procedure caa5CardSetHighValue( var Hand: Tcaa5CardHand );
var
  evalHand : Tcaa5CardArray; { actual hand to evaluate }
  flush, straight: boolean;
begin
  { set hand rating to 0 }
  Hand.Rating := 0;

  { copy the card values to the test array }
  evalHand := Hand.Cards;

  { test routines expect the hand to be sorted }
  sortCardsLowToHigh( evalHand );

  { test to see if hand contains a pair }
  if isOnePair( evalHand ) then
  begin

    { we have at least a pair. test to see if the hand contains trips. }
    if isThreeOfAKind( evalHand ) then
    begin

      { we have at least trips. test to see if it is a full house }
      if isFullHouse( evalHand ) then
      begin
        { set the card order, then set the rating and exit. }
        { if the third and first cards match, the trips are out of position. }
        if evalHand[3].CardRank = evalHand[1].CardRank then  { 54321 }
        begin                                                { bbAAA }
          SwapCards( evalHand[1], evalHand[4] );             { bAAAb }
          SwapCards( evalHand[2], evalHand[5] );             { AAAbb }
        end;
        Hand.Rating := CardsRating( evalHand ) or caa5CardFullHouse;
        Exit;
      end; { if isFullHouse }

      { not a full house. test to see if we have four of a kind. }
      if isFourOfAKind( evalHand ) then
      begin
        { set the card order, set the rating and exit }      { 54321 }
        if evalHand[4].CardRank = evalHand[1].CardRank then  { bAAAA }
          SwapCards( evalHand[1], evalHand[5] );             { AAAAb }
        Hand.Rating := CardsRating( evalHand ) or caa5CardFourOfAKind;
        Exit;
      end; { if isFourOfAKind }

      { not four of a kind or a full house, but it is trips.
        set the order of the cards in the evaluation hand.
        the trips should be in positions 5, 4 and 3, but they may be in
          3,2,1 or 4,3, and 2.
        set the rating and exit. }
      if evalHand[3].CardRank = evalHand[1].CardRank then  { 54321 }
      begin                                                { bcAAA }
        SwapCards( evalHand[1], evalHand[4] );             { AcAbA }
        SwapCards( evalHand[2], evalHand[5] );             { AAAbc }
      end
      else if evalHand[4].CardRank = evalHand[2].CardRank then  { 54321 }
      begin                                                     { bAAAc }
        SwapCards( evalHand[2], evalHand[5] );                  { AAAbc }
      end;
      Hand.Rating := CardsRating( evalHand ) or caa5CardThreeOfAKind;
      Exit;
    end; { if isThreeOfAKind }

    { not three of a kind. it could still be two pair. }
    if isTwoPair( evalHand ) then
    begin
      { set the card order. set the hand rating and exit.
        the order should be in AABBc. but it could be:
        AAcBB or cAABB.  }
      if (evalHand[1].CardRank = evalHand[2].CardRank) and
         (evalHand[4].CardRank = evalHand[5].CardRank) then  { 54321 }
      begin                                                  { AAcBB }
        SwapCards( evalHand[1], evalHand[3] );               { AABBc }
      end
      else if (evalHand[3].CardRank = evalHand[4].CardRank) then  { 54321 }
      begin                                                       { cAABB }
        SwapCards( evalHand[3], evalHand[5] );                    { AAcBB }
        SwapCards( evalHand[1], evalHand[3] );                    { AABBc }
      end;
      Hand.Rating := CardsRating( evalHand ) or caa5CardTwoPair;
      Exit;
    end; { if isTwoPair }

    { not three of a kind, four of a kind or two pair, but it is a pair.
      set the order of the cards in the evaluation hand.
      the pair should be in positions 5 and 4. the possiblities are:
        AAbcd, bAAcd, bcAAd, and bcdAA.
      set the rating and exit. }
      if (evalHand[1].CardRank = evalHand[2].CardRank) then { 54321 }
      begin                                                 { bcdAA }
        SwapCards( evalHand[1], evalHand[3] );              { bcAAd }
        SwapCards( evalHand[2], evalHand[4] );              { bAAcd }
        SwapCards( evalHand[3], evalHand[5] );              { AAbcd }
      end
      else if (evalHand[2].CardRank = evalHand[3].CardRank) then  { 54321 }
      begin                                                       { bcAAd }
        SwapCards( evalHand[2], evalHand[4]);                     { bAAcd }
        SwapCards( evalHand[3], evalHand[5]);                     { AAbcd }
      end
      else if (evalHand[3].CardRank = evalHand[4].CardRank) then { 54321 }
      begin                                                      { bAAcd }
        SwapCards( evalHand[3], evalHand[5]);                    { AAbcd }
      end;
      Hand.Rating := CardsRating( evalHand ) or caa5CardOnePair;
      Exit;
  end; { if isOnePair }

  { if we get this far, we know that there are no cards of matching rank.
    it is now time to test for straights and flushes. }
  straight := isStraight( evalHand );
  flush    := isFlush( evalHand );

  { if the hand is a straight flush,
    the isStraight function sets the proper order for a straight.
    set the rating for a straight flush or royal flush and exit. }
  if straight and flush then
  begin
    if (evalHand[5].CardRank = caaAceHigh) then
      Hand.Rating := CardsRating( evalHand ) or caa5CardRoyalFlush
    else
      Hand.Rating := CardsRating( evalHand ) or caa5CardStraightFlush;
    Exit;
  end;

  { if the hand is a straight,
    the isStraight function sets the proper order for a straight.
    set the rating and exit. }
  if straight then
  begin
    Hand.Rating := CardsRating( evalHand ) or caa5CardStraight;
    Exit;
  end;

  { if the hand is a straight flush,
    set the rating and exit. }
  if flush then
  begin
    Hand.Rating := CardsRating( evalHand ) or caa5CardFlush;
    Exit;
  end;

  { if we got this far, we have trash. set the hand rating. }
  Hand.Rating := CardsRating( evalHand ) or caa5CardNoPair;
end;

{ procedure caa5CardSetLowValue
  Expects: A valid hand of 5 cards.
  Returns: The same hand with the rating set.
  Notes:   This routine preserves the original card order. The actual
           processing is done on a copy of the card array. }
procedure caa5CardSetLowValue( var Hand: Tcaa5CardHand );
var
  evalHand : Tcaa5CardArray; { actual hand to evaluate }
begin
  { set hand rating to 0 }
  Hand.Rating := 0;

  { copy the card values to the test array }
  evalHand := Hand.Cards;

  { for the low rating, the aces must be set to low. }
  if evalHand[1].CardRank = caaAceHigh then
    evalHand[1].CardRank := caaAceLow;
  if evalHand[2].CardRank = caaAceHigh then
    evalHand[2].CardRank := caaAceLow;
  if evalHand[3].CardRank = caaAceHigh then
    evalHand[3].CardRank := caaAceLow;
  if evalHand[4].CardRank = caaAceHigh then
    evalHand[4].CardRank := caaAceLow;
  if evalHand[5].CardRank = caaAceHigh then
    evalHand[5].CardRank := caaAceLow;

  { test routines expect the hand to be sorted }
  sortCardsLowToHigh( evalHand );

  { test to see if hand contains a pair }
  if isOnePair( evalHand ) then
  begin

    { we have at least a pair. test to see if the hand contains trips. }
    if isThreeOfAKind( evalHand ) then
    begin

      { we have at least trips. test to see if it is a full house }
      if isFullHouse( evalHand ) then
      begin
        { set the card order, then set the rating and exit. }
        { if the third and first cards match, the trips are out of position. }
        if evalHand[3].CardRank = evalHand[1].CardRank then  { 54321 }
        begin                                                { bbAAA }
          SwapCards( evalHand[1], evalHand[4] );             { bAAAb }
          SwapCards( evalHand[2], evalHand[5] );             { AAAbb }
        end;
        Hand.Rating := CardsRating( evalHand ) or caa5CardFullHouse;
        Exit;
      end;

      { not a full house. test to see if we have four of a kind. }
      if isFourOfAKind( evalHand ) then
      begin
        { set the card order, set the rating and exit }       { 54321 }
        if evalHand[4].CardRank = evalHand[1].CardRank then   { bAAAA }
          SwapCards( evalHand[1], evalHand[5] );              { AAAAb }
        Hand.Rating := CardsRating( evalHand ) or caa5CardFourOfAKind;
        Exit;
      end;

      { not four of a kind or a full house, but it is trips.
        set the order of the cards in the evaluation hand.
        the trips should be in positions 5, 4 and 3, but they may be in
          3,2,1 or 4,3, and 2.
        set the rating and exit. }
      if evalHand[3].CardRank = evalHand[1].CardRank then  { 54321 }
      begin                                                { bcAAA }
        SwapCards( evalHand[1], evalHand[4] );             { bAAAc }
        SwapCards( evalHand[2], evalHand[5] );             { AAAbc }
      end
      else if evalHand[4].CardRank = evalHand[2].CardRank then  { 54321 }
      begin                                                     { bAAAc }
        SwapCards( evalHand[2], evalHand[5] );                  { AAAbc }
      end;
      Hand.Rating := CardsRating( evalHand ) or caa5CardThreeOfAKind;
      Exit;
    end; { if is ThreeOfAKind }

    { not three of a kind or four of a kind. it could be two pair. }
    if isTwoPair( evalHand ) then
    begin
      { set the card order. set the hand rating and exit.
        the order should be in AABBc. but it could be:
        AAcBB or cAABB.  }
      if (evalHand[1].CardRank = evalHand[2].CardRank) and
         (evalHand[4].CardRank = evalHand[5].CardRank) then  { 54321 }
      begin                                                  { AAcBB }
        SwapCards( evalHand[1], evalHand[3] );               { AABBc }
      end
      else if (evalHand[3].CardRank = evalHand[4].CardRank) then  { 54321 }
      begin                                                       { cAABB }
        SwapCards( evalHand[3], evalHand[5] );                    { AAcBB }
        SwapCards( evalHand[1], evalHand[3] );                    { AABBc }
      end;
      Hand.Rating := CardsRating( evalHand ) or caa5CardTwoPair;
      Exit;
    end;

    { not three of a kind, four of a kind or two pair, but it is a pair.
      set the order of the cards in the evaluation hand.
      the pair should be in positions 5 and 4. the possiblities are:
        AAbcd, bAAcd, bcAAd, and bcdAA.
      set the rating and exit. }
      if (evalHand[1].CardRank = evalHand[2].CardRank) then { 54321 }
      begin                                                 { bcdAA }
        SwapCards( evalHand[1], evalHand[3] );              { bcAAd }
        SwapCards( evalHand[2], evalHand[4] );              { bAAcd }
        SwapCards( evalHand[3], evalHand[5] );              { AAbcd }
      end
      else if (evalHand[2].CardRank = evalHand[3].CardRank) then  { 54321 }
      begin                                                       { bcAAd }
        SwapCards( evalHand[2], evalHand[4]);                     { bAAcd }
        SwapCards( evalHand[3], evalHand[5]);                     { AAbcd }
      end
      else if (evalHand[3].CardRank = evalHand[4].CardRank) then { 54321 }
      begin                                                      { bAAcd }
        SwapCards( evalHand[3], evalHand[5]);                    { AAbcd }
      end;
      Hand.Rating := CardsRating( evalHand ) or caa5CardOnePair;
      Exit;
  end; { if isOnePair }

  { if we got this far, we have trash. set the hand rating. }
  Hand.Rating := CardsRating( evalHand ) or caa5CardNoPair;
end;

end.
