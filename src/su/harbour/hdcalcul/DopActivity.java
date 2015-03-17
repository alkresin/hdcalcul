package su.harbour.hdcalcul;

import android.app.Activity;
import android.os.Bundle;
import android.content.Context;
import android.view.View;
import android.view.Menu;
import android.view.MenuItem;
import android.content.Intent;
import su.harbour.hDroidGUI.*;

public class DopActivity extends Activity {

    private View mainView;
    private String sId;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

       Intent intent = getIntent();   
       String sAct = intent.getStringExtra("sact");
       sId = intent.getStringExtra("sid");

       mainView = MainApp.harb.createAct( this, sAct );
       //MainApp.harb.hlog("Dop - onCreate "+sId+sAct);
       setContentView( mainView );
       MainApp.harb.hrbCall( "HD_INITWINDOW",sId );
    }

   @Override
   protected void onResume() {
       super.onResume();

      //MainApp.harb.hlog("Dop - onResume");
      MainApp.harb.setContext( this, mainView );
   }

   @Override
   protected void onDestroy() {
       super.onDestroy();

       //MainApp.harb.hlog("Dop - onDestroy "+sId);
       MainApp.harb.closeAct( sId );
   }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
       MainApp.harb.SetMenu( menu );
       return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
       MainApp.harb.onMenuSel( item.getItemId() );
       return true;
    }

}
