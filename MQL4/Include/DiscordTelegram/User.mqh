#define PRODMAXLENGTH 255
#include <>
struct ea_user 
  {
   ea_user() {expired = -1;}
   datetime expired;                //License expiration (-1 - unlimited)
   int      namelength;             //Product name length
   char    uname[PRODMAXLENGTH];    //Product name
   void SetEAname(string name) 
     {
      namelength = StringToCharArray(name, uname);
     }
   string GetEAname() 
     {
      return CharArrayToString(uname, 0, namelength);
     }
   bool IsExpired() 
     {
      if (expired == -1) 
         return false; // NOT expired
      return expired <= TimeLocal();
     }
  };//struct ea_user
#define COUNTACC 5

struct user_lic {
   user_lic() {
      uid       = -1;
      log_count =  0;
      ea_count  =  0;
      expired   = -1;
      ArrayFill(logins, 0, COUNTACC, 0);
   }
   long uid;                       //User ID
   datetime expired;               //End of user service (-1 - unlimited)
   int  log_count;                 //The number of the user's accounts
   long logins[COUNTACC];          //User's accounts
   int  ea_count;                  //The number of licensed products
   bool AddLogin(long lg){
      if (log_count >= COUNTACC) return false;
      logins[log_count++] = lg;
      return true;
   }
   long GetLogin(int num) {
      if (num >= log_count) return -1;
      return logins[num];
   }
   bool IsExpired() {
      if (expired == -1) return false; // NOT expired
      return expired <= TimeLocal();
   }   
};//struct user_lic

class CLic {

public:

   static int iSizeEauser;
   static int iSizeUserlic;
   
   CLic() {}
  ~CLic() {}
   
   CList list;
   void ArrayInsert(string dest,string tmp, string,c){
   lis
   
   
   }
   int SetUser(const user_lic& header){
      Reset();
      if (!StructToCharArray(header, dest) ) return 0;
      return ArraySize(dest);
   }//int SetUser(user_lic& header)

   int AddEA(const ea_user& ea) {
      int c = ArraySize(dest);
      if (c == 0) return 0;
      uchar tmp[];
      if (!StructToCharArray(ea, tmp) ) return 0;
      ArrayInsert(dest, tmp, c);
      return ArraySize(dest);
   }//int AddEA(ea_user& ea)
   
   bool GetUser(user_lic& header) const {
      if (ArraySize(dest) < iSizeUserlic) return false;
      return CharArrayToStruct(header, dest);
   }//bool GetUser(user_lic& header)
   
   //num - 0 based
   bool GetEA(int num, ea_user& ea) const {
      int index = iSizeUserlic + num * iSizeEauser;
      if (ArraySize(dest) < index + iSizeEauser) return false;
      return CharArrayToStruct(ea, dest, index);
   }//bool GetEA(int num, ea_user& ea)
   
   int Encode(ENUM_CRYPT_METHOD method, string key, uchar&  buffer[]) const {
      if (ArraySize(dest) < iSizeUserlic) return 0;
      if(!IsKeyCorrect(method, key) ) return 0;      
      uchar k[];
      StringToCharArray(key, k);
      return CryptEncode(method, dest, k, buffer); 
   }
   
   int Decode(ENUM_CRYPT_METHOD method, string key, uchar&  buffer[]) {
      Reset();
      if(!IsKeyCorrect(method, key) ) return 0;
      uchar k[];
      StringToCharArray(key, k);
      return CryptDecode(method, buffer, k, dest); 
   }   

protected:
   void Reset() {ArrayResize(dest, 0);}
   
   bool IsKeyCorrect(ENUM_CRYPT_METHOD method, string key) const {
      int len = StringLen(key);
      switch (method) {
         case CRYPT_AES128:
            if (len == 16) return true;
            break;
         case CRYPT_AES256:
            if (len == 32) return true;
            break;
         case CRYPT_DES:
            if (len == 7) return true;
            break;
      }
#ifdef __DEBUG_USERMQH__
   Print("Key length is incorrect: ",len);
#endif       
      return false;
   }//bool IsKeyCorrect(ENUM_CRYPT_METHOD method, string key)
   
private:
   uchar dest[];
};//class CLic

   static int CLic::iSizeEauser  = sizeof(ea_user);
   static int CLic::iSizeUserlic = sizeof(user_lic);
   
   bool CreateLic(ENUM_CRYPT_METHOD method, string key, CLic& li, string licname) {
   uchar cd[];
   if (li.Encode(method, key, cd) == 0) return false;
   int h = FileOpen(licname, FILE_WRITE | FILE_BIN);
   if (h == INVALID_HANDLE) {
#ifdef __DEBUG_USERMQH__
      Print("File create failed: ",licname);
#endif    
      return false;
   }
   FileWriteArray(h, cd);
   FileClose(h);  
#ifdef __DEBUG_USERMQH__    
   li.SaveArray();
#endif    
   return true;
}// bool CreateLic(ENUM_CRYPT_METHOD method, string key, const CLic& li, string licname)


bool ReadLic(ENUM_CRYPT_METHOD method, string key, CLic& li, string licname) {
   int h = FileOpen(licname, FILE_READ | FILE_BIN);
   if (h == INVALID_HANDLE) {
#ifdef __DEBUG_USERMQH__
      Print("File open failed: ",licname);
#endif    
      return false;
   }
   uchar cd[];
   FileReadArray(h,cd);
   if (ArraySize(cd) < CLic::iSizeUserlic) {
#ifdef __DEBUG_USERMQH__
      Print("File too small: ",licname);
#endif    
      return false;
   }
   li.Decode(method, key, cd);
   FileClose(h);
   return true;
}// bool ReadLic(ENUM_CRYPT_METHOD method, string key, CLic& li, string licname)
