package agent;

import model.Message;

import java.io.*;
import java.net.ServerSocket;
import java.net.Socket;

public class mainAgent extends Thread {
    /**
     *  @param IP agent_ip
     *  @param port agent_port
     */
    private String IP;
    private int port;
    private ServerSocket server = null;
    Object obj = new Object();

    /**
     * @param client_use 当前服务器的性能信息
     * @param isConnected 当前服务器连接情况
     */
    public Message client_use = null;
    public  boolean isConnected = false;


    public mainAgent(String ip,int port){ this.IP=ip; this.port=port;}
    @Override
    public void run(){
        try {
            Socket socket = new Socket(IP,port);//连接agent，启动节点并运行parity
        } catch (IOException e) {
            e.printStackTrace();
        }

        try {
            server = new ServerSocket(8420);
            server.setSoTimeout(20000);
        } catch (IOException e) {
            e.printStackTrace();
        }

        while(true){
            try {
                Socket client = server.accept();


                ObjectInput in = new ObjectInputStream(client.getInputStream());
                isConnected=true;
                client_use = (Message) in.readObject();
                System.out.println("cpu:"+ client_use.getCPU()+"% mem:"+ client_use.getMEM()+"%"+"disk:"+ client_use.getDisk()+" IP:"+ client.getInetAddress().getHostAddress()+" PORT:"+ client.getPort());
                client.close();
            } catch (IOException e) {
                e.printStackTrace();
                System.out.println("客户端断开");
                isConnected=false;
            } catch (ClassNotFoundException e) {
                e.printStackTrace();
            }

        }
    }





}
