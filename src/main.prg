
#include "hdroidgui.ch"

FUNCTION HDroidMain

   LOCAL oActivity, oLayV, oLayH1, oBtn1, oEdit1, oText1

   INIT WINDOW oActivity TITLE "Calculator"
   
      BEGIN LAYOUT oLayV BACKCOLOR "#FFFFFF" SIZE MATCH_PARENT,MATCH_PARENT
   
         BEGIN LAYOUT oLayH1 HORIZONTAL SIZE MATCH_PARENT,WRAP_CONTENT

         EDITBOX oEdit1 HINT "Input an expression" SIZE 0,MATCH_PARENT

         BUTTON oBtn1 TEXT "Ok" TEXTCOLOR 255 SIZE WRAP_CONTENT,WRAP_CONTENT ;
              ON CLICK {||onBtn1(oEdit1,oText1)}

         END LAYOUT oLayH1

         TEXTVIEW oText1 TEXTCOLOR 10485760 BACKCOLOR "#FFFFFF" SIZE MATCH_PARENT,MATCH_PARENT SCROLL
   
      END LAYOUT oLayV

   RETURN oActivity

STATIC Function OnBtn1( oEdit1, oText1 )
   LOCAL s, xRez, bOldError, lRes := .T.

   s := oEdit1:GetText()

   bOldError := ErrorBlock( { |e|break( e ) } )
   BEGIN SEQUENCE
      xRez := &( Trim( s ) )
   RECOVER
      xRez := "Error..."
   END SEQUENCE
   ErrorBlock( bOldError )

   oText1:SetText( Iif( xRez == Nil, "Nil", Iif( Valtype(xRez)=="A", "Array", ;
         Transform( xRez, "@B" ) ) + Chr(10)+Chr(13) + oText1:GetText() ) )

   RETURN "1"

