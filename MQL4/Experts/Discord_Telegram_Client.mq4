//+------------------------------------------------------------------+
//|                                       Discord_Telegram_Client.mq4 |
//|                        Copyright 2021, Noel Martial Nguemechieu. |
//|                                                                   |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Noel Martial Nguemechieu"
#property link      ""
#property  description "This bot trade generate signal and manage your positions"

//--- includes
#include <DoEasy\Engine.mqh>
#ifdef __MQL5__
#include <Trade\Trade.mqh>
#endif 
//--- enums
#define  EXPERT_NAME "TradeExpert"
#define EXPERT_VERSION "1"
#define CAPTION_COLOR "RED"
#define LOSS_COLOR "WHITE"

CEngine        engine;
#ifdef __MQL5__
CTrade         trade;
#endif 


#include <DiscordTelegram/CMybot.mqh>

enum ENUM_BUTTONS
  {
   BUTT_BUY,
   BUTT_BUY_LIMIT,
   BUTT_BUY_STOP,
   BUTT_BUY_STOP_LIMIT,
   BUTT_CLOSE_BUY,
   BUTT_CLOSE_BUY2,
   BUTT_CLOSE_BUY_BY_SELL,
   BUTT_SELL,
   BUTT_SELL_LIMIT,
   BUTT_SELL_STOP,
   BUTT_SELL_STOP_LIMIT,
   BUTT_CLOSE_SELL,
   BUTT_CLOSE_SELL2,
   BUTT_CLOSE_SELL_BY_BUY,
   BUTT_DELETE_PENDING,
   BUTT_CLOSE_ALL,
   BUTT_PROFIT_WITHDRAWAL,
   BUTT_SET_STOP_LOSS,
   BUTT_SET_TAKE_PROFIT,
   BUTT_TRAILING_ALL
  };
#define TOTAL_BUTT   (20)
//--- structures
struct SDataButt
  {
   string      name;
   string      text;
  };
 int MagicNumber = 1234567;
 double Lots = 0.01;

 string action;
  
double price=1;

SDataButt      butt_data[TOTAL_BUTT];
   datetime timess[1];
CMyBot bot;
//#################################################################################

//--- input variables
input ulong    InpMagic             =  123;  // Magic number
input double   InpLots              =  0.001;  // Lots
input uint     InpStopLoss          =  50;   // StopLoss in points
input uint     InpTakeProfit        = 50;   // TakeProfit in points
input uint     InpDistance          =  50;   // Pending orders distance (points)
input uint     InpDistanceSL        =  50;   // StopLimit orders distance (points)
input uint     InpSlippage          =  0;    // Slippage in points
input double   InpWithdrawal        =  10;   // Withdrawal funds (in tester)
input uint     InpButtShiftX        =  40;   // Buttons X shift 
input uint     InpButtShiftY        =  10;   // Buttons Y shift 
input uint     InpTrailingStop      =  50;   // Trailing Stop (points)
input uint     InpTrailingStep      =  20;   // Trailing Step (points)
input uint     InpTrailingStart     =  0;    // Trailing Start (points)
input uint     InpStopLossModify    =  20;   // StopLoss for modification (points)
input uint     InpTakeProfitModify  =  60;   // TakeProfit for modification (points)
//--- global variables
string         prefix;
double         lot;
double         withdrawal=(InpWithdrawal<InpLots ? InpLots : InpWithdrawal);
ulong          magic_number;
uint           stoploss;
uint           takeprofit;
uint           distance_pending;
uint           distance_stoplimit;
uint           slippage;
bool           trailing_on;
double         trailing_stop;
double         trailing_step;
uint           trailing_start;
uint           stoploss_to_modify;
uint           takeprofit_to_modify;
  
   double priceBid =0 ;
          double priceAsk=0;
//--- Get the correct StopLoss and TakeProfit prices relative to StopLevel
         double sl=CorrectStopLoss(Symbol(),ORDER_TYPE_BUY,0,stoploss);
         double tp=CorrectTakeProfit(Symbol(),ORDER_TYPE_BUY,0,takeprofit);
      

input string IndicatorList="RSI,Momentum, CCI";
input string Telegram_Channel_Name="tradeexpert_infos";
 string channel=Telegram_Channel_Name;
input long ChatID = 1001659738763;
input string IndicatorName="CCI";
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H1;

input color bullishColor = Green;   // Bullish candlestick color
input color bearishColor = Red;     // Bearish candlestick color
input color backgroundColor = White;  // Background color
input double riskPercentage = 2.0;  // Risk percentage per trade

input int startHour = 8;   // Trading start hour (24-hour format)
input int endHour = 16;    // Trading end hour (24-hour format)
int run_mode=0;
input string Telegram_Token ="2032573404:AAGnxJpNMJBKqLzvE5q4kGt1cCGF632bP7A";


int macd[],signal[];int count=0;
     


    
  
  
  
  input string _template="tradeexpert";
input bool showorderid=true;

void SetCandlestickColors() {
    // Set the candlestick and background colors
    ChartSetInteger(0, CHART_COLOR_CANDLE_BULL, bullishColor);
    ChartSetInteger(0, CHART_COLOR_CANDLE_BEAR, bearishColor);
    ChartSetInteger(0, CHART_COLOR_BACKGROUND, backgroundColor);
}

 void Showorderid(bool showorderids){
 if(showorderids){};
 }

input bool showentrytime ;void Showentrytime(bool showentrytimes){ if(showentrytimes){};}

input bool showtype ;void Showtype (bool showtypes){if(showtypes){};}

input bool showsymbol;void Showsymbol (bool showsymbols){if(showsymbols){};}

input bool showentryprice; void Showentryprice (bool showentryprices){if(showentryprices){};}

input bool showstoplossprice ; void Showstoplossprice (bool showentryprices){if(showentryprices){};}
input bool showriskinpips ;void Showriskinpips(bool showriskinpipss){if(showriskinpipss){};}
input bool showtakeprofitprice ;void Showtakeprofitprice(bool  showtakeprofitprices){if(showtakeprofitprices){};}
input bool showtakeprofitinpips ;void Showtakeprofitinpips(bool showtakeprofitinpipss){if(showtakeprofitinpipss){};}
input bool showclosetime;void Showclosetime (bool showclosetimes){if(showclosetimes){};}

input bool showcloseprice; void  Showcloseprice (bool showclosepriceS){if(showclosepriceS){};}

input bool shownetprofitloss ; void Shownetprofitloss(bool shownetprofitlosss){if( shownetprofitlosss){};}

input bool shownetprofitlossinpips ;void  Shownetprofitlossinpips (bool  shownetprofitlossinpipss ){if(shownetprofitlossinpipss){};}

input bool sendscreenshot ;void Sendscreenshot(bool sendscreenshots){if(sendscreenshots){};}

input ENUM_UPDATE_MODE InpUpdateMode;
input string Platform="T";
 MqlTick tick; 
  datetime mydate=TimeLocal()-TimeDay(TimeLocal());
 int time_check=0;                              
input string Name ="tradeexpert";



bool IsTradingTime() {
    // Get the current hour in 24-hour format
    int currentHour = Hour();

    // Check if the current time is within the allowed trading hours
    return (currentHour >= startHour && currentHour < endHour);
}

double CalculateLotSize() {
    // Implement Benford's Law or any other lot size calculation logic here
    // For simplicity, using a fixed lot size in this example
    
    int lotSize=0;
    if(OrdersTotal()==0){
          lotSize++;
          return  lotSize/100;
    }else
    {return AccountFreeMarginCheck(Symbol(), OP_BUY, 1) * riskPercentage / 100;
    
    }
}

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
  SetCandlestickColors();
//--- Calling the function displays the list of enumeration constants in the journal 
//--- (the list is set in the strings 22 and 25 of the DELib.mqh file) for checking the constants validity
 
 
//##############################################TELEGRAM#####BOT CONTROL
//---
   run_mode=GetRunMode();

//--- stop working in tester
   if(run_mode!=RUN_LIVE)
   {
      PrintError(ERR_RUN_LIMITATION,InpLanguage);
      return(INIT_FAILED);
   }

   int y=40;
   if(ChartGetInteger(0,CHART_SHOW_ONE_CLICK))
      y=120;
   comment.Create("BotPanel",20,y);
   comment.SetColor(clrDimGray,clrGreen,220);
//--- set language
   bot.Language(InpLanguage);

//--- set token
   init_error=bot.Token(Telegram_Token);

//--- set filter
   bot.UserNameFilter(Name);

//--- set templates
   bot.Templates(IndicatorList);

//--- set timer
   int timer_ms=3000;
   switch(InpUpdateMode)
   {
   case UPDATE_FAST:
      timer_ms=1000;
      break;
   case UPDATE_NORMAL:
      timer_ms=2000;
      break;
   case UPDATE_SLOW:
      timer_ms=3000;
      break;
   default:
      timer_ms=3000;
      break;
   };
   EventSetMillisecondTimer(timer_ms);
   
//--- done

 
 
 
   //EnumNumbersTest();

//--- Set EA global variables
   prefix=MQLInfoString(MQL_PROGRAM_NAME)+"_";
   for(int i=0;i<TOTAL_BUTT;i++)
     {
      butt_data[i].name=prefix+EnumToString((ENUM_BUTTONS)i);
      butt_data[i].text=EnumToButtText((ENUM_BUTTONS)i);
     }
   lot=CalculateLotSize();
   
   
  magic_number=InpMagic;
   stoploss=InpStopLoss;
   takeprofit=InpTakeProfit;
   distance_pending=InpDistance;
   distance_stoplimit=InpDistanceSL;
   slippage=InpSlippage;
   trailing_stop=InpTrailingStop*Point();
   trailing_step=InpTrailingStep*Point();
   trailing_start=InpTrailingStart;
   stoploss_to_modify=InpStopLossModify;
   takeprofit_to_modify=InpTakeProfitModify;

//--- Check and remove remaining EA graphical objects
   if(IsPresentObects(prefix))
      ObjectsDeleteAll(0,prefix);

//--- Create the button panel
   if(!CreateButtons(InpButtShiftX,InpButtShiftY))
      return INIT_FAILED;
//--- Set trailing activation button status
   ButtonState(butt_data[TOTAL_BUTT-1].name,trailing_on);

//--- Set CTrade trading class parameters
#ifdef __MQL5__
   trade.SetDeviationInPoints(slippage);
   trade.SetExpertMagicNumber(magic_number);
   trade.SetTypeFillingBySymbol(Symbol());
   trade.SetMarginMode();
   trade.LogLevel(LOG_LEVEL_NO);
#endif 
//--- Fast check of the account object
   CAccount* acc=new CAccount();
   if(acc!=NULL)
     {
      acc.PrintShort();
      acc.Print();
      delete acc;
     }
//--- Trade signal

int time_signal=0;

   
 
 #ifdef __MQL4__  
 
 int macd_handle=0;
   if(macd_handle==INVALID_HANDLE)
      return(INIT_FAILED);
//--- add the indicator to the chart
   int total=(int)ChartGetInteger(0,CHART_WINDOWS_TOTAL);
  
#endif 
#ifdef __MQL5__
   macd_handle=iMACD(NULL,0,12,26,9,PRICE_CLOSE);
   if(macd_handle==(string)INVALID_HANDLE)
      return(INIT_FAILED);
//--- add the indicator to the chart
   int total=(int)ChartGetInteger(0,CHART_WINDOWS_TOTAL);
   ChartIndicatorAdd(0,total,macd_handle);
#endif

OnTimer();

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- Remove EA graphical objects by an object name prefix
   ObjectsDeleteAll(0,prefix);
   Comment("");
   
   //Deinit trade signal
   //--- delete the indicator
#ifdef __MQL5__
   int total=(int)ChartGetInteger(0,CHART_WINDOWS_TOTAL);
   for(int subwin=total-1; subwin>=0; subwin--)
   {
      int amount=ChartIndicatorsTotal(0,subwin);
      for(int i=amount-1; i>=0; i--)
      {
         string name=ChartIndicatorName(0,subwin,i);
         if(StringFind(name,"MACD",0)==0)
            ChartIndicatorDelete(0,subwin,name);
      }
   }
#endif
   
   //---TELEGRAM BOTCONTROL
   if(reason==REASON_CLOSE ||
         reason==REASON_PROGRAM ||
         reason==REASON_PARAMETERS ||
         reason==REASON_REMOVE ||
         reason==REASON_RECOMPILE ||
         reason==REASON_ACCOUNT ||
         reason==REASON_INITFAILED)
   {
   
      comment.Destroy();
   }
//---

   EventKillTimer();
    
  
   ChartRedraw();
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()



  {
  string msg;
 const int BufferSar=0;
 static double lastSar=0,currentSar=0;
 static double lastClose=0;
 int InpStep=0, InputMax=0;
 
 //Trading signal
 int tradingSignal=(int)iCustom(Symbol(),TimeFrame,IndicatorName , InputMax,BufferSar,0);
   
   double close =iClose(Symbol(),Period(),1);
   double priceTarget=0; 

 double  securetrade1=Ask*priceTarget/100;
  double  securetrade2=Bid*priceTarget/100;
   bool BuyCondition=false;
   
   bool SellCondition=false;
  
  if(  tradingSignal<=0){
  BuyCondition=true;action="BUY";
 
   sl=CorrectStopLoss(Symbol(),ORDER_TYPE_BUY_LIMIT,Ask,stoploss,2);
          tp=CorrectTakeProfit(Symbol(),ORDER_TYPE_BUY_LIMIT,Ask,takeprofit,2);
       
   
  }else if(tradingSignal>1){
   action="SELL";
    sl=CorrectStopLoss(Symbol(),ORDER_TYPE_SELL_LIMIT,Bid,stoploss,2);
    tp=CorrectTakeProfit(Symbol(),ORDER_TYPE_SELL_LIMIT,Bid,takeprofit,2);
       
  }else{
  //trade signal send
    action="No trade Signal now!";
    bot.SendMessage(ChatID,action);
    }

string mytype;



//--- global variables


double time[];
datetime time_signal=0;
bool checked=false;

if(Platform=="T"||Platform=="t"){    

string msg;
    priceTarget=0;
    
   if(action=="BUY"){    
       priceTarget=(priceAsk-priceBid- trailing_on)/100;
         msg=StringFormat("Name: "+IndicatorName+"\xF4E3\nSymbol: %s\nTimeframe: %s\nType: Sell\nPrice: %s\nTime: %s\nTarget %2.4f:%s\nTakeProfit:%s\nStopLoss:%s\n",
                                 _Symbol,
                                 StringSubstr(EnumToString((ENUM_TIMEFRAMES)_Period),7),
                                 DoubleToString(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits),
                                   TimeToString(timess[0]),(string)priceTarget,(string)tp,(string)sl);
                               int res=    bot.SendScreenShot(ChatID,_Symbol,TimeFrame,IndicatorList);
                          
                        int res2=bot.SendMessage(ChatID,msg);
                         Sleep(500);
                          Buy(lot,Symbol(),magic_number,sl,tp);     
         
          }else  if(action=="SELL"){ 
          
              priceTarget=(priceAsk-priceBid-trailing_on)/100;
         msg=StringFormat("Name: "+IndicatorName+"\xF4E3\nSymbol: %s\nTimeframe: %s\nType: Sell\nPrice: %s\nTime: %s\nTarget :%2.4f %s\nTakeProfit:%s\nStopLoss:%s\n",
                                 _Symbol,
                                 StringSubstr(EnumToString((ENUM_TIMEFRAMES)_Period),7),
                                 DoubleToString(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits),
                                    TimeToString(timess[0]),(string)priceTarget,(string)tp,(string)sl);
                             int res=    bot.SendScreenShot(ChatID,_Symbol,TimeFrame,IndicatorList);
                       
                        int res2=bot.SendMessage(ChatID,msg);
                          Sleep(500);
                         Sell(lot,Symbol(),magic_number,sl,tp);
                         
  }
    
     
        
 
  }
  else if(Platform=="D"||Platform=="d"){
  priceTarget=0;
   priceTarget=(priceAsk-priceBid+ trailing_on)/100;
      if(action=="BUY"){
         msg=StringFormat("Name: "+IndicatorName+"\xF4E3\nSymbol: %s\nTimeframe: %s\nType: BUY\nPrice: %s\nTime: %s\nTarget %:%2.4f\nTakeProfit:%s\nStopLoss:%s\n",
                                 _Symbol,
                                 StringSubstr(EnumToString((ENUM_TIMEFRAMES)_Period),7),
                                 DoubleToString(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits),
                                  TimeToString(timess[0]),(string)Ask,(string)tp,(string)sl);
                                   bot.SendScreenShot(ChatID,Symbol(),TimeFrame,IndicatorList);
       
          int res=bot.SendMessage(ChatID,msg); 
          Sleep(500);
          Buy(lot,Symbol(),magic_number,sl,tp);
            
         
     } else if(action=="SELL"){ 
     
            priceTarget=(-priceAsk+priceBid+ trailing_on)/100;
     
         msg=StringFormat("Name: "+IndicatorName+"\xF4E3\nSymbol: %s\nTimeframe: %s\nType: Sell\nPrice: %s\nTime: %s\nTarget %:%2.4f\nTakeProfit:%s\nStopLoss:%s\n",
                                 _Symbol,
                                 StringSubstr(EnumToString((ENUM_TIMEFRAMES)_Period),7),
                                 DoubleToString(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits),
                                 TimeToString(timess[0]),(string)Bid,(string)tp,(string)sl);
                                   bot.SendScreenShot(ChatID,_Symbol,TimeFrame,IndicatorList);
       
                        int res=bot.SendMessage(ChatID,msg); 
                      
                       Sell(lot,Symbol(),magic_number,sl,tp);  
                           
                            Sleep(300);
                 }
               
                 
                 
     }else{Comment ("Invalid platform selected ! Please enter T for TELEGRAM OR D  for DISCORD"); 
                }
      
      
 
  
//--- Initialize the last trading event
   static ENUM_TRADE_EVENT last_event=WRONG_VALUE;
//--- If working in the tester
   if(MQLInfoInteger(MQL_TESTER))
     {
      engine.OnTimer();
      PressButtonsControl();
     }
//--- If the last trading event changed
   if(engine.LastTradeEvent()!=last_event)
     {
      last_event=engine.LastTradeEvent();
      Comment("                                                             Last_trade_event: ",EnumToString(last_event));
     
     }
//--- If the trailing flag is set
   if(trailing_on)
     {
      TrailingPositions();
      TrailingOrders();
     }
     //Trade signal control
     
     
 

//--- get time


   if(CopyTime(NULL,0,0,1,timess)!=1)
      return;

//--- check the signal on each bar
   if(time_signal!=timess[0])
   {
      //--- first calc
      if(time_signal==0)
      {
         time_signal=timess[0];
         return;
      }

      double macds[2]= {0.0};
      double signals[2]= {0.0};

#ifdef __MQL4__
      for(int i=0; i<=1; i++)
      {
         macds[i]=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,i);
         signals[i]=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,i);
      }
            

   
#endif

#ifdef __MQL5__
      if(CopyBuffer(macd_handle,0,1,2,macd)!=2)
         return;
      if(CopyBuffer(macd_handle,1,1,2,signal)!=2)
         return;
#endif

      //--- Send signal BUY
      if(macd[1]>signal[1] &&
            macd[0]<=signal[0] &&
            macd[0]<0.0)
      {
        string msg=StringFormat("Name: MACD Signal\xF4E3\nSymbol: %s\nTimeframe: %s\nType: Buy\nPrice: %s\nTime: %s",
                                 _Symbol,
                                 StringSubstr(EnumToString((ENUM_TIMEFRAMES)_Period),7),
                                 DoubleToString(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits),
                                 TimeToString(timess[0]));
         int res=bot.SendMessage(ChatID,msg);
         Buy(lot,Symbol(),magic_number,sl,tp);
         if(res!=0)
            Print("Error: ",GetErrorDescription(res));
      }

      //--- Send signal SELL
      if(macd[1]<signal[1] &&
            macd[0]>=signal[0] &&
            macd[0]>0.0)
      {
         msg=StringFormat("Name: MACD Signal\xF4E3\nSymbol: %s\nTimeframe: %s\nType: Sell\nPrice: %s\nTime: %s",
                                 _Symbol,
                                 StringSubstr(EnumToString((ENUM_TIMEFRAMES)_Period),7),
                                 DoubleToString(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits),
                                 TimeToString(timess[0]));
         int res=bot.SendMessage(ChatID,msg);
          Sell(lot,Symbol(),magic_number,sl,tp);
         
         if(res!=0)
            Print("Error: ",GetErrorDescription(res));
            msg=StringFormat("%s %s","Error: ",GetErrorDescription(res));
             
   
      }
   }
    
 
    
     
  }
  CComment comment;
  int init_error=0;int  web_error=0;
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//--- Launch the library timer (only not in the tester)
   if(!MQLInfoInteger(MQL_TESTER))
      engine.OnTimer();
      

      
//--- show init error
   if(init_error!=0)
   {
      //--- show error on display
      CustomInfo info;
      GetCustomInfo(info,init_error,InpLanguage);

      //---
      comment.Clear();
      comment.SetText(0,StringFormat("%s v.%s",EXPERT_NAME,EXPERT_VERSION),CAPTION_COLOR);
      comment.SetText(1,info.text1, LOSS_COLOR);
      if(info.text2!="")
         comment.SetText(2,info.text2,LOSS_COLOR);
      comment.Show();
      
        }

//--- show web error
   if(run_mode==RUN_LIVE )
   {  

      //--- check bot registration
      if(time_check<TimeLocal()-PeriodSeconds(PERIOD_H1))
      {
         time_check=TimeLocal();
         if(TerminalInfoInteger(TERMINAL_CONNECTED))
         {
            //---
            int web_error=bot.GetMe();
            if(web_error!=0)
            {
               //---
               if(web_error==ERR_NOT_ACTIVE)
               {
                  time_check=TimeCurrent()-PeriodSeconds(PERIOD_H1)+300;
               }
               //---
               else
               {
                  time_check=TimeCurrent()-PeriodSeconds(PERIOD_H1)+5;
               }
            }
         }
         else
         {
             web_error=ERR_NOT_CONNECTED;
            time_check=0;
         }
      }

      //--- show error
      if(web_error!=0)
      {
         comment.Clear();
         comment.SetText(0,StringFormat("%s v.%s",EXPERT_NAME,EXPERT_VERSION),CAPTION_COLOR);

         if(
#ifdef __MQL4__ web_error==ERR_FUNCTION_NOT_CONFIRMED 
#endif
#ifdef __MQL5__ web_error==ERR_FUNCTION_NOT_ALLOWED #endif
         )
         {
            time_check=0;

            CustomInfo info= {0};
            GetCustomInfo(info,web_error,InpLanguage);
            comment.SetText(1,info.text1,LOSS_COLOR);
            comment.SetText(2,info.text2,LOSS_COLOR);
         }
         else
            comment.SetText(1,GetErrorDescription(web_error,InpLanguage),LOSS_COLOR);

         comment.Show();
         return;
      }
      
   }

//---
  


 
//---
   if(run_mode==RUN_LIVE)
   {
      comment.Clear();
      comment.SetText(0,StringFormat("%s v.%s",EXPERT_NAME,EXPERT_VERSION),CAPTION_COLOR);
      comment.SetText(1,StringFormat("%s: %s",(InpLanguage==LANGUAGE_EN)?"Bot Name":"Имя Бота",bot.Name()),CAPTION_COLOR);
      comment.SetText(2,StringFormat("%s: %d",(InpLanguage==LANGUAGE_EN)?"Chats":"Чаты",bot.ChatsTotal()),CAPTION_COLOR);
      comment.Show();
     
   bot.ProcessMessages();
 bot.GetUpdates();

  }
   
   }


//
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   if(MQLInfoInteger(MQL_TESTER))
      return;
   if(id==CHARTEVENT_OBJECT_CLICK && StringFind(sparam,"BUTT_")>0)
     {
      PressButtonEvents(sparam);
     }
   if(id>=CHARTEVENT_CUSTOM)
     {
      ushort event=ushort(id-CHARTEVENT_CUSTOM);
      Print(DFUN,"id=",id,", event=",EnumToString((ENUM_TRADE_EVENT)event),", lparam=",lparam,", dparam=",DoubleToString(dparam,Digits()),", sparam=",sparam);
     }
     
   comment.OnChartEvent(id,lparam,dparam,sparam);
  }
//+------------------------------------------------------------------+
//| Return the flag of a prefixed object presence                    |
//+------------------------------------------------------------------+
bool IsPresentObects(const string object_prefix)
  {
   for(int i=ObjectsTotal(0,0)-1;i>=0;i--)
      if(StringFind(ObjectName(0,i,0),object_prefix)>WRONG_VALUE)
         return true;
   return false;
  }
//+------------------------------------------------------------------+
//| Tracking the buttons' status                                     |
//+------------------------------------------------------------------+
void PressButtonsControl(void)
  {
   int total=ObjectsTotal(0,0);
   for(int i=0;i<total;i++)
     {
      string obj_name=ObjectName(0,i);
      if(StringFind(obj_name,prefix+"BUTT_")<0)
         continue;
      PressButtonEvents(obj_name);
     }
  }
//+------------------------------------------------------------------+
//| Create the buttons panel                                         |
//+------------------------------------------------------------------+
bool CreateButtons(const int shift_x=20,const int shift_y=10)
  {
   int h=35,w=95,offset=2;
   int cx=offset+shift_x,cy=offset+shift_y+(h+1)*(TOTAL_BUTT/2)+3*h+1;
   int x=cx,y=cy;
   int shift=0;
   for(int i=0;i<TOTAL_BUTT;i++)
     {
      x=x+(i==7 ? w+2 : 0);
      if(i==TOTAL_BUTT-6) x=cx;
      y=(cy-(i-(i>6 ? 7 : 0))*(h+1));
      if(!ButtonCreate(butt_data[i].name,x,y,(i<TOTAL_BUTT-6 ? w : w*2+2),h,butt_data[i].text,(i<4 ? clrGreen : i>6 && i<11 ? clrRed : clrBlue)))
        {
         Alert(TextByLanguage("Не удалось создать кнопку \"","Could not create button \""),butt_data[i].text);
         return false;
        }
     }
   ChartRedraw(0);
   return true;
  }
//+------------------------------------------------------------------+
//| Create the button                                                |
//+------------------------------------------------------------------+
bool ButtonCreate(const string name,const int x,const int y,const int w,const int h,const string text,const color clr,const string font="Calibri",const int font_size=8)
  {
   if(ObjectFind(0,name)<0)
     {
      if(!ObjectCreate(ChartID(),name,OBJ_BUTTON,0,Time[0],Ask)) 
        { 
         Print(DFUN,TextByLanguage("не удалось создать кнопку! Код ошибки=","Could not create button! Error code="),GetLastError()); 
         return false; 
        } 
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
      ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
      ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
      ObjectSetInteger(0,name,OBJPROP_XSIZE,w);
      ObjectSetInteger(0,name,OBJPROP_YSIZE,h);
      ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_LOWER);
      ObjectSetInteger(0,name,OBJPROP_ANCHOR,ANCHOR_LEFT_LOWER);
      ObjectSetInteger(0,name,OBJPROP_FONTSIZE,font_size);
      ObjectSetString(0,name,OBJPROP_FONT,font);
      ObjectSetString(0,name,OBJPROP_TEXT,text);
      ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
      ObjectSetString(0,name,OBJPROP_TOOLTIP,"\n");
      ObjectSetInteger(0,name,OBJPROP_BORDER_COLOR,clrGray);
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//| Return the button status                                         |
//+------------------------------------------------------------------+
bool ButtonState(const string name)
  {
   return (bool)ObjectGetInteger(0,name,OBJPROP_STATE);
  }
//+------------------------------------------------------------------+
//| Set the button status                                            |
//+------------------------------------------------------------------+
void ButtonState(const string name,const bool state)
  {
   ObjectSetInteger(0,name,OBJPROP_STATE,state);
   if(name==butt_data[TOTAL_BUTT-1].name)
     {
      if(state)
         ObjectSetInteger(ChartID(),name,OBJPROP_BGCOLOR,C'220,255,240');
      else
         ObjectSetInteger(ChartID(),name,OBJPROP_BGCOLOR,C'240,240,240');
     }
  }
//+------------------------------------------------------------------+
//| Transform enumeration into the button text                       |
//+------------------------------------------------------------------+
string EnumToButtText(const ENUM_BUTTONS member)
  {
   string txt=StringSubstr(EnumToString(member),5);
   StringToLower(txt);
   StringReplace(txt,"set_take_profit","Set TakeProfit");
   StringReplace(txt,"set_stop_loss","Set StopLoss");
   StringReplace(txt,"trailing_all","Trailing All");
   StringReplace(txt,"buy","Buy");
   StringReplace(txt,"sell","Sell");
   StringReplace(txt,"_limit"," Limit");
   StringReplace(txt,"_stop"," Stop");
   StringReplace(txt,"close_","Close ");
   StringReplace(txt,"2"," 1/2");
   StringReplace(txt,"_by_"," by ");
   StringReplace(txt,"profit_","Profit ");
   StringReplace(txt,"delete_","Delete ");
   return txt;
  }
//+------------------------------------------------------------------+
//| Handle pressing the buttons                                      |
//+------------------------------------------------------------------+
void PressButtonEvents(const string button_name)
  {
   //--- Convert button name into its string ID
   string button=StringSubstr(button_name,StringLen(prefix));
   //--- If the button is pressed
   if(ButtonState(button_name))
     {
      //--- If the BUTT_BUY button is pressed: Open Buy position
      if(button==EnumToString(BUTT_BUY))
        {
         //--- Get the correct StopLoss and TakeProfit prices relative to StopLevel
          sl=CorrectStopLoss(Symbol(),ORDER_TYPE_BUY,0,stoploss);
          tp=CorrectTakeProfit(Symbol(),ORDER_TYPE_BUY,0,takeprofit);
         //--- Open Buy position
         #ifdef __MQL5__
            trade.Buy(lot,Symbol(),0,sl,tp);
         #else 
            Buy(lot,Symbol(),magic_number,sl,tp);
         #endif 
        }
      //--- If the BUTT_BUY_LIMIT button is pressed: Place BuyLimit
      else if(button==EnumToString(BUTT_BUY_LIMIT))
        {
         //--- Get correct order placement relative to StopLevel
         double price_set=CorrectPricePending(Symbol(),ORDER_TYPE_BUY_LIMIT,distance_pending);
         //--- Get correct StopLoss and TakeProfit prices relative to the order placement level considering StopLevel
         sl=CorrectStopLoss(Symbol(),ORDER_TYPE_BUY_LIMIT,price_set,stoploss);
         tp=CorrectTakeProfit(Symbol(),ORDER_TYPE_BUY_LIMIT,price_set,takeprofit);
         //--- Set BuyLimit order
        
         #ifdef __MQL5__
            trade.BuyLimit(lot,price_set,Symbol(),sl,tp);
         #else 
            BuyLimit(lot,price_set,Symbol(),magic_number,sl,tp);
         #endif 
        }
      //--- If the BUTT_BUY_STOP button is pressed: Set BuyStop
      else if(button==EnumToString(BUTT_BUY_STOP))
        {
         //--- Get correct order placement relative to StopLevel
         double price_set=CorrectPricePending(Symbol(),ORDER_TYPE_BUY_STOP,distance_pending);
         //--- Get correct StopLoss and TakeProfit prices relative to the order placement level considering StopLevel
         sl=CorrectStopLoss(Symbol(),ORDER_TYPE_BUY_STOP,price_set,stoploss);
         tp=CorrectTakeProfit(Symbol(),ORDER_TYPE_BUY_STOP,price_set,takeprofit);
         //--- Set BuyStop order
         #ifdef __MQL5__
            trade.BuyStop(lot,price_set,Symbol(),sl,tp);
         #else 
            BuyStop(lot,price_set,Symbol(),magic_number,sl,tp);
         #endif 
        }
      //--- If the BUTT_BUY_STOP_LIMIT button is pressed: Set BuyStopLimit
      else if(button==EnumToString(BUTT_BUY_STOP_LIMIT))
        {
         //--- Get the correct BuyStop order placement price relative to StopLevel
          double price_set_stop=CorrectPricePending(Symbol(),ORDER_TYPE_BUY_STOP,distance_pending);
         //--- Calculate BuyLimit order price relative to BuyStop level considering StopLevel
          double price_set_limit=CorrectPricePending(Symbol(),ORDER_TYPE_BUY_LIMIT,distance_stoplimit,price_set_stop);
         //--- Get correct StopLoss and TakeProfit prices relative to the order placement level considering StopLevel
          sl=CorrectStopLoss(Symbol(),ORDER_TYPE_BUY_STOP,price_set_limit,stoploss);
         tp=CorrectTakeProfit(Symbol(),ORDER_TYPE_BUY_STOP,price_set_limit,takeprofit);
         //--- Set BuyStopLimit order
         #ifdef __MQL5__
            trade.OrderOpen(Symbol(),ORDER_TYPE_BUY_STOP_LIMIT,lot,price_set_limit,price_set_stop,sl,tp);
         #else 
            
         #endif 
        }
      //--- If the BUTT_SELL button is pressed: Open Sell position
      else if(button==EnumToString(BUTT_SELL))
        {
         //--- Get the correct StopLoss and TakeProfit prices relative to StopLevel
          sl=CorrectStopLoss(Symbol(),ORDER_TYPE_SELL,0,stoploss);
         tp=CorrectTakeProfit(Symbol(),ORDER_TYPE_SELL,0,takeprofit);
         //--- Open Sell position
         #ifdef __MQL5__
            trade.Sell(lot,Symbol(),0,sl,tp);
         #else 
            Sell(lot,Symbol(),magic_number,sl,tp);
         #endif 
        }
      //--- If the BUTT_SELL_LIMIT button is pressed: Set SellLimit
      else if(button==EnumToString(BUTT_SELL_LIMIT))
        {
         //--- Get correct order placement relative to StopLevel
         double price_set=CorrectPricePending(Symbol(),ORDER_TYPE_SELL_LIMIT,distance_pending);
         //--- Get correct StopLoss and TakeProfit prices relative to the order placement level considering StopLevel
          sl=CorrectStopLoss(Symbol(),ORDER_TYPE_SELL_LIMIT,price_set,stoploss);
         tp=CorrectTakeProfit(Symbol(),ORDER_TYPE_SELL_LIMIT,price_set,takeprofit);
         //--- Set SellLimit order
         #ifdef __MQL5__
            trade.SellLimit(lot,price_set,Symbol(),sl,tp);
         #else 
            SellLimit(lot,price_set,Symbol(),magic_number,sl,tp);
         #endif 
        }
      //--- If the BUTT_SELL_STOP button is pressed: Set SellStop
      else if(button==EnumToString(BUTT_SELL_STOP))
        {
         //--- Get correct order placement relative to StopLevel
         double price_set=CorrectPricePending(Symbol(),ORDER_TYPE_SELL_STOP,distance_pending);
         //--- Get correct StopLoss and TakeProfit prices relative to the order placement level considering StopLevel
          sl=CorrectStopLoss(Symbol(),ORDER_TYPE_SELL_STOP,price_set,stoploss);
         tp=CorrectTakeProfit(Symbol(),ORDER_TYPE_SELL_STOP,price_set,takeprofit);
         //--- Set SellStop order
         #ifdef __MQL5__
            trade.SellStop(lot,price_set,Symbol(),sl,tp);
         #else 
            SellStop(lot,price_set,Symbol(),magic_number,sl,tp);
         #endif 
        }
      //--- If the BUTT_SELL_STOP_LIMIT button is pressed: Set SellStopLimit
      else if(button==EnumToString(BUTT_SELL_STOP_LIMIT))
        {
         //--- Get the correct SellStop order price relative to StopLevel
         double price_set_stop=CorrectPricePending(Symbol(),ORDER_TYPE_SELL_STOP,distance_pending);
         //--- Calculate SellLimit order price relative to SellStop level considering StopLevel
         double price_set_limit=CorrectPricePending(Symbol(),ORDER_TYPE_SELL_LIMIT,distance_stoplimit,price_set_stop);
         //--- Get correct StopLoss and TakeProfit prices relative to the order placement level considering StopLevel
          sl=CorrectStopLoss(Symbol(),ORDER_TYPE_SELL_STOP,price_set_limit,stoploss);
         tp=CorrectTakeProfit(Symbol(),ORDER_TYPE_SELL_STOP,price_set_limit,takeprofit);
         //--- Set SellStopLimit order
         #ifdef __MQL5__
            trade.OrderOpen(Symbol(),ORDER_TYPE_SELL_STOP_LIMIT,lot,price_set_limit,price_set_stop,sl,tp);
         #else 
            
         #endif 
        }
      //--- If the BUTT_CLOSE_BUY button is pressed: Close Buy with the maximum profit
      else if(button==EnumToString(BUTT_CLOSE_BUY))
        {
         //--- Get the list of all open positions
         CArrayObj* list=engine.GetListMarketPosition();
         //--- Select only Buy positions from the list
         list=CSelect::ByOrderProperty(list,ORDER_PROP_TYPE,POSITION_TYPE_BUY,EQUAL);
         //--- Sort the list by profit considering commission and swap
         list.Sort(SORT_BY_ORDER_PROFIT_FULL);
         //--- Get the index of the Buy position with the maximum profit
         int index=CSelect::FindOrderMax(list,ORDER_PROP_PROFIT_FULL);
         if(index>WRONG_VALUE)
           {
            COrder* position=list.At(index);
            if(position!=NULL)
              {
               //--- Get the Buy position ticket and close the position by the ticket
               #ifdef __MQL5__
                  trade.PositionClose(position.Ticket());
               #else 
                  PositionClose(position.Ticket(),position.Volume());
               #endif 
              }
           }
        }
      //--- If the BUTT_CLOSE_BUY2 button is pressed: Close the half of the Buy with the maximum profit
      else if(button==EnumToString(BUTT_CLOSE_BUY2))
        {
         //--- Get the list of all open positions
         CArrayObj* list=engine.GetListMarketPosition();
         //--- Select only Buy positions from the list
         list=CSelect::ByOrderProperty(list,ORDER_PROP_TYPE,POSITION_TYPE_BUY,EQUAL);
         //--- Sort the list by profit considering commission and swap
         list.Sort(SORT_BY_ORDER_PROFIT_FULL);
         //--- Get the index of the Buy position with the maximum profit
         int index=CSelect::FindOrderMax(list,ORDER_PROP_PROFIT_FULL);
         if(index>WRONG_VALUE)
           {
            COrder* position=list.At(index);
            if(position!=NULL)
              {
               //--- Calculate the closed volume and close the half of the Buy position by the ticket
               if(engine.IsHedge())
                 {
                  #ifdef __MQL5__
                     trade.PositionClosePartial(position.Ticket(),NormalizeLot(position.Symbol(),position.Volume()/2.0));
                  #else 
                     PositionClose(position.Ticket(),NormalizeLot(position.Symbol(),position.Volume()/2.0));
                  #endif 
                 }
               else
                 {
                  #ifdef __MQL5__
                     trade.Sell(NormalizeLot(position.Symbol(),position.Volume()/2.0));
                  #endif 
                 }
              }
           }
        }
      //--- If the BUTT_CLOSE_BUY_BY_SELL button is pressed: Close Buy with the maximum profit by the opposite Sell with the maximum profit
      else if(button==EnumToString(BUTT_CLOSE_BUY_BY_SELL))
        {
         //--- Get the list of all open positions
         CArrayObj* list_buy=engine.GetListMarketPosition();
         //--- Select only Buy positions from the list
         list_buy=CSelect::ByOrderProperty(list_buy,ORDER_PROP_TYPE,POSITION_TYPE_BUY,EQUAL);
         //--- Sort the list by profit considering commission and swap
         list_buy.Sort(SORT_BY_ORDER_PROFIT_FULL);
         //--- Get the index of the Buy position with the maximum profit
         int index_buy=CSelect::FindOrderMax(list_buy,ORDER_PROP_PROFIT_FULL);
         //--- Get the list of all open positions
         CArrayObj* list_sell=engine.GetListMarketPosition();
         //--- Select only Sell positions from the list
         list_sell=CSelect::ByOrderProperty(list_sell,ORDER_PROP_TYPE,POSITION_TYPE_SELL,EQUAL);
         //--- Sort the list by profit considering commission and swap
         list_sell.Sort(SORT_BY_ORDER_PROFIT_FULL);
         //--- Get the index of the Sell position with the maximum profit
         int index_sell=CSelect::FindOrderMax(list_sell,ORDER_PROP_PROFIT_FULL);
         if(index_buy>WRONG_VALUE && index_sell>WRONG_VALUE)
           {
            //--- Select the Buy position with the maximum profit
            COrder* position_buy=list_buy.At(index_buy);
            //--- Select the Sell position with the maximum profit
            COrder* position_sell=list_sell.At(index_sell);
            if(position_buy!=NULL && position_sell!=NULL)
              {
               //--- Close the Buy position by the opposite Sell one
               #ifdef __MQL5__
                  trade.PositionCloseBy(position_buy.Ticket(),position_sell.Ticket());
               #else 
                  PositionCloseBy(position_buy.Ticket(),position_sell.Ticket());
               #endif 
              }
           }
        }
      //--- If the BUTT_CLOSE_SELL button is pressed: Close Sell with the maximum profit
      else if(button==EnumToString(BUTT_CLOSE_SELL))
        {
         //--- Get the list of all open positions
         CArrayObj* list=engine.GetListMarketPosition();
         //--- Select only Sell positions from the list
         list=CSelect::ByOrderProperty(list,ORDER_PROP_TYPE,POSITION_TYPE_SELL,EQUAL);
         //--- Sort the list by profit considering commission and swap
         list.Sort(SORT_BY_ORDER_PROFIT_FULL);
         //--- Get the index of the Sell position with the maximum profit
         int index=CSelect::FindOrderMax(list,ORDER_PROP_PROFIT_FULL);
         if(index>WRONG_VALUE)
           {
            COrder* position=list.At(index);
            if(position!=NULL)
              {
               //--- Get the Sell position ticket and close the position by the ticket
               #ifdef __MQL5__
                  trade.PositionClose(position.Ticket());
               #else 
                  PositionClose(position.Ticket());
               #endif 
              }
           }
        }
      //--- If the BUTT_CLOSE_SELL2 button is pressed: Close the half of the Sell with the maximum profit
      else if(button==EnumToString(BUTT_CLOSE_SELL2))
        {
         //--- Get the list of all open positions
         CArrayObj* list=engine.GetListMarketPosition();
         //--- Select only Sell positions from the list
         list=CSelect::ByOrderProperty(list,ORDER_PROP_TYPE,POSITION_TYPE_SELL,EQUAL);
         //--- Sort the list by profit considering commission and swap
         list.Sort(SORT_BY_ORDER_PROFIT_FULL);
         //--- Get the index of the Sell position with the maximum profit
         int index=CSelect::FindOrderMax(list,ORDER_PROP_PROFIT_FULL);
         if(index>WRONG_VALUE)
           {
            COrder* position=list.At(index);
            if(position!=NULL)
              {
               //--- Calculate the closed volume and close the half of the Sell position by the ticket
               if(engine.IsHedge())
                 {
                  #ifdef __MQL5__
                     trade.PositionClosePartial(position.Ticket(),NormalizeLot(position.Symbol(),position.Volume()/2.0));
                  #else 
                     PositionClose(position.Ticket(),NormalizeLot(position.Symbol(),position.Volume()/2.0));
                  #endif 
                 }
               else
                 {
                  #ifdef __MQL5__
                     trade.Buy(NormalizeLot(position.Symbol(),position.Volume()/2.0));
                  #endif 
                 }
              }
           }
        }
      //--- If the BUTT_CLOSE_SELL_BY_BUY button is pressed: Close Sell with the maximum profit by the opposite Buy with the maximum profit
      else if(button==EnumToString(BUTT_CLOSE_SELL_BY_BUY))
        {
         //--- Get the list of all open positions
         CArrayObj* list_sell=engine.GetListMarketPosition();
         //--- Select only Sell positions from the list
         list_sell=CSelect::ByOrderProperty(list_sell,ORDER_PROP_TYPE,POSITION_TYPE_SELL,EQUAL);
         //--- Sort the list by profit considering commission and swap
         list_sell.Sort(SORT_BY_ORDER_PROFIT_FULL);
         //--- Get the index of the Sell position with the maximum profit
         int index_sell=CSelect::FindOrderMax(list_sell,ORDER_PROP_PROFIT_FULL);
         //--- Get the list of all open positions
         CArrayObj* list_buy=engine.GetListMarketPosition();
         //--- Select only Buy positions from the list
         list_buy=CSelect::ByOrderProperty(list_buy,ORDER_PROP_TYPE,POSITION_TYPE_BUY,EQUAL);
         //--- Sort the list by profit considering commission and swap
         list_buy.Sort(SORT_BY_ORDER_PROFIT_FULL);
         //--- Get the index of the Buy position with the maximum profit
         int index_buy=CSelect::FindOrderMax(list_buy,ORDER_PROP_PROFIT_FULL);
         if(index_sell>WRONG_VALUE && index_buy>WRONG_VALUE)
           {
            //--- Select the Sell position with the maximum profit
            COrder* position_sell=list_sell.At(index_sell);
            //--- Select the Buy position with the maximum profit
            COrder* position_buy=list_buy.At(index_buy);
            if(position_sell!=NULL && position_buy!=NULL)
              {
               //--- Close the Sell position by the opposite Buy one
               #ifdef __MQL5__
                  trade.PositionCloseBy(position_sell.Ticket(),position_buy.Ticket());
               #else 
                  PositionCloseBy(position_sell.Ticket(),position_buy.Ticket());
               #endif 
              }
           }
        }
      //--- If the BUTT_CLOSE_ALL is pressed: Close all positions starting with the one with the least profit
      else if(button==EnumToString(BUTT_CLOSE_ALL))
        {
         //--- Get the list of all open positions
         CArrayObj* list=engine.GetListMarketPosition();
         if(list!=NULL)
           {
            //--- Sort the list by profit considering commission and swap
            list.Sort(SORT_BY_ORDER_PROFIT_FULL);
            int total=list.Total();
            //--- In the loop from the position with the least profit
            for(int i=0;i<total;i++)
              {
               COrder* position=list.At(i);
               if(position==NULL)
                  continue;
               //--- close each position by its ticket
               #ifdef __MQL5__
                  trade.PositionClose(position.Ticket());
               #else 
                  PositionClose(position.Ticket(),position.Volume());
               #endif 
              }
           }
        }
      //--- If the BUTT_DELETE_PENDING button is pressed: Remove the first pending order
      else if(button==EnumToString(BUTT_DELETE_PENDING))
        {
         //--- Get the list of all orders
         CArrayObj* list=engine.GetListMarketPendings();
         if(list!=NULL)
           {
            //--- Sort the list by placement time
            list.Sort(SORT_BY_ORDER_TIME_OPEN);
            int total=list.Total();
            //--- In the loop from the position with the most amount of time
            for(int i=total-1;i>=0;i--)
              {
               COrder* order=list.At(i);
               if(order==NULL)
                  continue;
               //--- delete the order by its ticket
               #ifdef __MQL5__
                  trade.OrderDelete(order.Ticket());
               #else 
                  PendingOrderDelete(order.Ticket());
               #endif 
              }
           }
        }
      //--- If the BUTT_PROFIT_WITHDRAWAL button is pressed: Withdraw funds from the account
      if(button==EnumToString(BUTT_PROFIT_WITHDRAWAL))
        {
         //--- If the program is launched in the tester
         if(MQLInfoInteger(MQL_TESTER))
           {
            //--- Emulate funds withdrawal
            TesterWithdrawal(withdrawal);
           }
        }
      //--- If the BUTT_SET_STOP_LOSS button is pressed: Place StopLoss to all orders and positions where it is not present
      if(button==EnumToString(BUTT_SET_STOP_LOSS))
        {
         SetStopLoss();
        }
      //--- If the BUTT_SET_TAKE_PROFIT button is pressed: Place TakeProfit to all orders and positions where it is not present
      if(button==EnumToString(BUTT_SET_TAKE_PROFIT))
        {
         SetTakeProfit();
        }
      //--- Wait for 1/10 of a second
      Sleep(100);
      //--- "Unpress" the button (if this is not a trailing button)
      if(button!=EnumToString(BUTT_TRAILING_ALL))
         ButtonState(button_name,false);
      //--- If the BUTT_TRAILING_ALL button is pressed
      else
        {
         //--- Set the color of the active button
         ButtonState(button_name,true);
         trailing_on=true;
        }
      //--- re-draw the chart
      ChartRedraw();
     }
   //--- Return the inactive button color (if this is a trailing button)
   else if(button==EnumToString(BUTT_TRAILING_ALL))
     {
      ButtonState(button_name,false);
      trailing_on=false;
      //--- re-draw the chart
      ChartRedraw();
     }
  }
//+------------------------------------------------------------------+
//| Set StopLoss to all orders and positions                         |
//+------------------------------------------------------------------+
void SetStopLoss(void)
  {
   if(stoploss_to_modify==0)
      return;
//--- Set StopLoss to all positions where it is absent
   CArrayObj* list=engine.GetListMarketPosition();
   list=CSelect::ByOrderProperty(list,ORDER_PROP_SL,0,EQUAL);
   if(list==NULL)
      return;
   int total=list.Total();
   for(int i=total-1;i>=0;i--)
     {
      COrder* position=list.At(i);
      if(position==NULL)
         continue;
     sl=CorrectStopLoss(position.Symbol(),position.TypeByDirection(),0,stoploss_to_modify);
      #ifdef __MQL5__
         trade.PositionModify(position.Ticket(),sl,position.TakeProfit());
      #else 
         PositionModify(position.Ticket(),sl,position.TakeProfit());
      #endif 
     }
//--- Set StopLoss to all pending orders where it is absent
   list=engine.GetListMarketPendings();
   list=CSelect::ByOrderProperty(list,ORDER_PROP_SL,0,EQUAL);
   if(list==NULL)
      return;
   total=list.Total();
   for(int i=total-1;i>=0;i--)
     {
      COrder* order=list.At(i);
      if(order==NULL)
         continue;
      sl=CorrectStopLoss(order.Symbol(),(ENUM_ORDER_TYPE)order.TypeOrder(),order.PriceOpen(),stoploss_to_modify);
      #ifdef __MQL5__
         trade.OrderModify(order.Ticket(),order.PriceOpen(),sl,order.TakeProfit(),trade.RequestTypeTime(),trade.RequestExpiration(),order.PriceStopLimit());
      #else 
         PendingOrderModify(order.Ticket(),order.PriceOpen(),sl,order.TakeProfit());
      #endif 
     }
  }
//+------------------------------------------------------------------+
//| Set TakeProfit to all orders and positions                       |
//+------------------------------------------------------------------+
void SetTakeProfit(void)
  {
   if(takeprofit_to_modify==0)
      return;
//--- Set TakeProfit to all positions where it is absent
   CArrayObj* list=engine.GetListMarketPosition();
   list=CSelect::ByOrderProperty(list,ORDER_PROP_TP,0,EQUAL);
   if(list==NULL)
      return;
   int total=list.Total();
   for(int i=total-1;i>=0;i--)
     {
      COrder* position=list.At(i);
      if(position==NULL)
         continue;
     tp=CorrectTakeProfit(position.Symbol(),position.TypeByDirection(),0,takeprofit_to_modify);
      #ifdef __MQL5__
         trade.PositionModify(position.Ticket(),position.StopLoss(),tp);
      #else 
         PositionModify(position.Ticket(),position.StopLoss(),tp);
      #endif 
     }
//--- Set TakeProfit to all pending orders where it is absent
   list=engine.GetListMarketPendings();
   list=CSelect::ByOrderProperty(list,ORDER_PROP_TP,0,EQUAL);
   if(list==NULL)
      return;
   total=list.Total();
   for(int i=total-1;i>=0;i--)
     {
      COrder* order=list.At(i);
      if(order==NULL)
         continue;
      tp=CorrectTakeProfit(order.Symbol(),(ENUM_ORDER_TYPE)order.TypeOrder(),order.PriceOpen(),takeprofit_to_modify);
      #ifdef __MQL5__
         trade.OrderModify(order.Ticket(),order.PriceOpen(),order.StopLoss(),tp,trade.RequestTypeTime(),trade.RequestExpiration(),order.PriceStopLimit());
      #else 
         PendingOrderModify(order.Ticket(),order.PriceOpen(),order.StopLoss(),tp);
      #endif 
     }
  }
//+------------------------------------------------------------------+
//| Trailing stop of a position with the maximum profit              |
//+------------------------------------------------------------------+
void TrailingPositions(void)
  {
   
   if(!SymbolInfoTick(Symbol(),tick))
      return;
   double stop_level=StopLevel(Symbol(),2)*Point();
   //--- Get the list of all open positions
   CArrayObj* list=engine.GetListMarketPosition();
   //--- Select only Buy positions from the list
   CArrayObj* list_buy=CSelect::ByOrderProperty(list,ORDER_PROP_TYPE,POSITION_TYPE_BUY,EQUAL);
   //--- Sort the list by profit considering commission and swap
   list_buy.Sort(SORT_BY_ORDER_PROFIT_FULL);
   //--- Get the index of the Buy position with the maximum profit
   int index_buy=CSelect::FindOrderMax(list_buy,ORDER_PROP_PROFIT_FULL);
   if(index_buy>WRONG_VALUE)
     {
      COrder* buy=list_buy.At(index_buy);
      if(buy!=NULL)
        {
         //--- Calculate the new StopLoss
         sl=NormalizeDouble(tick.bid-trailing_stop,Digits());
         //--- If the price and the StopLevel based on it are higher than the new StopLoss (the distance by StopLevel is maintained)
         if(tick.bid-stop_level>sl) 
           {
            //--- If the new StopLoss level exceeds the trailing step based on the current StopLoss
            if(buy.StopLoss()+trailing_step<sl)
              {
               //--- If we trail at any profit or position profit in points exceeds the trailing start, modify StopLoss
               if(trailing_start==0 || buy.ProfitInPoints()>(int)trailing_start)
                 {
                  #ifdef __MQL5__
                     trade.PositionModify(buy.Ticket(),sl,buy.TakeProfit());
                  #else 
                     PositionModify(buy.Ticket(),sl,buy.TakeProfit());
                  #endif 
                 }
              }
           }
        }
     }
   //--- Select only Sell positions from the list
   CArrayObj* list_sell=CSelect::ByOrderProperty(list,ORDER_PROP_TYPE,POSITION_TYPE_SELL,EQUAL);
   //--- Sort the list by profit considering commission and swap
   list_sell.Sort(SORT_BY_ORDER_PROFIT_FULL);
   //--- Get the index of the Sell position with the maximum profit
   int index_sell=CSelect::FindOrderMax(list_sell,ORDER_PROP_PROFIT_FULL);
   if(index_sell>WRONG_VALUE)
     {
      COrder* sell=list_sell.At(index_sell);
      if(sell!=NULL)
        {
         //--- Calculate the new StopLoss
         sl=NormalizeDouble(tick.ask+trailing_stop,Digits());
         //--- If the price and StopLevel based on it are below the new StopLoss (the distance by StopLevel is maintained)
         if(tick.ask+stop_level<sl) 
           {
            //--- If the new StopLoss level is below the trailing step based on the current StopLoss or a position has no StopLoss
            if(sell.StopLoss()-trailing_step>sl || sell.StopLoss()==0)
              {
               //--- If we trail at any profit or position profit in points exceeds the trailing start, modify StopLoss
               if(trailing_start==0 || sell.ProfitInPoints()>(int)trailing_start)
                 {
                  #ifdef __MQL5__
                     trade.PositionModify(sell.Ticket(),sl,sell.TakeProfit());
                  #else 
                     PositionModify(sell.Ticket(),sl,sell.TakeProfit());
                  #endif 
                 }
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Trailing the farthest pending orders                             |
//+------------------------------------------------------------------+
void TrailingOrders(void)
  {
  
   if(!SymbolInfoTick(Symbol(),tick))
      return;
   double stop_level=StopLevel(Symbol(),2)*Point();
//--- Get the list of all placed orders
   CArrayObj* list=engine.GetListMarketPendings();
//--- Select only Buy orders from the list
   CArrayObj* list_buy=CSelect::ByOrderProperty(list,ORDER_PROP_DIRECTION,ORDER_TYPE_BUY,EQUAL);
   //--- Sort the list by distance from the price in points (by profit in points)
   list_buy.Sort(SORT_BY_ORDER_PROFIT_PT);
   //--- Get the index of the Buy order with the greatest distance
   int index_buy=CSelect::FindOrderMax(list_buy,ORDER_PROP_PROFIT_PT);
   if(index_buy>WRONG_VALUE)
     {
      COrder* buy=list_buy.At(index_buy);
      if(buy!=NULL)
        {
         //--- If the order is below the price (BuyLimit) and it should be "elevated" following the price
         if(buy.TypeOrder()==ORDER_TYPE_BUY_LIMIT)
           {
            //--- Calculate the new order price and stop levels based on it
            price=NormalizeDouble(tick.ask-trailing_stop,Digits());
            sl=(buy.StopLoss()>0 ? NormalizeDouble(price-(buy.PriceOpen()-buy.StopLoss()),Digits()) : 0);
            tp=(buy.TakeProfit()>0 ? NormalizeDouble(price+(buy.TakeProfit()-buy.PriceOpen()),Digits()) : 0);
            //--- If the calculated price is below the StopLevel distance based on Ask order price (the distance by StopLevel is maintained)
            if(price<tick.ask-stop_level) 
              {
               //--- If the calculated price exceeds the trailing step based on the order placement price, modify the order price
               if(price>buy.PriceOpen()+trailing_step)
                 {
                  #ifdef __MQL5__
                     trade.OrderModify(buy.Ticket(),price,sl,tp,trade.RequestTypeTime(),trade.RequestExpiration(),buy.PriceStopLimit());
                  #else 
                     PendingOrderModify(buy.Ticket(),price,sl,tp);
                  #endif 
                 }
              }
           }
         //--- If the order exceeds the price (BuyStop and BuyStopLimit), and it should be "decreased" following the price
         else
           {
            //--- Calculate the new order price and stop levels based on it
           price=NormalizeDouble(tick.ask+trailing_stop,Digits());
             sl=(buy.StopLoss()>0 ? NormalizeDouble(price-(buy.PriceOpen()-buy.StopLoss()),Digits()) : 0);
            tp=(buy.TakeProfit()>0 ? NormalizeDouble(price+(buy.TakeProfit()-buy.PriceOpen()),Digits()) : 0);
            //--- If the calculated price exceeds the StopLevel based on Ask order price (the distance by StopLevel is maintained)
            if(price>tick.ask+stop_level) 
              {
               //--- If the calculated price is lower than the trailing step based on order price, modify the order price
               if(price<buy.PriceOpen()-trailing_step)
                 {
                  #ifdef __MQL5__
                     trade.OrderModify(buy.Ticket(),price,sl,tp,trade.RequestTypeTime(),trade.RequestExpiration(),(buy.PriceStopLimit()>0 ? price-distance_stoplimit*Point() : 0));
                  #else 
                     PendingOrderModify(buy.Ticket(),price,sl,tp);
                  #endif 
                 }
              }
           }
        }
     }
//--- Select only Sell order from the list
   CArrayObj* list_sell=CSelect::ByOrderProperty(list,ORDER_PROP_DIRECTION,ORDER_TYPE_SELL,EQUAL);
   //--- Sort the list by distance from the price in points (by profit in points)
   list_sell.Sort(SORT_BY_ORDER_PROFIT_PT);
   //--- Get the index of the Sell order having the greatest distance
   int index_sell=CSelect::FindOrderMax(list_sell,ORDER_PROP_PROFIT_PT);
   if(index_sell>WRONG_VALUE)
     {
      COrder* sell=list_sell.At(index_sell);
      if(sell!=NULL)
        {
         //--- If the order exceeds the price (SellLimit), and it needs to be "decreased" following the price
         if(sell.TypeOrder()==ORDER_TYPE_SELL_LIMIT)
           {
            //--- Calculate the new order price and stop levels based on it
            price=NormalizeDouble(tick.bid+trailing_stop,Digits());
            sl=(sell.StopLoss()>0 ? NormalizeDouble(price+(sell.StopLoss()-sell.PriceOpen()),Digits()) : 0);
            tp=(sell.TakeProfit()>0 ? NormalizeDouble(price-(sell.PriceOpen()-sell.TakeProfit()),Digits()) : 0);
            //--- If the calculated price exceeds the StopLevel distance based on the Bid order price (the distance by StopLevel is maintained)
            if(price>tick.bid+stop_level) 
              {
               //--- If the calculated price is lower than the trailing step based on order price, modify the order price
               if(price<sell.PriceOpen()-trailing_step)
                 {
                  #ifdef __MQL5__
                     trade.OrderModify(sell.Ticket(),price,sl,tp,trade.RequestTypeTime(),trade.RequestExpiration(),sell.PriceStopLimit());
                  #else 
                     PendingOrderModify(sell.Ticket(),price,sl,tp);
                  #endif 
                 }
              }
           }
         //--- If the order is below the price (SellStop and SellStopLimit), and it should be "elevated" following the price
         else
           {
            //--- Calculate the new order price and stop levels based on it
          price=NormalizeDouble(tick.bid-trailing_stop,Digits());
            sl=(sell.StopLoss()>0 ? NormalizeDouble(price+(sell.StopLoss()-sell.PriceOpen()),Digits()) : 0);
             tp=(sell.TakeProfit()>0 ? NormalizeDouble(price-(sell.PriceOpen()-sell.TakeProfit()),Digits()) : 0);
            //--- If the calculated price is below the StopLevel distance based on the Bid order price (the distance by StopLevel is maintained)
            if(price<tick.bid-stop_level) 
              {
               //--- If the calculated price exceeds the trailing step based on the order placement price, modify the order price
               if(price>sell.PriceOpen()+trailing_step)
                 {
                  #ifdef __MQL5__
                     trade.OrderModify(sell.Ticket(),price,sl,tp,trade.RequestTypeTime(),trade.RequestExpiration(),(sell.PriceStopLimit()>0 ? price+distance_stoplimit*Point() : 0));
                  #else 
                     PendingOrderModify(sell.Ticket(),price,sl,tp);
                  #endif 
                 }
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|   GetCustomInfo                                                  |
//+------------------------------------------------------------------+
void GetCustomInfo(CustomInfo &info,
                   const int _error_code,
                   const ENUM_LANGUAGES _lang)
{
   switch(_error_code)
   {
#ifdef __MQL5__
   case ERR_FUNCTION_NOT_ALLOWED:
      info.text1 = (_lang==LANGUAGE_EN)?"The URL does not allowed for WebRequest":"Этого URL нет в списке для WebRequest.";
      info.text2 = TELEGRAM_BASE_URL;
      break;
#endif
#ifdef __MQL4__
   case ERR_FUNCTION_NOT_CONFIRMED:
      info.text1 = (_lang==LANGUAGE_EN)?"The URL does not allowed for WebRequest":"Этого URL нет в списке для WebRequest.";
      info.text2 = TELEGRAM_BASE_URL;
      break;
#endif

   case ERR_TOKEN_ISEMPTY:
      info.text1 = (_lang==LANGUAGE_EN)?"The 'Token' parameter is empty.":"Параметр 'Token' пуст.";
      info.text2 = (_lang==LANGUAGE_EN)?"Please fill this parameter.":"Пожалуйста задайте значение для этого параметра.";
      break;
   }

}