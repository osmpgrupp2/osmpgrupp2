
import java.applet.*;
import java.awt.Graphics;
import java.awt.Image;
import java.awt.event.KeyEvent;
import java.awt.event.KeyListener;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;

	

import javax.imageio.ImageIO;

public class GameLoop extends Applet implements Runnable, KeyListener {
		
	public static int x,y;
	public static Image off;
	public static Graphics d;
	public static boolean up,down,left,right;
	public static Image images;
	public static Image ship;

	
	
	
	
	
	public void run() {
	
		x = 100;
		y = 100;
		try {
		    images = ImageIO.read(new File("spaceinvaders.gif"));
		    ship = ImageIO.read(new File("vitt.jpg"));
		} catch (IOException e) {
		}
		while(true){
			if(left == true){
				x = x-10;
			}
			if(right == true){
				x= x+10;
			}
			if(down == true){
				y = y+ 10;
			}
			if(up == true){
				y = y-10;
			}
			repaint();
		try {
			Thread.sleep(10);
		} catch (InterruptedException e) {
			
			e.printStackTrace();
		}
		}
	}

	@Override
	public void keyPressed(KeyEvent e) {
		if(e.getKeyCode() == 37){
			left = true;
		}
		if(e.getKeyCode() == 38){
			up = true;
		}
		if(e.getKeyCode() == 39){
			right = true;
		}
		if(e.getKeyCode() == 40){
			down = true;
		}
		
	}

	@Override
	public void keyReleased(KeyEvent e) {
		if(e.getKeyCode() == 37){
			left = false;
		}
		if(e.getKeyCode() == 38){
			up = false;
		}
		if(e.getKeyCode() == 39){
			right = false;
		}
		if(e.getKeyCode() == 40){
			down = false;
		}
	}

	@Override
	public void keyTyped(KeyEvent arg0) {
		
		
	}

}





