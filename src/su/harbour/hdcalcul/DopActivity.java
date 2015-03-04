package su.harbour.hdcalcul;

import android.app.Activity;
import android.os.Bundle;
import android.content.Context;
import android.view.View;
import android.view.Menu;
import android.view.MenuItem;
import su.harbour.hDroidGUI.Harbour;

public class DopActivity extends Activity {

    private static View mainView;
    public static String sId;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        mainView = MainApp.harb.createAct( this );
        sId = MainApp.harb.sActId;
        //MainApp.harb.hlog("Dop - onCreate "+sId);
        setContentView( mainView );
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
