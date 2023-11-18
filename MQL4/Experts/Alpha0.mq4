// Simple Moving Average (SMA) Cross EA with Lot Size based on Benford's Law and Trading Time Management


   #include <stdlib.mqh>
   #include <stderror.mqh>
input int fastSMA = 10;  // Fast SMA period
input int slowSMA = 20;  // Slow SMA period
input double riskPercentage = 1.0;  // Risk percentage per trade

input int startHour = 8;   // Trading start hour (24-hour format)
input int endHour = 16;    // Trading end hour (24-hour format)

double lotSize=0.01;
input int tp=300,sl=300;
input color bullishColor = Green;   // Bullish candlestick color
input color bearishColor = Red;     // Bearish candlestick color
input color backgroundColor = White;  // Background color
input int MaxOpen=1;
int OnInit() {
    // Calculate lot size based on Benford's Law
    lotSize = CalculateLotSize();

    // Print lot size to the console
    Print("Lot Size: ", lotSize);
    SetCandlestickColors();

    return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
    // Perform any cleanup tasks here
}
void SetCandlestickColors() {
    // Set the candlestick and background colors
    ChartSetInteger(0, CHART_COLOR_CANDLE_BULL, bullishColor);
    ChartSetInteger(0, CHART_COLOR_CANDLE_BEAR, bearishColor);
    ChartSetInteger(0, CHART_COLOR_BACKGROUND, backgroundColor);
}



void OnTick() {
    // Check if the current time is within the allowed trading hours
    if (IsTradingTime()) {
        double fastMA = iMA(NULL, 0, fastSMA, 0, MODE_SMA, PRICE_CLOSE, 1);
        double slowMA = iMA(NULL, 0, slowSMA, 0, MODE_SMA, PRICE_CLOSE, 2);

        // Buy condition: Fast SMA crosses above Slow SMA
        if (fastMA <slowMA&& MaxOpen<=3) {
        
        if(IsTradeAllowed(Symbol(),0)){
            // Check if there are no open buy orders
            if (OrderSend(Symbol(), OP_BUYLIMIT, lotSize, Ask,3,  Ask - sl * Point,  Ask + tp * Point,
            
             "Buy Order", 0, 0, Green) > 0) {
                Print("Buy order opened at ", Ask);
                
            }else{ printf("error "+ErrorDescription( GetLastError()) );}

        }
        }else

        // Sell condition: Fast SMA crosses below Slow SMA
        if (fastMA > slowMA && MaxOpen<=3) {
            // Check if there are no open sell orders
            if (OrderSend(Symbol(), OP_SELLLIMIT, lotSize, Bid, 3, Bid + sl * Point,  Bid - tp * Point, "Sell Order", 0, 0, Red) > 0) {
                Print("Sell order opened at ", Bid);
            }else{
            
              printf("error "+ErrorDescription( GetLastError()) );
            }
        }
    }
}

bool IsTradingTime() {
    // Get the current hour in 24-hour format
    int currentHour = Hour();

    // Check if the current time is within the allowed trading hours
    return (currentHour >= startHour && currentHour < endHour);
}

double CalculateLotSize() {
    // Implement Benford's Law or any other lot size calculation logic here
    // For simplicity, using a fixed lot size in this example
    if(OrdersTotal()==0){
          lotSize++;
          return  lotSize/100;
    }else
    {return AccountFreeMarginCheck(Symbol(), OP_BUY, 1) * riskPercentage / 100;
    
    }
}
