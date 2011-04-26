/**
 * Instrument Infos.mq4
 *
 * Zeigt die Eigenschaften eines Instruments an.
 */
#include <stdlib.mqh>


#property indicator_chart_window


double Pip;
int    PipDigits;
string PriceFormat;

color  Background.Color    = C'212,208,200';
color  Font.Color.Enabled  = Blue;
color  Font.Color.Disabled = Gray;
string Font.Name           = "Tahoma";
int    Font.Size           = 9;

string names[] = { "TRADEALLOWED","POINT","TICKSIZE","SPREAD","STOPLEVEL","FREEZELEVEL","LOTSIZE","TICKVALUE","MINLOT","MAXLOT","LOTSTEP","MARGINCALCMODE","MARGINREQUIRED","MARGININIT","MARGINMAINTENANCE","MARGINHEDGED","SWAPTYPE","SWAPLONG","SWAPSHORT","PROFITCALCMODE","STARTING","EXPIRATION","ACCOUNT_LEVERAGE","STOPOUT_LEVEL" };

#define TRADEALLOWED       0
#define POINT              1
#define TICKSIZE           2
#define SPREAD             3
#define STOPLEVEL          4
#define FREEZELEVEL        5
#define LOTSIZE            6
#define TICKVALUE          7
#define MINLOT             8
#define MAXLOT             9
#define LOTSTEP           10
#define MARGINCALCMODE    11
#define MARGINREQUIRED    12
#define MARGININIT        13
#define MARGINMAINTENANCE 14
#define MARGINHEDGED      15
#define SWAPTYPE          16
#define SWAPLONG          17
#define SWAPSHORT         18
#define PROFITCALCMODE    19
#define STARTING          20
#define EXPIRATION        21
#define ACCOUNT_LEVERAGE  22
#define STOPOUT_LEVEL     23


string labels[];


/**
 * Initialisierung
 *
 * @return int - Fehlerstatus
 */
int init() {
   init = true; init_error = NO_ERROR; __SCRIPT__ = WindowExpertName();
   stdlib_init(__SCRIPT__);

   PipDigits   = Digits - Digits%2;
   Pip         = 1 / MathPow(10, PipDigits);
   PriceFormat = "."+ PipDigits + ifString(Digits==PipDigits, "", "'");

   // Datenanzeige ausschalten
   SetIndexLabel(0, NULL);

   CreateLabels();
   return(catch("init()"));
}


/**
 * Main-Funktion
 *
 * @return int - Fehlerstatus
 */
int start() {
   Tick++;
   if      (init_error != NO_ERROR)                   ValidBars = 0;
   else if (last_error == ERR_TERMINAL_NOT_YET_READY) ValidBars = 0;
   else                                               ValidBars = IndicatorCounted();
   ChangedBars = Bars - ValidBars;
   stdlib_onTick(ValidBars);

   // init() nach ERR_TERMINAL_NOT_YET_READY nochmal aufrufen oder abbrechen
   if (init_error == ERR_TERMINAL_NOT_YET_READY) /*&&*/ if (!init)
      init();
   init = false;
   if (init_error != NO_ERROR)
      return(init_error);

   // nach Terminal-Start Abschlu� der Initialisierung �berpr�fen
   if (Bars == 0) {
      last_error = ERR_TERMINAL_NOT_YET_READY;
      return(last_error);
   }
   last_error = 0;
   // -----------------------------------------------------------------------------


   static int error = NO_ERROR;

   if (error == NO_ERROR)
      error = UpdateInfos();

   return(catch("start()"));
}


/**
 * Deinitialisierung
 *
 * @return int - Fehlerstatus
 */
int deinit() {
   RemoveChartObjects(labels);
   return(catch("deinit()"));
}


/**
 *
 */
int CreateLabels() {
   string expertName = WindowExpertName();
   int c = 10;

   // Background
   c++;
   string label = StringConcatenate(expertName, ".", c, ".Background");
   if (ObjectFind(label) > -1)
      ObjectDelete(label);
   if (ObjectCreate(label, OBJ_LABEL, 0, 0, 0)) {
      ObjectSet(label, OBJPROP_CORNER, CORNER_TOP_LEFT);
      ObjectSet(label, OBJPROP_XDISTANCE, 14);
      ObjectSet(label, OBJPROP_YDISTANCE, 134);
      ObjectSetText(label, "g", 174, "Webdings", Background.Color);
      RegisterChartObject(label, labels);
   }
   else GetLastError();

   c++;
   label = StringConcatenate(expertName, ".", c, ".Background");
   if (ObjectFind(label) > -1)
      ObjectDelete(label);
   if (ObjectCreate(label, OBJ_LABEL, 0, 0, 0)) {
      ObjectSet(label, OBJPROP_CORNER, CORNER_TOP_LEFT);
      ObjectSet(label, OBJPROP_XDISTANCE, 14);
      ObjectSet(label, OBJPROP_YDISTANCE, 358);
      ObjectSetText(label, "g", 174, "Webdings", Background.Color);
      RegisterChartObject(label, labels);
   }
   else GetLastError();

   // Textlabel
   int yCoord = 140;
   for (int i=0; i < ArraySize(names); i++) {
      c++;
      label = StringConcatenate(expertName, ".", c, ".", names[i]);
      if (ObjectFind(label) > -1)
         ObjectDelete(label);
      if (ObjectCreate(label, OBJ_LABEL, 0, 0, 0)) {
         ObjectSet(label, OBJPROP_CORNER, CORNER_TOP_LEFT);
         ObjectSet(label, OBJPROP_XDISTANCE,  20);
            if (i==POINT || i==SPREAD || i==LOTSIZE || i==MARGINCALCMODE || i==SWAPTYPE || i==PROFITCALCMODE || i==STARTING || i==ACCOUNT_LEVERAGE)
               yCoord += 8;
         ObjectSet(label, OBJPROP_YDISTANCE, yCoord + i*16);
         ObjectSetText(label, " ", Font.Size, Font.Name);
         RegisterChartObject(label, labels);
         names[i] = label;
      }
      else GetLastError();
   }

   return(catch("CreateLabels()"));
}


/**
 *
 * @return int - Fehlerstatus
 */
int UpdateInfos() {
   string strBool[] = { "no","yes" };
   string strMCM[]  = { "Forex","CFD","CFD Futures","CFD Index","CFD Leverage" };               // margin calculation modes
   string strPCM[]  = { "Forex","CFD","Futures" };                                              // profit calculation modes
   string strSCM[]  = { "in points","in base currency","by interest","in margin currency" };    // swap calculation modes

   string symbol          = Symbol();
   string accountCurrency = AccountCurrency();

   bool   tradeAllowed = MarketInfo(symbol, MODE_TRADEALLOWED);
   color  Font.Color = ifInt(tradeAllowed, Font.Color.Enabled, Font.Color.Disabled);

                                                            ObjectSetText(names[TRADEALLOWED], StringConcatenate("Trading enabled: ", strBool[0+tradeAllowed]), Font.Size, Font.Name, Font.Color);
                                                            ObjectSetText(names[POINT       ], StringConcatenate("Point size:  ", NumberToStr(Point, PriceFormat)), Font.Size, Font.Name, Font.Color);
   double tickSize     = MarketInfo(symbol, MODE_TICKSIZE); ObjectSetText(names[TICKSIZE    ], StringConcatenate("Tick size:   ", NumberToStr(tickSize, PriceFormat)), Font.Size, Font.Name, Font.Color);

   double spread       = MarketInfo(symbol, MODE_SPREAD     ) / MathPow(10, Digits-PipDigits);
   double stopLevel    = MarketInfo(symbol, MODE_STOPLEVEL  ) / MathPow(10, Digits-PipDigits);
   double freezeLevel  = MarketInfo(symbol, MODE_FREEZELEVEL) / MathPow(10, Digits-PipDigits);
      string strSpread      = DoubleToStr(spread,      Digits-PipDigits); ObjectSetText(names[SPREAD     ], StringConcatenate("Spread:        "      , strSpread     , " pip"), Font.Size, Font.Name, Font.Color);
      string strStopLevel   = DoubleToStr(stopLevel,   Digits-PipDigits); ObjectSetText(names[STOPLEVEL  ], StringConcatenate("Stop level:   "  , strStopLevel  , " pip"), Font.Size, Font.Name, Font.Color);
      string strFreezeLevel = DoubleToStr(freezeLevel, Digits-PipDigits); ObjectSetText(names[FREEZELEVEL], StringConcatenate("Freeze level: ", strFreezeLevel, " pip"), Font.Size, Font.Name, Font.Color);

   double lotSize           = MarketInfo(symbol, MODE_LOTSIZE          ); ObjectSetText(names[LOTSIZE          ], StringConcatenate("Lot size: ", NumberToStr(lotSize, ", .+"), " units"), Font.Size, Font.Name, Font.Color);
   double tickValue         = MarketInfo(symbol, MODE_TICKVALUE        );
   double pointValue        = tickValue / (tickSize/Point);
   double pipValue = pointValue * MathPow(10, Digits-PipDigits);           ObjectSetText(names[TICKVALUE        ], StringConcatenate("Pip value: ", NumberToStr(pipValue, ", .2+"), " ", accountCurrency), Font.Size, Font.Name, Font.Color);

   double minLot            = MarketInfo(symbol, MODE_MINLOT           ); ObjectSetText(names[MINLOT           ], StringConcatenate("Min lot: ", NumberToStr(minLot, ", .+")), Font.Size, Font.Name, Font.Color);
   double maxLot            = MarketInfo(symbol, MODE_MAXLOT           ); ObjectSetText(names[MAXLOT           ], StringConcatenate("Max lot: ", NumberToStr(maxLot, ", .+")), Font.Size, Font.Name, Font.Color);
   double lotStep           = MarketInfo(symbol, MODE_LOTSTEP          ); ObjectSetText(names[LOTSTEP          ], StringConcatenate("Lot step: ", NumberToStr(lotStep, ", .+")), Font.Size, Font.Name, Font.Color);

   int    marginCalcMode    = MarketInfo(symbol, MODE_MARGINCALCMODE   ); ObjectSetText(names[MARGINCALCMODE   ], StringConcatenate("Margin calculation mode: ", strMCM[marginCalcMode]), Font.Size, Font.Name, Font.Color);
   double marginRequired    = MarketInfo(symbol, MODE_MARGINREQUIRED   );
   double lotValue          = Bid / tickSize * tickValue;
   double leverage          = lotValue / marginRequired;                  ObjectSetText(names[MARGINREQUIRED   ], StringConcatenate("Margin required:     ", NumberToStr(marginRequired, ", .2+"), " ", accountCurrency, " (1:", MathRound(leverage), ")"), Font.Size, Font.Name, Font.Color);

   double marginInit        = MarketInfo(symbol, MODE_MARGININIT       ); ObjectSetText(names[MARGININIT       ], StringConcatenate("Margin init:                ", NumberToStr(marginInit, ", .2+"), " ", accountCurrency), Font.Size, Font.Name, Font.Color);
   double marginMaintenance = MarketInfo(symbol, MODE_MARGINMAINTENANCE); ObjectSetText(names[MARGINMAINTENANCE], StringConcatenate("Margin maintenance:  ", NumberToStr(marginMaintenance, ", .2+"), " ", accountCurrency), Font.Size, Font.Name, Font.Color);
   double marginHedged      = MarketInfo(symbol, MODE_MARGINHEDGED     );
          marginHedged      = marginHedged / lotSize * 100;               ObjectSetText(names[MARGINHEDGED     ], StringConcatenate("Margin hedged:         ", MathRound(marginHedged), " %"), Font.Size, Font.Name, Font.Color);

   int    swapType          = MarketInfo(symbol, MODE_SWAPTYPE         ); ObjectSetText(names[SWAPTYPE         ], StringConcatenate("Swap calculation: ", strSCM[swapType]), Font.Size, Font.Name, Font.Color);
   double swapLong          = MarketInfo(symbol, MODE_SWAPLONG         ); ObjectSetText(names[SWAPLONG         ], StringConcatenate("Swap long:  ", NumberToStr(swapLong, "+, .+")), Font.Size, Font.Name, Font.Color);
   double swapShort         = MarketInfo(symbol, MODE_SWAPSHORT        ); ObjectSetText(names[SWAPSHORT        ], StringConcatenate("Swap short: ", NumberToStr(swapShort, "+, .+")), Font.Size, Font.Name, Font.Color);

   int    profitCalcMode    = MarketInfo(symbol, MODE_PROFITCALCMODE   ); ObjectSetText(names[PROFITCALCMODE   ], StringConcatenate("Profit calculation mode: ", strPCM[profitCalcMode]), Font.Size, Font.Name, Font.Color);

   double starts            = MarketInfo(symbol, MODE_STARTING         ); if (starts  > 0) ObjectSetText(names[STARTING  ], StringConcatenate("Future starts: ", TimeToStr(starts)), Font.Size, Font.Name, Font.Color);
   double expires           = MarketInfo(symbol, MODE_EXPIRATION       ); if (expires > 0) ObjectSetText(names[EXPIRATION], StringConcatenate("Future expires: ", TimeToStr(expires)), Font.Size, Font.Name, Font.Color);

   int    accountLeverage   = AccountLeverage();                          ObjectSetText(names[ACCOUNT_LEVERAGE], StringConcatenate("Account leverage:       1:", MathRound(accountLeverage)), Font.Size, Font.Name, Font.Color);
   int    stopoutLevel      = AccountStopoutLevel();                      ObjectSetText(names[STOPOUT_LEVEL   ], StringConcatenate("Account stopout level: ", NumberToStr(NormalizeDouble(stopoutLevel, 2), ", .+"), ifString(AccountStopoutMode()==ASM_PERCENT, " %", " "+ accountCurrency)), Font.Size, Font.Name, Font.Color);

   int error = GetLastError();
   if (error==NO_ERROR || error==ERR_OBJECT_DOES_NOT_EXIST)
      return(NO_ERROR);
   return(catch("UpdateInfos()", error));
}

/*
MODE_TRADEALLOWED       Trade is allowed for the symbol.
MODE_DIGITS             Count of digits after decimal point in the symbol prices. For the current symbol, it is stored in the predefined variable Digits

MODE_POINT              Point size in the quote currency.   => Aufl�sung des Preises
MODE_TICKSIZE           Tick size in the quote currency.    => kleinste �nderung des Preises, Vielfaches von MODE_POINT

MODE_SPREAD             Spread value in points.
MODE_STOPLEVEL          Stop level in points.
MODE_FREEZELEVEL        Order freeze level in points. If the execution price lies within the range defined by the freeze level, the order cannot be modified, cancelled or closed.

MODE_LOTSIZE            Lot size in the base currency.
MODE_TICKVALUE          Tick value in the deposit currency.
MODE_MINLOT             Minimum permitted amount of a lot.
MODE_MAXLOT             Maximum permitted amount of a lot.
MODE_LOTSTEP            Step for changing lots.

MODE_MARGINCALCMODE     Margin calculation mode. 0 - Forex; 1 - CFD; 2 - Futures; 3 - CFD for indices.
MODE_MARGINREQUIRED     Free margin required to open 1 lot for buying.
MODE_MARGININIT         Initial margin requirements for 1 lot.
MODE_MARGINMAINTENANCE  Margin to maintain open positions calculated for 1 lot.
MODE_MARGINHEDGED       Hedged margin calculated for 1 lot.

MODE_SWAPTYPE           Swap calculation method. 0 - in points; 1 - in the symbol base currency; 2 - by interest; 3 - in the margin currency.
MODE_SWAPLONG           Swap of the long position.
MODE_SWAPSHORT          Swap of the short position.

MODE_PROFITCALCMODE     Profit calculation mode. 0 - Forex; 1 - CFD; 2 - Futures.

MODE_STARTING           Market starting date (usually used for futures).
MODE_EXPIRATION         Market expiration date (usually used for futures).
*/