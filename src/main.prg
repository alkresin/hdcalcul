
#include "hbmemvar.ch"
#include "hdroidgui.ch"

#define HISTORY_SIZE_MAX   32

FUNCTION HDroidMain

   LOCAL oActivity, oLayV, oLayH1, oBtn1, oBtn2, oBtn3, oEdit1, oText1
   PUBLIC aHistory := Array( HISTORY_SIZE_MAX ), nHistLen := 0, nHistCurr := 1

   INIT WINDOW oActivity TITLE "Calculator"
   
      BEGIN LAYOUT oLayV BACKCOLOR "#FFFFFF" SIZE MATCH_PARENT,MATCH_PARENT

         EDITBOX oEdit1 HINT "Input an expression" ON KEYDOWN {|n|onKey(n,oEdit1,oText1)}
               
         BEGIN LAYOUT oLayH1 HORIZONTAL SIZE MATCH_PARENT,WRAP_CONTENT

         BUTTON oBtn2 TEXT " < " TEXTCOLOR 255 SIZE WRAP_CONTENT,WRAP_CONTENT ;
               ON CLICK {||onBtnHist(.T.,oEdit1)}
         BUTTON oBtn1 TEXT "Ok" TEXTCOLOR 255 SIZE 0,WRAP_CONTENT ;
               ON CLICK {||onBtnCalc(oEdit1,oText1)}
         BUTTON oBtn3 TEXT " > " TEXTCOLOR 255 SIZE WRAP_CONTENT,WRAP_CONTENT ;
               ON CLICK {||onBtnHist(.F.,oEdit1)}

         END LAYOUT oLayH1

         TEXTVIEW oText1 TEXTCOLOR 10485760 BACKCOLOR "#FFFFFF" SIZE MATCH_PARENT,MATCH_PARENT SCROLL
   
      END LAYOUT oLayV

   RETURN oActivity

STATIC Function OnBtnHist( lBack, oEdit1 )

   IF lBack
      IF nHistCurr >= 2
         oEdit1:SetText( aHistory[--nHistCurr] )
      ENDIF
   ELSE
      IF nHistCurr < nHistLen
         oEdit1:SetText( aHistory[++nHistCurr] )
      ELSE
         nHistCurr := nHistLen + 1
         oEdit1:SetText( "" )
      ENDIF
   ENDIF

   RETURN "1"

STATIC Function OnBtnCalc( oEdit1, oText1 )
   LOCAL s, xRez, bOldError, lRes := .T., n, i, cname, cType
   STATIC aVars := Nil

   IF !Empty( aVars )
      FOR i := 1 to Len( aVars )
         __mvPublic( aVars[i,1] )
         __mvPut( aVars[i,1], aVars[i,2] )
      NEXT
      aVars := Nil
   ENDIF

   s := Alltrim( oEdit1:GetText() )
   IF Empty( s )
      RETURN "0"
   ENDIF

   bOldError := ErrorBlock( { |e|break( e ) } )
   BEGIN SEQUENCE
      xRez := &s
   RECOVER
      xRez := "Error..."
      lRes := .F.
   END SEQUENCE
   ErrorBlock( bOldError )

   oText1:SetText( Iif( xRez == Nil, "Nil", Iif( cType := Valtype(xRez)=="A", "Array", ;
         Iif( cType == "O", "Object", ;
         Transform( xRez, "@B" ) ) + Chr(10)+Chr(13) + oText1:GetText() ) ) )

   IF lRes
      IF nHistLen < HISTORY_SIZE_MAX
         aHistory[++nHistLen] := s
      ELSE
         Adel( aHistory, 1 )
         aHistory[nHistLen] := s
      ENDIF
      nHistCurr := nHistLen + 1
      IF ( n := __mvDbgInfo( HB_MV_PRIVATE_LOCAL ) ) > 0
         aVars := {}
         FOR i := 1 to n
            xRez := __mvDbgInfo( HB_MV_PRIVATE_LOCAL, i, @cname )
            Aadd( aVars, { cname, xRez } )
         NEXT
      ENDIF
   ENDIF

   RETURN "1"

STATIC Function OnKey( nKey, oEdit1, oText1 )

   IF nKey == 66     
      RETURN OnBtnCalc( oEdit1, oText1 )
   ENDIF

   RETURN "0"
