//+------------------------------------------------------------------+
//|                                                         News.mqh |
//|                         Copyright 2021, Noel Martial Nguemechieu |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Noel Martial Nguemechieu"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <DiscordTelegram\jason.mqh>
#property strict
  input string google_urls = "https://nfs.faireconomy.media/ff_calendar_thisweek.json?version=bb202ad20af9b89d8ef8c6233e0b77a2";
 

class CNews
  {private:
  int offset;//GMT OFFSET (EX:-4 OR 6)

string jamberita ;
bool judulnews ;
    string title;//": "Monetary Base y/y",
    string  country;//": "JPY",
    string  date;//": "2022-04-03T19:50:00-04:00",
    string  impact;//": "Low",

    double forecast;//": "8.0%",
    double  previous;//": "7.6%"
    string sourceUrl;//SOURCE URL
    int minutes;//minutes;
    int hours;//hours;
    int secondes;   //secondes



//--- Alert
bool FirstAlert ;
bool SecondAlert ;
datetime AlertTime ;
//--- Buffers

//--- time
datetime xmlModifed;
int TimeOfDay ;
datetime Midnight ;
string message ;
 



//+------------------------------------------------------------------+
//|                          TimeNewsFunck                                        |
//+------------------------------------------------------------------+
datetime TimeNewsFunck(int nomf)//RETURN CORRECT NEWS TIME FORMAT
  {
   string s = (string)getDate();
   string time = StringConcatenate(StringSubstr(s, 0, 4), ".", StringSubstr(s, 5, 2), ".", StringSubstr(s, 8, 2), " ", StringSubstr(s, 11, 2), ":", StringSubstr(s, 14, 5));
   string hour = StringSubstr(s, 5, 2);
   setHours((int)hour);
   string seconde = StringSubstr(s, 14, 5);
   setSecondes((int)seconde);
   return ((datetime)StringToTime(time) + offset* 3600);
  }

//+------------------------------------------------------------------+
//|                              ReadWEB                                 |
//+------------------------------------------------------------------+
public:
string ReadWEB()
  {
     string params = "[]";
   int timeout = 5000;
   char data[];
   int data_size = StringLen(params);
   uchar result[];
   string result_headers;
   int   start_index = 0;
   string mynewss[][1][1][1];
//--- application/x-www-form-urlencoded
   int res = WebRequest("GET", google_urls, "0", params, 5000, data, 0, result, result_headers);
   string  out;
   out = CharArrayToString(result, 0, WHOLE_ARRAY);
   printf("News output " + out);
   if(res == 200) //OK
     {
      //--- delete BOM
      int size = ArraySize(result);
      //---
      CJAVal  js(NULL, out);
      js.Deserialize(result);
      int total = ArraySize(js[""].m_e);
      ArrayResize(mynewss,total,0);
      printf("json array size" + (string)total);
      int NomNewss = total;
      
      ArrayResize(mynewss, total, 0);
      for(int i = 0; i < total; i++)
        {
         //Getting jason data'
         CJAVal item = js.m_e[i];
         //looping troughout each arrays to get data
         setDate(item["date"].ToStr());
         setTitle(item["title"].ToStr());
         setSourceUrl(google_urls);
         setCountry(item["country"].ToStr());
         setImpact(item["impact"].ToStr());
         setForecast(item["forecast"].ToDbl());
         setPrevious(item["previous"].ToDbl());
         setMinutes((int)(-TimeNewsFunck(i) + TimeCurrent()));
         
         
         mynewss[i][0][0][0]=getDate();
            mynewss[i][0][0][0]=getTitle();
               mynewss[i][0][0][0]=getImpact();
                  mynewss[i][0][0][0]=(string)getForecast();
                     mynewss[i][0][0][0]=(string)getPrevious();
                        mynewss[i][0][0][0]=(string)getMinutes();
         
        }
      for(int i = 0; i < total; i++)
        {
         bool handle = FileOpen("News" + "\\" + "news.csv", FILE_READ|FILE_SHARE_READ| FILE_CSV | FILE_WRITE|FILE_ANSI,";");
         if(!handle)
           {
            printf("Error Can't open file" + "news.csv" + " to store news events! \nIf open please close it while bot is running.");
           }
         else
           {
            message = toString();
            FileSeek(handle, offset, SEEK_END);
            FileWrite(handle, message);
            FileClose(handle);
            printf(toString());
           }
        }
     }
   else
     {
      if(res == -1)
        {
         printf((string)(_LastError));
        }
      else
        {
         //--- HTTP errors
         if(res >= 100 && res <= 511)
           {
            out = CharArrayToString(result, 0, WHOLE_ARRAY, CP_UTF8);
            Print(out);
            
            
            printf((string) GetLastError() + (string)res);
           }
         printf(((string)res));
        }
     }
   printf(out);
   return(out);
  }

//+------------------------------------------------------------------+
//|                            newsUpdate                                    |
//+------------------------------------------------------------------+
public: 
void newsUpdate()//UPDATE NEWS DATA
  {
//--- do not download on saturday
   if(TimeDayOfWeek(Midnight) == 6)
      return;
   else
     {
      Print(" check for updates...");
      Print("Delete old file" + "news.csv");
      FileDelete("news.csv");
      ReadWEB();
      xmlModifed = (datetime)FileGetInteger("news.csv", FILE_MODIFY_DATE, false);
      PrintFormat("Updated successfully! last modified: %s","news.csv");
     }
  }




 string getTitle() {
        return title;
    }

   
    string toString() {
        return  StringFormat( "\n----->>  News  <<----\n"+
        
        
        "Date :%s \n Title:%s\nCountry: %s\nImpact: %s\nForecast %2.4f \nPrevious :%2.4f\nSourceUrl :%s",(string)date,title,country,impact,forecast,previous,sourceUrl)+
        
                
                "\n============================\nMinutes :" +(string) minutes +"\n"+
                ", Hours=" + (string)hours +"\n"+
                ", Secondes :" + (string)secondes +
                "\n"
                ;
    }

   void setTitle(string title1) {
        this.title = title1;
    }

     string getCountry() {
        return country;
    }

     void setCountry(string country1) {
        this.country = country1;
    }

   string getDate() {
        return date;
    }

   void setDate(string date1) {
        this.date = date1;
    }

    string getImpact() {
        return impact;
    }

    void setImpact(string impact1) {
        this.impact = impact1;
    }

    double getForecast() {
        return forecast;
    }

   void setForecast(double forecast1) {
        this.forecast = forecast1;
    }

  double getPrevious() {
        return previous;
    }

 void setPrevious(double previous1) {
        this.previous = previous1;
    }

    string getSourceUrl() {
        return sourceUrl;
    }

     void setSourceUrl(string sourceUrl1) {
        this.sourceUrl = sourceUrl1;
    }

  int getMinutes() {
        return minutes;
    }

    void setMinutes(int minutes1) {
        this.minutes = minutes1;
    }

     int getHours() {
        return hours;
    }

   void setHours(int hours1) {
        this.hours = hours1;
    }

  int getSecondes() {
        return secondes;
    }

    void setSecondes(int secondes1) {
        this.secondes = secondes1;
    }

    public :CNews(string title1, string country1, string date1, string impact1, double forecast1,
                 double previous1, string sourceUrl1, int minutes1, int hours1, int secondes1) {
        this.title = title1;
        this.country = country1;
        this.date = date1;
        this.impact = impact1;
        this.forecast = forecast1;
        this.previous = previous1;
        this.sourceUrl = sourceUrl1;
        this.minutes = minutes1;
        this.hours = hours1;
        this.secondes = secondes1;
    }

                  CNews();
                    ~CNews();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CNews::CNews()
  {
  
  minutes=0;
  hours=0;
  secondes=0;
  title=NULL;
    country= NULL;
    date= NULL;
    impact= NULL;
    forecast= 0;
    previous=0;
    sourceUrl=NULL;
  }
  

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CNews::~CNews()
  {
  }
//+------------------------------------------------------------------+
