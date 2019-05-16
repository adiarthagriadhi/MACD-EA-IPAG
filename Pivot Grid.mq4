//+------------------------------------------------------------------+
//|                                      Double Stochastic 90120.mq4 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#define SIGNAL_NONE 0
#define SIGNAL_BUY   1
#define SIGNAL_SELL  2
#define SIGNAL_CLOSEBUY 3
#define SIGNAL_CLOSESELL 4
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {

//----------------------------+
// General                    |
//----------------------------+

int Total;
Total = OrdersTotal (); 
if (Volume[0] > 1) return;
 int Order = SIGNAL_NONE;

//----------------------------+
// Sizing Risk dan Volume     |
//----------------------------+
 
bool isSizingOn = true;
double Risk = 10;
double Lots = 1.0; 

int StopLoss = 200;
int P = 10;

 if (isSizingOn == true) 
   {
      if (AccountInfoDouble(ACCOUNT_BALANCE) < 50000) Risk = 10;
      if (AccountInfoDouble(ACCOUNT_BALANCE)< 80000 && AccountInfoDouble(ACCOUNT_BALANCE)> 500000) Risk = 5;
      if (AccountInfoDouble(ACCOUNT_BALANCE)> 100000) Risk = 22;
      Lots = Risk * 0.01 * AccountBalance() / (MarketInfo(Symbol(),MODE_LOTSIZE) * StopLoss * P * Point); // Sizing Algo based on account size
      Lots = NormalizeDouble(Lots, 2); // Round to 2 decimal place
   } 
 
//----------------------------+
// Expired time pending order |
//----------------------------+

datetime et1 = TimeCurrent()+(PERIOD_M1 * 60 * 60)*50;
datetime et2 = TimeCurrent()+(PERIOD_M1 * 60 * 60)*25;

//----------------------------+
// Filter position dari akun  |
//----------------------------+

double B = (AccountInfoDouble(ACCOUNT_BALANCE)- AccountInfoDouble(ACCOUNT_EQUITY))/ AccountInfoDouble(ACCOUNT_BALANCE);
//if (B >=0.5) return;

//----------------------//
// GRID                 //
//----------------------//  

//-------------------------------+
// Nilai Highest dan Low (26/52) |
//-------------------------------+

double HighestD    = High[iHighest(NULL, PERIOD_CURRENT, MODE_HIGH,365,1)];
double LowestD     = Low[iLowest(NULL, PERIOD_CURRENT, MODE_LOW, 365,1)];
double Highest    = High[iHighest(NULL, PERIOD_CURRENT, MODE_HIGH,24,1)];
double Lowest     = Low[iLowest(NULL, PERIOD_CURRENT, MODE_LOW, 24,1)];
double Pivot      = LowestD + NormalizeDouble ((HighestD - LowestD)/2,5);
double Range      = NormalizeDouble ((HighestD - LowestD)/4,5);
double UpperHalf  = Pivot + Range;
double LowerHalf  = Pivot - Range;

double MACDMain_a      = iMACD(Symbol(), PERIOD_CURRENT,12,26,9, PRICE_CLOSE, MODE_MAIN,3);
double MACDSignal_b    = iMACD(Symbol(), PERIOD_CURRENT,12,26,9, PRICE_CLOSE, MODE_SIGNAL,3);
double MACDMain_c      = iMACD(Symbol(), PERIOD_CURRENT,12,26,9, PRICE_CLOSE, MODE_MAIN,1);
double MACDSignal_d    = iMACD(Symbol(), PERIOD_CURRENT,12,26,9, PRICE_CLOSE, MODE_SIGNAL,1);

double MA100_5 = iMA(Symbol(),PERIOD_CURRENT,100,0,MODE_SMA,PRICE_MEDIAN,6);
double MA100_1 = iMA(Symbol(),PERIOD_CURRENT,100,0,MODE_SMA,PRICE_MEDIAN,1);

double ATRcurrent = iATR(Symbol(),PERIOD_CURRENT,7,0);
double ATRpast    = iATR(Symbol(),PERIOD_CURRENT,72,0);


// CLOSE ORDER
int Ticket2;

Total = OrdersTotal ();
bool IsTrade = False;
   for (int i = 0; i < Total; i ++) 
      {
         Ticket2 = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
         if(OrderType() == OP_BUY &&  OrderProfit() >=0) 
         {
            IsTrade = True;
            if(OrderType() == OP_BUY) 
               {
                  if (MACDMain_a > MACDSignal_b && MACDMain_c < MACDSignal_d )Order = SIGNAL_CLOSEBUY;
                  if (Order == SIGNAL_CLOSEBUY) 
                  {
                     Ticket2 = OrderClose(OrderTicket(), OrderLots(), Bid, 10, MediumSeaGreen);
                     IsTrade = False;
                     continue;
                  }
               }
         } 
         
         if(OrderType() == OP_SELL &&  OrderProfit() >=0) 
         {
            if (MACDMain_a < MACDSignal_b && MACDMain_c > MACDSignal_d ) Order = SIGNAL_CLOSESELL; 
            if (Order == SIGNAL_CLOSESELL)             
            {
               Ticket2 = OrderClose(OrderTicket(), OrderLots(), Ask, 10, DarkOrange);
               IsTrade = False;
               continue;
            }
         }
         
      }
   
if (Total >=15) return; 
B = (AccountInfoDouble(ACCOUNT_BALANCE)- AccountInfoDouble(ACCOUNT_EQUITY))/ AccountInfoDouble(ACCOUNT_BALANCE);
if (B >=0.005) return;

//Open Buy Stop
if (MACDMain_a < MACDSignal_b && MACDMain_c > MACDSignal_d && MACDMain_a <=0 && MA100_5 < MA100_1 && Ask >= MA100_1 && ATRcurrent < ATRpast) int Tiket = OrderSend (Symbol(), OP_BUY, Lots,Ask,3,0,0);
//if (Ask < Pivot      && MACD >=0) int Ticket    = OrderSend (Symbol (),OP_BUY,Lots,Ask,3,LowestD,Pivot,"PIVOT_BUY",0,et1);
//if (Ask < Pivot      && MACD >=0) int Ticket    = OrderSend (Symbol (),OP_BUYSTOP,Lots,Pivot,3,LowestD,Pivot + 300*Point,"PIVOT_BUY",0,et1);
//if (Ask < UpperHalf  && MACD >=0) int Ticket2   = OrderSend (Symbol (),OP_SELLLIMIT,Lots,UpperHalf,3,HighestD,Lowest,"PIVOT_BUY",0,et1);

//Open Sell Stop
if (MACDMain_a > MACDSignal_b && MACDMain_c < MACDSignal_d && MACDMain_a >=0 && MA100_5 > MA100_1 && Bid <= MA100_1 && ATRcurrent < ATRpast) int Tiket = OrderSend (Symbol(), OP_SELL, Lots,Bid,3,0,0);

//if (Ask > Pivot      && MACD <=0) int Ticket    = OrderSend (Symbol (),OP_SELL,Lots,Bid,3,HighestD,Pivot,"PIVOT_BUY",0,et1);
//if (Ask > Pivot      && MACD <=0) int Ticket    = OrderSend (Symbol (),OP_SELLSTOP,Lots,Pivot,3,HighestD,Pivot- 300*Point,"PIVOT_BUY",0,et1);
//if (Ask > LowerHalf  && MACD <=0) int Ticket    = OrderSend (Symbol (),OP_BUYLIMIT,Lots,LowerHalf,3,LowestD,Highest,"PIVOT_BUY",0,et1);
  }

//+------------------------------------------------------------------+
