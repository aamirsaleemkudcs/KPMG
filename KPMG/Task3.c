#include <stdio.h>
#include <string.h>

char * function(char str1[],char str2[]);

int main () {
   char str1[50],str2[50],* value;
   
   printf("Enter a string1 : ");
   gets(str1);
      
   printf("Enter a string2 : ");
   gets(str2);
  
   value=function(str1,str2);
   printf("\n \n Valur = %c", value);
   return 0;
}



   char * function(char str1[],char str2[])
   {
     
     printf("\nString 1 %s",str1);
     printf("\nString 2 %s",str2);
    

     char str3[50],str4[50]; 
     int x=0,y=0,value=0;
    for(int i=0;i<=strlen(str1);i++)
   {
     if(str1[i]>=97 && str1[i]<=122)
     {
       str3[x]=str1[i];
       //printf("\n %c",str2[x]);
       x++;
     }
   }
    for(int i=0;i<=strlen(str2);i++)
   {
     if(str2[i]>=97 && str2[i]<=122)
     {
       str4[y]=str2[i];
       //printf("\n %c",str2[x]);
       y++;
     }
   }
    
      printf("\nString 3 %s",str3);
      printf("\nString 4 %s",str4);

    for(int i=0;i<strlen(str3);i++)
  {
    if(str4[i]!=str3[i])
    {
      // do nothing
    }
  }

  value = strlen(str3)-1;
  //printf(" \n The Value is %c", str2[value]);
  return str3[value];
   }
