
import java.applet.*;
import java.awt.Graphics;
import java.awt.Image;
import java.awt.event.KeyEvent;
import java.awt.event.KeyListener;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.util.Iterator;
import javax.imageio.ImageIO;
import com.ericsson.otp.erlang.*;


public class GameLoop extends Applet implements Runnable, KeyListener {

	private static int gameHeight = 480;
	private static int gameWidth = 854;
	private GameBoard gameBoard = new GameBoard(gameHeight, gameWidth);

	private static Image off;
	private static Graphics d;
	private static boolean up,down,left,right;
	private static Image background;
	private static Image ship;
	private static Image shot;
	private static Image meteor;
	
	OptNode MyNode = new OptNode("hoppsansa", "hojjsa");
	OptMbox MyBox = MyNode.createMbox("boxarn");



	public void run() {
		try {
			background = ImageIO.read(new File("spaceinvaders.gif"));
			ship = ImageIO.read(new File("vitt.jpg"));
			shot = ImageIO.read(new File("green.jpg"));
			meteor = ImageIO.read(new File("pink.jpg"));
		} catch (IOException e) {
		}

		//ta emot pid från erlang mejlbox



		while(true){

			//ta emot meddelande

			if(left == true){
				gameBoard.moveSpaceShip(-10);
			}
			if(right == true){
				gameBoard.moveSpaceShip(10);
			}
			repaint();
			try {
				Thread.sleep(10);
			} catch (InterruptedException e) {

				e.printStackTrace();
			}
		}
	}
	public void init(){
		setSize(gameWidth,gameHeight);
		Thread th = new Thread(this);
		th.start();

		off = createImage(gameWidth,gameHeight);
		d = off.getGraphics();
		addKeyListener(this);
	}

	public void paint(Graphics g){
		d.clearRect(0, 0, gameWidth, gameHeight);
		d.drawImage(background, 0, 0,gameWidth, gameHeight, this);
		d.drawImage(ship, gameBoard.getSpaceShipX(), gameBoard.getSpaceShipY(), 20, 20, this);

		Iterator<GameObject> GameObjectIterator = gameBoard.getMeteorList().iterator();
		GameObject currentGameObject;

		/*Meteors*/
		while(GameObjectIterator.hasNext()){
			currentGameObject = GameObjectIterator.next();
			d.drawImage(meteor, gameBoard.getGameObjectX(currentGameObject), gameBoard.getGameObjectY(currentGameObject), 20, 20, this);
		}

		/*Shots*/
		GameObjectIterator = gameBoard.getShotList().iterator();
		while(GameObjectIterator.hasNext()){
			currentGameObject = GameObjectIterator.next();
			d.drawImage(shot, gameBoard.getGameObjectX(currentGameObject), gameBoard.getGameObjectY(currentGameObject), 20, 20, this);
		}
		g.drawImage(off,0,0,this); 
	}

	public void update(Graphics g){
		paint(g);
	}







	@Override
	public void keyPressed(KeyEvent e) {
		int keyCode = e.getKeyCode();
		switch( keyCode ) { 
		case KeyEvent.VK_LEFT:
			left = true;
			break;
		case KeyEvent.VK_RIGHT :
			right = true;
			break;
		case KeyEvent.VK_SPACE:
			//space
			break;
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
	public void keyTyped(KeyEvent e) {

	}

}





