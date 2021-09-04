//+------------------------------------------------------------------+
//|                                                     Telegram.mqh |
//|                        Copyright 2021, Noel Martial Nguemechieu. |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Noel Martial Nguemechieu."
#property link      "http://www.mql5.com"
#property strict

//+------------------------------------------------------------------+
//|   Include                                                        |
//+------------------------------------------------------------------+
#include <Arrays\List.mqh>
#include <Arrays\ArrayString.mqh>
#include <DiscordTelegram/Common.mqh>
#include <DiscordTelegram/Jason.mqh>

#include <DiscordTelegram/Comment.mqh>
//+------------------------------------------------------------------+
#define EXPERT_NAME     "Discord_Telegram Client Bot"
#define EXPERT_VERSION  "1.00"
#property version       EXPERT_VERSION
#define CAPTION_COLOR   clrWhite
#define LOSS_COLOR      clrOrangeRed
#define SEARCH_URL      "https://www.google.com"
//---
#define BUTTON_TOP      "\xF51D"
#define BUTTON_LEFT     "\x25C0"
#define BUTTON_RIGHT    "\x25B6"
//---
#define RADIO_SELECT    "\xF518"
#define RADIO_EMPTY     "\x26AA"
//---
#define CHECK_SELECT    "\xF533"
#define CHECK_EMPTY     "\x25FB"
//---
#define MENU_LANGUAGES  "Languages"
#define MENU_MODULES    "Modules"
//---
#define LANG_EN 0
#define LANG_FR 1
#define LANG_RU 2
#define LANG_ZH 3
#define LANG_ES 4
#define LANG_DE 5
#define LANG_JA 6

//---
#define ACCOUNT_INFOS   0x001
#define TRADE    0x002
#define TRADES_REPORT   0x004
#define MARKET_ANALYSIS   0x008
#define MODULE_EXPERT     0x010
#define MODULE_FOREX_MARKET       0x020
#define MODULE_CRYPO_MARKET     0x040
#define MODULE_SIGNALS    0x080
#define MODULE_BLOGS      0x100
#define HELP     0x121












 string msg="None";
//+------------------------------------------------------------------+
//|   Input parameters                                               |
//+----------------------------------------------------------------
input ENUM_LANGUAGES    InpLanguage=LANGUAGE_EN;//Language
input ENUM_UPDATE_MODE  InpUpdateMode=UPDATE_NORMAL;//Update
input string  LicenseKey="Enter your licence key here";
input string Platform="T";
input string Name="";
//Discord input
extern const  string Discord_Parameters="===================Discord=====================================";

input string Discord_Token="Enter discord token here";
input string Discord_Channel_Name="Enter discord channel name here";

extern const string Telegram_Parameters="===================Telegram====================================";


input string Telegram_Token="1934022436:AAHkm7xefpM-JlZdq8zepnTgVpNygrvCgTo";//Token";
input string Telegram_Channel_Name="GoldMiner307";
input const string s="======================================================================================";
input int TimeFrame=4;
input string IndicatorList="Bollinger Bands,THE_ATM_INDICATOR_FX_master,THE_ATM_INDICATOR_FX_master(1),4xgoddess_Zones_master,ADX,Momentum,RSI,ATR,Parabolic SAR,MACD,CCI,stochastic,Ichimoku,None";//Templates
input const string IndicatorName="Bollinger Bands";
CComment       comment;
ENUM_RUN_MODE  run_mode;
datetime       time_check;
int            web_error;
int            init_error;
string         photo_id=NULL;
//+------------------------------------------------------------------+
//|   Defines                                                        |
//+------------------------------------------------------------------+
#define TELEGRAM_BASE_URL  "https://api.telegram.org"
#define WEB_TIMEOUT        5000
//+------------------------------------------------------------------+
//|   ENUM_CHAT_ACTION                                               |
//+------------------------------------------------------------------+

const ENUM_TIMEFRAMES _periods[] = {PERIOD_M1,PERIOD_M5,PERIOD_M15,PERIOD_M30,PERIOD_H1,PERIOD_H4,PERIOD_D1,PERIOD_W1,PERIOD_MN1};



enum ENUM_CHAT_ACTION
{
   ACTION_FIND_LOCATION,   //picking location...
   ACTION_RECORD_AUDIO,    //recording audio...
   ACTION_RECORD_VIDEO,    //recording video...
   ACTION_TYPING,          //typing...
   ACTION_UPLOAD_AUDIO,    //sending audio...
   ACTION_UPLOAD_DOCUMENT, //sending file...
   ACTION_UPLOAD_PHOTO,    //sending photo...
   ACTION_UPLOAD_VIDEO ,
   
   ACTION_OPEN_BUY,
   ACTION_OPEN_SELL,
   
   ACTION_CLOSE_BUY,
   ACTION_CLOSE_SELL,
   ACTION_NO_TRADE_NOW,
   ACTION_OPEN_SAFE_TRADE,
   ACTION_OPEN_PENDING_ORDERS,
   ACTION_OPEN_ORDERS_CLOSE,
   ACTION_OPEN_LIMIT_ORDER,
   ACTION_CLOSE_LIMIT_ORDER,
   ACTION_CLOSE_PENDING_ORDERS,
   ACTION_CLOSE_ALL_OPEN_POSITIONS
   
       //sending video...
};

      
//+------------------------------------------------------------------+
//|   ChatActionToString                                             |
//+------------------------------------------------------------------+
string ChatActionToString(const ENUM_CHAT_ACTION _action)
{
   string result=EnumToString(_action);
   result=StringSubstr(result,7);
   StringToLower(result);
   return(result);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CCustomMessage : public CObject
{
public:
   bool              done;
   long              update_id;
   long              message_id;
   //---
   long              from_id;
   string            from_first_name;
   string            from_last_name;
   string            from_username;
   //---
   long              chat_id;
   string            chat_first_name;
   string            chat_last_name;
   string            chat_username;
   string            chat_type;
   //---
   datetime          message_date;
   string            message_text;

                     CCustomMessage()
   {
      done=false;
      update_id=0;
      message_id=0;
      from_id=0;
      from_first_name=NULL;
      from_last_name=NULL;
      from_username=NULL;
      chat_id=0;
      chat_first_name=NULL;
      chat_last_name=NULL;
      chat_username=NULL;
      chat_type=NULL;
      message_date=0;
      message_text=NULL;
      from_id=0;
      from_first_name=NULL;
      from_last_name=NULL;
      from_username=NULL;
      chat_id=0;
      chat_first_name=NULL;
      chat_last_name=NULL;
      chat_username=NULL;
      chat_type=NULL;
      message_date=0;
      message_text=NULL;
   }

};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CCustomChat : public CObject
{
public:
   long              m_id;
   CCustomMessage    m_last;
   CCustomMessage    m_new_one;
   int               m_state;
   datetime          m_time;
};

//Create custom message
CCustomMessage msgs;
//+------------------------------------------------------------------+
//|   TelegramBot                                                     |
//+------------------------------------------------------------------+
class TelegramBot 

{




private:
   ENUM_LANGUAGES    m_lang;
   string            m_symbol;
   ENUM_TIMEFRAMES   m_period;
   string            m_template;
   CArrayString      m_templates;

public:


   //+------------------------------------------------------------------+
   void              Language(const ENUM_LANGUAGES _lang)
   {
      m_lang=_lang;
   }

   //+------------------------------------------------------------------+
   int               Templatess(const string _list)
   {
      m_templates.Clear();
      //--- parsing
      string text=StringTrim(_list);
      if(text=="")
         return(0);

      //---
      while(StringReplace(text,"  "," ")>0);
      StringReplace(text,";"," ");
      StringReplace(text,","," ");

      //---
      string array[];
      int amount=StringSplit(text,' ',array);
      amount=fmin(amount,25);

      for(int i=0; i<amount; i++)
      {
         array[i]=StringTrim(array[i]);
         if(array[i]!="")
            m_templates.Add(array[i]);
      }

      return(amount);
   }

   //+------------------------------------------------------------------+
   int               SendScreenShot(const string _chat_id,
                                    const string _symbol,
                                    const ENUM_TIMEFRAMES m_period2,
                                    const string _templatess)
   {
      int result=0;

      long chart_id=ChartOpen(_symbol,m_period2);
      if(chart_id==0)
         return(ERR_CHART_NOT_FOUND);

      ChartSetInteger(ChartID(),CHART_BRING_TO_TOP,true);

      //--- updates chart
      int wait=30;
      while(--wait>0)
      {
    
         if(SeriesInfoInteger(_symbol,m_period2,SERIES_SYNCHRONIZED))
            break;
         Sleep(1000);
      }
                       
      if(_templatess!=NULL)
         if(!ChartApplyTemplate(chart_id,m_template))
            Comment(_LastError,InpLanguage);

      ChartRedraw(chart_id);
      Sleep(30);

      ChartSetInteger(chart_id,CHART_SHOW_GRID,false);

      ChartSetInteger(chart_id,CHART_SHOW_PERIOD_SEP,false);

      string filename=StringFormat("%s%d.gif",_symbol,m_period2);

      if(FileIsExist(filename))
         FileDelete(filename);
      ChartRedraw(chart_id);

      Sleep(30);

      if(ChartScreenShot(chart_id,filename,800,600,ALIGN_RIGHT))
      {
         
         Sleep(2000);
         
         //--- Need for MT4 on weekends !!!
         ChartRedraw(chart_id);
         
       bot. SendChatAction(chart_id,ACTION_UPLOAD_PHOTO);

         //--- waitng 30 sec for save screenshot
         wait=30;
         while(!FileIsExist(filename) && --wait>0)
            Sleep(30);

         //---
         if(FileIsExist(filename))
         {
            string screen_id;
            result=SendPhoto(screen_id,_chat_id,filename,_symbol+"_"+StringSubstr(EnumToString(m_period),7));
         }
         else
         {
            string mask=m_lang==LANGUAGE_EN?"Screenshot file '%s' not created.":"Файл скриншота '%s' не создан.";
            PrintFormat(mask,filename);
            SendMessage(msgs.chat_id,mask +filename);
         }
      }

      ChartClose(chart_id);
      return(result);
   }

 
 
 
  //+------------------------------------------------------------------+
   void              ProcessMessages(void)
   {
#define EMOJI_TOP    "\xF51D"
#define EMOJI_BACK   "\xF519"
#define KEYB_MAIN    (m_lang==LANGUAGE_EN)?"[[\"/AccountInfo\"],[\"/ordertrade\"],[\"/historytotal\"],[\"/ticket\"],[\"/Quotes\"],[\"/Charts\"],[\"/MarketAnalysis\"],[\"/Trade\"],[\"/TradeReport\"],[\"/News\"],[\"/CryptoMarket\"],[\"/help\"]]":"[[\"Информация\"],[\"Котировки\"],[\"Графики\"]]"
#define KEYB_SYMBOLS "[[\""+EMOJI_TOP+"\",\"GBPUSD\",\"EURUSD\"], [\"AUDUSD\",\"CADCHF\",\"EURJPY\"],[\"USDCAD\",\"EURDKK\",\"EURCHF\"], [\"AUDCAD\",\"EURNZD\",\"EURJPY\"],[\"AUDCHF\",\"EURSEK\",\"EURCAD\"],[\"AUDHKD\",\"NZDCHF\",\"GBPCAD\"],[\"AUDJPY\",\"NZDJPY\",\"USDCHF\"],[\"AUDCAD\",\"USDJPY\",\"GBPUSD\",\""+EMOJI_BACK+"\"]]"
#define KEYB_PERIODS "[[\""+EMOJI_TOP+"\",\"M1\",\"M5\",\"M15\"],\"M30\",\"H1\",\"H4\"],[\" \",\"D1\",\"W1\",\"MN1\",\""+EMOJI_BACK+"\"]]"
#define KEYS_TRADE   "[[\""+EMOJI_TOP+"\",[\"/BUY\"],[\"/SELL\",[\"/BUYLIMIT\"],[\"/SELLLIMIT\"],[\"/BUYSTOP\"],[\"/SELLSTTOP\"],\""+EMOJI_TOP+"\"]]"
#define  NL "\n"  

      msg=NL;
      const string strOrderTrade="/ordertrade";
      const string strHistoryTicket="/historyticket";
      int pos=0, ticket=0;
  
  





 for(int i=0; i<m_chats.Total(); i++)
      {
         CCustomChat *chat=m_chats.GetNodeAtIndex(i);
         if(!chat.m_new_one.done)
         {
            chat.m_new_one.done=true;
            string text=chat.m_new_one.message_text;
            
            
            
            
            
            
            
            
            if( text=="/ordertotal" ) {
               SendMessage( chat.m_id, BotOrdersTotal() );
            }
            
            if( StringFind( text, strOrderTrade )>=0 ) {
               pos =(int) StringToInteger( StringSubstr( text, StringLen(strOrderTrade)+1 ) );
               SendMessage( chat.m_id, BotOrdersTrade(pos) );
            }

            if( text=="/historytotal" ) {
               SendMessage( chat.m_id, BotOrdersHistoryTotal() );
            }

            if( StringFind( text, strHistoryTicket )>=0 ) {
               ticket = (int)StringToInteger( StringSubstr( text, StringLen(strHistoryTicket)+1 ) );
               SendMessage( chat.m_id, BotHistoryTicket(ticket) );
            }
            
            if( text=="/account"|| text=="/AccountInfo" ||text=="/accountinfo" ) {
               SendMessage( chat.m_id, BotAccount() );
            }
            
            
            //---
            if(text=="/quotes" || text=="Quotes" || text=="Котировки")
            {   chat.m_state=2;
              
              msg=(m_lang==LANGUAGE_EN)?"##################QUOTES####################\nEnter a symbol name like this 'EURUSD'":"Введите название инструмента, например 'EURUSD'";
               bot.SendMessage(msgs.chat_id,msg,ReplyKeyboardMarkup(KEYB_SYMBOLS,false,false));
               continue;
            }

            //---
            if(text=="/charts" || text=="Charts" || text=="Графики")
            {
                chat.m_state=3;
               msg=(m_lang==LANGUAGE_EN)?"Charts\nEnter a symbol name like 'EURUSD'":"Введите название инструмента, например 'EURUSD'";
              bot. SendMessage(chat.m_id,msg,ReplyKeyboardMarkup(KEYB_SYMBOLS,false,false));
             continue;
             
             }
               
               
               
                  //---
            if(text=="/MarketAnalysis" || text=="marketanalysis" || text=="Графики")
            {chat.m_state=4;
              
               msg=(m_lang==LANGUAGE_EN)?"MARKET ANALYSIS\nEnter a symbol name like 'EURUSD'":"Введите название инструмента, например 'EURUSD'";
              bot. SendMessage(chat.m_id,msg,ReplyKeyboardMarkup(KEYB_SYMBOLS,false,false));
               continue;
            }
               
                  //---
            if(text=="/Trade" || text=="\trade" || text=="Графики")
            {chat.m_state=5;
              
               msg=(m_lang==LANGUAGE_EN)?"Enter a symbol name like 'EURUSD'":"Введите название инструмента, например 'EURUSD'";
              bot. SendMessage(chat.m_id,msg,ReplyKeyboardMarkup(KEYB_SYMBOLS,false,false));
            
               
              
               continue;
            }
            
               //---
            if(text=="/TradeReport" || text=="tradereport" || text=="Графики")
            {
             chat.m_state=6;
               msg=(m_lang==LANGUAGE_EN)?"Here is your trade report":"Введите название инструмента, например 'EURUSD'";
              bot. SendMessage(chat.m_id,msg,ReplyKeyboardMarkup(EMOJI_TOP,false,false));
               continue;
            }
            
            
             if(text=="/CryptoMarket" )
            {
             chat.m_state=7;
               msg=(m_lang==LANGUAGE_EN)?"Here is your CryptoMarket ":"Введите название инструмента, например 'EURUSD'";
              bot. SendMessage(chat.m_id,msg,ReplyKeyboardMarkup(KEYS_TRADE,false,false));
               continue;
            }
            
             
            
            
 if(text=="/News" || text=="news" || text=="Графики")
            {
             chat.m_state=8;
               msg=(m_lang==LANGUAGE_EN)?"Here is your Market news":"Введите название инструмента, например 'EURUSD'";
              bot. SendMessage(chat.m_id,msg,ReplyKeyboardMarkup(EMOJI_TOP,false,false));
               continue;
            }
            
             
            
            



            //---
            if(text==EMOJI_TOP)
            {
               chat.m_state=0;
              msg=(m_lang==LANGUAGE_EN)?"Choose a menu item":"Выберите пункт меню";
               bot.SendMessage(chat.m_id,msg,ReplyKeyboardMarkup(KEYB_MAIN,false,false));
               continue;
            }

            //---
            if(text==EMOJI_BACK)
            { 
               if(chat.m_state==31)
               {
                  chat.m_state=8;
                 msg=(m_lang==LANGUAGE_EN)?"Enter a symbol name like 'EURUSD'":"Введите название инструмента, например 'EURUSD'";
                 bot. SendMessage(chat.m_id,msg,ReplyKeyboardMarkup(KEYB_SYMBOLS,false,false));
               }
               else if(chat.m_state==32)
               {
                  chat.m_state=31;
                  msg=(m_lang==LANGUAGE_EN)?"Select a timeframe like 'H1'":"Введите период графика, например 'H1'";
                  bot.SendMessage(chat.m_id,msg,ReplyKeyboardMarkup(KEYB_PERIODS,false,false));
               }
               else
               {
                  
                  msg=(m_lang==LANGUAGE_EN)?"Choose a menu item":"Выберите пункт меню";
                 bot. SendMessage(chat.m_id,msg,ReplyKeyboardMarkup(KEYB_MAIN,false,false));
               }
               continue;
            }

     
       
            
          
            //--- Quotes
            if(chat.m_state==2)
            {
               string mask=(m_lang==LANGUAGE_EN)?"Invalid symbol name '%s'":"Инструмент '%s' не найден";
               msg=StringFormat(mask,text);
               StringToUpper(text);
               string symbol=text;
               if(SymbolSelect(symbol,true))
               {
                  double open[1]= {0};

                  m_symbol=symbol;
                  //--- upload history
                  for(int k=0; k<100; k++)
                  {
#ifdef __MQL4__
                     double array[][100];
                     ArrayCopyRates(array,symbol,PERIOD_D1);
#endif

                     Sleep(30);
                     CopyOpen(symbol,PERIOD_D1,0,1,open);
                     if(open[0]>0.0)
                        break;
                  }

                  int digits=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);
                  double bid=SymbolInfoDouble(symbol,SYMBOL_BID);

                  CopyOpen(symbol,PERIOD_D1,0,1,open);
                  if(open[0]>0.0)
                  {
                     double percent=100*(bid-open[0])/open[0];
                     //--- sign
                     string sign=ShortToString(0x25B2);
                     if(percent<0.0)
                        sign=ShortToString(0x25BC);

                     msg=StringFormat("%s: %s %s (%s%%)",symbol,DoubleToString(bid,digits),sign,DoubleToString(percent,2));
                  }
                  else
                  {
                     msg=(m_lang==LANGUAGE_EN)?"No history for ":"Нет истории для "+symbol;
                  }
               }

               bot.SendMessage(chat.m_id,msg,ReplyKeyboardMarkup(KEYB_SYMBOLS,false,false));
               continue;
            }

            //--- Charts
            if(chat.m_state==3)
            {

               StringToUpper(text);
               string symbol=text;
               if(SymbolSelect(symbol,true))
               {
                  m_symbol=symbol;

                  chat.m_state=31;
                  msg=(m_lang==LANGUAGE_EN)?"Select a Timeframe like 0 for '5Min 1 for 15 min 2 for 30 min etc... '":"Введите период графика, например 'H1'";
                  bot.SendMessage(chat.m_id,msg,ReplyKeyboardMarkup(KEYB_PERIODS,false,false));
               }
               else
               {
                  string mask=(m_lang==LANGUAGE_EN)?"Invalid symbol name '%s'":"Инструмент '%s' не найден";
                  msg=StringFormat(mask,text);
                 bot. SendMessage(chat.m_id,msg,ReplyKeyboardMarkup(EMOJI_BACK,false,false));
               }
               continue;
            }
           if(chat.m_state==4){
            
              
            
            
            msg=StringFormat("%s", "############################################\nHere is your Market Analysis \nwww.tradingview.com");
                 bot. SendMessage(chat.m_id,msg,ReplyKeyboardMarkup(EMOJI_TOP,false,false));
           
            
     
            }
            
            
            if(chat.m_state==5){
            
            
            msg=StringFormat("%s", "############################################\nTRADE STATION  #####\n");
                 bot. SendMessage(chat.m_id,msg,ReplyKeyboardMarkup(KEYS_TRADE,false,false));
            
            
              if(text!=(string)EMPTY_VALUE){
               msg=(m_lang==LANGUAGE_EN)?"Press Buy or Sell":"Введите название инструмента, например 'EURUSD'";
              bot. SendMessage(chat.m_id,msg,ReplyKeyboardMarkup(KEYS_TRADE,false,false));
            
             
              }
      
            }




            if(chat.m_state==5){
            
            
            msg=StringFormat("%s", "############################################\nTRADE STATION  #####\n");
                 bot. SendMessage(chat.m_id,msg,ReplyKeyboardMarkup(KEYS_TRADE,false,false));
   
            }

            if(chat.m_state==6){
            
            
            msg=StringFormat("%s", "############################################\nTRADE STATION  #####\n");
                 bot. SendMessage(chat.m_id,msg,ReplyKeyboardMarkup(KEYS_TRADE,false,false));
            
           
            }


            if(chat.m_state==7){
            
            
            msg=StringFormat("%s", "############################################\nTRADE STATION  #####");
                 bot. SendMessage(chat.m_id,msg,ReplyKeyboardMarkup(KEYS_TRADE,false,false));
            
        
            }


            if(chat.m_state==8){
            
            
            msg=StringFormat("%s", "############################################\nEND#####");
                 bot. SendMessage(chat.m_id,msg,ReplyKeyboardMarkup(EMOJI_TOP,false,false));
            
           
           }
           

            //Charts->Periods
            if(chat.m_state==31)
            {
               bool found=false;
               int total=ArraySize(_periods);
               for(int k=0; k<total; k++)
               {
                  string str_tf=StringSubstr(EnumToString(_periods[k]),7);
                  if(StringCompare(str_tf,text,false)==0)
                  {
                     m_period=_periods[k];
                     found=true;
                     break;
                  }
               }

               if(found)
               {
                  //--- template
                  chat.m_state=32;
                  string str="[[\""+EMOJI_BACK+"\",\""+EMOJI_TOP+"\"]";
                  str+=",[\"None\"]";
                  for(int k=0; k<m_templates.Total(); k++)
                     str+=",[\""+m_templates.At(k)+"\"]";
                  str+="]";

                bot.  SendMessage(chat.m_id,(m_lang==LANGUAGE_EN)?"Select a template":"Выберите шаблон",ReplyKeyboardMarkup(str,false,false));
               }
               else
               {
                  bot.SendMessage(chat.m_id,(m_lang==LANGUAGE_EN)?"Invalid timeframe":"Неправильно задан период графика",ReplyKeyboardMarkup(KEYB_PERIODS,false,false));
               }
               continue;
            
            //---
            if(chat.m_state==32)
            {m_template=m_templates[TimeFrame];
               m_template=text;
               if(m_template=="None")
                  m_template=NULL;
               int result=bot.SendScreenShot((string)(msgs.chat_id),m_symbol,_periods[TimeFrame],m_template);
               if(result!=0)
                  Print(GetErrorDescription(result,InpLanguage));
            }//end last if
            
            msg = StringConcatenate(msg,"My commands list:",NL);
            msg = StringConcatenate(msg,"/ordertotal-return count of orders",NL);
            msg = StringConcatenate(msg,"/ordertrade-return ALL opened orders",NL);
            msg = StringConcatenate(msg,"/orderticket <ticket>-return an order or a chain of history by ticket",NL);
            msg = StringConcatenate(msg,"/historytotal-return count of history",NL);
            msg = StringConcatenate(msg,"/historyticket <ticket>-return a history or chain of history by ticket",NL);
            msg = StringConcatenate(msg,"/account-return account info",NL);
            msg = StringConcatenate(msg,"/help-get help");
           
         
               chat.m_state=0;
               msg="The bot works with your trading account:\n";
               msg+="/AccountInfo - get account information\n";
               msg+="/Quotes - get quotes\n";
               msg+="/Charts - get chart images\n";
               msg+="/Trade";
            
            if( text=="/help" ) {
               SendMessage( chat.m_id, msg );
            }
       
         
      }
            
      
            //---
            if(text==EMOJI_TOP)
            {
               chat.m_state=0;
               msg=(m_lang==LANGUAGE_EN)?"Choose a menu item":"Выберите пункт меню";
               SendMessage(chat.m_id,msg,ReplyKeyboardMarkup(KEYB_MAIN,false,false));
               continue;
            }

            //---
            if(text==EMOJI_BACK)
            {
               if(chat.m_state==31)
               {
                  chat.m_state=3;
                   msg=(m_lang==LANGUAGE_EN)?"Enter a symbol name like 'EURUSD'":"Введите название инструмента, например 'EURUSD'";
                  SendMessage(chat.m_id,msg,ReplyKeyboardMarkup(KEYB_SYMBOLS,false,false));
               }
               else if(chat.m_state==32)
               {
                  chat.m_state=31;
                  msg=(m_lang==LANGUAGE_EN)?"Select a timeframe like 'H1'":"Введите период графика, например 'H1'";
                  SendMessage(chat.m_id,msg,ReplyKeyboardMarkup(KEYB_PERIODS,false,false));
               }
               else
               {
                  chat.m_state=0;
                  msg=(m_lang==LANGUAGE_EN)?"Choose a menu item":"Выберите пункт меню";
                  SendMessage(chat.m_id,msg,ReplyKeyboardMarkup(KEYB_MAIN,false,false));
               }
               continue;
            }

            //---
            if(text=="/info" || text=="Account Info" || text=="Информация")
            {
               chat.m_state=1;
               string currency=AccountInfoString(ACCOUNT_CURRENCY);
               string msgSS=StringFormat("%d: %s\n",AccountInfoInteger(ACCOUNT_LOGIN),AccountInfoString(ACCOUNT_SERVER));
               msgSS+=StringFormat("%s: %.2f %s\n",(m_lang==LANGUAGE_EN)?"Balance":"Баланс",AccountInfoDouble(ACCOUNT_BALANCE),currency);
               msgSS+=StringFormat("%s: %.2f %s\n",(m_lang==LANGUAGE_EN)?"Profit":"Прибыль",AccountInfoDouble(ACCOUNT_PROFIT),currency);
               SendMessage(chat.m_id,msg,ReplyKeyboardMarkup(KEYB_MAIN,false,false));
            }

            //---
            if(text=="/quotes" || text=="Quotes" || text=="Котировки")
            {
               chat.m_state=2;
               msg=(m_lang==LANGUAGE_EN)?"Enter a symbol name like 'EURUSD'":"Введите название инструмента, например 'EURUSD'";
               SendMessage(chat.m_id,msg,ReplyKeyboardMarkup(KEYB_SYMBOLS,false,false));
               continue;
            }

            //---
            if(text=="/charts" || text=="Charts" || text=="Графики")
            {
               chat.m_state=3;
               msg=(m_lang==LANGUAGE_EN)?"Enter a symbol name like 'EURUSD'":"Введите название инструмента, например 'EURUSD'";
               SendMessage(chat.m_id,msg,ReplyKeyboardMarkup(KEYB_SYMBOLS,false,false));
               continue;
            }

            //--- Quotes
            if(chat.m_state==2)
            {
               string mask=(m_lang==LANGUAGE_EN)?"Invalid symbol name '%s'":"Инструмент '%s' не найден";
               msg=StringFormat(mask,text);
               StringToUpper(text);
               string symbol=text;
               if(SymbolSelect(symbol,true))
               {
                  double open[1]= {0};

                  m_symbol=symbol;
                  //--- upload history
                  for(int k=0; k<3; k++)
                  {
#ifdef __MQL4__
                     double array[][6];
                     ArrayCopyRates(array,symbol,PERIOD_D1);
#endif

                     Sleep(2000);
                     CopyOpen(symbol,PERIOD_D1,0,1,open);
                     if(open[0]>0.0)
                        break;
                  }

                  int digits=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);
                  double bid=SymbolInfoDouble(symbol,SYMBOL_BID);

                  CopyOpen(symbol,PERIOD_D1,0,1,open);
                  if(open[0]>0.0)
                  {
                     double percent=100*(bid-open[0])/open[0];
                     //--- sign
                     string sign=ShortToString(0x25B2);
                     if(percent<0.0)
                        sign=ShortToString(0x25BC);

                     msg=StringFormat("%s: %s %s (%s%%)",symbol,DoubleToString(bid,digits),sign,DoubleToString(percent,2));
                  }
                  else
                  {
                     msg=(m_lang==LANGUAGE_EN)?"No history for ":"Нет истории для "+symbol;
                  }
               }

               SendMessage(chat.m_id,msg,ReplyKeyboardMarkup(KEYB_SYMBOLS,false,false));
               continue;
            }

            //--- Charts
            if(chat.m_state==3)
            {

               StringToUpper(text);
               string symbol=text;
               if(SymbolSelect(symbol,true))
               {
                  m_symbol=symbol;

                  chat.m_state=31;
                  msg=(m_lang==LANGUAGE_EN)?"Select a timeframe like 'H1'":"Введите период графика, например 'H1'";
                  SendMessage(chat.m_id,msg,ReplyKeyboardMarkup(KEYB_PERIODS,false,false));
               }
               else
               {
                  string mask=(m_lang==LANGUAGE_EN)?"Invalid symbol name '%s'":"Инструмент '%s' не найден";
                  msg=StringFormat(mask,text);
                  SendMessage(chat.m_id,msg,ReplyKeyboardMarkup(KEYB_SYMBOLS,false,false));
               }
               continue;
            }

            //Charts->Periods
            if(chat.m_state==31)
            {
               bool found=false;
               int total=ArraySize(_periods);
               for(int k=0; k<total; k++)
               {
                  string str_tf=StringSubstr(EnumToString(_periods[k]),7);
                  if(StringCompare(str_tf,text,false)==0)
                  {
                     m_period=_periods[k];
                     found=true;
                     break;
                  }
               }

               if(found)
               {
                  //--- template
                  chat.m_state=32;
                  string str="[[\""+EMOJI_BACK+"\",\""+EMOJI_TOP+"\"]";
                  str+=",[\"None\"]";
                  for(int k=0; k<m_templates.Total(); k++)
                     str+=",[\""+m_templates.At(k)+"\"]";
                  str+="]";

                  SendMessage(chat.m_id,(m_lang==LANGUAGE_EN)?"Select a template":"Выберите шаблон",ReplyKeyboardMarkup(str,false,false));
               }
               else
               {
                  SendMessage(chat.m_id,(m_lang==LANGUAGE_EN)?"Invalid timeframe":"Неправильно задан период графика",ReplyKeyboardMarkup(KEYB_PERIODS,false,false));
               }
               continue;
            }
            //---
            if(chat.m_state==32)
            {
               m_template=text;
               if(m_template=="None")
                  m_template=NULL;
               int result=SendScreenShot((string)chat.m_id,m_symbol,m_period,m_template);
               if(result!=0)
                  Print(GetErrorDescription(result,InpLanguage));
            }
         }
      }
   }

     
            
      
   

   //+------------------------------------------------------------------+
   void              ArrayAdd(uchar &dest[],const uchar &src[])
   {
      int src_size=ArraySize(src);
      if(src_size==0)
         return;

      int dest_size=ArraySize(dest);
      ArrayResize(dest,dest_size+src_size,500);
      ArrayCopy(dest,src,dest_size,0,src_size);
   }

   //+------------------------------------------------------------------+
   void              ArrayAdd(char &dest[],const string text)
   {
      int len=StringLen(text);
      if(len>0)
      {
         uchar src[];
         for(int i=0; i<len; i++)
         {
            ushort ch=StringGetCharacter(text,i);

            uchar array[];
            int total=ShortToUtf8(ch,array);

            int size=ArraySize(src);
            ArrayResize(src,size+total);
            ArrayCopy(src,array,size,0,total);
         }
         ArrayAdd(dest,src);
      }
   }

   //+------------------------------------------------------------------+
   int               SaveToFile(const string filename,
                                const char &text[])
   {
      ResetLastError();

      int handle=FileOpen(filename,FILE_BIN|FILE_ANSI|FILE_WRITE);
      if(handle==INVALID_HANDLE)
      {
         return(GetLastError());
      }

      FileWriteArray(handle,text);
      FileClose(handle);

      return(0);
   }

   //+------------------------------------------------------------------+
   string            UrlEncode(const string text)
   {
      string result=NULL;
      int length=StringLen(text);
      for(int i=0; i<length; i++)
      {
         ushort ch=StringGetCharacter(text,i);

         if((ch>=48 && ch<=57) || // 0-9
               (ch>=65 && ch<=90) || // A-Z
               (ch>=97 && ch<=122) || // a-z
               (ch=='!') || (ch=='\'') || (ch=='(') ||
               (ch==')') || (ch=='*') || (ch=='-') ||
               (ch=='.') || (ch=='_') || (ch=='~')
           )
         {
            result+=ShortToString(ch);
         }
         else
         {
            if(ch==' ')
               result+=ShortToString('+');
            else
            {
               uchar array[];
               int total=ShortToUtf8(ch,array);
               for(int k=0; k<total; k++)
                  result+=StringFormat("%%%02X",array[k]);
            }
         }
      }
      return result;
   }

protected:
   CList             m_chats;

private:
   string            m_token;
   string            m_name;
   long              m_update_id;
   CArrayString      m_users_filter;
   bool              m_first_remove;

   //+------------------------------------------------------------------+
   int               PostRequest(string &out,
                                 const string url,
                                 const string params,
                                 const int timeout=5000)
   {
      char data[];
      int data_size=StringLen(params);
      StringToCharArray(params,data,0,data_size);

      uchar result[];
      string result_headers;

      //--- application/x-www-form-urlencoded
      int res=WebRequest("POST",url,NULL,NULL,timeout,data,data_size,result,result_headers);
      if(res==200)//OK
      {
         //--- delete BOM
         int start_index=0;
         int size=ArraySize(result);
         for(int i=0; i<fmin(size,8); i++)
         {
            if(result[i]==0xef || result[i]==0xbb || result[i]==0xbf)
               start_index=i+1;
            else
               break;
         }
         //---
         out=CharArrayToString(result,start_index,WHOLE_ARRAY,CP_UTF8);
         return(0);
      }
      else
      {
         if(res==-1)
         {
            return(_LastError);
         }
         else
         {
            //--- HTTP errors
            if(res>=100 && res<=511)
            {
               out=CharArrayToString(result,0,WHOLE_ARRAY,CP_UTF8);
               Print(out);
               return(ERR_HTTP_ERROR_FIRST+res);
            }
            return(res);
         }
      }

      return(0);
   }

   //+------------------------------------------------------------------+
   int               ShortToUtf8(const ushort _ch,uchar &out[])
   {
      //---
      if(_ch<0x80)
      {
         ArrayResize(out,1);
         out[0]=(uchar)_ch;
         return(1);
      }
      //---
      if(_ch<0x800)
      {
         ArrayResize(out,2);
         out[0] = (uchar)((_ch >> 6)|0xC0);
         out[1] = (uchar)((_ch & 0x3F)|0x80);
         return(2);
      }
      //---
      if(_ch<0xFFFF)
      {
         if(_ch>=0xD800 && _ch<=0xDFFF)//Ill-formed
         {
            ArrayResize(out,1);
            out[0]=' ';
            return(1);
         }
         else if(_ch>=0xE000 && _ch<=0xF8FF)//Emoji
         {
            int ch=0x10000|_ch;
            ArrayResize(out,4);
            out[0] = (uchar)(0xF0 | (ch >> 18));
            out[1] = (uchar)(0x80 | ((ch >> 12) & 0x3F));
            out[2] = (uchar)(0x80 | ((ch >> 6) & 0x3F));
            out[3] = (uchar)(0x80 | ((ch & 0x3F)));
            return(4);
         }
         else
         {
            ArrayResize(out,3);
            out[0] = (uchar)((_ch>>12)|0xE0);
            out[1] = (uchar)(((_ch>>6)&0x3F)|0x80);
            out[2] = (uchar)((_ch&0x3F)|0x80);
            return(3);
         }
      }
      ArrayResize(out,3);
      out[0] = 0xEF;
      out[1] = 0xBF;
      out[2] = 0xBD;
      return(3);
   }

   //+-------------------Post and Get Request-----------------------------------------------+
   string            StringDecode(string text)
   {
      //--- replace \n
      StringReplace(text,"\n",ShortToString(0x0A));

      //--- replace \u0000
      int haut=0;
      int pos=StringFind(text,"\\u");
      while(pos!=-1)
      {
         string strcode=StringSubstr(text,pos,6);
         string strhex=StringSubstr(text,pos+2,4);

         StringToUpper(strhex);

         int total=StringLen(strhex);
         int result=0;
         for(int i=0,k=total-1; i<total; i++,k--)
         {
            int coef=(int)pow(2,4*k);
            ushort ch=StringGetCharacter(strhex,i);
            if(ch>='0' && ch<='9')
               result+=(ch-'0')*coef;
            if(ch>='A' && ch<='F')
               result+=(ch-'A'+10)*coef;
         }

         if(haut!=0)
         {
            if(result>=0xDC00 && result<=0xDFFF)
            {
               int dec=((haut-0xD800)<<10)+(result-0xDC00);//+0x10000;
               StringReplaceEx(text,pos,6,ShortToString((ushort)dec));
               haut=0;
            }
            else
            {
               //--- error: Second byte out of range
               haut=0;
            }
         }
         else
         {
            if(result>=0xD800 && result<=0xDBFF)
            {
               haut=result;
               StringReplaceEx(text,pos,6,"");
            }
            else
            {
               StringReplaceEx(text,pos,6,ShortToString((ushort)result));
            }
         }

         pos=StringFind(text,"\\u",pos);
      }
      return(text);
   }

   //+------------------------------------------------------------------+
   int               StringReplaceEx(string &string_var,
                                     const int start_pos,
                                     const int length,
                                     const string replacement)
   {
      string temp=(start_pos==0)?"":StringSubstr(string_var,0,start_pos);
      temp+=replacement;
      temp+=StringSubstr(string_var,start_pos+length);
      string_var=temp;
      return(StringLen(replacement));
   }

   //+------------------------------------------------------------------+
   string            BoolToString(const bool _value)
   {
      if(_value)return("true");
      return("false");
   }

protected:
   //+------------------------------------------------------------------+
   string            StringTrim(string text)
   {
#ifdef __MQL4__
      text = StringTrimLeft(text);
      text = StringTrimRight(text);
#endif
#ifdef __MQL5__
      StringTrimLeft(text);
      StringTrimRight(text);
#endif
      return(text);
   }

public:
   //+------------------------------------------------------------------+
   void              TelegamBot()
   {
      m_token=NULL;
      m_name=NULL;
      m_update_id=0;
      m_first_remove=true;
      m_chats.Clear();
      m_users_filter.Clear();
   }

   //+------------------------------------------------------------------+
   int               ChatsTotal()
   {
      return(m_chats.Total());
   }

   //+------------------------------------------------------------------+
   int               Token(const string _token)
   {
      string token=StringTrim(_token);
      if(token=="")
         return(ERR_TOKEN_ISEMPTY);
      //---
      m_token=token;
      return(0);
   }

   //+------------------------------------------------------------------+
   void              UserNameFilter(const string username_list)
   {
      m_users_filter.Clear();

      //--- parsing
      string text=StringTrim(username_list);
      if(text=="")
         return;

      //---
      while(StringReplace(text,"  "," ")>0);
      StringReplace(text,";"," ");
      StringReplace(text,","," ");

      //---
      string array[];
      int amount=StringSplit(text,' ',array);
      for(int i=0; i<amount; i++)
      {
         string username=StringTrim(array[i]);
         if(username!="")
         {
            //--- remove first @
            if(StringGetCharacter(username,0)=='@')
               username=StringSubstr(username,1);

            m_users_filter.Add(username);
         }
      }

   }
   //+------------------------------------------------------------------+
   string            Name()
   {
      return(m_name);
   }





   //+------------------------------------------------------------------+
   int               GetMe()
   {
      if(m_token==NULL)
         return(ERR_TOKEN_ISEMPTY);
      //---
      string out;
      string url=StringFormat("%s/bot%s/getMe",TELEGRAM_BASE_URL,m_token);
      string params="";
      int res=PostRequest(out,url,params,WEB_TIMEOUT);
      if(res==0)
      {
         CJAVal js(NULL,jtUNDEF);
         //---
         bool done=js.Deserialize(out);
         if(!done)
            return(ERR_JSON_PARSING);

         //---
         bool ok=js["ok"].ToBool();
         if(!ok)
            return(ERR_JSON_NOT_OK);

         //---
         if(m_name==NULL)
            m_name=js["result"]["username"].ToStr();
      }
      //---
      return(res);
   }
   
   
   ///#####################################################################
   
   
   
   
   
   
   
   
   
   
   //+------------------------------------------------------------------+
   int               GetUpdates()
   {
      if(m_token==NULL)
         return(ERR_TOKEN_ISEMPTY);

      string out;
      string url=StringFormat("%s/bot%s/getUpdates",TELEGRAM_BASE_URL,m_token);
      string params=StringFormat("offset=%d",m_update_id);
      //---
      int res=PostRequest(out,url,params,WEB_TIMEOUT);
      if(res==0)
      {
         //Print(out);
         //--- parse result
         CJAVal js(NULL,jtUNDEF);
         bool done=js.Deserialize(out);
         if(!done)
            return(ERR_JSON_PARSING);

         bool ok=js["ok"].ToBool();
         if(!ok)
            return(ERR_JSON_NOT_OK);

         

         int total=ArraySize(js["result"].m_e);
         for(int i=0; i<total; i++)
         {
            CJAVal item=js["result"].m_e[i];
            //---
            msgs.update_id=item["update_id"].ToInt();
            //---
            msgs.message_id=item["message"]["message_id"].ToInt();
            msgs.message_date=(datetime)item["message"]["date"].ToInt();
            //---
            msgs.message_text=item["message"]["text"].ToStr();
            msgs.message_text=StringDecode(msgs.message_text);
            //---
            msgs.from_id=item["message"]["from"]["id"].ToInt();

            msgs.from_first_name=item["message"]["from"]["first_name"].ToStr();
            msgs.from_first_name=StringDecode(msgs.from_first_name);

            msgs.from_last_name=item["message"]["from"]["last_name"].ToStr();
            msgs.from_last_name=StringDecode(msgs.from_last_name);

            msgs.from_username=item["message"]["from"]["username"].ToStr();
            msgs.from_username=StringDecode(msgs.from_username);
            //---
            msgs.chat_id=item["message"]["chat"]["id"].ToInt();

            msgs.chat_first_name=item["message"]["chat"]["first_name"].ToStr();
            msgs.chat_first_name=StringDecode(msgs.chat_first_name);

            msgs.chat_last_name=item["message"]["chat"]["last_name"].ToStr();
            msgs.chat_last_name=StringDecode(msgs.chat_last_name);

            msgs.chat_username=item["message"]["chat"]["username"].ToStr();
            msgs.chat_username=StringDecode(msgs.chat_username);

            msgs.chat_type=item["message"]["chat"]["type"].ToStr();

            m_update_id=msgs.update_id+1;

            if(m_first_remove)
               continue;

            //--- filter
            if(m_users_filter.Total()==0 || (m_users_filter.Total()>0 && m_users_filter.SearchLinear(msgs.from_username)>=0))
            {

               //--- find the chat
               int index=-1;
               for(int j=0; j<m_chats.Total(); j++)
               {
                  CCustomChat *chat=m_chats.GetNodeAtIndex(j);
                  if(chat.m_id==msgs.chat_id)
                  {
                     index=j;
                     break;
                  }
               }

               //--- add new one to the chat list
               if(index==-1)
               {
                  m_chats.Add(new CCustomChat);
                  CCustomChat *chat=m_chats.GetLastNode();
                  chat.m_id=msgs.chat_id;
                  chat.m_time=TimeLocal();
                  chat.m_state=0;
                  chat.m_new_one.message_text=msgs.message_text;
                  chat.m_new_one.done=false;
               }
               //--- update chat message
               else
               {
                  CCustomChat *chat=m_chats.GetNodeAtIndex(index);
                  chat.m_time=TimeLocal();
                  chat.m_new_one.message_text=msgs.message_text;
                  chat.m_new_one.done=false;
               }
            }
         }
         m_first_remove=false;
      }
      //---
      return(res);
   }

   //+------------------------------------------------------------------+
   int               SendChatAction(const long _chat_id,
                                    const ENUM_CHAT_ACTION _action)
   {
      if(m_token==NULL)
         return(ERR_TOKEN_ISEMPTY);
      string out;
      string url=StringFormat("%s/bot%s/sendChatAction",TELEGRAM_BASE_URL,m_token);
      string params=StringFormat("chat_id=%lld&action=%s",_chat_id,ChatActionToString(_action));
      int res=PostRequest(out,url,params,WEB_TIMEOUT);
      return(res);
   }

   //+------------------------------------------------------------------+
   int               SendPhoto(const long   _chat_id,
                               const string _photo_id,
                               const string _caption=NULL)
   {
      if(m_token==NULL)
         return(ERR_TOKEN_ISEMPTY);

      string out;
      string url=StringFormat("%s/bot%s/sendPhoto",TELEGRAM_BASE_URL,m_token);
      string params=StringFormat("chat_id=%lld&photo=%s",_chat_id,_photo_id);
      if(_caption!=NULL)
         params+="&caption="+UrlEncode(_caption);

      int res=PostRequest(out,url,params,WEB_TIMEOUT);
      if(res!=0)
      {
         //--- parse result
         CJAVal js(NULL,jtUNDEF);
         bool done=js.Deserialize(out);
         if(!done)
            return(ERR_JSON_PARSING);

         //--- get error description
         bool ok=js["ok"].ToBool();
         long err_code=js["error_code"].ToInt();
         string err_desc=js["description"].ToStr();
      }
      //--- done
      return(res);
   }

   //+------------------------------------------------------------------+
   int               SendPhoto(string &_photo_id,
                               const string _channel_name,
                               const string _local_path,
                               const string _caption=NULL,
                               const bool _common_flag=false,
                               const int _timeout=10000)
   {
      if(m_token==NULL)
         return(ERR_TOKEN_ISEMPTY);

      string name=StringTrim(_channel_name);
      if(StringGetCharacter(name,0)!='@')
         name="@"+name;

      if(m_token==NULL)
         return(ERR_TOKEN_ISEMPTY);

      ResetLastError();
      //--- copy file to memory buffer
      if(!FileIsExist(_local_path,_common_flag))
         return(ERR_FILE_NOT_EXIST);

      //---
      int flags=FILE_READ|FILE_BIN|FILE_SHARE_WRITE|FILE_SHARE_READ;
      if(_common_flag)
         flags|=FILE_COMMON;

      //---
      int file=FileOpen(_local_path,flags);
      if(file<0)
         return(_LastError);

      //---
      int file_size=(int)FileSize(file);
      uchar photo[];
      ArrayResize(photo,file_size);
      FileReadArray(file,photo,0,file_size);
      FileClose(file);

      //--- create boundary: (data -> base64 -> 1024 bytes -> md5)
      uchar base64[];
      uchar key[];
      CryptEncode(CRYPT_BASE64,photo,key,base64);
      //---
      uchar temp[1024]= {0};
      ArrayCopy(temp,base64,0,0,1024);
      //---
      uchar md5[];
      CryptEncode(CRYPT_HASH_MD5,temp,key,md5);
      //---
      string hash=NULL;
      int total=ArraySize(md5);
      for(int i=0; i<total; i++)
         hash+=StringFormat("%02X",md5[i]);
      hash=StringSubstr(hash,0,16);

      //--- WebRequest
      uchar result[];
      string result_headers;

      string url=StringFormat("%s/bot%s/sendPhoto",TELEGRAM_BASE_URL,m_token);

      //--- 1
      uchar data[];

      //--- add chart_id
      ArrayAdd(data,"\r\n");
      ArrayAdd(data,"--"+hash+"\r\n");
      ArrayAdd(data,"Content-Disposition: form-data; name=\"chat_id\"\r\n");
      ArrayAdd(data,"\r\n");
      ArrayAdd(data,name);
      ArrayAdd(data,"\r\n");

      if(StringLen(_caption)>0)
      {
         ArrayAdd(data,"--"+hash+"\r\n");
         ArrayAdd(data,"Content-Disposition: form-data; name=\"caption\"\r\n");
         ArrayAdd(data,"\r\n");
         ArrayAdd(data,_caption);
         ArrayAdd(data,"\r\n");
      }

      ArrayAdd(data,"--"+hash+"\r\n");
      ArrayAdd(data,"Content-Disposition: form-data; name=\"photo\"; filename=\"lampash.gif\"\r\n");
      ArrayAdd(data,"\r\n");
      ArrayAdd(data,photo);
      ArrayAdd(data,"\r\n");
      ArrayAdd(data,"--"+hash+"--\r\n");

      // SaveToFile("debug.txt",data);

      //---
      string headers="Content-Type: multipart/form-data; boundary="+hash+"\r\n";
      int res=WebRequest("POST",url,headers,_timeout,data,result,result_headers);
      if(res==200)//OK
      {
         //--- delete BOM
         int start_index=0;
         int size=ArraySize(result);
         for(int i=0; i<fmin(size,8); i++)
         {
            if(result[i]==0xef || result[i]==0xbb || result[i]==0xbf)
               start_index=i+1;
            else
               break;
         }

         //---
         string out=CharArrayToString(result,start_index,WHOLE_ARRAY,CP_UTF8);

         //--- parse result
         CJAVal js(NULL,jtUNDEF);
         bool done=js.Deserialize(out);
         if(!done)
            return(ERR_JSON_PARSING);

         //--- get error description
         bool ok=js["ok"].ToBool();
         if(!ok)
            return(ERR_JSON_NOT_OK);

         total=ArraySize(js["result"]["photo"].m_e);
         for(int i=0; i<total; i++)
         {
            CJAVal image=js["result"]["photo"].m_e[i];

            long image_size=image["file_size"].ToInt();
            if(image_size<=file_size)
               _photo_id=image["file_id"].ToStr();
         }

         return(0);
      }
      else
      {
         if(res==-1)
         {
            string out=CharArrayToString(result,0,WHOLE_ARRAY,CP_UTF8);
            //Print(out);
            return(_LastError);
         }
         else
         {
            if(res>=100 && res<=511)
            {
               string out=CharArrayToString(result,0,WHOLE_ARRAY,CP_UTF8);
               //Print(out);
               return(ERR_HTTP_ERROR_FIRST+res);
            }
            return(res);
         }
      }
      //---
      return(0);
   }

   //+------------------------------------------------------------------+
   int               SendPhoto(string &_photo_id,
                               const long _chat_id,
                               const string _local_path,
                               const string _caption=NULL,
                               const bool s_common_flag=false,
                               const int _timeout=10000)
   {
      if(m_token==NULL)
         return(ERR_TOKEN_ISEMPTY);

      ResetLastError();
      //--- copy file to memory buffer
      if(!FileIsExist(_local_path,s_common_flag))
         return(ERR_FILE_NOT_EXIST);

      //---
      int flags=FILE_READ|FILE_BIN|FILE_SHARE_WRITE|FILE_SHARE_READ;
      if(s_common_flag)
         flags|=FILE_COMMON;

      //---
      int file=FileOpen(_local_path,flags);
      if(file<0)
         return(_LastError);

      //---
      int file_size=(int)FileSize(file);
      uchar photo[];
      ArrayResize(photo,file_size);
      FileReadArray(file,photo,0,file_size);
      FileClose(file);

      //--- create boundary: (data -> base64 -> 1024 bytes -> md5)
      uchar base64[];
      uchar key[];
      CryptEncode(CRYPT_BASE64,photo,key,base64);
      //---
      uchar temp[1024]= {0};
      ArrayCopy(temp,base64,0,0,1024);
      //---
      uchar md5[];
      CryptEncode(CRYPT_HASH_MD5,temp,key,md5);
      //---
      string hash=NULL;
      int total=ArraySize(md5);
      for(int i=0; i<total; i++)
         hash+=StringFormat("%02X",md5[i]);
      hash=StringSubstr(hash,0,16);

      //--- WebRequest
      uchar result[];
      string result_headers;

      string url=StringFormat("%s/bot%s/sendPhoto",TELEGRAM_BASE_URL,m_token);

      //--- 1
      uchar data[];

      //--- add chart_id
      ArrayAdd(data,"\r\n");
      ArrayAdd(data,"--"+hash+"\r\n");
      ArrayAdd(data,"Content-Disposition: form-data; name=\"chat_id\"\r\n");
      ArrayAdd(data,"\r\n");
      ArrayAdd(data,IntegerToString(_chat_id));
      ArrayAdd(data,"\r\n");

      if(StringLen(_caption)>0)
      {
         ArrayAdd(data,"--"+hash+"\r\n");
         ArrayAdd(data,"Content-Disposition: form-data; name=\"caption\"\r\n");
         ArrayAdd(data,"\r\n");
         ArrayAdd(data,_caption);
         ArrayAdd(data,"\r\n");
      }

      ArrayAdd(data,"--"+hash+"\r\n");
      ArrayAdd(data,"Content-Disposition: form-data; name=\"photo\"; filename=\"lampash.gif\"\r\n");
      ArrayAdd(data,"\r\n");
      ArrayAdd(data,photo);
      ArrayAdd(data,"\r\n");
      ArrayAdd(data,"--"+hash+"--\r\n");

      // SaveToFile("debug.txt",data);

      //---
      string headers="Content-Type: multipart/form-data; boundary="+hash+"\r\n";
      int res=WebRequest("POST",url,headers,_timeout,data,result,result_headers);
      if(res==200)//OK
      {
         //--- delete BOM
         int start_index=0;
         int size=ArraySize(result);
         for(int i=0; i<fmin(size,8); i++)
         {
            if(result[i]==0xef || result[i]==0xbb || result[i]==0xbf)
               start_index=i+1;
            else
               break;
         }

         //---
         string out=CharArrayToString(result,start_index,WHOLE_ARRAY,CP_UTF8);

         //--- parse result
         CJAVal js(NULL,jtUNDEF);
         bool done=js.Deserialize(out);
         if(!done)
            return(ERR_JSON_PARSING);

         //--- get error description
         bool ok=js["ok"].ToBool();
         if(!ok)
            return(ERR_JSON_NOT_OK);

         total=ArraySize(js["result"]["photo"].m_e);
         for(int i=0; i<total; i++)
         {
            CJAVal image=js["result"]["photo"].m_e[i];

            long image_size=image["file_size"].ToInt();
            if(image_size<=file_size)
               _photo_id=image["file_id"].ToStr();
         }

         return(0);
      }
      else
      {
         if(res==-1)
         {
            string out=CharArrayToString(result,0,WHOLE_ARRAY,CP_UTF8);
            //Print(out);
            return(_LastError);
         }
         else
         {
            if(res>=100 && res<=511)
            {
               string out=CharArrayToString(result,0,WHOLE_ARRAY,CP_UTF8);
               //Print(out);
               return(ERR_HTTP_ERROR_FIRST+res);
            }
            return(res);
         }
      }
      //---
      return(0);
   }
   //+------------------------------------------------------------------+
  

   //+------------------------------------------------------------------+
   int               SendMessage(const long    _chat_id,
                                 const string  _text,
                                 const string  _reply_markup=NULL,
                                 const bool    _as_HTML=false,
                                 const bool    _silently=false)
   {
      //--- check token
      if(m_token==NULL)
         return(ERR_TOKEN_ISEMPTY);

      string out;
      string url=StringFormat("%s/bot%s/sendMessage",TELEGRAM_BASE_URL,m_token);

      string params=StringFormat("chat_id=%lld&text=%s",_chat_id,UrlEncode(_text));
      if(_reply_markup!=NULL)
         params+="&reply_markup="+_reply_markup;
      if(_as_HTML)
         params+="&parse_mode=HTML";
      if(_silently)
         params+="&disable_notification=true";

      int res=PostRequest(out,url,params,WEB_TIMEOUT);
      return(res);
   }

   //+------------------------------------------------------------------+
   int               SendMessage(const string _channel_name,
                                 const string _text,
                                 const bool   _as_HTML=false,
                                 const bool   _silently=false)
   {
      //--- check token
      if(m_token==NULL)
         return(ERR_TOKEN_ISEMPTY);

      string name=StringTrim(_channel_name);
      if(StringGetCharacter(name,0)!='@')
         name="@"+name;

      string out;
      string url=StringFormat("%s/bot%s/sendMessage",TELEGRAM_BASE_URL,m_token);
      string params=StringFormat("chat_id=%s&text=%s",name,UrlEncode(_text));
      if(_as_HTML)
         params+="&parse_mode=HTML";
      if(_silently)
         params+="&disable_notification=true";
      //      Print(params);
      int res=PostRequest(out,url,params,WEB_TIMEOUT);
      return(res);
   }

   //+------------------------------------------------------------------+
   string            ReplyKeyboardMarkup(const string keyboard,
                                         const bool resize,
                                         const bool one_time)
   {
      string result=StringFormat("{\"keyboard\": %s, \"one_time_keyboard\": %s, \"resize_keyboard\": %s, \"selective\": false}",UrlEncode(keyboard),BoolToString(resize),BoolToString(one_time));
      return(result);
   }

   //+------------------------------------------------------------------+
   string            ReplyKeyboardHide()
   {
      return("{\"hide_keyboard\": true}");
   }

   //+------------------------------------------------------------------+
   string            ForceReply()
   {
      return("{\"force_reply\": true}");
   }
   
    //+------------------------------------------------------------------+
 
};
//+------------------------------------------------------------------+
   
   TelegramBot bot;



//|-----------------------------------------------------------------------------------------|
//|                                O R D E R S   S T A T U S                                |
//|-----------------------------------------------------------------------------------------|
string BotOrdersTotal(bool noPending=true)
{
   int counter=0;
   int total=OrdersTotal();
//--- Assert optimize function by checking total > 0
   if( total<=0 ) return( strBotInt("Total", counter) );   
//--- Assert optimize function by checking noPending = false
   if( noPending==false ) return( strBotInt("Total", total) );
   
//--- Assert determine count of all trades that are opened
   for(int i=0;i<total;i++) {
      int mySelection2=OrderSelect( i, SELECT_BY_POS, MODE_TRADES );
   //--- Assert OrderType is either BUY or SELL
      if( OrderType() <= 1 ) counter++;
   }
   return( strBotInt( "Total", counter ) );
}

string BotOrdersTrade(bool noPending=true)
{string myType="";
   int counter=0;
      const string strPartial="from #";
   int total=OrdersTotal();
//--- Assert optimize function by checking total > 0
   if( total<=0 ) return( msg );   

//--- Assert determine count of all trades that are opened
   for(int i=0;i<total;i++) { int myselection=OrderSelect( i, SELECT_BY_POS, MODE_TRADES );

   //--- Assert OrderType is either BUY or SELL if noPending=true
      if( noPending==true && OrderType() > 1 ){ 
      if(OrderType()==0){ myType="BUY";} else if(OrderType()==1){ myType="SELL";};continue ;
     } else{ counter++;
                   }
      msg = StringConcatenate(msg, strBotInt( "Ticket",OrderTicket() ));
      msg = StringConcatenate(msg, strBotStr( "Symbol",OrderSymbol() ));
      msg = StringConcatenate(msg, strBotStr( "Type",myType ));
      msg = StringConcatenate(msg, strBotDbl( "Lots",OrderLots(),2 ));
      msg = StringConcatenate(msg, strBotDbl( "OpenPrice",OrderOpenPrice(),5 ));
      msg = StringConcatenate(msg, strBotDbl( "CurPrice",OrderClosePrice(),5 ));
      msg = StringConcatenate(msg, strBotDbl( "StopLoss",OrderStopLoss(),5 ));
      msg = StringConcatenate(msg, strBotDbl( "TakeProfit",OrderTakeProfit(),5 ));
      msg = StringConcatenate(msg, strBotTme( "OpenTime",OrderOpenTime() ));
      msg = StringConcatenate(msg, strBotTme( "CloseTime",OrderCloseTime() ));
      
   //--- Assert Partial Trade has comment="from #<historyTicket>"
      if( StringFind( OrderComment(), strPartial )>=0 )
         msg = StringConcatenate(msg, strBotStr( "PrevTicket", StringSubstr(OrderComment(),StringLen(strPartial)) ));
      else
         msg = StringConcatenate(msg, strBotStr( "PrevTicket", "0" ));
   }
//--- Assert msg isnt empty
   if( msg=="" ) return( msg );   
   
//--- Assert append count of trades
   msg = StringConcatenate(strBotInt( "Count",counter ), msg);
   return( msg );
}

string BotOrdersTicket(int ticket, bool noPending=true)
{



   return( "" );
}

string BotHistoryTicket(int ticket, bool noPending=true)
{
   msg=NL;
   const string strPartial="from #";
   int total=OrdersHistoryTotal();
//--- Assert optimize function by checking total > 0
   if( total<=0 ) return( msg );   

//--- Assert determine history by ticket
   if( OrderSelect( ticket, SELECT_BY_TICKET, MODE_HISTORY )==false ) return( msg );
   
//--- Assert OrderType is either BUY or SELL if noPending=true
   if( noPending==true && OrderType() > 1 ) return( msg );
      
//--- Assert OrderTicket is found
   msg = StringConcatenate(msg, strBotInt( "Ticket",OrderTicket() ));
   msg = StringConcatenate(msg, strBotStr( "Symbol",OrderSymbol() ));
   msg = StringConcatenate(msg, strBotInt( "Type",OrderType() ));
   msg = StringConcatenate(msg, strBotDbl( "Lots",OrderLots(),2 ));
   msg = StringConcatenate(msg, strBotDbl( "OpenPrice",OrderOpenPrice(),5 ));
   msg = StringConcatenate(msg, strBotDbl( "ClosePrice",OrderClosePrice(),5 ));
   msg = StringConcatenate(msg, strBotDbl( "StopLoss",OrderStopLoss(),5 ));
   msg = StringConcatenate(msg, strBotDbl( "TakeProfit",OrderTakeProfit(),5 ));
   msg = StringConcatenate(msg, strBotTme( "OpenTime",OrderOpenTime() ));
   msg = StringConcatenate(msg, strBotTme( "CloseTime",OrderCloseTime() ));
   
//--- Assert Partial Trade has comment="from #<historyTicket>"
   if( StringFind( OrderComment(), strPartial )>=0 )
      msg = StringConcatenate(msg, strBotStr( "PrevTicket", StringSubstr(OrderComment(),StringLen(strPartial)) ));
   else
      msg = StringConcatenate(msg, strBotStr( "PrevTicket", "0" ));

   return( msg );
}

string BotOrdersHistoryTotal(bool noPending=true)
{
   return( strBotInt( "Total :", OrdersHistoryTotal() ) );
}

//|-----------------------------------------------------------------------------------------|
//|                               A C C O U N T   S T A T U S                               |
//|-----------------------------------------------------------------------------------------|
string BotAccount(void)
{
  msg=NL;

       msg="####################ACCOUNT INFOS#####################\n";
               
                       string currency=AccountInfoString(ACCOUNT_CURRENCY);
               msg=StringFormat("%s: %s",AccountInfoInteger(ACCOUNT_LOGIN),AccountInfoString(ACCOUNT_SERVER));
               msg+=StringFormat("%s: %.2f %s\n",AccountInfoDouble(ACCOUNT_BALANCE),currency);
               msg+=StringFormat("%s: %.2f %s\n",AccountInfoDouble(ACCOUNT_PROFIT),currency);
                            //--- show all the information available from the function AccountInfoDo
   msg+=StringFormat("%s: %.2f %s\n","EQUITY $:  ",AccountInfoDouble(ACCOUNT_EQUITY),currency); 
   msg+=StringFormat("%s: %.2f %s\n","MARGIN  $:  ",AccountInfoDouble(ACCOUNT_MARGIN),currency); 
   msg+=StringFormat("%s: %.2f %s\n","MARGIN_FREE $:  ",AccountInfoDouble(ACCOUNT_FREEMARGIN),currency); 
   msg+=StringFormat("%s: %.2f %s\n","MARGIN_LEVEL $:  ",AccountInfoDouble(ACCOUNT_MARGIN_LEVEL),currency); 
   msg+=StringFormat("%s: %.2f %s\n","MARGIN_SO_CALL $: ",AccountInfoDouble(ACCOUNT_MARGIN_SO_CALL),currency); 
   msg+=StringFormat("%s: %.2f %s\n","MARGIN_SO_SO $:",AccountInfoDouble(ACCOUNT_MARGIN_SO_SO),currency); 
      
   return( msg );
}


//|-----------------------------------------------------------------------------------------|
//|                           I N T E R N A L   F U N C T I O N S                           |
//|-----------------------------------------------------------------------------------------|
string strBotInt(string key, int val)
{
   return( StringConcatenate(NL,key,"=",val) );
}
string strBotDbl(string key, double val, int dgt=5)
{
   return( StringConcatenate(NL,key,"=",NormalizeDouble(val,dgt)) );
}
string strBotTme(string key, datetime val)
{
   return( StringConcatenate(NL,key,"=",TimeToString(val)) );
}
string strBotStr(string key, string val)
{
   return( StringConcatenate(NL,key,"=",val) );
}
string strBotBln(string key, bool val)
{
   string valType;
   if( val )   valType="true";
   else        valType="false";
   return( StringConcatenate(NL,key,"=",valType) );
}