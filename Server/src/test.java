
import agent.*;

import java.io.IOException;
import java.util.ArrayList;

public class test {


    public static void main(String[] args) throws InterruptedException, IOException {
        ArrayList<mainAgent> list = new ArrayList<mainAgent>();

        mainAgent ts = new mainAgent("172.23.25.175",8420);
//        mainAgent ts1 = new mainAgent("172.23.24.46",8420);
        ts.start();





    }


}
