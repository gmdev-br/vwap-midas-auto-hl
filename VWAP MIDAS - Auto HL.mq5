//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "© GM, 2021, 2022, 2023"
#property description "VWAP Midas - Auto HL"

#property indicator_chart_window
#property indicator_buffers 38
#property indicator_plots   38

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#define IsProperValue(value) (value!=0 && value!=EMPTY_VALUE)

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum PRICE_method {
   Close,
   Open,
   High,
   TripleHigh,
   Low,
   TripleLow,
   Median,  // Median Price (HL/2)
   Typical, // Typical Price (HLC/3)
   Weighted, // Weighted Close (HLCC/4)
   New // New
};


//--- indicator buffers
double         vwapBuffer1[], vwapBuffer2[], vwapBuffer3[], vwapBuffer4[], vwapBuffer5[], vwapBuffer6[], vwapBuffer7[], vwapBuffer8[], vwapBuffer9[], vwapBuffer10[];
double         vwapBuffer11[], vwapBuffer12[], vwapBuffer13[], vwapBuffer14[], vwapBuffer15[], vwapBuffer16[], vwapBuffer17[], vwapBuffer18[], vwapBuffer19[], vwapBuffer20[];
double         vwapBuffer21[], vwapBuffer22[], vwapBuffer23[], vwapBuffer24[], vwapBuffer25[], vwapBuffer26[], vwapBuffer27[], vwapBuffer28[], vwapBuffer29[], vwapBuffer30[];
//double         vwapBuffer31[], vwapBuffer32[], vwapBuffer33[], vwapBuffer34[], vwapBuffer35[], vwapBuffer36[], vwapBuffer37[], vwapBuffer38[], vwapBuffer39[], vwapBuffer40[];

double         vwapBufferMirror1[], vwapBufferMirror2[], vwapBufferMirror3[], vwapBufferMirror4[], vwapBufferMirror5[], vwapBufferMirror6[];

int            startVWAP1 = 0, startVWAP2 = 0, startVWAP3 = 0, startVWAP4 = 0, startVWAP5 = 0, startVWAP6 = 0, startVWAP7 = 0, startVWAP8 = 0, startVWAP9 = 0, startVWAP10 = 0;
//int            startVWAP11 = 0, startVWAP12 = 0, startVWAP13 = 0, startVWAP14 = 0, startVWAP15 = 0, startVWAP16 = 0, startVWAP17 = 0, startVWAP18 = 0, startVWAP19 = 0, startVWAP20 = 0;
//int            startVWAP21 = 0, startVWAP22 = 0, startVWAP13 = 0, startVWAP14 = 0, startVWAP15 = 0, startVWAP16 = 0, startVWAP17 = 0, startVWAP18 = 0, startVWAP19 = 0, startVWAP20 = 0;
//int            startVWAP11 = 0, startVWAP12 = 0, startVWAP13 = 0, startVWAP14 = 0, startVWAP15 = 0, startVWAP16 = 0, startVWAP17 = 0, startVWAP18 = 0, startVWAP19 = 0, startVWAP20 = 0;

string         indicatorPrefix, prefix1, prefix2, prefix3, prefix4, prefix5, prefix6, prefix7, prefix8, prefix9, prefix10;
//string         prefix11, prefix12, prefix13, prefix14, prefix15, prefix16, prefix17, prefix18, prefix19, prefix20;

datetime       arrayTime[];
double         arrayOpen[], arrayHigh[], arrayLow[], arrayClose[];
double         arrayZZOpen[], arrayZZHigh[], arrayZZLow[], arrayZZClose[];
string         prefix[];
long           VolumeBuffer[];
int            startVwap[];
long           obj_time;
bool           first = true;
int            visible_bars, tempVar;
datetime       Hposition;
double         Vposition;
int            totalRates;
string         vwap_type = "Typical";
int            vwapToCalc = 0;
int            vwapRef  = 0;
double         onetick;
double         chartPoint;
color          targetColor, targetColorHigh, targetColorLow;
int            vwapCount;
color          zigzagColor;

//--- indicator buffers
double         ZigzagBuffer[];      // main buffer
double         HighMapBuffer[];     // highs
double         LowMapBuffer[];      // lows
int            level = 3;           // recounting depth
double         deviation;           // deviation in points
//--- Indicator buffer arrays and zigzag globals
double         _peaks[], _troughs[];
int            lows[], highs[];
bool           _zzLastDirection;
bool           _realtimeChange;
int            _lastIndex;
int            _lastIndex2;
int            _contraIndex;
double            _atr;
//--- Other globals
bool           _lastDirection;
double         _lastPeakValue;
double         _lastTroughValue;
int            _lastPeak;
int            _lastTrough;
string         metodo, asset;
bool           needToReset = false;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//--- input parameters
input int                              IndicatorId = 1;                       // VWAP Id  (must be unique)
input string                           input_asset = "";
input int                              inputVwapCount    = 2;                      // VWAP count
input PRICE_method                     input_method    = High;                   // Price Calculation method

input color                            vwapColorHigh = clrRed;                   // VWAP High Color
input int                              width_high = 2;                 // Line width
input ENUM_LINE_STYLE                  style_high = STYLE_SOLID;           // Estilo da linha

input color                            vwapColorTypical = clrYellow;           // VWAP Typical Color
input int                              width_typical = 2;                   // width das linhas
input ENUM_LINE_STYLE                  style_typical = STYLE_SOLID;           // Estilo da linha

input color                            vwapColorLow = clrLime;               // VWAP Low Color
input int                              width_low = 2;                 // width das linhas
input ENUM_LINE_STYLE                  style_low = STYLE_SOLID;           // Estilo da linha

input bool                             showZZ = false;
input color                            i_zigzagColor = clrRoyalBlue;                   // Zigzag Color
input int                              arrowSize = 1;                         // Arrow Size
input ENUM_ARROW_ANCHOR                Anchor    = ANCHOR_TOP;                // Arrow Anchor Point
input ENUM_APPLIED_VOLUME              applied_volume = VOLUME_TICK;          // tipo de volume
input int                              WaitMilliseconds  = 10000;              // Timer (milliseconds) for recalculation
input bool                             debug = false;
input bool                             showSupport = false;
//input double                           cotDolar1 = 5.1574;
//input double                           cotDolar2 = 5.3952;

bool mirroring = false;
bool bands = false;
bool history_mode = false;

input bool                             autoMode = false;
input string                           zigzagSettings = "-=ZigZag Settings=-"; //-=ZigZag Settings=-
input double                           i_zzAtrMultiplier = 4;   //ATR ZZ atr multiplier
input int                              i_zzAtrPeriod = 50;           //ATR ZZ atr period
input int                              i_zzMaxPeriod = 10;         //ATR ZZ max period
input int                              i_zzMinPeriod = 3;          //ATR ZZ min period
input bool                             i_zzRealtime = true;       //ATR ZZ realtime
input int                              i_history = 2000;           //Max. history bars to process

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {

   if (input_asset == "")
      asset = _Symbol;
   else
      asset = input_asset;

   onetick = SymbolInfoDouble(asset, SYMBOL_TRADE_TICK_VALUE);
   chartPoint = _Point;

   if (input_method == Low)
      metodo = "Low";
   else if (input_method == High || input_method == TripleHigh)
      metodo = "High";

   vwapCount = inputVwapCount;

   if (showZZ)
      zigzagColor = i_zigzagColor;
   else
      zigzagColor = clrNONE;

   SetIndexBuffer(30, _peaks, INDICATOR_DATA);
   SetIndexBuffer(31, _troughs, INDICATOR_DATA);
   PlotIndexSetDouble(30, PLOT_EMPTY_VALUE, 0.0);
   PlotIndexSetDouble(31, PLOT_EMPTY_VALUE, 0.0);
   PlotIndexSetInteger(30, PLOT_DRAW_TYPE, DRAW_ZIGZAG);
   PlotIndexSetInteger(30, PLOT_LINE_WIDTH, width_low);
   PlotIndexSetInteger(30, PLOT_LINE_STYLE, style_low);
   PlotIndexSetInteger(30, PLOT_LINE_COLOR, zigzagColor);

   indicatorPrefix = IndicatorId;

   SetIndexBuffer(0, vwapBuffer1, INDICATOR_DATA);
   SetIndexBuffer(1, vwapBuffer2, INDICATOR_DATA);
   SetIndexBuffer(2, vwapBuffer3, INDICATOR_DATA);
   SetIndexBuffer(3, vwapBuffer4, INDICATOR_DATA);
   SetIndexBuffer(4, vwapBuffer5, INDICATOR_DATA);
   SetIndexBuffer(5, vwapBuffer6, INDICATOR_DATA);
   SetIndexBuffer(6, vwapBuffer7, INDICATOR_DATA);
   SetIndexBuffer(7, vwapBuffer8, INDICATOR_DATA);
   SetIndexBuffer(8, vwapBuffer9, INDICATOR_DATA);
   SetIndexBuffer(9, vwapBuffer10, INDICATOR_DATA);
   SetIndexBuffer(10, vwapBuffer11, INDICATOR_DATA);
   SetIndexBuffer(11, vwapBuffer12, INDICATOR_DATA);
   SetIndexBuffer(12, vwapBuffer13, INDICATOR_DATA);
   SetIndexBuffer(13, vwapBuffer14, INDICATOR_DATA);
   SetIndexBuffer(14, vwapBuffer15, INDICATOR_DATA);
   SetIndexBuffer(15, vwapBuffer16, INDICATOR_DATA);
   SetIndexBuffer(16, vwapBuffer17, INDICATOR_DATA);
   SetIndexBuffer(17, vwapBuffer18, INDICATOR_DATA);
   SetIndexBuffer(18, vwapBuffer19, INDICATOR_DATA);
   SetIndexBuffer(19, vwapBuffer20, INDICATOR_DATA);
   SetIndexBuffer(20, vwapBuffer21, INDICATOR_DATA);
   SetIndexBuffer(21, vwapBuffer22, INDICATOR_DATA);
   SetIndexBuffer(22, vwapBuffer23, INDICATOR_DATA);
   SetIndexBuffer(23, vwapBuffer24, INDICATOR_DATA);
   SetIndexBuffer(24, vwapBuffer25, INDICATOR_DATA);
   SetIndexBuffer(25, vwapBuffer26, INDICATOR_DATA);
   SetIndexBuffer(26, vwapBuffer27, INDICATOR_DATA);
   SetIndexBuffer(27, vwapBuffer28, INDICATOR_DATA);
   SetIndexBuffer(28, vwapBuffer29, INDICATOR_DATA);
   SetIndexBuffer(29, vwapBuffer30, INDICATOR_DATA);
//SetIndexBuffer(20, vwapBufferMirror1, INDICATOR_DATA);
//SetIndexBuffer(21, vwapBufferMirror2, INDICATOR_DATA);
//SetIndexBuffer(22, vwapBufferMirror3, INDICATOR_DATA);
//SetIndexBuffer(23, vwapBufferMirror4, INDICATOR_DATA);
//SetIndexBuffer(24, vwapBufferMirror5, INDICATOR_DATA);
//SetIndexBuffer(25, vwapBufferMirror6, INDICATOR_DATA);

   ArrayResize(prefix, 10);
   ArrayResize(startVwap, 10);
   for (int i = 0; i <= 9; i++) {
      prefix[i] = "VWAP_" + indicatorPrefix + "_" + (i + 1);
   }

   if (input_method == High) {
      targetColorHigh = vwapColorHigh;
      targetColorLow = vwapColorLow;
      targetColor = vwapColorTypical;
   } else if (input_method == Low) {
      targetColorHigh = vwapColorLow;
      targetColorLow = vwapColorHigh;
      targetColor = vwapColorTypical;
   } else {
      targetColorHigh = vwapColorHigh;
      targetColorLow = vwapColorLow;
      targetColor = vwapColorTypical;
   }

   for (int i = 0; i <= 9; i++) {
      PlotIndexSetInteger(i, PLOT_LINE_COLOR, targetColorHigh);
      PlotIndexSetDouble(i, PLOT_EMPTY_VALUE, 0);
      PlotIndexSetInteger(i, PLOT_DRAW_TYPE, DRAW_LINE);
      PlotIndexSetString(i, PLOT_LABEL, "VWAP " + "High" + " " + i);
      PlotIndexSetInteger(i, PLOT_LINE_WIDTH, width_high);
      PlotIndexSetInteger(i, PLOT_LINE_STYLE, style_high);
   }

   for (int i = 10; i <= 19; i++) {
      PlotIndexSetInteger(i, PLOT_LINE_COLOR, targetColor);
      PlotIndexSetDouble(i, PLOT_EMPTY_VALUE, 0);
      PlotIndexSetInteger(i, PLOT_DRAW_TYPE, DRAW_LINE);
      PlotIndexSetString(i, PLOT_LABEL, "VWAP " + "Typical" + " " + i);
      PlotIndexSetInteger(i, PLOT_LINE_WIDTH, width_typical);
      PlotIndexSetInteger(i, PLOT_LINE_STYLE, style_typical);
   }

   for (int i = 20; i <= 29; i++) {
      PlotIndexSetInteger(i, PLOT_LINE_COLOR, targetColorLow);
      PlotIndexSetDouble(i, PLOT_EMPTY_VALUE, 0);
      PlotIndexSetInteger(i, PLOT_DRAW_TYPE, DRAW_LINE);
      PlotIndexSetString(i, PLOT_LABEL, "VWAP " + "Low" + " " + i);
      PlotIndexSetInteger(i, PLOT_LINE_WIDTH, width_low);
      PlotIndexSetInteger(i, PLOT_LINE_STYLE, style_low);
   }

   objectCleanup(vwapCount + 1, 9);

   initializeArrays();

   _updateTimer = new MillisecondTimer(WaitMilliseconds, false);

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void initializeArrays() {

   ArrayInitialize(startVwap, 0);

   if (vwapCount == 0 || autoMode) {
      ArrayInitialize(vwapBuffer1, 0);
      ArrayInitialize(vwapBuffer2, 0);
      ArrayInitialize(vwapBuffer3, 0);
      ArrayInitialize(vwapBuffer4, 0);
      ArrayInitialize(vwapBuffer5, 0);
      ArrayInitialize(vwapBuffer6, 0);
      ArrayInitialize(vwapBuffer7, 0);
      ArrayInitialize(vwapBuffer8, 0);
      ArrayInitialize(vwapBuffer9, 0);
      ArrayInitialize(vwapBuffer10, 0);
      ArrayInitialize(vwapBuffer11, 0);
      ArrayInitialize(vwapBuffer12, 0);
      ArrayInitialize(vwapBuffer13, 0);
      ArrayInitialize(vwapBuffer14, 0);
      ArrayInitialize(vwapBuffer15, 0);
      ArrayInitialize(vwapBuffer16, 0);
      ArrayInitialize(vwapBuffer17, 0);
      ArrayInitialize(vwapBuffer18, 0);
      ArrayInitialize(vwapBuffer19, 0);
      ArrayInitialize(vwapBuffer20, 0);
      ArrayInitialize(vwapBuffer21, 0);
      ArrayInitialize(vwapBuffer22, 0);
      ArrayInitialize(vwapBuffer23, 0);
      ArrayInitialize(vwapBuffer24, 0);
      ArrayInitialize(vwapBuffer25, 0);
      ArrayInitialize(vwapBuffer26, 0);
      ArrayInitialize(vwapBuffer27, 0);
      ArrayInitialize(vwapBuffer28, 0);
      ArrayInitialize(vwapBuffer29, 0);
      ArrayInitialize(vwapBuffer30, 0);
      //ArrayInitialize(vwapBufferMirror1, 0);
      //ArrayInitialize(vwapBufferMirror2, 0);
      //ArrayInitialize(vwapBufferMirror3, 0);
      //ArrayInitialize(vwapBufferMirror4, 0);
      //ArrayInitialize(vwapBufferMirror5, 0);
      //ArrayInitialize(vwapBufferMirror6, 0);
   } else if (vwapCount > 0) {
      if (vwapCount == 1) {
         ArrayInitialize(vwapBuffer1, 0);
         ArrayInitialize(vwapBuffer11, 0);
         ArrayInitialize(vwapBuffer21, 0);
      } else  if (vwapCount == 2) {
         ArrayInitialize(vwapBuffer2, 0);
         ArrayInitialize(vwapBuffer12, 0);
         ArrayInitialize(vwapBuffer22, 0);
      } else  if (vwapCount == 3) {
         ArrayInitialize(vwapBuffer3, 0);
         ArrayInitialize(vwapBuffer13, 0);
         ArrayInitialize(vwapBuffer23, 0);
      } else  if (vwapCount == 4) {
         ArrayInitialize(vwapBuffer4, 0);
         ArrayInitialize(vwapBuffer14, 0);
         ArrayInitialize(vwapBuffer24, 0);
      } else  if (vwapCount == 5) {
         ArrayInitialize(vwapBuffer5, 0);
         ArrayInitialize(vwapBuffer15, 0);
         ArrayInitialize(vwapBuffer25, 0);
      } else  if (vwapCount == 6) {
         ArrayInitialize(vwapBuffer6, 0);
         ArrayInitialize(vwapBuffer16, 0);
         ArrayInitialize(vwapBuffer26, 0);
      } else  if (vwapCount == 7) {
         ArrayInitialize(vwapBuffer7, 0);
         ArrayInitialize(vwapBuffer17, 0);
         ArrayInitialize(vwapBuffer27, 0);
      } else  if (vwapCount == 8) {
         ArrayInitialize(vwapBuffer8, 0);
         ArrayInitialize(vwapBuffer18, 0);
         ArrayInitialize(vwapBuffer28, 0);
      } else  if (vwapCount == 9) {
         ArrayInitialize(vwapBuffer9, 0);
         ArrayInitialize(vwapBuffer19, 0);
         ArrayInitialize(vwapBuffer29, 0);
      } else  if (vwapCount == 10) {
         ArrayInitialize(vwapBuffer10, 0);
         ArrayInitialize(vwapBuffer20, 0);
         ArrayInitialize(vwapBuffer30, 0);
      }
   }

   for (int i = 0; i < vwapCount; i++) {
      criaVwap(prefix[i]);
   }

   ChartRedraw();

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void criaVwap(string pprefix) {

   if (autoMode) {
      CreateObject(pprefix);
   } else {
      datetime timeArrow = GetObjectTime1(pprefix);
      if (timeArrow == 0 && vwapCount >= 1) {
         CreateObject(pprefix);
         //CustomizeObject(pprefix);
      } else if (timeArrow != 0 && vwapCount >= 1) {
         CustomizeObject(pprefix);
      } else if (timeArrow != 0 && vwapCount < 1) {
         ObjectDelete(0, pprefix);
      }
   }
}

//+------------------------------------------------------------------+
//| Custom indicator Deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   delete(_updateTimer);

   if(reason == REASON_REMOVE) {
      objectCleanup();
   }

   OnReinit();
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void objectCleanup(const int start = 0, const int end = 9) {
   for (int i = start; i <= end; i++) {
      if (debug)
         Print(i);

      ObjectDelete(0, "VWAP_" + indicatorPrefix + "_" + i);
      ObjectDelete(0, "VWAP_" + indicatorPrefix + "_" + metodo + "_" + i + "_line");
      ObjectDelete(0, "VWAP_" + indicatorPrefix + "_typical_" + i + "_line");
   }

   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Indicator reinitialization function                              |
//+------------------------------------------------------------------+
void OnReinit() {
   _lastPeak = 0;
   _lastTrough = 0;
   _lastPeakValue = 0;
   _lastTroughValue = 0;
   ArrayResize(highs, 0);
   ArrayResize(lows, 0);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const int begin, const double &price[]) {
   return (1);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ArrayAdd(int &sourceArr[], int value) {
   int iLast = ArraySize(sourceArr);        // End
   ArrayResize(sourceArr, iLast + 1);       // Make room
   sourceArr[iLast] = value;                // Store at new
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer() {
   CheckTimer();
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void calculateZZ() {

   tempVar = CopyLow(asset, PERIOD_CURRENT, 0, totalRates, arrayZZLow);
   tempVar = CopyClose(asset, PERIOD_CURRENT, 0, totalRates, arrayZZClose);
   tempVar = CopyHigh(asset, PERIOD_CURRENT, 0, totalRates, arrayZZHigh);
   tempVar = CopyOpen(asset, PERIOD_CURRENT, 0, totalRates, arrayZZOpen);

   ArraySetAsSeries(arrayZZOpen, true);
   ArraySetAsSeries(arrayZZLow, true);
   ArraySetAsSeries(arrayZZClose, true);
   ArraySetAsSeries(arrayZZHigh, true);

   ArrayReverse(arrayZZOpen);
   ArrayReverse(arrayZZLow);
   ArrayReverse(arrayZZClose);
   ArrayReverse(arrayZZHigh);

//--- Call embedded zigzag
   ZZOnCalculate(totalRates, arrayZZOpen, arrayZZHigh, arrayZZLow, arrayZZClose);
//---
   int start = 1;
   OnReinit();

//--- main loop
   for(int bar = start; bar < totalRates; bar++) {
      //--- Efficency checks
      if(bar < totalRates - i_history)
         continue;
      int lastPeak = FirstNonZeroFrom(bar, _peaks);
      int lastTrough = FirstNonZeroFrom(bar, _troughs);
      if(lastPeak == -1 || lastTrough == -1)
         continue;
      double lastPeakValue = _peaks[lastPeak];
      double lastTroughValue = _troughs[lastTrough];

      if(lastPeakValue == _lastPeakValue && lastTroughValue == _lastTroughValue)
         continue;

      if (lastTroughValue != _lastTroughValue)
         ArrayAdd(lows, lastTrough);

      if (lastPeakValue != _lastPeakValue)
         ArrayAdd(highs, lastPeak);

      //--- ZZ assessment
      bool endsInTrough = lastTrough > lastPeak;
      if(lastTrough == lastPeak) {
         int zzDirection = ZigZagDirection(lastPeak, _peaks, _troughs);
         if(zzDirection == 0) continue;
         else if(zzDirection == -1) endsInTrough = true;
         else if(zzDirection == 1) endsInTrough = false;
      }

      //--- Save most recent peaks/troughs and direction
      _lastPeak = lastPeak;
      _lastTrough = lastTrough;
      _lastPeakValue = lastPeakValue;
      _lastTroughValue = lastTroughValue;
      _lastDirection = endsInTrough;
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Update() {

   totalRates = SeriesInfoInteger(asset, PERIOD_CURRENT, SERIES_BARS_COUNT);

   if (autoMode) {
      calculateZZ();

      if (input_method == Low) {
         if (vwapCount > ArraySize(lows))
            vwapCount = vwapCount - MathAbs(vwapCount - ArraySize(lows));
      } else if (input_method == High || input_method == TripleHigh) {
         if (vwapCount > ArraySize(highs))
            vwapCount = vwapCount - MathAbs(vwapCount - ArraySize(highs));
      }

      objectCleanup();
   }

   initializeArrays();
   prepareData(vwapToCalc);

   if (vwapToCalc == 0) {
      vwapRef = 0;
      ArrayInitialize(vwapBuffer1, 0);
      ArrayInitialize(vwapBuffer2, 0);
      ArrayInitialize(vwapBuffer3, 0);
      ArrayInitialize(vwapBuffer4, 0);
      ArrayInitialize(vwapBuffer5, 0);
      ArrayInitialize(vwapBuffer6, 0);
      ArrayInitialize(vwapBuffer7, 0);
      ArrayInitialize(vwapBuffer8, 0);
      ArrayInitialize(vwapBuffer9, 0);
      ArrayInitialize(vwapBuffer10, 0);
      ArrayInitialize(vwapBuffer11, 0);
      ArrayInitialize(vwapBuffer12, 0);
      ArrayInitialize(vwapBuffer13, 0);
      ArrayInitialize(vwapBuffer14, 0);
      ArrayInitialize(vwapBuffer15, 0);
      ArrayInitialize(vwapBuffer16, 0);
      ArrayInitialize(vwapBuffer17, 0);
      ArrayInitialize(vwapBuffer18, 0);
      ArrayInitialize(vwapBuffer19, 0);
      ArrayInitialize(vwapBuffer20, 0);
      ArrayInitialize(vwapBuffer21, 0);
      ArrayInitialize(vwapBuffer22, 0);
      ArrayInitialize(vwapBuffer23, 0);
      ArrayInitialize(vwapBuffer24, 0);
      ArrayInitialize(vwapBuffer25, 0);
      ArrayInitialize(vwapBuffer26, 0);
      ArrayInitialize(vwapBuffer27, 0);
      ArrayInitialize(vwapBuffer28, 0);
      ArrayInitialize(vwapBuffer29, 0);
      ArrayInitialize(vwapBuffer30, 0);

      if (vwapCount >= 1) CalculateVWAP(startVwap[0], vwapBuffer1, vwapBuffer11, vwapBuffer21, 1);
      if (vwapCount >= 2) CalculateVWAP(startVwap[1], vwapBuffer2, vwapBuffer12, vwapBuffer22, 2);
      if (vwapCount >= 3) CalculateVWAP(startVwap[2], vwapBuffer3, vwapBuffer13, vwapBuffer23, 3);
      if (vwapCount >= 4) CalculateVWAP(startVwap[3], vwapBuffer4, vwapBuffer14, vwapBuffer24, 4);
      if (vwapCount >= 5) CalculateVWAP(startVwap[4], vwapBuffer5, vwapBuffer15, vwapBuffer25, 5);
      if (vwapCount >= 6) CalculateVWAP(startVwap[5], vwapBuffer6, vwapBuffer16, vwapBuffer26, 6);
      if (vwapCount >= 7) CalculateVWAP(startVwap[6], vwapBuffer7, vwapBuffer17, vwapBuffer27, 7);
      if (vwapCount >= 8) CalculateVWAP(startVwap[7], vwapBuffer8, vwapBuffer18, vwapBuffer28, 8);
      if (vwapCount >= 9) CalculateVWAP(startVwap[8], vwapBuffer9, vwapBuffer19, vwapBuffer29, 9);
      if (vwapCount >= 10) CalculateVWAP(startVwap[9], vwapBuffer10, vwapBuffer20, vwapBuffer30, 10);
   } else {
      vwapRef = vwapToCalc - 1;
      if (vwapToCalc == 1) {
         ArrayInitialize(vwapBuffer1, 0);
         ArrayInitialize(vwapBuffer11, 0);
         ArrayInitialize(vwapBuffer21, 0);
         CalculateVWAP(startVwap[vwapRef], vwapBuffer1, vwapBuffer11, vwapBuffer21, vwapToCalc);
      } else  if (vwapToCalc == 2) {
         ArrayInitialize(vwapBuffer2, 0);
         ArrayInitialize(vwapBuffer12, 0);
         ArrayInitialize(vwapBuffer22, 0);
         CalculateVWAP(startVwap[vwapRef], vwapBuffer2, vwapBuffer12, vwapBuffer22, vwapToCalc);
      } else  if (vwapToCalc == 3) {
         ArrayInitialize(vwapBuffer3, 0);
         ArrayInitialize(vwapBuffer13, 0);
         ArrayInitialize(vwapBuffer23, 0);
         CalculateVWAP(startVwap[vwapRef], vwapBuffer3, vwapBuffer13, vwapBuffer23, vwapToCalc);
      } else  if (vwapToCalc == 4) {
         ArrayInitialize(vwapBuffer4, 0);
         ArrayInitialize(vwapBuffer14, 0);
         ArrayInitialize(vwapBuffer24, 0);
         CalculateVWAP(startVwap[vwapRef], vwapBuffer4, vwapBuffer14, vwapBuffer24, vwapToCalc);
      } else  if (vwapToCalc == 5) {
         ArrayInitialize(vwapBuffer5, 0);
         ArrayInitialize(vwapBuffer15, 0);
         ArrayInitialize(vwapBuffer25, 0);
         CalculateVWAP(startVwap[vwapRef], vwapBuffer5, vwapBuffer15, vwapBuffer25, vwapToCalc);
      } else  if (vwapToCalc == 6) {
         ArrayInitialize(vwapBuffer6, 0);
         ArrayInitialize(vwapBuffer16, 0);
         ArrayInitialize(vwapBuffer26, 0);
         CalculateVWAP(startVwap[vwapRef], vwapBuffer6, vwapBuffer16, vwapBuffer26, vwapToCalc);
      } else  if (vwapToCalc == 7) {
         ArrayInitialize(vwapBuffer7, 0);
         ArrayInitialize(vwapBuffer17, 0);
         ArrayInitialize(vwapBuffer27, 0);
         CalculateVWAP(startVwap[vwapRef], vwapBuffer7, vwapBuffer17, vwapBuffer27, vwapToCalc);
      } else  if (vwapToCalc == 8) {
         ArrayInitialize(vwapBuffer8, 0);
         ArrayInitialize(vwapBuffer18, 0);
         ArrayInitialize(vwapBuffer28, 0);
         CalculateVWAP(startVwap[vwapRef], vwapBuffer8, vwapBuffer18, vwapBuffer28, vwapToCalc);
      } else  if (vwapToCalc == 9) {
         ArrayInitialize(vwapBuffer9, 0);
         ArrayInitialize(vwapBuffer19, 0);
         ArrayInitialize(vwapBuffer29, 0);
         CalculateVWAP(startVwap[vwapRef], vwapBuffer9, vwapBuffer19, vwapBuffer29, vwapToCalc);
      } else  if (vwapToCalc == 10) {
         ArrayInitialize(vwapBuffer10, 0);
         ArrayInitialize(vwapBuffer20, 0);
         ArrayInitialize(vwapBuffer30, 0);
         CalculateVWAP(startVwap[vwapRef], vwapBuffer10, vwapBuffer20, vwapBuffer30, vwapToCalc);
      }
   }

   ChartRedraw();
   if (debug)
      Print("VWAP Midas HL calculada.");
   return(true);

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void prepareData(int count = 0) {

   if (autoMode) {
      if (input_method == Low) {
         int numero = 1;
         for (int i = 0; i < vwapCount; i++) {
            int indiceLows = ArraySize(lows) - numero;
            int indiceTroughs = lows[indiceLows];
            int barra = totalRates - indiceTroughs - 1;
            double preco = _troughs[indiceTroughs] - _troughs[indiceTroughs] * 0.01;
            ObjectMove(0, prefix[i], 0, iTime(NULL, PERIOD_CURRENT, barra), preco);
            ObjectSetInteger(0, prefix[i], OBJPROP_ANCHOR, ANCHOR_BOTTOM);
            ObjectSetInteger(0, prefix[i], OBJPROP_ARROWCODE, 233);
            ObjectSetInteger(0, prefix[i], OBJPROP_SELECTABLE, false);
            ObjectSetInteger(0, prefix[i], OBJPROP_SELECTED, false);
            
            //ObjectSetInteger(0, prefix[i], OBJPROP_COLOR, targetColor);
            ObjectSetInteger(0, prefix[i], OBJPROP_COLOR, clrLime);
            numero++;
         }
      } else if (input_method == High) {
         int numero = 1;
         for (int i = 0; i < vwapCount; i++) {
            int indiceHighs = ArraySize(highs) - numero;
            int indicePeaks = highs[indiceHighs];
            int barra = totalRates - indicePeaks - 1;
            double preco = _peaks[indicePeaks] + _peaks[indicePeaks] * 0.01;
            int x = 0, y = 0;
            ObjectMove(0, prefix[i], 0, iTime(NULL, PERIOD_CURRENT, barra), preco);
            ObjectSetInteger(0, prefix[i], OBJPROP_ANCHOR, ANCHOR_TOP);
            ObjectSetInteger(0, prefix[i], OBJPROP_ARROWCODE, 234);
            ObjectSetInteger(0, prefix[i], OBJPROP_SELECTABLE, false);
            ObjectSetInteger(0, prefix[i], OBJPROP_SELECTED, false);
            //ObjectSetInteger(0, prefix[i], OBJPROP_COLOR, targetColor);
            ObjectSetInteger(0, prefix[i], OBJPROP_COLOR, clrRed);
            numero++;
         }
      }
   } else {
      if (input_method == Low) {
         for (int i = 0; i < vwapCount; i++) {
            ObjectSetInteger(0, prefix[i], OBJPROP_ANCHOR, ANCHOR_BOTTOM);
            ObjectSetInteger(0, prefix[i], OBJPROP_ARROWCODE, 233);
            ObjectSetInteger(0, prefix[i], OBJPROP_SELECTABLE, true);
            ObjectSetInteger(0, prefix[i], OBJPROP_SELECTED, true);
            //ObjectSetInteger(0, prefix[i], OBJPROP_COLOR, targetColor);
            ObjectSetInteger(0, prefix[i], OBJPROP_COLOR, clrLime);
         }
      } else if (input_method == High || input_method == TripleHigh) {
         for (int i = 0; i < vwapCount; i++) {

            ObjectSetInteger(0, prefix[i], OBJPROP_ANCHOR, ANCHOR_TOP);
            ObjectSetInteger(0, prefix[i], OBJPROP_ARROWCODE, 234);
            ObjectSetInteger(0, prefix[i], OBJPROP_SELECTABLE, true);
            ObjectSetInteger(0, prefix[i], OBJPROP_SELECTED, true);
            //ObjectSetInteger(0, prefix[i], OBJPROP_COLOR, targetColor);
            ObjectSetInteger(0, prefix[i], OBJPROP_COLOR, clrRed);
         }
      }
   }

   if (count == 0) {
      for (int i = 0; i <= vwapCount - 1; i++) {
         startVwap[i] = iBarShift2(asset, PERIOD_CURRENT, ObjectGetInteger(0, prefix[i], OBJPROP_TIME)) + 1;
      }
   } else {
      if (count == 1) {
         startVwap[0] = iBarShift2(asset, PERIOD_CURRENT, ObjectGetInteger(0, prefix[0], OBJPROP_TIME)) + 1;
      } else  if (count == 2) {
         startVwap[1] = iBarShift2(asset, PERIOD_CURRENT, ObjectGetInteger(0, prefix[1], OBJPROP_TIME)) + 1;
      } else  if (count == 3) {
         startVwap[2] = iBarShift2(asset, PERIOD_CURRENT, ObjectGetInteger(0, prefix[2], OBJPROP_TIME)) + 1;
      } else  if (count == 4) {
         startVwap[3] = iBarShift2(asset, PERIOD_CURRENT, ObjectGetInteger(0, prefix[3], OBJPROP_TIME)) + 1;
      } else  if (count == 5) {
         startVwap[4] = iBarShift2(asset, PERIOD_CURRENT, ObjectGetInteger(0, prefix[4], OBJPROP_TIME)) + 1;
      } else  if (count == 6) {
         startVwap[5] = iBarShift2(asset, PERIOD_CURRENT, ObjectGetInteger(0, prefix[5], OBJPROP_TIME)) + 1;
      } else  if (count == 7) {
         startVwap[6] = iBarShift2(asset, PERIOD_CURRENT, ObjectGetInteger(0, prefix[6], OBJPROP_TIME)) + 1;
      } else  if (count == 8) {
         startVwap[7] = iBarShift2(asset, PERIOD_CURRENT, ObjectGetInteger(0, prefix[7], OBJPROP_TIME)) + 1;
      } else  if (count == 9) {
         startVwap[8] = iBarShift2(asset, PERIOD_CURRENT, ObjectGetInteger(0, prefix[8], OBJPROP_TIME)) + 1;
      } else  if (count == 10) {
         startVwap[9] = iBarShift2(asset, PERIOD_CURRENT, ObjectGetInteger(0, prefix[9], OBJPROP_TIME)) + 1;
      }
   }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   int maxIndex = startVwap[ArrayMaximum(startVwap)];
//Print("startVWAP10: " + startVWAP10);
   if (applied_volume == VOLUME_TICK) {
      tempVar = CopyTickVolume(asset, 0, 0, maxIndex, VolumeBuffer);
   } else if (applied_volume == VOLUME_REAL) {
      tempVar = CopyRealVolume(asset, 0, 0, maxIndex, VolumeBuffer);
   }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   tempVar = CopyLow(asset, PERIOD_CURRENT, 0, maxIndex, arrayLow);
   tempVar = CopyClose(asset, PERIOD_CURRENT, 0, maxIndex, arrayClose);
   tempVar = CopyHigh(asset, PERIOD_CURRENT, 0, maxIndex, arrayHigh);
   tempVar = CopyOpen(asset, PERIOD_CURRENT, 0, maxIndex, arrayOpen);

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   ArraySetAsSeries(arrayOpen, true);
   ArraySetAsSeries(arrayLow, true);
   ArraySetAsSeries(arrayClose, true);
   ArraySetAsSeries(arrayHigh, true);
   ArraySetAsSeries(VolumeBuffer, true);

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   ArraySetAsSeries(vwapBuffer1, true);
   ArraySetAsSeries(vwapBuffer2, true);
   ArraySetAsSeries(vwapBuffer3, true);
   ArraySetAsSeries(vwapBuffer4, true);
   ArraySetAsSeries(vwapBuffer5, true);
   ArraySetAsSeries(vwapBuffer6, true);
   ArraySetAsSeries(vwapBuffer7, true);
   ArraySetAsSeries(vwapBuffer8, true);
   ArraySetAsSeries(vwapBuffer9, true);
   ArraySetAsSeries(vwapBuffer10, true);
   ArraySetAsSeries(vwapBuffer11, true);
   ArraySetAsSeries(vwapBuffer12, true);
   ArraySetAsSeries(vwapBuffer13, true);
   ArraySetAsSeries(vwapBuffer14, true);
   ArraySetAsSeries(vwapBuffer15, true);
   ArraySetAsSeries(vwapBuffer16, true);
   ArraySetAsSeries(vwapBuffer17, true);
   ArraySetAsSeries(vwapBuffer18, true);
   ArraySetAsSeries(vwapBuffer19, true);
   ArraySetAsSeries(vwapBuffer20, true);
   ArraySetAsSeries(vwapBuffer21, true);
   ArraySetAsSeries(vwapBuffer22, true);
   ArraySetAsSeries(vwapBuffer23, true);
   ArraySetAsSeries(vwapBuffer24, true);
   ArraySetAsSeries(vwapBuffer25, true);
   ArraySetAsSeries(vwapBuffer26, true);
   ArraySetAsSeries(vwapBuffer27, true);
   ArraySetAsSeries(vwapBuffer28, true);
   ArraySetAsSeries(vwapBuffer29, true);
   ArraySetAsSeries(vwapBuffer30, true);
   ArraySetAsSeries(vwapBufferMirror1, true);
   ArraySetAsSeries(vwapBufferMirror2, true);
   ArraySetAsSeries(vwapBufferMirror3, true);
   ArraySetAsSeries(vwapBufferMirror4, true);
   ArraySetAsSeries(vwapBufferMirror5, true);
   ArraySetAsSeries(vwapBufferMirror6, true);

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CalculateVWAP(int index, double & targetBufferPrincipal[], double & targetBufferSecundario[], double & targetBufferTerciario[], int number) {

   double sumPrice = 0, sumVol = 0, vwap = 0;
   if (VolumeBuffer[index - 1] <= 0)
      return;

   if(input_method == Open) {
      for(int i = index - 1 ; i >= 0; i--) {
         sumPrice    += arrayOpen[i] * VolumeBuffer[i];
         sumVol      += VolumeBuffer[i];
         targetBufferPrincipal[i] = sumPrice / sumVol;
      }
   } else if(input_method == High) {
      for(int i = index - 1 ; i >= 0; i--) {
         sumPrice    += arrayHigh[i] * VolumeBuffer[i];
         sumVol      += VolumeBuffer[i];
         targetBufferPrincipal[i] = sumPrice / sumVol;
         if (bands) {
            if (mirroring) {
               vwapBufferMirror1[i] = arrayHigh[index - 1] + 0.25 * MathAbs(arrayHigh[index - 1] - targetBufferPrincipal[i]);
               vwapBufferMirror2[i] = arrayHigh[index - 1] + 0.75 * MathAbs(arrayHigh[index - 1] - targetBufferPrincipal[i]);
               vwapBufferMirror3[i] = arrayHigh[index - 1] + 0.5 * MathAbs(arrayHigh[index - 1] - targetBufferPrincipal[i]);
               vwapBufferMirror4[i] = arrayHigh[index - 1] + 1.25 * MathAbs(arrayHigh[index - 1] - targetBufferPrincipal[i]);
               vwapBufferMirror5[i] = arrayHigh[index - 1] + 1 * MathAbs(arrayHigh[index - 1] - targetBufferPrincipal[i]);
               vwapBufferMirror6[i] = arrayHigh[index - 1] + 1.5 * MathAbs(arrayHigh[index - 1] - targetBufferPrincipal[i]);
               //vwapBufferMirror1[i] = arrayHigh[index - 1] + 3 * MathAbs(arrayHigh[index - 1] - targetBufferPrincipal[i]);
            } else {
               vwapBufferMirror1[i] = targetBufferPrincipal[i] + 0.25 * MathAbs(arrayLow[index - 1] - targetBufferPrincipal[i]);
               vwapBufferMirror2[i] = targetBufferPrincipal[i] + 0.75 * MathAbs(arrayLow[index - 1] - targetBufferPrincipal[i]);
               vwapBufferMirror3[i] = targetBufferPrincipal[i] + 0.5 * MathAbs(arrayLow[index - 1] - targetBufferPrincipal[i]);
               vwapBufferMirror4[i] = targetBufferPrincipal[i] - 0.25 * MathAbs(arrayLow[index - 1] - targetBufferPrincipal[i]);
               vwapBufferMirror5[i] = targetBufferPrincipal[i] - 0.75 * MathAbs(arrayLow[index - 1] - targetBufferPrincipal[i]);
               vwapBufferMirror6[i] = targetBufferPrincipal[i] - 0.5 * MathAbs(arrayLow[index - 1] - targetBufferPrincipal[i]);
            }
         }
      }
   } else if(input_method == TripleHigh) {
      for(int i = index - 1 ; i >= 0; i--) {
         sumPrice    += arrayHigh[i]  * VolumeBuffer[i];
         sumVol      += VolumeBuffer[i];
         targetBufferPrincipal[i] = sumPrice / sumVol;
         if (bands) {
            if (mirroring) {
               vwapBufferMirror1[i] = arrayHigh[index - 1] + 0.25 * MathAbs(arrayHigh[index - 1] - targetBufferPrincipal[i]);
               vwapBufferMirror2[i] = arrayHigh[index - 1] + 0.75 * MathAbs(arrayHigh[index - 1] - targetBufferPrincipal[i]);
               vwapBufferMirror3[i] = arrayHigh[index - 1] + 0.5 * MathAbs(arrayHigh[index - 1] - targetBufferPrincipal[i]);
               vwapBufferMirror4[i] = arrayHigh[index - 1] + 1.25 * MathAbs(arrayHigh[index - 1] - targetBufferPrincipal[i]);
               vwapBufferMirror5[i] = arrayHigh[index - 1] + 1 * MathAbs(arrayHigh[index - 1] - targetBufferPrincipal[i]);
               vwapBufferMirror6[i] = arrayHigh[index - 1] + 1.5 * MathAbs(arrayHigh[index - 1] - targetBufferPrincipal[i]);
               //vwapBufferMirror1[i] = arrayHigh[index - 1] + 3 * MathAbs(arrayHigh[index - 1] - targetBufferPrincipal[i]);
            } else {
               vwapBufferMirror1[i] = targetBufferPrincipal[i] + 0.25 * MathAbs(arrayLow[index - 1] - targetBufferPrincipal[i]);
               vwapBufferMirror2[i] = targetBufferPrincipal[i] + 0.75 * MathAbs(arrayLow[index - 1] - targetBufferPrincipal[i]);
               vwapBufferMirror3[i] = targetBufferPrincipal[i] + 0.5 * MathAbs(arrayLow[index - 1] - targetBufferPrincipal[i]);
               vwapBufferMirror4[i] = targetBufferPrincipal[i] - 0.25 * MathAbs(arrayLow[index - 1] - targetBufferPrincipal[i]);
               vwapBufferMirror5[i] = targetBufferPrincipal[i] - 0.75 * MathAbs(arrayLow[index - 1] - targetBufferPrincipal[i]);
               vwapBufferMirror6[i] = targetBufferPrincipal[i] - 0.5 * MathAbs(arrayLow[index - 1] - targetBufferPrincipal[i]);
            }
         }
      }
   } else if(input_method == Low) {
      for(int i = index - 1 ; i >= 0; i--) {
         sumPrice    += arrayLow[i] * VolumeBuffer[i];
         sumVol      += VolumeBuffer[i];
         targetBufferPrincipal[i] = sumPrice / sumVol;
         if (bands) {
            vwapBufferMirror1[i] = targetBufferPrincipal[i] + 0.25 * MathAbs(arrayLow[index - 1] - targetBufferPrincipal[i]);
            vwapBufferMirror2[i] = targetBufferPrincipal[i] + 0.75 * MathAbs(arrayLow[index - 1] - targetBufferPrincipal[i]);
            vwapBufferMirror3[i] = targetBufferPrincipal[i] + 0.5 * MathAbs(arrayLow[index - 1] - targetBufferPrincipal[i]);
            vwapBufferMirror4[i] = targetBufferPrincipal[i] - 0.25 * MathAbs(arrayLow[index - 1] - targetBufferPrincipal[i]);
            vwapBufferMirror5[i] = targetBufferPrincipal[i] - 0.75 * MathAbs(arrayLow[index - 1] - targetBufferPrincipal[i]);
            vwapBufferMirror6[i] = targetBufferPrincipal[i] - 0.5 * MathAbs(arrayLow[index - 1] - targetBufferPrincipal[i]);
         }
      }
   } else if(input_method == Median) {
      for(int i = index - 1 ; i >= 0; i--) {
         sumPrice    += ((arrayHigh[i] + arrayLow[i]) / 2) * VolumeBuffer[i];
         sumVol      += VolumeBuffer[i];
         targetBufferPrincipal[i] = sumPrice / sumVol;
      }
   } else if(input_method == Typical) {
      for(int i = index - 1 ; i >= 0; i--) {
         sumPrice    += ((arrayHigh[i] + arrayLow[i] + arrayClose[i]) / 3) * VolumeBuffer[i];
         sumVol      += VolumeBuffer[i];
         targetBufferPrincipal[i] = sumPrice / sumVol;
         if (bands) {
            vwapBufferMirror1[i] = targetBufferPrincipal[i] + 0.25 * MathAbs(((arrayHigh[index - 1] + arrayLow[index - 1] + arrayClose[index - 1]) / 3) - targetBufferPrincipal[i]);
            vwapBufferMirror2[i] = targetBufferPrincipal[i] + 0.75 * MathAbs(((arrayHigh[index - 1] + arrayLow[index - 1] + arrayClose[index - 1]) / 3) - targetBufferPrincipal[i]);
            vwapBufferMirror3[i] = targetBufferPrincipal[i] + 0.5 * MathAbs(((arrayHigh[index - 1] + arrayLow[index - 1] + arrayClose[index - 1]) / 3) - targetBufferPrincipal[i]);
            vwapBufferMirror4[i] = targetBufferPrincipal[i] - 0.25 * MathAbs(((arrayHigh[index - 1] + arrayLow[index - 1] + arrayClose[index - 1]) / 3) - targetBufferPrincipal[i]);
            vwapBufferMirror5[i] = targetBufferPrincipal[i] - 0.75 * MathAbs(((arrayHigh[index - 1] + arrayLow[index - 1] + arrayClose[index - 1]) / 3) - targetBufferPrincipal[i]);
            vwapBufferMirror6[i] = targetBufferPrincipal[i] - 0.5 * MathAbs(((arrayHigh[index - 1] + arrayLow[index - 1] + arrayClose[index - 1]) / 3) - targetBufferPrincipal[i]);
         }
      }
   } else if(input_method == Weighted) {
      for(int i = index - 1 ; i >= 0; i--) {
         sumPrice    += ((arrayHigh[i] + arrayLow[i] + arrayClose[i] + arrayClose[i]) / 4) * VolumeBuffer[i];
         sumVol      += VolumeBuffer[i];
         targetBufferPrincipal[i] = sumPrice / sumVol;
      }
   } else {
      for(int i = index - 1 ; i >= 0; i--) {
         sumPrice    += arrayClose[i] * VolumeBuffer[i];
         sumVol      += VolumeBuffer[i];
         targetBufferPrincipal[i] = sumPrice / sumVol;
      }
   }

   sumPrice = 0;
   sumVol = 0;
   for(int i = index - 1 ; i >= 0; i--) {
      sumPrice    += ((arrayHigh[i] + arrayLow[i] + arrayClose[i]) / 3) * VolumeBuffer[i];
      sumVol      += VolumeBuffer[i];
      targetBufferSecundario[i] = sumPrice / sumVol;
   }

   sumPrice = 0;
   sumVol = 0;
   if(input_method == High) {
      for(int i = index - 1 ; i >= 0; i--) {
         sumPrice    += arrayLow[i] * VolumeBuffer[i];
         sumVol      += VolumeBuffer[i];
         targetBufferTerciario[i] = sumPrice / sumVol;
      }
   } else if(input_method == Low) {
      for(int i = index - 1 ; i >= 0; i--) {
         sumPrice    += arrayHigh[i] * VolumeBuffer[i];
         sumVol      += VolumeBuffer[i];
         targetBufferTerciario[i] = sumPrice / sumVol;
      }
   } else {
      for(int i = index - 1 ; i >= 0; i--) {
         sumPrice    += arrayLow[i] * VolumeBuffer[i];
         sumVol      += VolumeBuffer[i];
         targetBufferTerciario[i] = sumPrice / sumVol;
      }
   }

   if (showSupport) {
      string tempString;
      int indiceTemp = number - 1;
      if (indiceTemp < 0)
         indiceTemp = 0;
      if (startVwap[indiceTemp] > 0) {

         int bar = startVwap[indiceTemp] - 1;
         double valor1 = 0, valor2 = 0;
         if(input_method == Open) {
            valor1    = arrayOpen[bar];
         } else if(input_method == High) {
            valor1    = arrayHigh[bar];
         } else if(input_method == Low) {
            valor1    = arrayLow[bar];
         } else if(input_method == Median) {
            valor1    = (arrayHigh[bar] +
                         arrayLow[bar]) / 2;
         } else if(input_method == Typical) {
            valor1    = (arrayHigh[bar] +
                         arrayLow[bar] +
                         arrayClose[bar]) / 3;
         } else if(input_method == Weighted) {
            valor1    = (arrayHigh[bar] +
                         arrayLow[bar] +
                         arrayClose[bar] +
                         arrayClose[bar]) / 3;
         } else {
            valor1    = arrayClose[bar];
         }

         valor2    = (arrayHigh[bar] +
                      arrayLow[bar] +
                      arrayClose[bar]) / 3;

         tempString = "VWAP_" + indicatorPrefix + "_" + metodo + "_" + number;
         ObjectDelete(0, tempString + "_line");
         ObjectCreate(0, tempString + "_line", OBJ_TREND, 0, iTime(NULL, PERIOD_CURRENT, bar), valor1,
                      iTime(NULL, PERIOD_CURRENT, 0) + PeriodSeconds(PERIOD_CURRENT) * 20, valor1);
         ObjectSetInteger(0, tempString + "_line", OBJPROP_COLOR, targetColor);
         ObjectSetInteger(0, tempString + "_line", OBJPROP_WIDTH, width_low);
         ObjectSetInteger(0, tempString + "_line", OBJPROP_STYLE, STYLE_DASHDOTDOT);

         tempString = "VWAP_" + indicatorPrefix + "_typical_" + number;
         ObjectDelete(0, tempString + "_line");
         ObjectCreate(0, tempString + "_line", OBJ_TREND, 0, iTime(NULL, PERIOD_CURRENT, bar), valor2,
                      iTime(NULL, PERIOD_CURRENT, 0) + PeriodSeconds(PERIOD_CURRENT) * 20, valor2);
         ObjectSetInteger(0, tempString + "_line", OBJPROP_COLOR, vwapColorTypical);
         ObjectSetInteger(0, tempString + "_line", OBJPROP_WIDTH, width_low);
         ObjectSetInteger(0, tempString + "_line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
      } else {
         ObjectDelete(0, tempString + "_line");
      }
   }

   PlotIndexSetString(index, PLOT_LABEL, "VWAP " + metodo + " " + arrayClose[0]);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateObject(string name) {

   visible_bars = (int)ChartGetInteger(0, CHART_WIDTH_IN_BARS);

   int      offset = (int)ChartGetInteger(0, CHART_FIRST_VISIBLE_BAR) - visible_bars / 2;
   Hposition = iTime(asset, PERIOD_CURRENT, offset);

   if(Anchor == ANCHOR_TOP)
      Vposition = iLow(asset, PERIOD_CURRENT, offset) - chartPoint * 50 * onetick;
   else
      Vposition = iHigh(asset, PERIOD_CURRENT, offset) + chartPoint * 50 * onetick;

   if (!history_mode) {
      ObjectCreate(0, name, OBJ_ARROW, 0, Hposition, Vposition);
   } else {
      ObjectCreate(0, name, OBJ_ARROW, 0, Hposition, 0);
   }

   ObjectSetInteger(0, name, OBJPROP_ARROWCODE, 233);
//ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_DOT);

   if (input_method == High) {
      ObjectSetInteger(0, name, OBJPROP_COLOR, clrLime);
   } else if (input_method == Low) {
      ObjectSetInteger(0, name, OBJPROP_COLOR, clrRed);
   } else {
      ObjectSetInteger(0, name, OBJPROP_COLOR, clrYellow);
   }

//ObjectSetInteger(0, name, OBJPROP_FILL, false);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
//--- permitir (true) ou desabilitar (false) o modo de movimento do sinal com o mouse
//--- ao criar um objeto gráfico usando a função ObjectCreate, o objeto não pode ser
//--- destacado e movimentado por padrão. Dentro deste método, o parâmetro de seleção
//--- é verdade por padrão, tornando possível destacar e mover o objeto
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, true);
   ObjectSetInteger(0, name, OBJPROP_SELECTED, true);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, false);
   ObjectSetInteger(0, name, OBJPROP_ZORDER, 100);
   ObjectSetInteger(0, name, OBJPROP_FILL, true);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CustomizeObject(string name) {

   int posicao = iBarShift2(asset, PERIOD_CURRENT, ObjectGetInteger(0, name, OBJPROP_TIME));
   double preco = ObjectGetDouble(0, name, OBJPROP_PRICE);
   if (preco == 0 && !history_mode) {
      if(Anchor == ANCHOR_TOP)
         preco = iLow(asset, PERIOD_CURRENT, posicao) - chartPoint * 50 * onetick;
      else
         preco = iHigh(asset, PERIOD_CURRENT, posicao) + chartPoint * 50 * onetick;

      Hposition = iTime(asset, PERIOD_CURRENT, posicao);
      ObjectMove(0, name, 0, Hposition, preco);
   }

   if (history_mode)
      ObjectMove(0, name, 0, Hposition, 0);

   if (input_method == High) {
      ObjectSetInteger(0, name, OBJPROP_COLOR, clrLime);
   } else if (input_method == Low) {
      ObjectSetInteger(0, name, OBJPROP_COLOR, clrRed);
   } else {
      ObjectSetInteger(0, name, OBJPROP_COLOR, clrYellow);
   }

   ObjectSetInteger(0, name, OBJPROP_WIDTH, arrowSize);
   ObjectSetInteger(0, name, OBJPROP_ANCHOR, Anchor);

   if(Anchor == ANCHOR_TOP)
      ObjectSetInteger(0, name, OBJPROP_ARROWCODE, 233);

   if(Anchor == ANCHOR_BOTTOM)
      ObjectSetInteger(0, name, OBJPROP_ARROWCODE, 234);

//ObjectSetInteger(0, name, OBJPROP_COLOR, vwapColorHigh);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class MillisecondTimer {
 private:
   int               _milliseconds;
 private:
   uint              _lastTick;

 public:
   void              MillisecondTimer(const int milliseconds, const bool reset = true) {
      _milliseconds = milliseconds;

      if(reset)
         Reset();
      else
         _lastTick = 0;
   }

 public:
   bool              Check() {
      uint now = getCurrentTick();
      bool stop = now >= _lastTick + _milliseconds;

      if(stop)
         _lastTick = now;

      return(stop);
   }

 public:
   void              Reset() {
      _lastTick = getCurrentTick();
   }

 private:
   uint              getCurrentTick() const {
      return(GetTickCount());
   }
};

bool _lastOK = false;
MillisecondTimer *_updateTimer;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CheckTimer() {
   EventKillTimer();

   if(_updateTimer.Check() || !_lastOK) {
      if (!autoMode) {
         _lastOK = Update();
      } else {
         vwapToCalc = 0;
         _lastOK = Update();
      }
      EventSetMillisecondTimer(WaitMilliseconds);

      ChartRedraw();
      if (debug) Print("VWAP Midas " + " " + asset + ":" + GetTimeFrame(Period()) + " ok");

      _updateTimer.Reset();
   } else {
      EventSetTimer(1);
   }
}

//+------------------------------------------------------------------+
//| Custom indicator Chart Event function                            |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long & lparam, const double & dparam, const string & sparam) {


   if(!autoMode && id == CHARTEVENT_OBJECT_DRAG && StringSubstr(sparam, 0, 4) == "VWAP") {

      int number = StringSubstr(sparam, 7);
      if (number <= vwapCount) {
         vwapToCalc = 0;
         if (sparam == prefix[0]) vwapToCalc = 1;
         else if (sparam == prefix[1]) vwapToCalc = 2;
         else if (sparam == prefix[2]) vwapToCalc = 3;
         else if (sparam == prefix[3]) vwapToCalc = 4;
         else if (sparam == prefix[4]) vwapToCalc = 5;
         else if (sparam == prefix[5]) vwapToCalc = 6;
         else if (sparam == prefix[6]) vwapToCalc = 7;
         else if (sparam == prefix[7]) vwapToCalc = 8;
         else if (sparam == prefix[8]) vwapToCalc = 9;
         else if (sparam == prefix[9]) vwapToCalc = 10;
         else vwapToCalc = 0;

         _lastOK = false;
         CheckTimer();
      }
   }

   if(id == CHARTEVENT_CHART_CHANGE) {
      _lastOK = true;
      CheckTimer();
   }
}

//+---------------------------------------------------------------------+
//| GetTimeFrame function - returns the textual timeframe               |
//+---------------------------------------------------------------------+
string GetTimeFrame(int lPeriod) {
   switch(lPeriod) {
   case PERIOD_M1:
      return("M1");
   case PERIOD_M2:
      return("M2");
   case PERIOD_M3:
      return("M3");
   case PERIOD_M4:
      return("M4");
   case PERIOD_M5:
      return("M5");
   case PERIOD_M6:
      return("M6");
   case PERIOD_M10:
      return("M10");
   case PERIOD_M12:
      return("M12");
   case PERIOD_M15:
      return("M15");
   case PERIOD_M20:
      return("M20");
   case PERIOD_M30:
      return("M30");
   case PERIOD_H1:
      return("H1");
   case PERIOD_H2:
      return("H2");
   case PERIOD_H3:
      return("H3");
   case PERIOD_H4:
      return("H4");
   case PERIOD_H6:
      return("H6");
   case PERIOD_H8:
      return("H8");
   case PERIOD_H12:
      return("H12");
   case PERIOD_D1:
      return("D1");
   case PERIOD_W1:
      return("W1");
   case PERIOD_MN1:
      return("MN1");
   }
   return IntegerToString(lPeriod);
}

//+------------------------------------------------------------------+
//| iBarShift2() function                                             |
//+------------------------------------------------------------------+
int iBarShift2(string symbol, ENUM_TIMEFRAMES timeframe, datetime time) {
   if(time < 0) {
      return(-1);
   }
   datetime Arr[], time1;

   time1 = (datetime)SeriesInfoInteger(symbol, timeframe, SERIES_LASTBAR_DATE);

   if(CopyTime(symbol, timeframe, time, time1, Arr) > 0) {
      int size = ArraySize(Arr);
      return(size - 1);
   } else {
      return(-1);
   }
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime GetObjectTime1(const string name) {
   datetime time;

   if(!ObjectGetInteger(0, name, OBJPROP_TIME, 0, time))
      return(0);

   return(time);
}

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Embedded zigzag OnCalculate() method                             |
//+------------------------------------------------------------------+
int ZZOnCalculate(const int rates_total,
                  const double & open[],
                  const double & high[],
                  const double & low[],
                  const double & close[]) {
//---
   int start = 1;
   _lastIndex = 0;
   _lastIndex2 = 0;
   _contraIndex = 0;
   _atr = 0;
   _realtimeChange = false;
   double atr = _atr;
//--- main loop
   for(int bar = start; bar < rates_total; bar++) {
      bool realtimeBar = bar == rates_total - 1;
      //--- Update ATR and other tasks
      if(!realtimeBar) {
         double tr = MathMax(high[bar], close[bar - 1]) - MathMin(low[bar], close[bar - 1]);
         atr += (tr - atr) * (2.0 / (1.0 + i_zzAtrPeriod));
         _atr = atr;
         if(_realtimeChange && i_zzRealtime) {
            if(_zzLastDirection)
               _peaks[_lastIndex] = high[_lastIndex];
            else
               _troughs[_lastIndex] = low[_lastIndex];
            _peaks[rates_total - 1] = 0;
            _troughs[rates_total - 1] = 0;
            _realtimeChange = false;
         }
         //---
         _troughs[bar] = 0;
         _peaks[bar] = 0;
      }
      //--- Conditions
      bool shouldntChange = bar - _lastIndex < i_zzMinPeriod;
      bool shallChange = bar - _lastIndex > i_zzMaxPeriod;
      bool mustChange, shouldChange, canChange;
      if(_zzLastDirection) {
         mustChange = low[bar] < low[_lastIndex2];
         shouldChange = _peaks[_lastIndex] - low[bar] > atr * i_zzAtrMultiplier;
         canChange = low[bar] < low[_contraIndex];
      } else {
         mustChange = high[bar] > high[_lastIndex2];
         shouldChange = high[bar] - _troughs[_lastIndex] > atr * i_zzAtrMultiplier;
         canChange = high[bar] > high[_contraIndex];
      }
      bool changeNow = mustChange || (canChange && shouldChange && !shouldntChange);
      //--- Algorithm realtime
      if(realtimeBar && i_zzRealtime) {
         if(_zzLastDirection) {
            if(!_realtimeChange && high[bar] > _peaks[_lastIndex]) {
               _peaks[_lastIndex] = 0;
               _peaks[bar] = high[bar];
               _realtimeChange = true;
            } else if(_realtimeChange && high[bar] > _peaks[bar]) {
               _peaks[bar] = high[bar];
            }
         } else {
            if(!_realtimeChange && low[bar] < _troughs[_lastIndex]) {
               _troughs[_lastIndex] = 0;
               _troughs[bar] = low[bar];
               _realtimeChange = true;
            } else if(_realtimeChange && low[bar] < _troughs[bar]) {
               _troughs[bar] = low[bar];
            }
         }
      } else {
         if(canChange)
            _contraIndex = bar;
         if(_zzLastDirection) {
            if(high[bar] > _peaks[_lastIndex]) {
               _peaks[_lastIndex] = 0;
               _peaks[bar] = high[bar];
               if(open[bar] > close[bar]) {
                  shouldntChange = 0 < i_zzMinPeriod;
                  shouldChange = _peaks[bar] - low[bar] > atr * i_zzAtrMultiplier;
                  changeNow = mustChange || (canChange && shouldChange && !shouldntChange);
                  if(changeNow) {
                     _troughs[bar] = low[bar];
                     _zzLastDirection = false;
                     _lastIndex2 = bar;
                  }
               } else if(changeNow) {
                  _peaks[_lastIndex] = high[_lastIndex];
                  _troughs[bar] = low[bar];
                  _lastIndex2 = bar;
               }
               _lastIndex = bar;
               _contraIndex = bar;
            } else if(changeNow) {
               _troughs[bar] = low[bar];
               _zzLastDirection = false;
               _lastIndex2 = _lastIndex;
               _lastIndex = bar;
               _contraIndex = bar;
            } else if(shallChange) {
               int startSkip = _troughs[_lastIndex] == 0 ? 0 : 1;
               if(open[_lastIndex] < close[_lastIndex] && startSkip == 0) startSkip++;
               bar = ArrayMinimum(low, _lastIndex + startSkip, bar - _lastIndex - startSkip + 1);
               _troughs[bar] = low[bar];
               _zzLastDirection = false;
               _lastIndex2 = _lastIndex;
               _lastIndex = bar;
               _contraIndex = bar;
            }
         } else {
            //--- bear trend
            if(low[bar] < _troughs[_lastIndex]) {
               _troughs[_lastIndex] = 0;
               _troughs[bar] = low[bar];
               if(open[bar] < close[bar]) {
                  shouldntChange = 0 < i_zzMinPeriod;
                  shouldChange = high[bar] - _troughs[bar] > atr * i_zzAtrMultiplier;
                  changeNow = mustChange || (canChange && shouldChange && !shouldntChange);
                  if(changeNow) {
                     _peaks[bar] = high[bar];
                     _zzLastDirection = true;
                     _lastIndex2 = bar;
                  }
               } else if(changeNow) {
                  _troughs[_lastIndex] = low[_lastIndex];
                  _peaks[bar] = high[bar];
                  _lastIndex2 = bar;
               }
               _lastIndex = bar;
               _contraIndex = bar;
            } else if(changeNow) {
               _peaks[bar] = high[bar];
               _zzLastDirection = true;
               _lastIndex2 = _lastIndex;
               _lastIndex = bar;
               _contraIndex = bar;
            } else if(shallChange) {
               int startSkip = _peaks[_lastIndex] == 0 ? 0 : 1;
               if(open[_lastIndex] > close[_lastIndex] && startSkip == 0) startSkip++;
               bar = ArrayMaximum(high, _lastIndex + startSkip, bar - _lastIndex - startSkip + 1);
               _peaks[bar] = high[bar];
               _zzLastDirection = true;
               _lastIndex2 = _lastIndex;
               _lastIndex = bar;
               _contraIndex = bar;
            }
         }
         //---
         _peaks[rates_total - 1] = 0;
         _troughs[rates_total - 1] = 0;
      }
   }
//--- return value of prev_calculated for next call
   return(rates_total);
}

//+------------------------------------------------------------------+
//| Helper method finds ZigZag direction in before index             |
//+------------------------------------------------------------------+
int ZigZagDirection(int index, const double & peaks[], const double & troughs[]) {
   int lastPeakBefore = FirstNonZeroFrom(index - 1, peaks);
   int lastTroughBefore = FirstNonZeroFrom(index - 1, troughs);
   while(lastPeakBefore == lastTroughBefore) {
      lastPeakBefore = FirstNonZeroFrom(lastPeakBefore - 1, peaks);
      lastTroughBefore = FirstNonZeroFrom(lastTroughBefore - 1, troughs);
      if(lastPeakBefore == -1 || lastTroughBefore == -1) return 0;
   }
   if(lastPeakBefore == -1 || lastTroughBefore == -1) return 0;
   else if(lastPeakBefore < lastTroughBefore) return -1;
   else return 1;
}
//+------------------------------------------------------------------+
//| Helper method finds first proper value from start                |
//+------------------------------------------------------------------+
int FirstNonZeroFrom(int start, const double & array[]) {
   for(int j = start; j >= 0; j--)
      if(IsProperValue(array[j]))
         return j;
   return -1;
}
//+------------------------------------------------------------------+
