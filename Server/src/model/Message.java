package model;

import java.io.Serializable;

public class Message implements Serializable {

    private static final long serialVersionUID = 6529685098267757690L;
    private String CPU;
    private String MEM;
    private String Disk;


    public Message(String cpu, String mem, String disk) {
        this.CPU = cpu;
        this.MEM = mem;
        this.Disk = disk;
    }

    public String getCPU() {
        return CPU;
    }

    public void setCPU(String CPU) {
        this.CPU = CPU;
    }

    public String getMEM() {
        return MEM;
    }

    public void setMEM(String MEM) {
        this.MEM = MEM;
    }

    public String getDisk() {
        return Disk;
    }

    public void setDisk(String disk) {
        Disk = disk;
    }

}
