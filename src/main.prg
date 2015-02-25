
#include "hbmemvar.ch"
#include "hdroidgui.ch"

FUNCTION HDroidMain

   LOCAL oActivity, oLayV, oLayH1, oBtn1, oBtn2, oBtn3, oEdit1, oText1

   INIT WINDOW oActivity TITLE "Calculator"
   
      BEGIN LAYOUT oLayV BACKCOLOR "#FFFFFF" SIZE MATCH_PARENT,MATCH_PARENT

         EDITBOX oEdit1 HINT "Input an expression" ON KEYDOWN {|n|onKey(n,oEdit1,oText1)}
               
         BEGIN LAYOUT oLayH1 HORIZONTAL SIZE MATCH_PARENT,WRAP_CONTENT

         BUTTON oBtn2 TEXT " < " TEXTCOLOR 255 SIZE WRAP_CONTENT,WRAP_CONTENT
         BUTTON oBtn1 TEXT "Ok" TEXTCOLOR 255 SIZE 0,WRAP_CONTENT ;
              ON CLICK {||onBtn1(oEdit1,oText1)}
         BUTTON oBtn3 TEXT " > " TEXTCOLOR 255 SIZE WRAP_CONTENT,WRAP_CONTENT

         END LAYOUT oLayH1

         TEXTVIEW oText1 TEXTCOLOR 10485760 BACKCOLOR "#FFFFFF" SIZE MATCH_PARENT,MATCH_PARENT SCROLL
   
      END LAYOUT oLayV

   RETURN oActivity

STATIC Function OnBtn1( oEdit1, oText1 )
   LOCAL s, xRez, bOldError, lRes := .T., n, i, cname
   STATIC aVars := Nil

   IF !Empty( aVars )
      FOR i := 1 to Len( aVars )
         __mvPublic( aVars[i,1] )
         __mvPut( aVars[i,1], aVars[i,2] )
      NEXT
      aVars := Nil
   ENDIF

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

   IF ( n := __mvDbgInfo( HB_MV_PRIVATE_LOCAL ) ) > 0
      aVars := {}
      FOR i := 1 to n
         xRez := __mvDbgInfo( HB_MV_PRIVATE_LOCAL, i, @cname )
         Aadd( aVars, { cname, xRez } )
      NEXT
   ENDIF

   RETURN "1"

STATIC Function OnKey( nKey, oEdit1, oText1 )

   IF nKey == 66     
      RETURN OnBtn1( oEdit1, oText1 )
   ENDIF

   RETURN "0"
