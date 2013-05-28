import java.io.*;
import javax.sound.sampled.*;

public class PlaySound implements Runnable{

	public void run(){
	try {
    File yourFile = new File("meteor.wav");
    
    
    AudioInputStream stream;
    AudioFormat format;
    DataLine.Info info;
    Clip clip;

    stream = AudioSystem.getAudioInputStream(yourFile);
    format = stream.getFormat();
    info = new DataLine.Info(Clip.class, format);
    clip = (Clip) AudioSystem.getLine(info);
    clip.open(stream);
    clip.loop(10);
}
catch (Exception e) {
    //whatever
}
}
	/*
	public static void main(String[] args){
		(new Thread(new PlaySound())).start();
	}
	*/
}